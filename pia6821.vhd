--===========================================================================--
--                                                                           --
--        Synthesizable 6821 Compatible Parallel Interface Adapter           --
--                                                                           --
--===========================================================================--
--
--  File name      : pia6821.vhd
--
--  Entity name    : pia6821
--
--  Purpose        : Implements a 6821 like PIA with
--                   2 x 8 bit parallel I/O ports with
--                   programmable data direction registers and
--                   2 x 2 bit control signals.
--                  
--  Dependencies   : ieee.std_logic_1164
--                   ieee.std_logic_unsigned
--                   unisim.vcomponents
--
--  Author         : John E. Kent
--
--  Email          : dilbert57@opencores.org      
--
--  Web            : http://opencores.org/project,system09
--
--  Description    : Register Memory Map
--
--                   Base + $00 - Port A Data & Direction register
--                   Base + $01 - Port A Control register
--                   Base + $02 - Port B Data & Direction Direction Register
--                   Base + $03 - Port B Control Register
--
--  Copyright (C) 2004 - 2010 John Kent
--
--  This program is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
--===========================================================================--
--                                                                           --
--                              Revision  History                            --
--                                                                           --
--===========================================================================--
--
-- Version  Author     Date          Description
-- 0.0      John Kent  2004-05-01    Initial version developed from ioport.vhd
-- 0.1      John Kent  2010-05-30    Updated header & GPL information
-- 0.2      John Kent  2010-08-09    Made reset synchronous for wishbone compliance          
--
--===========================================================================--

library ieee;
   use ieee.std_logic_1164.all;
   use ieee.std_logic_unsigned.all;
--library unisim;
--   use unisim.vcomponents.all;

entity pia6821 is
  port (	
    Clk       : in    std_logic;
    Reset_H   : in    std_logic;
    CS_H      : in    std_logic;
    Write_L   : in    std_logic;
    addr      : in    std_logic_vector(1 downto 0);
    DataIn    : in    std_logic_vector(7 downto 0);
    DataOut   : out   std_logic_vector(7 downto 0);
    IRQ_A     : out   std_logic;						-- active low interrupt request (Note: They are NOT open drain)
    IRQ_B     : out   std_logic;
    PortA     : inout std_logic_vector(7 downto 0);
    CA1       : in    std_logic;
    CA2       : inout std_logic;
    PortB     : inout std_logic_vector(7 downto 0);
    CB1       : in    std_logic;
    CB2       : inout std_logic
  );
end;

architecture pia_arch of pia6821 is

signal porta_ddr   : std_logic_vector(7 downto 0);
signal porta_data  : std_logic_vector(7 downto 0);
signal porta_ctrl  : std_logic_vector(5 downto 0);
signal porta_read  : std_logic;

signal portb_ddr   : std_logic_vector(7 downto 0);
signal portb_data  : std_logic_vector(7 downto 0);
signal portb_ctrl  : std_logic_vector(5 downto 0);
signal portb_read  : std_logic;
signal portb_write : std_logic;

signal CA1_del     : std_logic;
signal CA1_rise    : std_logic;
signal CA1_fall    : std_logic;
signal CA1_edge    : std_logic;
signal IRQ_A1       : std_logic;

signal CA2_del     : std_logic;
signal CA2_rise    : std_logic;
signal CA2_fall    : std_logic;
signal CA2_edge    : std_logic;
signal IRQ_A2       : std_logic;
signal CA2_out     : std_logic;

signal CB1_del     : std_logic;
signal CB1_rise    : std_logic;
signal CB1_fall    : std_logic;
signal CB1_edge    : std_logic;
signal IRQ_B1       : std_logic;

signal CB2_del     : std_logic;
signal CB2_rise    : std_logic;
signal CB2_fall    : std_logic;
signal CB2_edge    : std_logic;
signal IRQ_B2       : std_logic;
signal CB2_out     : std_logic;

signal InternalDataOut : Std_Logic_Vector(7 downto 0) ;

begin


---------------------------------------------------------------
-- Tri_State Data Output Controller
--------------------------------------------------------------

PIA_DataOut: process(CS_H, Write_L, InternalDataOut)
begin
	 if(CS_H = '1' and Write_L = '1') then
		 DataOut <= InternalDataOut ;
	 else
		 DataOut <= "ZZZZZZZZ";   -- else tri-state
	 end if;
end process;

--------------------------------
--
-- read I/O port
--
--------------------------------

pia_read : process(  addr,	CS_H,
                     IRQ_A1, IRQ_A2, IRQ_B1, IRQ_B2,
                     porta_ddr,  portb_ddr,
                     porta_data, portb_data,
                     porta_ctrl, portb_ctrl,
                     PortA,         PortB )
