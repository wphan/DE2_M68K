LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.std_logic_arith.all; 
use ieee.std_logic_unsigned.all; 

entity IODecoder is
	Port (
		Address : in Std_logic_vector(31 downto 0) ;
		IOSelect_H : in Std_logic ;
		WE_L : in Std_Logic ;
		UDS_L : in Std_Logic ;
				
		OutputPortA_Enable : out Std_Logic;
		InputPortA_Enable : out Std_Logic;
		OutputPortB_Enable : out Std_Logic;
		InputPortB_Enable : out Std_Logic;
		OutputPortC_Enable : out Std_Logic;
		InputPortC_Enable : out Std_Logic;				
		OutputPortD_Enable : out Std_Logic;
		InputPortD_Enable : out Std_Logic;				
	    OutputPortE_Enable : out Std_Logic;
		InputPortE_Enable : out Std_Logic;				
		
		LCDCommandOrData: out Std_Logic ;
		LCDWrite : out Std_Logic;
		
		Timer1ControlReg_Enable : out Std_logic;
		Timer1DataReg_Enable : out Std_logic; 
		Timer2ControlReg_Enable : out Std_logic;
		Timer2DataReg_Enable : out Std_logic ;
		Timer3ControlReg_Enable : out Std_logic;
		Timer3DataReg_Enable : out Std_logic ;
		Timer4ControlReg_Enable : out Std_logic;
		Timer4DataReg_Enable : out Std_logic ;
		
		Timer5ControlReg_Enable : out Std_logic;
		Timer5DataReg_Enable : out Std_logic; 
		Timer6ControlReg_Enable : out Std_logic;
		Timer6DataReg_Enable : out Std_logic ;
		Timer7ControlReg_Enable : out Std_logic;
		Timer7DataReg_Enable : out Std_logic ;
		Timer8ControlReg_Enable : out Std_logic;
		Timer8DataReg_Enable : out Std_logic ;
		
		HexDisplay7and6Enable : out Std_logic ;
		HexDisplay5and4Enable : out Std_logic ;
		HexDisplay3and2Enable : out Std_logic ;
		HexDisplay1and0Enable : out Std_logic ;
		
		TraceExceptionEnable : out Std_logic	
	);
end ;


architecture bhvr of IODecoder is
Begin
	process(Address, IOSelect_H, WE_L, UDS_L)
	Begin
		OutputPortA_Enable <= '0' ;
		InputPortA_Enable <= '0' ;
		OutputPortB_Enable <= '0' ;
		InputPortB_Enable <= '0' ;
		OutputPortC_Enable <= '0' ;
		InputPortC_Enable <= '0' ;
		OutputPortD_Enable <= '0' ;
		InputPortD_Enable <= '0' ;
		OutputPortE_Enable <= '0' ;
		InputPortE_Enable <= '0' ;
						
		LCDCommandOrData <= '0' ;
		LCDWrite <= '0' ;
		
		Timer1DataReg_Enable <= '0' ;
		Timer1ControlReg_Enable <= '0' ;
		Timer2DataReg_Enable <= '0' ;
		Timer2ControlReg_Enable <= '0' ;
		Timer3DataReg_Enable <= '0' ;
		Timer3ControlReg_Enable <= '0' ;
		Timer4DataReg_Enable <= '0' ;
		Timer4ControlReg_Enable <= '0' ;	
		
		Timer5DataReg_Enable <= '0' ;
		Timer5ControlReg_Enable <= '0' ;
		Timer6DataReg_Enable <= '0' ;
		Timer6ControlReg_Enable <= '0' ;
		Timer7DataReg_Enable <= '0' ;
		Timer7ControlReg_Enable <= '0' ;
		Timer8DataReg_Enable <= '0' ;
		Timer8ControlReg_Enable <= '0' ;	
		
		HexDisplay7and6Enable <= '0' ;
		HexDisplay5and4Enable <= '0' ;
		HexDisplay3and2Enable <= '0' ;
		HexDisplay1and0Enable <= '0' ;
		
		TraceExceptionEnable <= '0';
		
		
