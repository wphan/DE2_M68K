-----------------------------------------------------------------
--
-- ACIA Clock Divider for System09
--
-----------------------------------------------------------------
--
library IEEE;
   use IEEE.std_logic_1164.all;
   use IEEE.std_logic_arith.all;
   use IEEE.std_logic_unsigned.all;

package bit_funcs is
   function log2(v: in natural) return natural;
end package bit_funcs;
      
library IEEE;
   use IEEE.std_logic_1164.all;
   use IEEE.std_logic_arith.all;
   use IEEE.std_logic_unsigned.all;

package body bit_funcs is
   function log2(v: in natural) return natural is
      variable n: natural;
      variable logn: natural;
   begin
      n := 1;
      for i in 0 to 128 loop
         logn := i;
         exit when (n>=v);
         n := n * 2;
      end loop;
      return logn;
   end function log2;

end package body bit_funcs;

library ieee;
   use ieee.std_logic_1164.all;
   use IEEE.STD_LOGIC_ARITH.ALL;
   use IEEE.STD_LOGIC_UNSIGNED.ALL;
   use ieee.numeric_std.all;
--library unisim;
	--use unisim.vcomponents.all;
library work;
   use work.bit_funcs.all;

entity ACIA_Clock is
   port(
     Clk      : in  Std_Logic;  -- System Clock input
	 ACIA_Clk : out Std_Logic;   -- ACIA Clock output
	 BaudRateSelect : in std_logic_vector(2 downto 0) 
  );
end ACIA_Clock;

-------------------------------------------------------------------------------
-- Architecture for ACIA_Clock the baud rate generator
-------------------------------------------------------------------------------
architecture rtl of ACIA_Clock is

--
-- Baud Rate Clock Divider
--
-- 50MHz / 14  = 3,571,428 KHz = 115,740Bd = (230.4Kbaud)@ 16 times acia
-- 50MHz / 27  = 1,851,851 KHz = 115,740Bd = (115.2Kbaud)@ 16 times acia
-- 50MHz / 54  = 926,000 KHz = 57,870Bd = (57.6Kbaud)@ 16 times acia 
--
-- 50Mhz / 81  = 617,284 Khz = 38,580Bd = (38.4Kbaud) @ 16 times acia clock
-- 50Mhz / 163  = 306,748 Khz = 19,171Bd = (19.2Kbaud) @ 16 times acia clock
-- 50Mhz / 326  = 153,374 Khz = 9,585Bd = (9600 baud) @ 16 times acia clock
--

--constant SYS_Clock_Frequency : integer := 50000000; -- 0010 1111 1010 1111 0000 1000 0000"

constant ACIA_Clock_Frequency0 : integer := 3571428; -- "0001 1100 0100 0001 1100 1011"
constant ACIA_Clock_Frequency1 : integer := 1851851; -- "0001 1100 0100 0001 1100 1011"
constant ACIA_Clock_Frequency2 : integer := 926000;  -- "0000 1110 0010 0001 0011 0000"
constant ACIA_Clock_Frequency3 : integer := 617284;  -- "0000 1001 0110 1011 0100 0100"
constant ACIA_Clock_Frequency4 : integer := 306748;  -- "0000 0100 1010 1110 0011 1100"
constant ACIA_Clock_Frequency5 : integer := 153374;  -- "0000 0010 0101 0111 0001 1110"
--

-- constant FULL_CYCLE : integer :=  (SYS_Clock_Frequency / ACIA_Clock_Frequency);
-- 14 or "0000 0000 1110" for 230k baud with a 50Mhz clock
-- 27 or "0000 0001 1011" for 115k baud with a 50Mhz clock
-- 53 or "0000 0011 0101" for 57.6k baud with a 50Mhz clock
-- 80 or "0000 0101 0000" for 38.4kbaud with a 50Mhz clock
-- 163 or "0000 1010 0011" for 19.2kbaud @ 50Mhz clock
-- 326 or "0001 0100 0110" for 9600 baud @ 50Mhz clock

