library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common.all;

entity yafc is
  port 
    (
      clk         : in std_logic;
      rst_in      : in std_logic;
      o_out       : out word;
      o_strobe    : out std_logic;
      o_debug_1   : out word;
      o_debug_2   : out word;
      o_debug_3   : out word;
      o_debug_4   : out word
      );

end entity;

architecture structural of yafc is
  -- program counter signals
  signal pc_inc, pc_load  : std_logic := '0';
  signal pc               : address := ( others => '0' );
  signal pc_next          : address;
  signal insn             : word := ( others => '0' );
  
  -- RAM signals
  signal mem_addr             : address := ( others => '0' );
  signal mem_write, mem_read  : word := ( others => '0' );
  signal mem_we, mem_re       : std_logic := '0';

  -- data stack signals
  signal dpush, dpop        : std_logic := '0';
  signal dtos_sel, dnos_sel : std_logic_vector( 1 downto 0 ) := "00";
  signal dtos_in, dnos_in   : word := ( others => '0' );
  signal dstk_sel           : std_logic := '0';
  signal dtos, dnos         : word := ( others => '0' );

  -- return stack
  signal rpush, rpop  : std_logic := '0';
  signal rtos_sel     : std_logic := '0';
  signal rtos_in      : word := ( others => '0' );
  signal rtos         : word := ( others => '0' );

  -- logic of ALU
  signal alu_results : alu_results_t := ( others => ( others => '0') );
  
  -- Reset
  signal rst_n : std_logic := '0';
begin

  ----------------------------------------------------------------------
  -- TODO:
  --  - Switch to Harvard arch (?)
  --  - Add I/O (peripheral) bus
  --  - Add interrupts
  --  - Make assembler better
  --  - Implement Forth! :-)
  ----------------------------------------------------------------------

  -- debug outputs
  o_debug_1 <= dtos;
  o_debug_2 <= dnos;
  o_debug_3 <= "000" & pc;
  o_debug_4 <= insn;

  -- async assert, sync deassert
  --reset_conditioner : entity work.reset( Behavioral )
  --  port map (
  --    clk => clk,
  --    rst_i => rst_in,
  --    rst_o => rst_n
  --    );

  rst_n <= rst_in;

  -- main controller
  controller : entity work.control( Behavioral )
    port map (
      clk			  => clk,
      rst_n			=> rst_n,
      -- input to controller
      alu_results	=> alu_results,     -- ALU
      dtos			=> dtos,        -- Data Top-of-Stack
      dnos      => dnos,        -- Data Next-on-Stack
      rtos			=> rtos,        -- Return Top-of-Stack
      mem_read	=> mem_read,    -- memory read bus
      insn			=> insn,        -- instruction,
      pc        => pc,           -- PC
      
      -- data stack
      dpush			=> dpush,
      dpop			=> dpop,
      dtos_sel  => dtos_sel,
      dnos_sel	=> dnos_sel,
      dtos_in		=> dtos_in,
      dnos_in		=> dnos_in,
      dstk_sel	=> dstk_sel,
      
      -- return stack
      rpush			=> rpush,
      rpop			=> rpop,
      rtos_sel	=> rtos_sel,
      rtos_in		=> rtos_in,
      
      -- PC     
      pc_inc		=> pc_inc,
      pc_load		=> pc_load,
      pc_next		=> pc_next,
      
      -- I/O bus
      o_strobe	=> o_strobe,
      o_out			=> o_out,
      
      -- Memory bus
      mem_addr	=> mem_addr,
      mem_write	=> mem_write,
      mem_we		=> mem_we
    );
  
  -- ALU
  inst_alu : entity work.alu( Behavioral )
    port map (
      tos     => dtos,
      nos     => dnos,
      results => alu_results
    );

  -- program counter
  prog_cntr : entity work.up_counter( rtl )
    generic map (
	   g_width => c_address_width,
      g_reset_value => "0000000000000"
	  )
    port map (
      clk     => clk,
      rst_n   => rst_n,
      inc     => pc_inc,
      load    => pc_load,
      d       => pc_next,
      q       => pc
    );
  
  -- Dual-Port RAM
  --  contains instructions and working memory
  ram : entity work.dpram( rtl )
    generic map (
      g_data_width  => 16,
      g_addr_width  => 13,
      g_init        => true,
      g_init_file   => "..\examples\loop.init"
    )
    port map (
      clk     => clk,
      -- instruction port
      data_a  => ( others => '0' ),
      addr_a  => pc,
      we_a    => '0',
      q_a     => insn,
      -- working memory
      addr_b  => mem_addr,
      data_b  => mem_write,
      we_b    => mem_we,
      q_b     => mem_read
    );
  
  -- the stack
  dstack : entity work.data_stack( Behavioral )
    port map(
      clk     => clk,
      rst_n   => rst_n,
      push    => dpush,
      pop     => dpop,
      tos_sel => dtos_sel,
      tos_in  => dtos_in,
      nos_sel => dnos_sel,
      nos_in  => dnos_in,
      stk_sel => dstk_sel,
      tos     => dtos,
      nos     => dnos,
      ros     => open
    );
  
  -- Return stack
  rstack : entity work.return_stack( Behavioral )
    port map(
      clk 		=> clk,
      rst_n		=> rst_n,
      push		=> rpush,
      pop		=> rpop,
      tos_sel	=> rtos_sel,
      tos_in	=> rtos_in,
      tos		=> rtos
    );
  
end structural;