variable count : integer;
begin
  case addr is
  when "00" =>
    for count in 0 to 7 loop
      if porta_ctrl(2) = '0' then
        InternalDataOut(count) <= porta_ddr(count);
        porta_read <= '0';
      else
        if porta_ddr(count) = '1' then
          InternalDataOut(count) <= porta_data(count);
        else
          InternalDataOut(count) <= PortA(count);
        end if;
        porta_read <= CS_H;
      end if;
    end loop;
    portb_read <= '0';

  when "01" =>
    InternalDataOut <= IRQ_A1 & IRQ_A2 & porta_ctrl;
    porta_read <= '0';
    portb_read <= '0';

  when "10" =>
    for count in 0 to 7 loop
      if portb_ctrl(2) = '0' then
        InternalDataOut(count) <= portb_ddr(count);
        portb_read <= '0';
      else
        if portb_ddr(count) = '1' then
          InternalDataOut(count) <= portb_data(count);
        else
          InternalDataOut(count) <= PortB(count);
        end if;
        portb_read <= CS_H;
      end if;
    end loop;
    porta_read <= '0';

  when "11" =>
    InternalDataOut <= IRQ_B1 & IRQ_B2 & portb_ctrl;
    porta_read <= '0';
    portb_read <= '0';

  when others =>
    InternalDataOut <= "00000000";
    porta_read <= '0';
    portb_read <= '0';

  end case;

end process;

---------------------------------
--
-- Write I/O ports
--
---------------------------------

pia_write : process( Clk, Reset_H, addr, CS_H, Write_L, DataIn,
                     porta_ctrl, portb_ctrl,
                     porta_data, portb_data,
                     porta_ddr, portb_ddr )
begin
  if Clk'event and Clk = '1' then
    portb_write <= '0';
    if Reset_H = '1' then
      porta_ddr   <= (others=>'0');
      porta_data  <= (others=>'0');
      porta_ctrl  <= (others=>'0');
      portb_ddr   <= (others=>'0');
      portb_data  <= (others=>'0');
      portb_ctrl  <= (others=>'0');
    elsif CS_H = '1' and Write_L = '0' then
      case addr is
	when "00" =>
        if porta_ctrl(2) = '0' then
          porta_ddr  <= DataIn;
        else
          porta_data <= DataIn;
        end if;
      when "01" =>
        porta_ctrl  <= DataIn(5 downto 0);
      when "10" =>
        if portb_ctrl(2) = '0' then
          portb_ddr   <= DataIn;
        else
          portb_data  <= DataIn;
          portb_write <= '1';
        end if;
      when "11" =>
        portb_ctrl  <= DataIn(5 downto 0);
      when others =>
        null;
      end case;
    end if;
  end if;
end process;

---------------------------------
--
-- direction control port a
--
---------------------------------
porta_direction : process ( porta_data, porta_ddr )
variable count : integer;
begin
  for count in 0 to 7 loop
    if porta_ddr(count) = '1' then
      PortA(count) <= porta_data(count);
    else
      PortA(count) <= 'Z';
    end if;
  end loop;
end process;

---------------------------------
--
-- CA1 Edge detect
--
---------------------------------
CA1_input : process( Clk, Reset_H, CA1, CA1_del,
                     CA1_rise, CA1_fall, CA1_edge,
                     IRQ_A1, porta_ctrl, porta_read )
begin
  if Clk'event and Clk = '0' then
    if Reset_H = '1' then
      CA1_del  <= '0';
      CA1_rise <= '0';
      CA1_fall <= '0';
      IRQ_A1    <= '0';
    else
      CA1_del  <= CA1;
      CA1_rise <= (not CA1_del) and CA1;
      CA1_fall <= CA1_del and (not CA1);
      if CA1_edge = '1' then
        IRQ_A1 <= '1';
      elsif porta_read = '1' then
        IRQ_A1 <= '0';
      end if;
    end if;  
  end if;

  if porta_ctrl(1) = '0' then
    CA1_edge <= CA1_fall;
  else
    CA1_edge <= CA1_rise;
  end if;

end process;

---------------------------------
--
-- CA2 Edge detect
--
---------------------------------
CA2_input : process( Clk, Reset_H, CA2, CA2_del,
                     CA2_rise, CA2_fall, CA2_edge,
                     IRQ_A2, porta_ctrl, porta_read )
begin
  if Clk'event and Clk = '0' then
    if Reset_H = '1' then
      CA2_del  <= '0';
      CA2_rise <= '0';
      CA2_fall <= '0';
      IRQ_A2    <= '0';
    else
      CA2_del  <= CA2;
      CA2_rise <= (not CA2_del) and CA2;
      CA2_fall <= CA2_del and (not CA2);
      if porta_ctrl(5) = '0' and CA2_edge = '1' then
        IRQ_A2 <= '1';
      elsif porta_read = '1' then
        IRQ_A2 <= '0';
      else
        IRQ_A2 <= IRQ_A2;
      end if;
    end if;
  end if;  

  if porta_ctrl(4) = '0' then
    CA2_edge <= CA2_fall;
  else
    CA2_edge <= CA2_rise;
  end if;
end process;

