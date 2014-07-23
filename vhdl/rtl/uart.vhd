----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:28:35 07/16/2014 
-- Design Name: 
-- Module Name:    uart - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.common.all;
use work.uart_pkg.all;

entity uart is
  port (
    clk           : in std_logic;
    rst_n         : in std_logic;
    regs_in       : in uart_in_regs_t;
    regs_out      : out uart_out_regs_t;
    pins_in       : in uart_in_pins_t;
    pins_out      : out uart_out_pins_t
  );
end uart;

architecture Behavioral of uart is
  signal in_regs  : uart_in_regs_t;
  signal out_regs : uart_out_regs_t;
  signal pins_i   : uart_in_pins_t;
  signal pins_o   : uart_out_pins_t;
begin

  rx_inst : entity work.uart_rx( Behavioral )
  port map (
    clk   => clk,
		din   => rx_din,
		dout  => rx_dout,
		busy  => rx_busy,
		err   => rx_err,
		done  => rx_done
  );

  tx_inst : entity work.uart_tx( Behavioral )
  port map (
    clk       => clk,
		new_data  => tx_new_data,
		din       => tx_din,
		dout      => tx_dout,
		busy      => tx_busy,
		done      => tx_done
  );

end Behavioral;
