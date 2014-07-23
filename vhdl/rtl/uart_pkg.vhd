library IEEE;
use IEEE.STD_LOGIC_1164.all;

package uart_pkg is
  ----------------
  -- Data types --
  ----------------
  
  subtype byte is std_logic_vector( 7 downto 0 );
  
  -------------
  -- Records --
  -------------
  
  -- Input registers to UART
  type uart_in_regs_t is record
    start     : std_logic;
    tx_data   : byte;
  end record;
  
  -- Output registers from UART
  type uart_out_regs_t is record
    rx_busy   : std_logic;
    tx_busy   : std_logic;
    rx_data   : byte;
    tx_done   : std_logic;
    rx_done   : std_logic;
    rx_err    : std_logic;
  end record;
  
  -- Pins in to UART
  type uart_in_pins_t is record
    rx    : std_logic;
  end record;
  
  -- Pins out from UART
  type uart_out_pins_t is record
    tx    : std_logic;
  end record;
  
  ---------------
  -- Constants --
  ---------------
  
  --constant uart_in_regs_reset   : uart_in_regs_t  := ( start      => '0',
  --                                                     tx_data    => ( others => '0' ) );
  
  --constant uart_out_regs_reset  : uart_out_regs_t := ( rx_busy    => '0',
  --                                                     tx_busy    => '0',
  --                                                     rx_data    => ( others => '0' ),
  --                                                     done       => '0',
  --                                                     err        => '0' );
                                                     
end uart_pkg;

package body uart_pkg is
end uart_pkg;
