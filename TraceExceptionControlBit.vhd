LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 
 

entity TraceExceptionControlBit is
 Port (
  DataIn : in Std_logic ;
  Enable: in Std_logic ;
  Clk : in Std_logic ;
  Reset : in Std_logic ;
  
  Q : out Std_Logic
 );
end ;
 
architecture bhvr of TraceExceptionControlBit is
Begin
 process(DataIn, Enable, Clk, RESET)
 Begin
  if(Reset = '0') then
	Q <= '0' ;
  elsif(rising_edge(Clk)) then
	if(Enable = '1') then
		Q <= DataIn
		 ;
	end if ;
  end if ;
 end process ;
end ;