--  IO Ports located at Base Address of Hex $00400000 upwards
--	Port A = Hex 00400000 (read and write since it's a bi-directional port)
--	Port B = Hex 00400002 (read and write since it's a bi-directional port)
--	Port C = Hex 00400004 (read and write since it's a bi-directional port)
--	Port D = Hex 00400006 (read and write since it's a bi-directional port)
--	Port E = Hex 00400008 (read and write since it's a bi-directional port)
--  TraceExceptionEnable = Hex 0040000A

		
		if(IOSelect_H = '1') then 
			-- Port A
			if(Address = X"00400000" and UDS_L = '0' ) then
				if(WE_L = '0') then
					OutputPortA_Enable <= '1' ;
				else 
					InputPortA_Enable <= '1' ;
				end if ;
			end if ;
				
			-- Port B
			if(Address = X"00400002" and UDS_L = '0') then
				if(WE_L = '0') then
					OutputPortB_Enable <= '1' ;
				else 
					InputPortB_Enable <= '1' ;
				end if ;
			end if ;			
				
			-- Port C
			if(Address = X"00400004" and UDS_L = '0') then
				if(WE_L = '0') then
					OutputPortC_Enable <= '1' ;
				else 
					InputPortC_Enable <= '1' ;
				end if ;
			end if ;
			
			-- Port D
			if(Address = X"00400006" and UDS_L = '0') then
				if(WE_L = '0') then
					OutputPortD_Enable <= '1' ;
				else 
					InputPortD_Enable <= '1' ;
				end if ;
			end if ;
			
			-- Port E
			if(Address = X"00400008" and UDS_L = '0') then
				if(WE_L = '0') then
					OutputPortE_Enable <= '1' ;
				else 
					InputPortE_Enable <= '1' ;
				end if ;
			end if ;		
	
			-- TraceException generator (write only)
			if(Address = X"0040000A" and UDS_L = '0') then
				if(WE_L = '0') then
					TraceExceptionEnable <= '1' ;
				end if ;
			end if ;		
			
	--	7 segment Display Port (RHS or least significant digits) = Hex 00400010
	--	7 segment Display Port (LHS or most significant digits) = Hex 00400012	
	--	7 segment Display Port (RHS or least significant digits) = Hex 00400014
	--	7 segment Display Port (LHS or most significant digits) = Hex 00400016
	
			if(Address = X"00400010" and UDS_L = '0') then
				if(WE_L = '0') then
					HexDisplay1and0Enable <= '1' ;
				end if ;
			end if ;	
			
			if(Address = X"00400012" and UDS_L = '0') then
				if(WE_L = '0') then
					HexDisplay3and2Enable <= '1' ;
				end if ;
			end if ;	
			
			if(Address = X"00400014" and UDS_L = '0') then
				if(WE_L = '0') then
					HexDisplay5and4Enable <= '1' ;
				end if ;
			end if ;	
			
			if(Address = X"00400016" and UDS_L = '0') then
				if(WE_L = '0') then
					HexDisplay7and6Enable <= '1' ;
				end if ;
			end if ;	
											
	
	--	LCD Port = Hex 00400020 for command register
	--	LCD Port = Hex 00400022 for data register
				
			if(Address = X"00400020" and UDS_L = '0') then
				if(WE_L = '0') then
					LCDWrite <= '1' ;
					LCDCommandOrData <= '0' ;		-- 0 for command
				end if ;
			end if ;
			
			if(Address = X"00400022" and UDS_L = '0') then
				if(WE_L = '0') then
					LCDWrite <= '1' ;
					LCDCommandOrData <= '1' ;		-- 1 for data
				end if ;
			end if ;
			
	-- decoder for the 4 Timers at base address Hex 00400030/32, 34/36, 38/3A, 3C/3E on d8-d15		
	
			if(Address = X"00400030" and UDS_L = '0') then					-- Timer 1 Data Register, d8-d15
				Timer1DataReg_Enable <= '1' ;
			elsif(Address = X"00400032" and UDS_L = '0') then				-- Timer 1 Control/status Register d8-d15
				Timer1ControlReg_Enable <= '1' ;
			elsif(Address = X"00400034" and UDS_L = '0') then				-- Timer 2 Data Register d8-d15
				Timer2DataReg_Enable <= '1' ;
			elsif(Address = X"00400036" and UDS_L = '0') then				-- Timer 2 Control/status Register d8-d15
				Timer2ControlReg_Enable <= '1' ;
			elsif(Address = X"00400038" and UDS_L = '0') then				-- Timer 3 Data Register d8-d15
				Timer3DataReg_Enable <= '1' ;
			elsif(Address = X"0040003A" and UDS_L = '0') then				-- Timer 3 Control/status Register d8-d15
				Timer3ControlReg_Enable <= '1' ;
			elsif(Address = X"0040003C" and UDS_L = '0') then				-- Timer 4 Data Register d8-d15
				Timer4DataReg_Enable <= '1' ;
			elsif(Address = X"0040003E" and UDS_L = '0') then				-- Timer 4 Control/status Register d8-d15
				Timer4ControlReg_Enable <= '1' ;
				
			elsif(Address = X"00400130" and UDS_L = '0') then				-- Timer 5 Data Register, d8-d15
				Timer5DataReg_Enable <= '1' ;
			elsif(Address = X"00400132" and UDS_L = '0') then				-- Timer 5 Control/status Register d8-d15
				Timer5ControlReg_Enable <= '1' ;
			elsif(Address = X"00400134" and UDS_L = '0') then				-- Timer 6 Data Register d8-d15
				Timer6DataReg_Enable <= '1' ;
			elsif(Address = X"00400136" and UDS_L = '0') then				-- Timer 6 Control/status Register d8-d15
				Timer6ControlReg_Enable <= '1' ;
			elsif(Address = X"00400138" and UDS_L = '0') then				-- Timer 7 Data Register d8-d15
				Timer7DataReg_Enable <= '1' ;
			elsif(Address = X"0040013A" and UDS_L = '0') then				-- Timer 7 Control/status Register d8-d15
				Timer7ControlReg_Enable <= '1' ;
			elsif(Address = X"0040013C" and UDS_L = '0') then				-- Timer 8 Data Register d8-d15
				Timer8DataReg_Enable <= '1' ;
			elsif(Address = X"0040013E" and UDS_L = '0') then				-- Timer 8 Control/status Register d8-d15
				Timer8ControlReg_Enable <= '1' ;				
			end if ;
		end if ;
	end process ;
END ;