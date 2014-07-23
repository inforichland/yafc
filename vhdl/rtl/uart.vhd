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
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        regs_in  : in  uart_in_regs_t;
        regs_out : out uart_out_regs_t;
        pins_in  : in  uart_in_pins_t;
        pins_out : out uart_out_pins_t
        );
end uart;

architecture Behavioral of uart is
    signal in_regs  : uart_in_regs_t;
    signal out_regs : uart_out_regs_t;
    signal pins_i   : uart_in_pins_t;
    signal pins_o   : uart_out_pins_t;

    signal rx_din, rx_busy, rx_err, rx_done       : std_logic := '0';  -- RX signals
    signal tx_new_data, tx_dout, tx_busy, tx_done : std_logic := '0';  -- TX signals
    signal rx_dout, tx_din                        : byte      := (others => '0');  -- byte-wide signals
begin

    ---------------------------------------------------------------------------
    -- Assign inputs & outputs
    ---------------------------------------------------------------------------

    -- inputs
    tx_new_data <= regs_in.start;
    tx_din      <= regs_in.tx_data;

    -- outputs
    regs_out.rx_busy <= rx_busy;
    regs_out.tx_busy <= tx_busy;
    regs_out.rx_data <= rx_dout;
    regs_out.tx_done <= tx_done;
    regs_out.rx_done <= rx_done;
    regs_out.rx_err  <= rx_err;

    -- input pins
    rx_din      <= pins_in.rx;

    -- output pins
    pins_out.tx <= tx_dout;

    ---------------------------------------------------------------------------
    -- Receive side
    ---------------------------------------------------------------------------
    rx_inst : entity work.uart_rx(Behavioral)
        port map (
            clk   => clk,
            rst_n => rst_n,
            din   => rx_din,
            dout  => rx_dout,
            busy  => rx_busy,
            err   => rx_err,
            done  => rx_done
            );

    ---------------------------------------------------------------------------
    -- Transmitter
    ---------------------------------------------------------------------------
    tx_inst : entity work.uart_tx(Behavioral)
        port map (
            clk      => clk,
            new_data => tx_new_data,
            din      => tx_din,
            dout     => tx_dout,
            busy     => tx_busy,
            done     => tx_done
            );

end Behavioral;
