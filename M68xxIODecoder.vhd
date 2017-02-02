LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

entity M68xxIODecoder is
	Port (
		Address : in Std_logic_vector(31 downto 0) ;
		IOSelect : in Std_logic ;
		UDS: in Std_Logic ;
		
		ACIA1_Port_Enable : out std_logic;
		ACIA1_Baud_Enable : out std_logic 
	);
end ;


architecture bhvr of M68xxIODecoder is
Begin
	process(Address, IOSelect, UDS)
	Begin
		
		ACIA1_Port_Enable <= '0' ;
		ACIA1_Baud_Enable <= '0' ;

	
-- decoder for the 6850 chip - 2 registers at locations 0x00400040 and 0x00400042 so that they occupy same half of data bus on D15-D8 and UDS = 0
-- decoder for the Baud Rate generator at 0x00400044 on D15-D8 and UDS = 0

		if(IOSelect = '1') then
			if((Address(31 downto 4) = X"0040004") and UDS = '0') then	
			    if((Address(3 downto 0) = X"0") OR (Address(3 downto 0) = X"2")) then
					ACIA1_Port_Enable <= '1' ;
				end if ;
				
				if(Address(3 downto 0) = X"4") then
					ACIA1_Baud_Enable <= '1' ;
				end if ;
			end if ;			
		end if ;
	end process;
END ;