LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 


entity FlashDtackGenerator is
	Port (
		AS_L	: in std_logic ;  				-- address strobe	from 68k
	   Clock : in std_logic ;
		FlashSelect_H : in std_logic ;
	   DtackOut_L : out std_logic
	);
end ;


architecture bhvr of FlashDtackGenerator is
	signal count_save : integer := 0;
Begin
	process(Clock, AS_L, FlashSelect_H)
	    variable count : integer := 0;
	begin
	   count := count_save;

		if (rising_edge(Clock))	then 
			DtackOut_L <= '1' ;
		
			if (AS_L = '0') and (FlashSelect_H = '1') then
				count := count + 1;
			else
				count := 0;
			end if;
			
			if (count > 5) then
				DtackOut_L <= '0';
				count := 6;
			end if;
			count_save <= count;
		end if;
		
	end process ;
END ;
