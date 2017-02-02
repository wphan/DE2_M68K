LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 
 

entity HWScroll is
 Port (
		RowIn  : 			in std_logic_vector(9 Downto 0) ;
		ScrollRegIn :		in std_logic_vector(9 downto 0) ;		

		RowOut : 			out Std_Logic_vector(9 Downto 0)
 );
end ;
 
architecture bhvr of HWScroll is
Begin
	RowOut <= RowIn + ScrollRegIn ;
end ;
