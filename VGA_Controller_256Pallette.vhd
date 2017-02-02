LIBRARY IEEE;
USE  IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY VGA_Controller_256Pallette IS PORT (
	Clock, Reset			: IN STD_LOGIC;
	Red,Green,Blue			: IN STD_LOGIC_VECTOR(7 downto 0);		-- 8 bit colour gives 2^6 colours = 64 colours with 1 byte per pixel

	H_Sync_out,V_Sync_out			: OUT STD_LOGIC;
	Red_out,Green_out,Blue_out		: OUT STD_LOGIC_VECTOR(7 downto 0);
	Column_out,Row_out				: OUT STD_LOGIC_VECTOR(9 DOWNTO 0));
END;

ARCHITECTURE FSM OF VGA_Controller_256Pallette IS
	-- Horizontal timings
			-- number of 25.175MHz clock periods
	CONSTANT B: INTEGER :=  95;
	CONSTANT C: INTEGER :=  45;
	CONSTANT D: INTEGER := 640-1;	-- 640 pixel columns per row; count starts from 0
	CONSTANT E: INTEGER :=  20;
				-- total   800

	-- Vertical timings
			-- number of horizontal line cycles
	CONSTANT P: INTEGER :=   2;
	CONSTANT Q: INTEGER :=  32;
	CONSTANT R: INTEGER := 480-1;	-- 480 pixel rows per screen; count starts from 0
	CONSTANT S: INTEGER :=  14;
				-- total   528

	SIGNAL HCount, VCount: STD_LOGIC_VECTOR(9 DOWNTO 0); -- horizontal and vertical counters
	SIGNAL V_Clock: STD_LOGIC;	-- clock for vertical counter

	SIGNAL H_Data_on,V_Data_on: STD_LOGIC;

	TYPE H_state_type IS (s_H0,s_H1,s_H2,s_H3);	-- states for the horizontal sync process
	TYPE V_state_type IS (s_V0,s_V1,s_V2,s_V3);	-- states for the vertical sync process
	SIGNAL H_state: H_state_type;
	SIGNAL V_state: V_state_type;

BEGIN
	Horizontal_Counter: PROCESS(Clock, Reset)
	BEGIN
		IF (Reset = '0') THEN
			HCount <= (OTHERS => '0');
			H_Data_on <= '0';
			H_Sync_out <= '1';
		ELSIF (Clock'EVENT AND Clock = '1') THEN
			-- Horizontal counter
			IF (HCount = B+C+D+E) THEN
				HCount <= (OTHERS => '0');
				V_Clock <= '1';	-- generate clock for vertical counter
			ELSE
				HCount <= HCount + 1;
				V_Clock <= '0';
			END IF;

			-- generate H_Sync_out
			IF (HCount = D+E+B) THEN
				H_Sync_out <= '1';
			ELSIF (HCount = D+E) THEN
				H_Sync_out <= '0';
			END IF;

			-- generate H_Data_on
			IF (HCount = D+E+B+C) THEN
				H_Data_on <= '1';
			ELSIF (HCount = D) THEN
				H_Data_on <= '0';
			END IF;
		END IF;
	END PROCESS;

	Vertical_Counter: PROCESS(V_Clock, reset)
	BEGIN
		IF (Reset = '0') THEN
			VCount <= (OTHERS => '0');
			V_Data_on <= '0';
			V_Sync_out <= '1';
		ELSIF (V_Clock'EVENT AND V_Clock = '1') THEN
			-- Vertical counter
			IF (VCount = P+Q+R+S) THEN
				VCount <= (OTHERS => '0');
			ELSE
				VCount <= VCount + 1;
			END IF;

			-- generate V_Sync_out
			IF (VCount = R+S+P) THEN
				V_Sync_out <= '1';
			ELSIF (VCount = R+S) THEN
				V_Sync_out <= '0';
			END IF;

			-- generate V_Data_on
			IF (VCount = R+S+P+Q) THEN
				V_Data_on <= '1';
			ELSIF (VCount = R) THEN
				V_Data_on <= '0';
			END IF;
		END IF;
	END PROCESS;

--	generate Red,Green,Blue data signals
	Colour_Latch: PROCESS(Clock)
	BEGIN
		IF (rising_edge(Clock)) then		
--		IF (falling_edge(Clock) ) THEN
			Red_out(7) <= H_data_on AND V_data_on AND Red(7);
			Red_out(6) <= H_data_on AND V_data_on AND Red(6);
			Red_out(5) <= H_data_on AND V_data_on AND Red(5);
			Red_out(4) <= H_data_on AND V_data_on AND Red(4);
			Red_out(3) <= H_data_on AND V_data_on AND Red(3);
			Red_out(2) <= H_data_on AND V_data_on AND Red(2);
			Red_out(1) <= H_data_on AND V_data_on AND Red(1);
			Red_out(0) <= H_data_on AND V_data_on AND Red(0);
	
			Green_out(7) <= H_data_on AND V_data_on AND Green(7);
			Green_out(6) <= H_data_on AND V_data_on AND Green(6);
			Green_out(5) <= H_data_on AND V_data_on AND Green(5);
			Green_out(4) <= H_data_on AND V_data_on AND Green(4);			
			Green_out(3) <= H_data_on AND V_data_on AND Green(3);
			Green_out(2) <= H_data_on AND V_data_on AND Green(2);			
			Green_out(1) <= H_data_on AND V_data_on AND Green(1);
			Green_out(0) <= H_data_on AND V_data_on AND Green(0);			
	
			Blue_out(7) <= H_data_on AND V_data_on AND Blue(7);
			Blue_out(6) <= H_data_on AND V_data_on AND Blue(6);
			Blue_out(5) <= H_data_on AND V_data_on AND Blue(5);
			Blue_out(4) <= H_data_on AND V_data_on AND Blue(4);
			Blue_out(3) <= H_data_on AND V_data_on AND Blue(3);
			Blue_out(2) <= H_data_on AND V_data_on AND Blue(2);
			Blue_out(1) <= H_data_on AND V_data_on AND Blue(1);
			Blue_out(0) <= H_data_on AND V_data_on AND Blue(0);

		END IF;
	END PROCESS;
	
--	generate column,row signals
	Column_out	<= HCount WHEN (H_Data_on = '1' AND V_Data_on = '1');
	Row_out 	<= VCount WHEN (H_Data_on = '1' AND V_Data_on = '1');

END FSM;
