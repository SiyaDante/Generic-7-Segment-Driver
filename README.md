# Generic-7-Segment-Driver
This module is a simple "Refreshing 7-Segments" driver written in VHDL and is fully "Generic".

You can adjust the polarites of both the "Common" pins and "Segment Diodes". So regardless of your hardware design, you won't be needing to do any sort of change to this code (unless you have an external decoder on your board !).

The refresh speed is also included in the Generics section but remind that you need to insert the "g_Clock_Frequency" correctly for it to work properly since all the time calculations are being done based on the "Clock Frequency" of the module.

Also you can control the number of "7-Segment Display"s only by changing the "g_Number_Of_Digits" generic, but note that the width of the ports will change accordingly.

Each 4 digits of "i_BCD_Number" will determine one of the values shown on a "7-Segment Display".

More details about the "Ports" and the "Generics" are commented inside the VHDL file.

Example : I connect the Clock port to a 20 MHz Clock, so I'm gonna have to set the "g_Clock_Frequency" to 20_000_000 (Twenty Million).
          Since i want each "7-Segment Display" to be ON for 1 millisecond on each "Refresh Frame", I will set the
          "g_Refresh_Time_Interval" to 1m since it's concidered to be in milliseconds.
          Lets say i have 2 "7-Segment Display"s on my board representin a "2-Digit" "Hexadecimal" number so I will set the
          "g_Number_Of_Digits" to 2. This makes "i_BCD_Number" port become a "STD_LOGIC_VECTOR(7 downto 0)" which is a "8_Bit Binary"               value, which it's upper 4 bits determine the left digit and the lower 4 bits determine the right digit on the                             "7-Segment Display"s. Also it makes "o_Display" port a STD_LOGIC_VECTOR(1 downto 0) which is a 2-Bit Binary number.
          Each of "o_Display's" bits has to be connected to one the common ports of the "7-Segment Display"s.
          The left-most bit will be the left-most Display's common pin.
          The "o_Segment" port is always a STD_LOGIC_VECTOR(7 downto 0). Each of "o_Segment" bit has to be connected to a certain segment.
          More details on the ports explained inside the code.
          About the "g_Common_Polarity", if each Display activates bu setting it's common pin to '0', then set this Generic to '0', and             '1' otherwise.
          Also if each "Segment Diode" illuminates by setting it's pin to '1', set "g_Segments_Polarity" to '1', and '0' otherwise.
          
                                                        Enjoy !