constant FULL_CYCLE_230400 : std_logic_vector(11 downto 0) := B"0000_0000_1110" ;
constant FULL_CYCLE_115200 : std_logic_vector(11 downto 0) := B"0000_0001_1011" ;
constant FULL_CYCLE_57600 : std_logic_vector(11 downto 0) := B"0000_0011_0101" ;
constant FULL_CYCLE_38400 : std_logic_vector(11 downto 0) := B"0000_0101_0000" ;
constant FULL_CYCLE_19200 : std_logic_vector(11 downto 0) := B"0000_1010_0011" ;
constant FULL_CYCLE_9600 : std_logic_vector(11 downto 0) := B"0001_0100_0110" ;

--constant HALF_CYCLE : integer :=  (FULL_CYCLE / 2);
-- 7 or "0000 0000 0111" for 230k baud with a 50Mhz clock
-- 13 or "0000 0000 1101" for 115k baud with a 50Mhz clock
-- 26 or "0000 0001 1010" for 57.6k baud with a 50Mhz clock
-- 40 or "0000 0010 1000" for 38.4kbaud with a 50Mhz clock
-- 81 or "0000 0101 0001" for 19.2kbaud @ 50Mhz clock
-- 163 or "0000 1010 0011" for 9600 baud @ 50Mhz clock


constant HALF_CYCLE_230400 : std_logic_vector(11 downto 0) := B"0000_0000_0111" ;
constant HALF_CYCLE_115200 : std_logic_vector(11 downto 0) := B"0000_0000_1101" ;
constant HALF_CYCLE_57600 : std_logic_vector(11 downto 0) := B"0000_0001_1010" ;
constant HALF_CYCLE_38400 : std_logic_vector(11 downto 0) := B"0000_0010_1000" ;
constant HALF_CYCLE_19200 : std_logic_vector(11 downto 0) := B"0000_0101_0001" ;
constant HALF_CYCLE_9600 : std_logic_vector(11 downto 0) := B"0000_1010_0011" ;

signal   ACIA_Count : Std_Logic_Vector(11 downto 0);
Signal   FULL_CYCLE : std_logic_vector(11 downto 0) ;
Signal	 HALF_CYCLE : std_logic_vector(11 downto 0) ;

begin
-- mux
	process (BaudRateSelect)
	begin
		if(BaudRateSelect = "000") then
			FULL_CYCLE <= FULL_CYCLE_230400 ;
			HALF_CYCLE <= HALF_CYCLE_230400 ;
		elsif(BaudRateSelect = "001") then
			FULL_CYCLE <= FULL_CYCLE_115200 ;
			HALF_CYCLE <= HALF_CYCLE_115200 ;
		elsif(BaudRateSelect = "010") then
			FULL_CYCLE <= FULL_CYCLE_57600 ;
			HALF_CYCLE <= HALF_CYCLE_57600 ;
		elsif(BaudRateSelect = "011") then
			FULL_CYCLE <= FULL_CYCLE_38400 ;
			HALF_CYCLE <= HALF_CYCLE_38400 ;
		elsif(BaudRateSelect = "100") then
			FULL_CYCLE <= FULL_CYCLE_19200 ;
			HALF_CYCLE <= HALF_CYCLE_19200 ;
		else
			FULL_CYCLE <= FULL_CYCLE_9600 ;
			HALF_CYCLE <= HALF_CYCLE_9600 ;
		end if ;
	end process ;
	
	-- clock generator
	
	process( clk, BaudRateSelect)
	begin
		if(rising_edge(clk)) then
			if( ACIA_Count = (FULL_CYCLE - 1) )	then
				ACIA_Clk   <= '0';
				ACIA_Count <= (others => '0'); 		-- "000000";
			else
				if( ACIA_Count = (HALF_CYCLE - 1) )	then
					ACIA_Clk <='1';
				end if;
				ACIA_Count <= ACIA_Count + 1; 
			end if;			 
		end if;
	end process;
end rtl;
