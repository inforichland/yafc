library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common.all;

entity yafc is
    port 
    (
        clk         : in std_logic;
        rst_n       : in std_logic;
        o_out       : out word;
        o_strobe    : out std_logic;
        o_debug_1   : out word;
        o_debug_2   : out word
    );

end entity;

architecture structural of yafc is
	-- machine state data type
	signal state, next_state : state_t := st_execute;

    -- program counter signals
	signal pc_inc, pc_load : std_logic := '0';
	signal pc : std_logic_vector( 9 downto 0 ) := "0000000000";
	signal pc_next : std_logic_vector( 9 downto 0 );
	signal insn : std_logic_vector( 15 downto 0 ) := ( others => '0' );
    
	-- RAM signals
	signal mem_addr : std_logic_vector( 9 downto 0 ) := ( others => '0' );
	signal mem_write, mem_read : std_logic_vector( 15 downto 0 ) := ( others => '0' );
	signal mem_we, mem_re : std_logic := '0';

	-- stack signals
	signal push, pop : std_logic := '0';
	signal tos_sel, nos_sel : std_logic_vector( 1 downto 0 ) := "00";
	signal tos_in, nos_in : word := ( others => '0' );
	signal stk_sel : std_logic := '0';
	signal tos, nos : word := ( others => '0' );

	-- logic of ALU
	signal alu_results : alu_results_t := ( others => ( others => '0') );
begin

	o_debug_1 <= tos;
	o_debug_2 <= nos;

	-- "ALU" ;-)
	alu_proc : process( tos, nos )
		variable not_shiftable : std_logic;
	begin
			
		not_shiftable := or_vector( tos( 15 downto 4 ) );

		alu_results.add_result <= std_logic_vector( signed( nos ) + signed( tos ) );
		alu_results.sub_result <= std_logic_vector( signed( nos ) - signed( tos ) );

		if not_shiftable = '1' then
			alu_results.sll_result <= ( others => '0' );
			alu_results.srl_result <= ( others => '0' );
		else
			alu_results.sll_result <= std_logic_vector( shift_left( signed( nos ), to_integer( signed( tos ) ) ) );
			alu_results.srl_result <= std_logic_vector( shift_right( signed( nos ), to_integer( signed( tos ) ) ) );
		end if;
    end process alu_proc;

	-- state register
	state_proc : process( clk, rst_n )
	begin
		if rst_n = '0' then
			state <= st_execute;
		elsif rising_edge( clk ) then
			state <= next_state;
		end if;
	end process state_proc;

	-- main controller
	controller : entity work.control( Behavioral )
	port map (
		clk			=> clk,
		rst_n			=> rst_n,
		-- input to controller
		alu_results	=> alu_results,
		tos			=> tos,
		mem_read		=> mem_read,
		insn			=> insn,
		state			=> state,
		-- output control signals
		push			=> push,
		pop			=> pop,
		tos_sel		=> tos_sel,
		nos_sel		=> nos_sel,
		tos_in		=> tos_in,
		nos_in		=> nos_in,
		stk_sel		=> stk_sel,
		pc_inc		=> pc_inc,
		pc_load		=> pc_load,
		pc_next		=> pc_next,
		o_strobe		=> o_strobe,
		o_out			=> o_out,
		mem_addr		=> mem_addr,
		mem_write	=> mem_write,
		mem_we		=> mem_we,
		next_state	=> next_state
	);

	-- program counter
	prog_cntr : entity work.up_counter( rtl )
	generic map (
		WIDTH => 10,
		RESET_VALUE => "0000000000"
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
		g_addr_width  => 10,
		g_init        => true,
		g_init_file   => "C:\Users\Tim\Documents\Source\yafc\examples\loop.init"
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
	data : entity work.data_stack( Behavioral )
	port map(
		clk     => clk,
		rst_n   => rst_n,
		push    => push,
		pop     => pop,
		tos_sel => tos_sel,
		tos_in  => tos_in,
		nos_sel => nos_sel,
		nos_in  => nos_in,
		stk_sel => stk_sel,
		tos     => tos,
		nos     => nos,
		ros     => open
	);
    
end structural;
