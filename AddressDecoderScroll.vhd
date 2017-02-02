LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 
 

entity AddressDecoderScroll is
 Port (
		AddressIn : in Std_logic_vector(31 downto 0) ;
		DataIn : in Std_logic_vector(15 downto 0) ;		-- 16 bit data bus

  		Clk, Reset_L 				: in Std_logic ;		
		AS_L, UDS_L, LDS_L, RW 		: in Std_logic ;
		ScrollValue 				: out std_logic_vector(9 downto 0)  
	);
end ;
 
architecture bhvr of AddressDecoderScroll is
Begin
	process(Clk, Reset_L)
	Begin
		if(Reset_L = '0') then
			ScrollValue <= "0000000000" ;
			
		elsif(rising_edge(Clk)) then
			if(AS_L = '0' and RW = '0' and LDS_L = '0' and UDS_L = '0') then
				if(AddressIn(31 downto 0) = B"1111_1111_0000_0000_0000_0000_0001_0000") then		-- writing to address FF00_0010
					ScrollValue <= DataIn(9 downto 0) ;			-- save scroll value
				end if ;
			end if ;
		end if ;
	end process ;
end ;
