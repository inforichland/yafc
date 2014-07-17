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
    uart_in       : in uart_in_ctrl;
    uart_out      : out uart_out_ctrl
  );
end uart;

architecture Behavioral of uart is

begin


end Behavioral;
