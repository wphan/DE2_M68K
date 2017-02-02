LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY BusRequestLogic IS
	PORT(
		Clock, Reset_L     	: IN Std_Logic ;
	   	AS_L	  			: IN STD_LOGIC;	-- 68000 address strobe
		BR_L      			: IN STD_LOGIC;	-- Bus request from potential bus master
       	BGACK_L   			: IN STD_LOGIC;	-- bus grant acknowledge from requesting bus master

	   	BG_L      			: OUT STD_LOGIC;	-- bus grant output to requesting bus master
		CLKEN_H    			: OUT STD_LOGIC 	-- 68000 clock enable
       );
END;

ARCHITECTURE fsm OF BusRequestLogic IS

    TYPE BusRequestStates IS (
		IDLE,
		GotBusRequest,
		WaitingforBusGrantAcknowledge,
		MasterHasBus,
		RemoveBusGrant 
	);

    
	SIGNAL Next_state	: BusRequestStates ;
	SIGNAL Current_state	: BusRequestStates ;

BEGIN

-- Now we implement a process to represent the state registers of our logic
-- concurrent process #1: state registers
--
-- On the rising edge of the clock, this VHDL process assigns the data present on t
-- signal 'current_state' to 'next_state'.

	
    PROCESS (Clock, Reset_L, Next_state)
    BEGIN
		IF (Reset_L = '0') THEN
          		Current_state <= IDLE;
		ELSIF (rising_edge (Clock)) THEN
	      		Current_state <= Next_state;
		END IF;
    END PROCESS;			

-- state maching process

    PROCESS(AS_L, BR_L, BGACK_L, Current_state )
    BEGIN		
		Next_State <= IDLE ;

		IF (Current_state = IDLE) THEN						-- waiting for a bus request
			IF (BR_L = '0') THEN							-- got bus request from system controller/DMA
				Next_State <= GotBusRequest ;
			ELSE
				Next_State <= IDLE ;
			END IF ;
			
		ELSIF (Current_State = GotBusRequest) THEN			-- waiting for 68000 to finish current bus cycle
			IF(AS_L = '1') then								-- when AS goes high 68000 has finished memory access to safe to hand over the bus to the requestingbus master
				Next_state <= WaitingforBusGrantAcknowledge;
			ELSE	
				Next_State <= GotBusRequest ;
			END IF ;	
			
		ELSIF (Current_State = WaitingforBusGrantAcknowledge) THEN		-- output bus grant in this state
			IF(BGACK_L = '0') THEN										-- wait for ack from bus master
				Next_State <= MasterHasBus ;
			ELSIF(BR_L = '1') then										-- if master removes BR unexpectedly before even acknowledging the br
				Next_State <= IDLE ;									-- safety net in case bus requester bottles out !!!
			ELSE
				Next_State <= WaitingforBusGrantAcknowledge;
			END IF ;

		ELSIF (Current_State = MasterHasBus) THEN						-- wait for master to remove BR	
			if(BR_L = '1') then
				Next_State <= RemoveBusGrant ;
			else
				Next_State <= MasterHasBus ;
			end if ;

		ELSIF (Current_State = RemoveBusGrant) THEN						-- wait for master to remove Bgack		
			if(BGACK_L = 'H') then
				Next_State <= IDLE ;
			else
				Next_State <= RemoveBusGrant;
			end if ;
		end if ;

    END PROCESS ;

-- concurrent process#3: Output logic which is just combinatorial logic
-- start off with the sensitivity list

    PROCESS (Current_state)
    BEGIN
		BG_L       <= '1' ;
		CLKEN_H    <= '1' ;
	
		IF (current_state = IDLE) THEN  -- normal 68000 operation
	 		BG_L       <= '1' ;
			CLKEN_H    <= '1' ;
	
		ELSIF (Current_State = GotBusRequest) THEN
			BG_L       <= '1' ;
			CLKEN_H    <= '1' ;

		ELSIF (Current_State = WaitingforBusGrantAcknowledge) THEN
			BG_L       <= '0' ;
			CLKEN_H    <= '0' ;

		ELSIF (Current_State = MasterHasBus) THEN
			BG_L       <= '0' ;
			CLKEN_H    <= '0' ;

		ELSIF (Current_State = RemoveBusGrant) THEN
			BG_L       <= '1' ;
			CLKEN_H    <= '0' ;

		END IF ;					
    END PROCESS;
END;
