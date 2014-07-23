----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:18:51 07/16/2014 
-- Design Name: 
-- Module Name:    peri_bus - Behavioral 
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

entity peri_bus is
  port (
    -- control signals
    io_addr       : in address;
    io_write      : in word;
    io_we         : in std_logic;
    io_read       : out word;
    io_re         : in std_logic;
    pins          : out peri_pins_t
  );
end peri_bus;

architecture Behavioral of peri_bus is
    
begin

    --------------------
    -- Assign outputs --
    --------------------



    ----------
    -- UART --
    ----------
  
    inst_uart : entity work.uart( Behavioral ) 
    port map (
        clk       => clk,
        rst_n     => rst_n,
        regs_in   => uart_regs_in,
        regs_out  => uart_regs_out,
        pins_in   => uart_pins_in,
        pins_out  => uart_pins_out
    );

    -- I/O space reads
    io_reads : process( io_re, io_addr, uart_out_regs )
    begin
        if io_re = '1' then
            case( io_addr ) is
        
                ----------
                -- UART --
                ----------
                when "0000000000000" => io_read     <= "000000000000000" & uart_out_regs.rx_busy;
                when "0000000000001" => io_read     <= "000000000000000" & uart_out_regs.tx_busy;
                when "0000000000010" => io_read     <= "00000000" & uart_out_regs.rx_data;
                when "0000000000011" => io_read     <= "000000000000000" & uart_out_regs.tx_done;
                when "0000000000100" => io_read     <= "000000000000000" & uart_out_regs.rx_done;
                when "0000000000101" => io_read     <= "000000000000000" & uart_out_regs.rx_err;

                -------------------
                -- Default value --
                -------------------
                when others          => io_read   <= ( others => '0' );
          
            end case; -- io_addr
        end if; -- io_re = '1'
    end process io_reads;
  
    -- I/O bus writes
    io_writes : process( clk )
    begin
        if rising_edge( clk ) then
      
            -- reset any registers here that are "self-resetting" (i.e., tx start)
            uart_in_regs.start    <= '0';

            -- check the write-enable
            if io_we = '1' then
                case( io_addr ) of
        
                    ----------
                    -- UART --
                    ----------
          
                    when "000000000000" => uart_in_regs.start     <= io_write( 0 );
                    when "000000000001" => uart_in_regs.tx_data   <= io_write( 7 downto 0 );
        
                end case;
            end if; -- io_we = '1'
        end if; -- rising_edge
    end process io_writes;

end Behavioral;
