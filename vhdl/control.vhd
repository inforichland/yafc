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
use ieee.numeric_std.all;

use work.common.all;
use work.opcodes.all;

entity control is
  port (
    -- entity control
    clk         : in   std_logic;
    rst_n       : in   std_logic;
    -- input control
    alu_results   : in  alu_results_t;
    dtos          : in  word;
    dnos          : in  word;
    rtos          : in  word;
    mem_read      : in  word;
    insn          : in  word;
    pc            : in  address;
    -- output control signals
    
    -- data stack
    dpush      : out std_logic;
    dpop       : out std_logic;
    dtos_sel   : out std_logic_vector( 1 downto 0 );
    dnos_sel   : out std_logic_vector( 1 downto 0 );
    dtos_in    : out word;
    dnos_in    : out word;
    dstk_sel   : out std_logic;
    -- return stack
    rpush      : out std_logic;
    rpop       : out std_logic;
    rtos_sel   : out std_logic;
    rtos_in    : out word;
    -- program counter
    pc_inc     : out std_logic;
    pc_load    : out std_logic;
    pc_next    : out address;
    -- output port
    o_strobe   : out   std_logic;
    o_out      : out   word;
    -- RAM
    mem_addr   : out address;
    mem_write  : out word;
    mem_we     : out std_logic
    );
end control;

architecture Behavioral of control is
  -- internal output signals
  signal o_out_i : word := ( others => '0' );
  signal o_strobe_i : std_logic := '0';
  signal stall, stall_i : std_logic := '1';
