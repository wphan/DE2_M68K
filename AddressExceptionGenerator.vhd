LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

entity AddressExceptionGenerator is
	Port (
		Address : in Std_logic_vector(31 downto 0) ;
		AS_L, UDS_L, LDS_L	: in std_logic ;  			-- address strobe etc
		RW_L, Reset_L    : in std_logic ;

		AddressIRQ_L : out std_logic 			-- to level 6 IRQ on 68000
	);
end ;


architecture bhvr of AddressExceptionGenerator is
Begin
	process(Reset_L, AS_L, UDS_L, LDS_L, Address, RW_L )
	begin
		if(Reset_L = '0') then
			AddressIRQ_L <= '1' ;		-- remove the address IRQ when reset or power on		
		elsif(AS_L = '0' and UDS_L = '0' and LDS_L = '0' and Address(0) = '1') then
			AddressIRQ_L <= '0' ;		-- assert the address IRQ 
		elsif(AS_L = '0' and RW_L = '1' and Address = X"00000078") then 
			AddressIRQ_L <= '1' ;		-- remove the address IRQ to the 68000 when it reads the level 5 vector
		end if ;
	end process ;
END ;