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
    clk         : in   std_logic;
    rst_n       : in   std_logic;
    -- input control
    alu_results   : in    alu_results_t;
    dtos            : in   word;
    rtos            : in    word;
    mem_read      : in   word;
    insn            : in   word;
    state         : in   state_t;
    -- output control signals
    
    -- data stack
    dpush      : out   std_logic;
    dpop         : out std_logic;
    dtos_sel   : out std_logic_vector( 1 downto 0 );
    dnos_sel   : out std_logic_vector( 1 downto 0 );
    dtos_in      : out word;
    dnos_in      : out   word;
    dstk_sel   : out std_logic;
    -- return stack
    rpush      : out std_logic;
    rpop         : out std_logic;
    rtos_sel   : out std_logic;
    rtos_in      : out word;
    -- program counter
    pc_inc      : out std_logic;
    pc_load      : out std_logic;
    pc_next      : out std_logic_vector( 9 downto 0 );
    -- output port
    o_strobe      : out   std_logic;
    o_out         : out   word;
    -- RAM
    mem_addr      : out   std_logic_vector( 9 downto 0 );
    mem_write   : out word;
    mem_we      : out std_logic;
    -- state of the controller
    next_state   : out state_t
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
  decode : process( insn, alu_results, dtos, rtos, mem_read, state, icode_stalled )
    variable icode : fcode;
  begin
    -- default values
    dpush        <= '0'; 
    dpop         <= '0';
    dtos_sel     <= "00"; 
    dnos_sel     <= "00";
    dtos_in      <= ( others => '0' );
    dnos_in      <= ( others => '0' );
    dstk_sel     <= '0';
    rpush       <= '0';
    rpop        <= '0';
    rtos_sel    <= '0';
    rtos_in     <= ( others => '0' );
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
        if icode_stalled = f_lds then -- load
          dtos_in    <= mem_read;
          dtos_sel    <= "11";
          dnos_sel    <= "01";
          dpush       <= '1';
        end if;
    
      when st_execute =>
    
       -- decode the instruction
       if insn( insn'high ) = '1' then -- literal
         dtos_in <= insn( 14 ) & insn( 14 downto 0 ); -- sign-extend the 15-bit literal to 16 bits
         dtos_sel <= "11";
         dnos_sel <= "01";
         dpush <= '1';
       else    
         case icode is
           when f_add =>   -- add  0001
             dtos_in    <= alu_results.add_result;
             dtos_sel    <= "11";
             dnos_sel    <= "10";
             dpop       <= '1';
             
           when f_sub =>   -- subtract  0010
             dtos_in    <= alu_results.sub_result;
             dtos_sel    <= "11";
             dnos_sel    <= "10";
             dpop       <= '1';
             
           when f_out =>   -- output TOS (non-destructively)  0011
             o_out_i      <= dtos;
             o_strobe_i    <= '1';
             
           when f_jmp =>   -- unconditional jump  0100
             pc_load    <= '1';
             pc_next    <= insn( 9 downto 0 );
             next_state   <= st_stall;
             
           when f_sla =>   -- arithmetic left shift  0101
             dtos_in    <= alu_results.sll_result;
             dtos_sel    <= "11";
             dnos_sel    <= "10";
             dpop       <= '1';
             
           when f_sra =>   -- arithmetic right shift  0110
             dtos_in    <= alu_results.srl_result;
             dtos_sel    <= "11";
             dnos_sel    <= "10";
             dpop       <= '1';
             
           when f_0br =>   -- conditional jump (0branch)  0111
             if dtos = "0000000000000000" then
               pc_load    <= '1';
               pc_next    <= insn( 9 downto 0 );
               
               pc_inc <= '0';
               next_state   <= st_stall;
             end if;
             
             dtos_sel  <= "01";
             dnos_sel  <= "10";
             dpop       <= '1';
             
           when f_dup =>  -- dup  1000
             dtos_sel    <= "00";
             dnos_sel    <= "01";
             dstk_sel    <= '0';
             dpush       <= '1';
             
           when f_not =>  -- not  1001
             dtos_sel    <= "11";
             dtos_in    <= not dtos;
             
           when f_1br =>  -- conditional jump (1branch) (branch if TOS not 0)  1010
             if dtos /= "0000000000000000" then
               pc_load    <= '1';
               pc_next    <= insn( 9 downto 0 );
               
               pc_inc   <= '0';
               next_state   <= st_stall;
             end if;
             
             dtos_sel    <= "01";
             dnos_sel    <= "10";
             dpop       <= '1';
             
           when f_lds =>   -- load  1011
             mem_addr   <= insn( 9 downto 0 );
             pc_inc       <= '0';
             next_state <= st_stall;
             
           when f_dtr =>   -- >R
             rpush <= '1';
             rtos_in <= dtos;
             dtos_sel <= "01";
             dnos_sel <= "10";
             dpop <= '1'; 
             
           when f_put =>   -- put   
             mem_addr      <= insn( 9 downto 0 );
             mem_write   <= dtos;
             mem_we      <= '1';
             
             dtos_sel <= "01";
             dnos_sel <= "10";
             dpop          <= '1';
             pc_inc      <= '0';
             next_state <= st_stall;
             
           when f_pop =>   -- drop
             dtos_sel <= "01";
             dnos_sel <= "10";
             dpop <= '1';
           
           when f_rtd =>    -- <R
             rtos_sel   <= '1';
             rpop       <= '1';
             dtos_in    <= rtos;
             dtos_sel    <= "11";
             dnos_sel    <= "01";
             dpush       <= '1';   
           
           when others =>  -- NOP
             null;
             
         end case; --case(icode)
       end if; -- insn(insn'high)=0
     end case; -- case(state)
  
   end process decode;
end Behavioral;
