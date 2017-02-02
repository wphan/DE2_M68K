LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- simple VHDL to make sure 68000 receives data on both halves of data bus from Flash when reading a bute regardless of byte address used

Entity DataMapper68k is
	Port ( 
		DataFromFlash: in STD_LOGIC_VECTOR(7 downto 0) ;
		DataTo68k : out STD_LOGIC_VECTOR(15 downto 0)
		);	
end;

Architecture a of DataMapper68k is
begin
	DataTo68k(15 downto 8) <= DataFromFlash(7 downto 0) ;
	DataTo68k(7 downto 0) <= DataFromFlash(7 downto 0) ;
end a ;
