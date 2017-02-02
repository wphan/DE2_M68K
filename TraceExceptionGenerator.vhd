LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

entity TraceExceptionGenerator is
	Port (
		Clock, Reset : in std_logic ;
		Address : in Std_logic_vector(31 downto 0) ;
		AS_L	: in std_logic ;  -- address strobe
		RW_L    : in std_logic ;
		SingleStep_H : in std_logic ;		-- from port - set when the user writes ff to 0x0040000a in debug monitor when selecting single step mode
		TraceRequest_L : in std_logic ;		-- from push button 3 on de1 board

		TraceIRQ_L : out std_logic -- to level 6 IR on 68000
	);
end ;


architecture bhvr of TraceExceptionGenerator is
	Signal Trace_L : std_logic ;
Begin
	-- trace_l will be 0 when tracing has been enabled in the debug monitor or user presses push button 3
	
	Trace_L <= (NOT(SingleStep_H) and TraceRequest_L) ;
	
	process(Clock, Reset)
	begin
		if(Reset = '0') then
			TraceIRQ_L <= '1' ;
			
		elsif(rising_edge(Clock)) then
		    if(Trace_L = '0') then
			
				-- if CPU reading (instruction) Dram program between 0080 0000 and 0083 FFFF i.e. user program space then assert trace IRQ so trace will be called after the next instruction
			
				if(AS_L = '0' and RW_L = '1' and ((Address(31 downto 16) >= X"0080") and (Address(31 downto 16) < X"0084"))) then 
					TraceIRQ_L <= '0' ;		-- assert the Trace IRQ
				end if ;
			end if ;			
			
			-- if CPU reads IRQ vector for trace remove the TraceIRQ to CPU
				
			if(AS_L = '0' and RW_L = '1' and Address = X"00000074") then 
				TraceIRQ_L <= '1' ;
			end if ;
		end if ;
	end process ;
END ;

