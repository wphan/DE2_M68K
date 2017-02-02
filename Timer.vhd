LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

-- Base + 0 = Data Register (write only)
-- Base + 2 = Control Register (write)/ Status Register (read) - both only use bit 0

entity Timer is
	Port (
		Clk : in Std_logic  ;							-- used for timing
		Reset_L : in Std_logic  ;							-- preloads timer and clears reset
				

		DataIn : in Std_logic_Vector(7 downto 0) ;		-- 8 bit number representing most significant 8 bits of timer
		DataOut : out Std_logic_Vector(7 downto 0) ;
		
		DataRegisterSelect : in Std_logic ;				-- signal indicates CPU is writing to data reg
		ControlRegisterSelect : in Std_logic;			-- signal indicates CPU is writing to control reg
		WE_L : in Std_logic ;
		
		IRQ_L : out STD_LOGIC 							-- interrupt Request active low
	 );

end ;


architecture bhvr of Timer is
	Signal TheTimer : std_logic_vector(23 downto 0) ;						-- actual timer
	Signal DataRegister : std_logic_vector(7 downto 0) ;					-- A data register holding the 8 most significant bits of the 24 bit timer
	Signal ControlRegister : std_logic_vector(1 downto 0);					-- control reister, writing to this location controls timer and pre-loads the counter back to initial value
																			-- equal to (DataRegister + FFFF), i.e. the timer is loaded with FFFF in lsbits plus the value of dataregister in ms 8 bit
																			-- Bit 0 = 1, IRQ enabled
																			-- Bit 0 = 0, IRQ disabled
																			-- Bit 1 = 1, Timer operation enabled (i.e. counts)
																			-- Bit 1 = 0, Timer operation disabled (doesn't count)		
	Signal IRQ_Internal : std_logic ;										-- internal IRQ							

Begin
	process(CLK, Reset_L, DataIn, DataRegisterSelect, ControlRegisterSelect, WE_L)
	Begin
		if(Reset_L = '0') then
			DataRegister <= X"FF" ;											-- set msbits of delay to FF
			ControlRegister <= "00" ;										-- disable IRQ, Timer not counting
			TheTimer <= X"FFFFFF" ;											-- preload timer with max delay
			IRQ_Internal <= '1' ;											-- clear any interrupt
			
	
		elsif(Rising_Edge(Clk)) then										-- used to be falling edge pre updates to tg68  
			if(DataRegisterSelect = '1' and WE_L = '0') then				-- if write operation being performed to data register
					DataRegister <= DataIn;									-- save in DataRegister

			elsif(ControlRegisterSelect = '1' and WE_L = '0') then			-- clear interrupt by writing to control register
					ControlRegister <= DataIn(1 downto 0);					-- save the control register
					IRQ_Internal <= '1' ;									-- clear the interrupt
					theTimer( 23 downto 16)  <= DataRegister ;				-- initialise the timer ms bits
					theTimer(15 downto 0) <= X"FFFF" ;						-- clear timer lsbits - 0000
		
			else 															-- if not writing to timer data or control register
				if(theTimer = X"000000") then
					if(ControlRegister(0) = '1') then						-- if IRQs are enabled
						IRQ_Internal <= '0' ;								-- as counter moves from 000000 to FFFFFF then generate IRQ, stays 0 until cleared by reset or a write to control register
					end if ;
					
					TheTimer(23 downto 16) <= DataRegister ;				-- reload the timer when it reaches 0
					TheTimer(15 downto 0) <= X"FFFF" ;
				
				else
					if(ControlRegister(1) = '1') then						-- if counter operation enabled
						theTimer <= theTimer - 1 ;							-- decrement timer
					end if;
				end if ;
			end if ;
		end if ;
	end process ;
	
	-- read status register (status of IRQ on Bit 0)
	process(ControlRegisterSelect, WE_L, IRQ_internal)
	Begin
		if(ControlRegisterSelect = '1' and WE_L = '1') then			-- if read operation being performed of status register
			DataOut <= "0000000" & (not IRQ_internal) ;  				-- output IRQ status 
		else
			DataOut <= "ZZZZZZZZ" ;									-- else tri-state outputs bus
		end if ;
	end process ;
	
	IRQ_L <= IRQ_internal ;
END ;