---------------------------------
--
-- CA2 output control
--
---------------------------------
CA2_output : process( Clk, Reset_H, porta_ctrl, porta_read, CA1_edge, CA2_out )
begin
  if Clk'event and Clk='0' then
    if Reset_H='1' then
      CA2_out <= '0';
    else
      case porta_ctrl(5 downto 3) is
      when "100" => -- read PA clears, CA1 edge sets
        if porta_read = '1' then
          CA2_out <= '0';
        elsif CA1_edge = '1' then
          CA2_out <= '1';
        else
          CA2_out <= CA2_out;
        end if;
      when "101" => -- read PA clears, E sets
        CA2_out <= not porta_read;
      when "110" =>	-- set low
        CA2_out <= '0';
      when "111" =>	-- set high
        CA2_out <= '1';
      when others => -- no change
        CA2_out <= CA2_out;
      end case;
    end if;
  end if;
end process;

---------------------------------
--
-- CA2 direction control
--
---------------------------------
CA2_direction : process( porta_ctrl, CA2, CA2_out )
begin
  if porta_ctrl(5) = '0' then
    CA2 <= 'Z';
  else
    CA2 <= CA2_out;
  end if;
end process;

---------------------------------
--
-- direction control port b
--
---------------------------------
portb_direction : process ( portb_data, portb_ddr )
variable count : integer;
begin
  for count in 0 to 7 loop
    if portb_ddr(count) = '1' then
      PortB(count) <= portb_data(count);
    else
      PortB(count) <= 'Z';
    end if;
  end loop;
end process;

---------------------------------
--
-- CB1 Edge detect
--
---------------------------------
CB1_input : process( Clk, Reset_H, CB1, CB1_del,
                     CB1_rise, CB1_fall, CB1_edge,
                     IRQ_B1, portb_ctrl, portb_read )
begin
  if Clk'event and Clk = '0' then
    if Reset_H = '1' then
      CB1_del  <= '0';
      CB1_rise <= '0';
      CB1_fall <= '0';
      IRQ_B1    <= '0';
    else
      CB1_del  <= CB1;
      CB1_rise <= (not CB1_del) and CB1;
      CB1_fall <= CB1_del and (not CB1);

      if CB1_edge = '1' then
        IRQ_B1 <= '1';
      elsif portb_read = '1' then
        IRQ_B1 <= '0';
      end if;

    end if;
  end if;

  if portb_ctrl(1) = '0' then
    CB1_edge <= CB1_fall;
  else
    CB1_edge <= CB1_rise;
  end if;
    
end process;

---------------------------------
--
-- CB2 Edge detect
--
---------------------------------
CB2_input : process( Clk, Reset_H, CB2, CB2_del,
                     CB2_rise, CB2_fall, CB2_edge,
                     IRQ_B2, portb_ctrl, portb_read )
begin
  if Clk'event and Clk = '0' then
    if Reset_H = '1' then
      CB2_del  <= '0';
      CB2_rise <= '0';
      CB2_fall <= '0';
      IRQ_B2    <= '0';
    else 
      CB2_del  <= CB2;
      CB2_rise <= (not CB2_del) and CB2;
      CB2_fall <= CB2_del and (not CB2);

      if portb_ctrl(5) = '0' and CB2_edge = '1' then
        IRQ_B2 <= '1';
      elsif portb_read = '1' then
        IRQ_B2 <= '0';
      end if;

    end if;
  end if;

  if portb_ctrl(4) = '0' then
    CB2_edge <= CB2_fall;
  else
    CB2_edge <= CB2_rise;
  end if;
end process;

---------------------------------
--
-- CB2 output control
--
---------------------------------
CB2_output : process( Clk, Reset_H, portb_ctrl, portb_write, CB1_edge, CB2_out )
begin
  if Clk'event and Clk='0' then
    if Reset_H='1' then
      CB2_out <= '0';
    else
      case portb_ctrl(5 downto 3) is
      when "100" => -- write PB clears, CA1 edge sets
        if portb_write = '1' then
          CB2_out <= '0';
        elsif CB1_edge = '1' then
          CB2_out <= '1';
        end if;
      when "101" => -- write PB clears, E sets
        CB2_out <= not portb_write;
      when "110" =>	-- set low
        CB2_out <= '0';
      when "111" =>	-- set high
        CB2_out <= '1';
      when others => -- no change
        null;
      end case;
    end if;
  end if;
end process;

---------------------------------
--
-- CB2 direction control
--
---------------------------------
CB2_direction : process( portb_ctrl, CB2, CB2_out )
begin
  if portb_ctrl(5) = '0' then
    CB2 <= 'Z';
  else
    CB2 <= CB2_out;
  end if;
end process;

---------------------------------
--
-- IRQ control
--
---------------------------------
pia_irq : process( IRQ_A1, IRQ_A2, IRQ_B1, IRQ_B2, porta_ctrl, portb_ctrl )
begin
  IRQ_A <= Not (IRQ_A1 and porta_ctrl(0)) or (IRQ_A2 and porta_ctrl(3));	-- active low IRQs
  IRQ_B <= Not (IRQ_B1 and portb_ctrl(0)) or (IRQ_B2 and portb_ctrl(3));
end process;

end pia_arch;
	
