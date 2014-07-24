-------------------------------------------------------------------------------
-- Title      : GPIO Controller
-- Project    : YAFC
-------------------------------------------------------------------------------
-- File       : gpio.vhd
-- Author     : Tim Wawrzynczak
-- Company    : 
-- Created    : 2014-07-24
-- Last update: 2014-07-24
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: General-purpose I/O controller
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-07-24  1.0      TW      Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.common.all;
use work.gpio_pkg.all;

entity gpio is
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        regs_in  : in  gpio_in_regs_t;
        regs_out : out gpio_out_regs_t;
        pins_in  : in  gpio_in_pins_t;
        pins_out : out gpio_out_pins_t
        );
end gpio;

architecture rtl of gpio is
    signal regs_i : gpio_in_regs_t;
    signal regs_o : gpio_out_regs_t;
    signal pins_i : gpio_in_pins_t;
    signal pins_o : gpio_out_pins_t;

    signal synced : word := (others => '0');
begin

    ---------------------------------------------------------------------------
    -- Assign inputs and outputs
    ---------------------------------------------------------------------------

    pins_out.output <= regs_in.input;
    regs_out.output <= synced;

    -- synchronize inputs to this clock domain
    input_synchronizers : for i in word'range generate
        sync : entity work.synchronizer(rtl)
            port map (
                clk   => clk,
                rst_n => rst_n,
                ain   => pins_in.input(i),
                sout  => synced(i));
    end generate input_synchronizers;

end architecture rtl;