begin
  
  -- create registers for o_out and o_strobe
  output_regs : process( clk, rst_n )
  begin
    if rst_n = '0' then
      o_strobe <= '0';
      stall   <= '1';
    elsif rising_edge( clk ) then
      o_out <= o_out_i;
      o_strobe <= o_strobe_i;
      stall <= stall_i;
    end if;
  end process output_regs;

  -- instruction decoding
  decode : process( insn, alu_results, dtos, dnos, rtos, mem_read, pc, stall )
    procedure pop_dstack is
    begin
      dtos_sel <= "01";
      dnos_sel <= "10";
      dpop <= '1';
    end procedure pop_dstack;

    variable mcode : mcode;
    variable fcode : fcode;
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
    stall_i     <= '0';
	 
    -- grab the major code and function code
    mcode := insn( 14 downto 13 );
    fcode := insn( 12 downto 8 );
    
    -- stalling or executing?
    if stall = '1' then
      stall_i   <= '0'; -- only ever need one cycle of stalling right now
    else
      -- decode the instruction
      if insn( insn'high ) = '1' then -- literal
        dtos_in  <= insn( insn'high-1 ) & insn( insn'high-1 downto 0 ); -- sign-extend the literal by 1 bit
        dtos_sel <= "11";
        dnos_sel <= "01";
        dpush    <= '1';
        -- if it's a new literal that's going on the stack, it could be an address to read from memory
        mem_addr <= insn( 12 downto 0 );
      else
        -- otherwise the memory address to use will come from the top of the D stack
        mem_addr <= dtos( 12 downto 0 );
        
        -- which major code is this instruction?
        case mcode is
        
          when m_jump =>  -- unconditional jump
            pc_load    <= '1';
            pc_next    <= insn( 12 downto 0 );
            stall_i      <= '1';
          
          when m_0bra =>  -- conditional jump (0branch)
            if dtos = "0000000000000000" then
              pc_load    <= '1';
              pc_next    <= insn( 12 downto 0 );
              stall_i      <= '1';
            end if;
            pop_dstack;
          
          when m_call =>  -- call a word
            pc_load     <= '1';
            pc_next     <= insn( 12 downto 0 );
            
            rtos_in     <= "000" & pc;
            rpush       <= '1';

            stall_i       <= '1';
          
          -- function
          when m_func =>
        
            -- execute the function
            case fcode is
              when f_add =>   -- add
                dtos_in    <= alu_results.add_result;
                dtos_sel    <= "11";
                dnos_sel    <= "10";
                dpop       <= '1';
              
              when f_sub =>   -- subtract
                dtos_in    <= alu_results.sub_result;
                dtos_sel    <= "11";
                dnos_sel    <= "10";
                dpop       <= '1';   
              
              when f_out =>   -- output TOS (non-destructively)
                o_out_i      <= dtos;
                o_strobe_i    <= '1';
              
              when f_sla =>   -- arithmetic left shift
                dtos_in    <= alu_results.sll_result;
                dtos_sel    <= "11";
                dnos_sel    <= "10";
                dpop       <= '1';
              
              when f_sra =>   -- arithmetic right shift
                dtos_in    <= alu_results.srl_result;
                dtos_sel    <= "11";
                dnos_sel    <= "10";
                dpop       <= '1';
              
              when f_dup =>  -- dup
                dtos_sel    <= "00";
                dnos_sel    <= "01";
                dstk_sel    <= '0';
                dpush       <= '1';
              
              when f_not =>  -- not
                dtos_sel    <= "11";
                dtos_in    <= not dtos;
              
              when f_ftc =>   -- fetch   @
                dtos_in    <= mem_read;
                dtos_sel   <= "11";
                          
              when f_dtr =>   -- >R   "to R"
                rpush     <= '1';
                rtos_in   <= dtos;
                dtos_sel  <= "01";
                dnos_sel  <= "10";
                dpop      <= '1'; 
              
              when f_str =>   -- store   !
                mem_addr  <= dtos( 12 downto 0 );
                mem_write <= dnos;
                mem_we    <= '1';
              
                pop_dstack;
              
              when f_pop =>   -- drop
                pop_dstack;
              
              when f_rtd =>    -- R>  "from R"
                rtos_sel  <= '1';
                rpop      <= '1';
                dtos_in   <= rtos;
                dtos_sel  <= "11";
                dnos_sel  <= "01";
                dpush     <= '1';   
              
              when f_rot =>	-- rot ( a b c -- b c a )
                dtos_sel  <= "10";
                dnos_sel  <= "01";
                dpush     <= '1';
                dpop      <= '1';
              
              when f_nrt =>	-- -rot ( a b c -- c b a )
                dtos_sel  <= "01";
                dnos_sel  <= "10";
                dstk_sel  <= '1';
                dpush     <= '1';
                dpop      <= '1';
              
              when f_swp =>	-- swap ( a b -- b a )
                dtos_sel  <= "01";
                dnos_sel  <= "01";
              
              when f_nip =>	-- nip	( a b c -- a c )
                dtos_sel  <= "00";
                dnos_sel  <= "10";
                dpop      <= '1';
              
              when f_tck => 	-- tuck	( a b -- b a b )
                dtos_sel  <= "00";
                dnos_sel  <= "00";
                dstk_sel  <= '1';
                dpush     <= '1';
              
              when f_ovr =>	-- over	( a b -- a b a )
                dtos_sel  <= "01";
                dnos_sel  <= "01";
                dpush     <= '1';
                
              when f_equ => -- = ( a b -- t/f )
                dtos_in    <= alu_results.eq_result;
                dtos_sel    <= "11";
                dnos_sel    <= "10";
                dpop       <= '1';
              
              when others =>  -- NOP
                null;
            end case; -- case( fcode )
        
            ------------------------
            -- check for subcodes --
            ------------------------
            
            -- ret (return from word)
            if insn( s_ret ) = '1' then
              rtos_sel  <= '1';
              rpop      <= '1';
              
              pc_load   <= '1';
              pc_next   <= rtos( pc_next'high downto 0 );
              stall_i   <= '1';
            end if;
        
          when others => 
            null;
        end case; -- case( mcode )
      end if; -- insn( insn'high ) = 0
    end if; -- if stall
  end process decode;
end Behavioral;
