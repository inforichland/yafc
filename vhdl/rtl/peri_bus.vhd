-------------------------------------------------------------------------------
-- Title      : peripheral bus
-- Project    : 
-------------------------------------------------------------------------------
-- File       : peri_bus.vhd
-- Author     : Tim Wawrzynczak
-- Company    : 
-- Created    : 2014-07-23
-- Last update: 2014-07-24
-- Platform   : 
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: peripheral / I/O space bus
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-07-23  1.0      TW      Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.common.all;
use work.uart_pkg.all;
use work.gpio_pkg.all;

entity peri_bus is
    port (
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        -- bus signals
        io_addr  : in  address;
        io_write : in  word;
        io_we    : in  std_logic;
        io_read  : out word;
        io_re    : in  std_logic;
        -- pins into and out of peripherals
        pins_in  : in  peri_in_pins_t;
        pins_out : out peri_out_pins_t
        );
end peri_bus;

architecture Behavioral of peri_bus is
    signal io_read_i : word := (others => '0');  -- internal io_read signal

    -- UART
    signal uart_in_pins  : uart_in_pins_t;
    signal uart_out_pins : uart_out_pins_t;
    signal uart_in_regs  : uart_in_regs_t;
    signal uart_out_regs : uart_out_regs_t;
    -- GPIO
    signal gpio_in_pins  : gpio_in_pins_t;
    signal gpio_out_pins : gpio_out_pins_t;
    signal gpio_in_regs  : gpio_in_regs_t;
    signal gpio_out_regs : gpio_out_regs_t;
begin

    ---------------------------------------------------------------------------
    -- Note: All data types with 'in' and 'out' in the name are named from
    -- the point of view of the peripheral.  Those data types flow in and
    -- out of the peripheral, and out and in to the bus.
    ---------------------------------------------------------------------------
    
    ---------------------------------------------------------------------------
    -- Assign inputs & outputs
    ---------------------------------------------------------------------------
    uart_in_pins           <= pins_in.uart_in_pins;
    pins_out.uart_out_pins <= uart_out_pins;
    gpio_in_pins           <= pins_in.gpio_in_pins;
    pins_out.gpio_out_pins <= gpio_out_pins;
    io_read                <= io_read_i;

    -------------------------------------------------------------------------------
    -- UART
    -------------------------------------------------------------------------------

    inst_uart : entity work.uart(Behavioral)
        port map (
            clk      => clk,
            rst_n    => rst_n,
            regs_in  => uart_in_regs,
            regs_out => uart_out_regs,
            pins_in  => uart_in_pins,
            pins_out => uart_out_pins);

    ---------------------------------------------------------------------------
    -- GPIO
    ---------------------------------------------------------------------------

    inst_gpio : entity work.gpio(rtl)
        port map (
            clk      => clk,
            rsT_n    => rst_n,
            regs_in  => gpio_in_regs,
            regs_out => gpio_out_regs,
            pins_in  => gpio_in_pins,
            pins_out => gpio_out_pins);

    ---------------------------------------------------------------------------
    -- Periheral Bus I/O space
    ---------------------------------------------------------------------------

    -- Reads from peripherals
    io_reads : process(io_addr, io_re, uart_out_regs, gpio_out_regs)
    begin
        -- default value
        io_read_i <= (others => '0');

        if io_re = '1' then
            case (io_addr) is

                ----------
                -- UART --
                ----------

                -- TODO: pack these into fewer registers
                when "0000000000000" => io_read_i <= "000000000000000" & uart_out_regs.rx_busy;
                when "0000000000001" => io_read_i <= "000000000000000" & uart_out_regs.tx_busy;
                when "0000000000010" => io_read_i <= "00000000" & uart_out_regs.rx_data;
                when "0000000000011" => io_read_i <= "000000000000000" & uart_out_regs.tx_done;
                when "0000000000100" => io_read_i <= "000000000000000" & uart_out_regs.rx_done;
                when "0000000000101" => io_read_i <= "000000000000000" & uart_out_regs.rx_err;

                ----------
                -- GPIO --
                ----------
                when "0000000010000" => io_read_i <= "000000000000000" & gpio_out_regs.output(0);

                -- Default value
                when others => io_read_i <= (others => '0');
                                        
            end case;  -- io_addr
        end if;  -- io_re = '1'
    end process io_reads;

    -- writes to peripherals
    io_writes : process(clk)
    begin
        if rising_edge(clk) then

            -- reset any registers here that are "self-resetting" (i.e., tx start)
            uart_in_regs.start <= '0';

            -- check the write-enable
            if io_we = '1' then
                case (io_addr) is

                    ----------
                    -- UART --
                    ----------
                    
                    when "0000000000000" => uart_in_regs.start   <= io_write(0);
                    when "0000000000001" => uart_in_regs.tx_data <= io_write(7 downto 0);

                    ----------
                    -- GPIO --
                    ----------

                    when "0000000010000" => gpio_in_regs.input <= io_write;

                    -- Do nothing for other addresses
                    when others          => null;
                                            
                end case;
            end if;  -- io_we = '1'
        end if;  -- rising_edge
    end process io_writes;

end Behavioral;
