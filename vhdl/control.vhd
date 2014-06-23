----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:42:42 06/22/2014 
-- Design Name: 
-- Module Name:    control - Behavioral 
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
use work.opcodes.all;

entity control is
  port (
    -- entity control
    clk			: in	std_logic;
    rst_n 		: in	std_logic;
    -- input control
    alu_results	: in 	alu_results_t;
    tos			: in	word;
    mem_read		: in	word;
    insn			: in	word;
    state			: in	state_t;
    -- output control signals
    push			: out	std_logic;
    pop			: out std_logic;
    tos_sel		: out std_logic_vector( 1 downto 0 );
    nos_sel		: out std_logic_vector( 1 downto 0 );
    tos_in		: out word;
    nos_in		: out	word;
    stk_sel		: out std_logic;
    pc_inc		: out std_logic;
    pc_load		: out std_logic;
    pc_next		: out std_logic_vector( 9 downto 0 );
    o_strobe		: out	std_logic;
    o_out			: out	word;
    mem_addr		: out	std_logic_vector( 9 downto 0 );
    mem_write	: out word;
    mem_we		: out std_logic;
    next_state	: out state_t
    );
end control;
architecture Behavioral of control is

  -- internal output signals
  signal o_out_i : word := ( others => '0' );
  signal o_strobe_i : std_logic := '0';
  
  signal icode_stalled : fcode;
begin
  -- state register
  state_proc : process( clk )
  begin
    if rising_edge( clk ) then
      icode_stalled <= insn( 14 downto 11 );
    end if;
  end process state_proc;
  
  -- create registers for o_out and o_strobe
  output_regs : process( clk, rst_n )
  begin
    if rst_n = '0' then
      o_strobe <= '0';
    elsif rising_edge( clk ) then
      o_out <= o_out_i;
      o_strobe <= o_strobe_i;
    end if;
  end process output_regs;

  -- instruction decoding
  decode : process( insn, alu_results, tos, mem_read, state, icode_stalled )
    variable icode : fcode;
  begin
    -- default values
    push        <= '0'; 
    pop         <= '0';
    tos_sel     <= "00"; 
    nos_sel     <= "00";
    tos_in      <= ( others => '0' );
    nos_in      <= ( others => '0' );
    stk_sel     <= '0';
    pc_inc      <= '1';
    pc_load     <= '0';
    pc_next     <= ( others => '0' );
    o_strobe_i  <= '0';
    o_out_i     <= ( others => '0' );
    mem_addr    <= ( others => '0' );
    mem_write   <= ( others => '0' );
    mem_we      <= '0';
    next_state  <= st_execute;
    
    -- grab the instruction code
    icode := insn( 14 downto 11 );
    
    case( state ) is
      -- have to use instruction register in this state
      when st_stall =>
        -- right now, there is only ever one cycle to stall 
        next_state <= st_execute;
    
        -- load (second step)
        if icode_stalled = "1011" then -- load
          tos_in 	<= mem_read;
          tos_sel 	<= "11";
          nos_sel 	<= "01";
          push 		<= '1';
        end if;
    
      when st_execute =>
    
    -- decode the instruction
    if insn( insn'high ) = '1' then -- literal
      tos_in <= insn( 14 ) & insn( 14 downto 0 ); -- sign-extend the 15-bit literal to 16 bits
      tos_sel <= "11";
      nos_sel <= "01";
      push <= '1';
    else	 
      case icode is
        when f_add =>   -- add  0001
          tos_in 	<= alu_results.add_result;
          tos_sel 	<= "11";
          nos_sel 	<= "10";
          pop 		<= '1';
          
        when f_sub =>   -- subtract  0010
          tos_in 	<= alu_results.sub_result;
          tos_sel 	<= "11";
          nos_sel 	<= "10";
          pop 		<= '1';
          
        when f_out =>   -- output TOS (non-destructively)  0011
          o_out_i		<= tos;
          o_strobe_i 	<= '1';
          
        when f_jmp =>   -- unconditional jump  0100
          pc_load 	<= '1';
          pc_next 	<= insn( 9 downto 0 );
          next_state	<= st_stall;
          
        when f_sla =>   -- arithmetic left shift  0101
          tos_in 	<= alu_results.sll_result;
          tos_sel 	<= "11";
          nos_sel 	<= "10";
          pop 		<= '1';
          
        when f_sra =>   -- arithmetic right shift  0110
          tos_in 	<= alu_results.srl_result;
          tos_sel 	<= "11";
          nos_sel 	<= "10";
          pop 		<= '1';
          
        when f_0br =>   -- conditional jump (0branch)  0111
          if tos = "0000000000000000" then
            pc_load 	<= '1';
            pc_next 	<= insn( 9 downto 0 );
            
            pc_inc <= '0';
            next_state	<= st_stall;
          end if;
                    tos_sel  <= "01";
          nos_sel  <= "10";
          pop 		<= '1';
          
        when f_dup =>  -- dup  1000
          tos_sel 	<= "00";
          nos_sel 	<= "01";
          stk_sel 	<= '0';
          push 		<= '1';
          
        when f_not =>  -- not  1001
          tos_sel 	<= "11";
          tos_in 	<= not tos;
          
        when f_1br =>  -- conditional jump (1branch) (branch if TOS not 0)  1010
          if tos /= "0000000000000000" then
            pc_load 	<= '1';
            pc_next 	<= insn( 9 downto 0 );
            
            pc_inc   <= '0';
            next_state	<= st_stall;
          end if;
          
          tos_sel 	<= "01";
          nos_sel 	<= "10";
          pop 		<= '1';
          
        when f_lds =>	-- load  1011
          mem_addr		<= insn( 9 downto 0 );
          pc_inc 		<= '0';
          next_state 	<= st_stall;
          
          --when "1101" =>	-- nop
          
          
        when f_put =>	-- put
          mem_addr		<= insn( 9 downto 0 );
          mem_write	<= tos;
          mem_we		<= '1';
          
          tos_sel <= "01";
          nos_sel <= "10";
          pop 			<= '1';
          pc_inc		<= '0';
          next_state <= st_stall;
          
        when f_pop =>	-- drop
          tos_sel <= "01";
          nos_sel <= "10";
          pop <= '1';
          
        when others =>  -- NOP
          null;
      end case; --case(icode)
    end if; -- insn(insn'high)=0
  end case; -- case(state)
  
end process decode;
end Behavioral;
