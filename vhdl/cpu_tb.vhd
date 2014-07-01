LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

use work.common.all;

ENTITY yafc_tb IS
END yafc_tb;

ARCHITECTURE test OF yafc_tb IS 

  --Inputs
  signal clk : std_logic := '0';
  signal rst_n : std_logic := '0';

  -- outputs
  signal o_out : word;
  signal o_strobe : std_logic;
  signal tos, nos : word;
  
  -- Clock period definitions
  constant clk_period : time := 10 ns;

  signal done : boolean := false;
  
BEGIN
  
  -- Instantiate the Unit Under Test (UUT)
  uut: entity work.yafc( structural ) PORT MAP (
    clk => clk,
    rst_in => rst_n,
    o_out => o_out,
    o_strobe => o_strobe,
    o_debug_1 => tos,
    o_debug_2 => nos
    );

  clk <= '0' when done else not clk after clk_period / 2;

  process
    variable l : line;
  begin
    wait until o_strobe'event;
    if o_strobe = '1' then
      write( l, string'( "o_out: " ) );
      write( l, o_out );
      write( l, string'( ",  " ) );
      write( l, integer'image( to_integer( unsigned( o_out ) ) ) );
      writeline( output, l );
    end if;
  end process;
  
--    process( tos, nos )
--        variable l : line;
--    begin
--        if tos'event or nos'event then
--            write( l, string'( "tos: " ) );
--            write( l, tos );
--            writeline( output, l );
--            write( l, string'( "nos: " ) );
--            write( l, nos );
--            writeline( output, l );
--            write( l, string'( "" ) );
--            writeline( output, l );            
--        end if;
--    end process;
  
  -- Stimulus process
  stim_proc: process
  begin		
    -- hold reset state for 100 ns.
    rst_n <= '0';
    wait for 90 ns;	
    rst_n <= '1';

    
    wait for clk_period*150;

    
    done <= true;
    wait;
  end process;

END;
