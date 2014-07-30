----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:53:29 07/24/2014 
-- Design Name: 
-- Module Name:    top - Behavioral 
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
use ieee.numeric_std.all;

use work.common.all;

entity top is
    Port (clk    : in  STD_LOGIC;
          tx     : out STD_LOGIC;
          rx     : in  STD_LOGIC;
          led    : out STD_LOGIC_VECTOR (7 downto 0);
          switch : in  STD_LOGIC_VECTOR (7 downto 0));
end top;

architecture rtl of top is
    component pll
        port(
            -- Clock in ports
            CLK_IN1  : in  std_logic;
            -- Clock out ports
            CLK_OUT1 : out std_logic;
            -- Status and control signals
            RESET    : in  std_logic;
            LOCKED   : out std_logic
            );
    end component;

    signal rst_n    : std_logic            := '0';  -- start out in reset
    signal rst      : std_logic            := '1';  -- negation of rst_n;
    signal rst_cntr : integer range 0 to 7 := 7;
    signal locked   : std_logic;
    signal clk0     : std_logic;

    signal gpio_in  : word;
    signal gpio_out : word;
begin

    -- purpose: initialize the chip with a small forced reset
    -- type   : sequential
    -- inputs : clk
    -- outputs: rst_n
--    init_reset : process (clk0) is
--    begin  -- process init_reset
--        if rising_edge(clk0) then       -- rising clock edge
--            if rst_cntr = 0 then
--                rst_n <= '1';
--            else
--                rst_cntr <= rst_cntr - 1;
--                rst_n    <= '0';
--            end if;
--        end if;
--    end process init_reset;

    --rst <= not rst_n;

    inst_pll : pll
        port map (
            clk_in1  => clk,
            clk_out1 => clk0,
            reset    => '0',
            locked   => open);

    gpio_in( 7 downto 0 ) <= switch;
    gpio_in( word'high downto 8 ) <= ( others => '0' );

    led <= gpio_out( 7 downto 0 );
    
    -- Instantiate the CPU
    cpu_inst : entity work.yafc(structural)
        port map(
            clk      => clk0,
            rst_in   => '1',
            tx       => tx,
            rx       => rx,
            gpio_in  => gpio_in,
            gpio_out => gpio_out);

end rtl;
