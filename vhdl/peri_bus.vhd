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
    
    -- UART
    uart_in_regs  : out uart_in_ctrl;
    uart_out_regs : in uart_out_ctrl;
    
  );
end peri_bus;

architecture Behavioral of peri_bus is

begin


end Behavioral;

