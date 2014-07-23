----------------------------------------------------------------------------------
-- Engineer: Tim Wawrzynczak
-- 
-- Design Name: Return Stack
-- Module Name: return_stack - Behavioral 
-- Project Name: YAFC
-- Target Devices: Xilinx Spartan-6
-- Tool versions: ISE 14.7
-- Description: Return Stack module for a Forth CPU
--
-- Dependencies: stack.vhd
--
-- Additional Comments: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.common.all;

entity return_stack is
    port (
        clk     : in  std_logic;
        rst_n   : in  std_logic;
        push    : in  std_logic;
        pop     : in  std_logic;
        tos_in  : in  word;
        tos_sel : in  std_logic;
        tos     : out word              -- Top-Of-Stack
        );
end return_stack;

architecture Behavioral of return_stack is
    signal tos_i, next_tos : word      := (others => '0');
    signal stack_dout      : word      := (others => '0');
    signal stack_din       : word      := (others => '0');
begin

    -- assign outputs
    tos <= tos_i;

    -- create registers
    regs_proc : process(clk)
    begin
        if rising_edge(clk) then
            if rst_n = '0' then
                tos_i <= (others => '0');
            else
                tos_i <= next_tos;
            end if;
        end if;
    end process regs_proc;

    -- the formal stack itself
    Inst_stack : entity work.stack(Behavioral)
        PORT MAP(
            clk   => clk,
            rst_n => rst_n,
            push  => push,
            pop   => pop,
            din   => stack_din,
            dout  => stack_dout,
            full  => open,
            empty => open
            );

    -- the only input to the stack is the TOS register
    stack_din <= tos_i;

    -- combinational logic
    comb_proc : process(tos_i, tos_in, tos_sel, stack_dout)
    begin
        -- defaults
        next_tos <= tos_i;

        if tos_sel = '0' then
            next_tos <= tos_in;
        else
            next_tos <= stack_dout;
        end if;
    end process comb_proc;

end Behavioral;
