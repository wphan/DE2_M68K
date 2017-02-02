LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

entity HexTo7SegmentDisplay is
	Port (
				Input1 : in std_logic_vector(7 downto 0);
				
				Display1 : out std_logic_vector(0 to 6) ;
				Display2 : out std_logic_vector(0 to 6) 
	 );

end ;


architecture bhvr of HexTo7SegmentDisplay is
Begin
	process(Input1)
	Begin
		if(Input1(7 downto 4) = X"0") then 	    Display1 <= b"0000001";
		elsif(Input1(7 downto 4) = X"1") then 	Display1 <= b"1001111";
		elsif(Input1(7 downto 4) = X"2") then 	Display1 <= b"0010010";
		elsif(Input1(7 downto 4) = X"3") then 	Display1 <= b"0000110";
		elsif(Input1(7 downto 4) = X"4") then 	Display1 <= b"1001100";
		elsif(Input1(7 downto 4) = X"5") then 	Display1 <= b"0100100";
		elsif(Input1(7 downto 4) = X"6") then 	Display1 <= b"0100000";
		elsif(Input1(7 downto 4) = X"7") then 	Display1 <= b"0001111";
		elsif(Input1(7 downto 4) = X"8") then 	Display1 <= b"0000000";
		elsif(Input1(7 downto 4) = X"9") then 	Display1 <= b"0000100";
		elsif(Input1(7 downto 4) = X"A") then 	Display1 <= b"0001000";
		elsif(Input1(7 downto 4) = X"B") then 	Display1 <= b"1100000";
		elsif(Input1(7 downto 4) = X"C") then 	Display1 <= b"0110001";
		elsif(Input1(7 downto 4) = X"D") then 	Display1 <= b"1000010";
		elsif(Input1(7 downto 4) = X"E") then 	Display1 <= b"0110000";
		else									Display1 <= b"0111000";
		end if;
	End Process;

	process(Input1)
	Begin
		if(Input1(3 downto 0) = X"0") then 	    Display2 <= b"0000001";
		elsif(Input1(3 downto 0) = X"1") then 	Display2 <= b"1001111";
		elsif(Input1(3 downto 0) = X"2") then 	Display2 <= b"0010010";
		elsif(Input1(3 downto 0) = X"3") then 	Display2 <= b"0000110";
		elsif(Input1(3 downto 0) = X"4") then 	Display2 <= b"1001100";
		elsif(Input1(3 downto 0) = X"5") then 	Display2 <= b"0100100";
		elsif(Input1(3 downto 0) = X"6") then 	Display2 <= b"0100000";
		elsif(Input1(3 downto 0) = X"7") then 	Display2 <= b"0001111";
		elsif(Input1(3 downto 0) = X"8") then 	Display2 <= b"0000000";
		elsif(Input1(3 downto 0) = X"9") then 	Display2 <= b"0000100";
		elsif(Input1(3 downto 0) = X"A") then 	Display2 <= b"0001000";
		elsif(Input1(3 downto 0) = X"B") then 	Display2 <= b"1100000";
		elsif(Input1(3 downto 0) = X"C") then 	Display2 <= b"0110001";
		elsif(Input1(3 downto 0) = X"D") then 	Display2 <= b"1000010";
		elsif(Input1(3 downto 0) = X"E") then 	Display2 <= b"0110000";
		else									Display2 <= b"0111000";
		end if ;
	End Process;
End;