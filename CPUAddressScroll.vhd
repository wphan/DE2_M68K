LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 
 

entity CPUAddressScroll is
 Port (
		AddressIn  		: in std_logic_vector(18 Downto 1) ;		
		ScrollRegValue  : in std_logic_vector(9 downto 0) ;

		AddressOut 		: out Std_Logic_vector(17 Downto 0)
 );
end ;
 
architecture bhvr of CPUAddressScroll is
Begin
	AddressOut(17 downto 9) <= ScrollRegValue(8 downto 0) + AddressIn(18 downto 10) ;
	AddressOut(8 downto 0) <= AddressIn(9 downto 1) ;
end ;
