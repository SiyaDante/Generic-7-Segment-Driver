--         __   __      __  __       _         _ _ 
--         \ \ / /_ _  |  \/  | __ _| |__   __| (_)
--          \ V / _` | | |\/| |/ _` | '_ \ / _` | |
--           | | (_| | | |  | | (_| | | | | (_| | |
--           |_|\__,_| |_|  |_|\__,_|_| |_|\__,_|_|
--

-----------------------------------------------
-- g_Clock_Frequency : Clock Frequency in Hz --
-----------------------------------------------
-------------------------------------------------------
-- g_Number_Of_Digits : Number of 7-Segment Displays --
-------------------------------------------------------
---------------------------------------------------------------------------
-- g_Segments_Polarity : 1 if Segments Turn on when Logic '1' is applied --
--						 0 Otherswise									 --
---------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------
-- g_Common_Polarity : 1 if Each Display Turns on when Logic '1' is applied to it's Common Pin --
--					   0 Otherwise 															   --
-------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
-- g_Refresh_Time_Interval : Time (in milliseconds) of each Display stayig ON when refreshing Displays --
---------------------------------------------------------------------------------------------------------

-------------------------
-- i_CLK : Clock Input --
-------------------------
-------------------------------------------
-- i_RST : Synchronous Active-HIGH Reset --
-------------------------------------------
------------------------------------------------------------------------------------------
-- i_BCD_Number : input BCD Numbers,													--
--				  Length = 4 * g_Number_Of_Digits										--
--				  Each 4 Bits value will be displayed on a respecting 7-Segment Display --
------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
-- o_Segment : Bit 0 : a 																--
--			   Bit 1 : b 																--
--			   Bit 2 : c 																--
--			   Bit 3 : d 																--
--			   Bit 4 : e 																--
--			   Bit 5 : f 																--
--			   Bit 6 : g 																--
--			   Bit 7 : Decimal Point 													--
------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------
-- o_Display : FPGA Pins controlling the common pins of 7-Segment Displays --
-----------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Refreshing_Seven_Segments is
	Generic (
		g_Clock_Frequency : integer := 50_000_000 ;

		g_Number_Of_Digits  : integer := 6 ; -- Number of 7-Segment Displays --
		g_Segments_Polarity : integer := 0 ; -- integer --
		g_Common_Polarity   : integer := 0 ; -- Integer --
		g_Refresh_Time_Interval : integer :=  1 -- in milliseconds --
	);
	Port (
		i_CLK : in STD_LOGIC ;
		i_RST : in STD_LOGIC ;
		i_BCD_Number : in UNSIGNED((4 * g_Number_Of_Digits) - 1 downto 0) ;
		o_Segment : out UNSIGNED(7 downto 0) ;
		o_Display : out UNSIGNED(g_Number_Of_Digits - 1 downto 0)
	);
end Refreshing_Seven_Segments;

architecture Behavioral of Refreshing_Seven_Segments is

	constant c_Clocks_Per_Refresh : integer := (g_Clock_Frequency / 1_000) * g_Refresh_Time_Interval; 
	signal r_Display_Refresh_Counter : integer range 0 to c_Clocks_Per_Refresh - 1 := 0 ;

	signal r_MUX_Select : integer range 0 to g_Number_Of_Digits - 1 := 0 ;

	signal r_o_Display  : UNSIGNED(g_Number_Of_Digits - 1 downto 0) := 
		TO_UNSIGNED(1, g_Number_Of_Digits) xor TO_UNSIGNED(((2 ** g_Number_Of_Digits) - 1) * (1 - g_Common_Polarity), g_Number_Of_Digits) ;
	
	signal s_Muxed_Number : UNSIGNED((4 * 1) - 1 downto 0) := (Others => '0') ;

	signal s_Segment : UNSIGNED(7 downto 0) ;

begin
	
	o_Display <= r_o_Display when i_RST = '0' else
				 (Others => '1') when g_Common_Polarity = 1 else
				 (Others => '0') when g_Common_Polarity = 0 ;

	o_Segment <= s_Segment when g_Segments_Polarity = 0 else
				 not s_Segment ;

	s_Segment <= "11000000" when s_Muxed_Number = X"0" else
				 "11111001" when s_Muxed_Number = X"1" else
				 "10100100" when s_Muxed_Number = X"2" else
				 "10110000" when s_Muxed_Number = X"3" else
				 "10011001" when s_Muxed_Number = X"4" else
				 "10010010" when s_Muxed_Number = X"5" else
				 "10000010" when s_Muxed_Number = X"6" else
				 "11111000" when s_Muxed_Number = X"7" else
				 "10000000" when s_Muxed_Number = X"8" else
				 "10010000" when s_Muxed_Number = X"9" else
				 "10001000" when s_Muxed_Number = X"a" else
				 "10000011" when s_Muxed_Number = X"b" else
				 "11000110" when s_Muxed_Number = X"c" else
				 "10100001" when s_Muxed_Number = X"d" else
				 "10000110" when s_Muxed_Number = X"e" else
				 "10001110" when s_Muxed_Number = X"f" else
				 (Others => '0') ;

	s_Muxed_Number <= i_BCD_Number((4 * (r_MUX_Select + 1)) - 1 downto (4 * r_MUX_Select)) ;

	Process(i_CLK) is
	begin
		if rising_edge(i_CLK) then
			if i_RST = '1' then
				r_o_Display <= TO_UNSIGNED(1, g_Number_Of_Digits) xor TO_UNSIGNED(((2 ** g_Number_Of_Digits) - 1) * (1 - g_Common_Polarity), g_Number_Of_Digits) ;
				r_Display_Refresh_Counter <= 0 ;
				r_MUX_Select <= 0 ;
			else
				if r_Display_Refresh_Counter < c_Clocks_Per_Refresh - 1 then
					r_Display_Refresh_Counter <= r_Display_Refresh_Counter + 1 ;
				else
					r_Display_Refresh_Counter <= 0 ;

					r_o_Display <= r_o_Display(g_Number_Of_Digits - 2 downto 0) & r_o_Display(g_Number_Of_Digits - 1) ;

					if r_MUX_Select < g_Number_Of_Digits - 1 then
						r_MUX_Select <= r_MUX_Select + 1 ;
					else
						r_MUX_Select <= 0 ;
					end if ;
				end if ;
			end if ;
		end if ;
	end Process ;

end Behavioral;

--  __                             
-- (_ o   _.   _. _|_   /\  _|o|_  
-- __)|\/(_|\/(_|_>| | /--\(_|||_) 
--     /                           
--                      _  
-- |\/|o _ ._ _  |  /\ |_) 
-- |  ||(_ | (_) |_/--\|_) 
-- 