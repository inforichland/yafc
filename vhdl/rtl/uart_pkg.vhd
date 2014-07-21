library IEEE;
use IEEE.STD_LOGIC_1164.all;

package uart_pkg is
  -- Data types
  subtype byte is std_logic_vector( 7 downto 0 );
  
  -- Records
  type uart_in_regs_t is record
    start     : std_logic;
    tx_data   : byte;
  end record;
  
  type uart_out_regs_t is record
    rx_busy   : std_logic;
    tx_busy   : std_logic;
    rx_data   : byte;
    done      : std_logic;
    err       : std_logic;
  end record;
  
  type uart_in_pins_t is record
    rx    : std_logic;
  end record;
  
  type uart_out_pins_t is record
    tx    : std_logic;
  end record;
  
  -- Constants
  constant uart_in_regs_reset   : uart_in_regs  := ( start   => '0',
                                                     tx_data => ( others => '0' ) );
  constant uart_out_regs_reset  : uart_out_regs := ( busy  => '0',
                                                     rx_data => ( others => '0' ) );
                                                     
end uart_pkg;

package body uart_pkg is
end uart_pkg;
