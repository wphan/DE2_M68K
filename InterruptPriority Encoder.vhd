LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

entity InterruptPriorityEncoder is
	Port (
		IRQ7_L : in Std_logic ;
		IRQ6_L : in Std_logic ;
		IRQ5_L : in Std_logic ;
		IRQ4_L : in Std_logic ;
		IRQ3_L : in Std_logic ;
		IRQ2_L : in Std_logic ;
		IRQ1_L : in Std_logic ;
		
		IPL : out Std_logic_Vector(2 downto 0)
	);
end ;


architecture bhvr of InterruptPriorityEncoder is
Begin
	process(IRQ7_L, IRQ6_L, IRQ5_L, IRQ4_L, IRQ3_L, IRQ2_L, IRQ1_L)
	begin
	
	IPL <= "111" ; -- default is no interrupt (note inverted outputs)
	
	if(IRQ7_L = '0') then
		IPL <= "000";		-- inverted outputs means 000 is level 7 interrupt
	elsif(IRQ6_L = '0') then
		IPL <= "001";		-- inverted outputs means 001 is level 6 interrupt
	elsif(IRQ5_L = '0') then
		IPL <= "010";		-- inverted outputs means 010 is level 5 interrupt
	elsif(IRQ4_L = '0') then
		IPL <= "011";		-- inverted outputs means 011 is level 4 interrupt
	elsif(IRQ3_L = '0') then
		IPL <= "100";		-- inverted outputs means 100 is level 3 interrupt
	elsif(IRQ2_L = '0') then
		IPL <= "101";		-- inverted outputs means 101 is level 2 interrupt
	elsif(IRQ1_L = '0') then
		IPL <= "110";		-- inverted outputs means 110 is level 1 interrupt
	end if ;
	
	end process ;
END ;