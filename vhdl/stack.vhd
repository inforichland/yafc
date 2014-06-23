----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:35:50 05/16/2014 
-- Design Name: 
-- Module Name:    stack - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

use work.common.all;

entity stack is
    Port ( clk : in  STD_LOGIC;
           rst_n : in  STD_LOGIC;
			  push : in std_logic;
			  pop : in std_logic;
           din : in  STD_LOGIC_VECTOR (15 downto 0);
           dout : out  STD_LOGIC_VECTOR (15 downto 0);
           full : out  STD_LOGIC;
           empty : out  STD_LOGIC);
end stack;

architecture Behavioral of stack is
	
	-----------
	-- Types --
	-----------	
	subtype index_t is unsigned( 4 downto 0 ); -- range 0 to c_stack_size - 1;
	type regs_t is record
		ptr_wr	:	index_t;
		ptr_rd	:	index_t;
		full		:	std_logic;
		empty		:	std_logic;
	end record;

	---------------
	-- Constants --
	---------------
	constant c_regs_reset : regs_t := ( ptr_wr 	=> ( others => '0' ),
													ptr_rd 	=> to_unsigned( c_stack_size - 1, 5 ),
													full 		=> '0', 
													empty 	=> '1' );
	
	-------------
	-- Signals --
	-------------
	
	-- registers
	signal regs, next_regs : regs_t := c_regs_reset;
	
	-- needed for type conversions (no extra logic)
	signal addr_wr_slv : std_logic_vector( 4 downto 0 ) := "00000";
	signal addr_rd_slv : std_logic_vector( 4 downto 0 ) := "00000";
	
	-- combinational
	signal we : std_logic := '0';
		
begin

	-- assign outputs
	full	<= regs.full;
	empty	<= regs.empty;

	-- instantiate the RAM for our stack
	Inst_dpram : entity work.dpram( rtl )
		generic map( 
            g_data_width => 16,
            g_addr_width => 5,
            g_init => false,
            g_init_file => ""
		)
		port map (
			clk => clk,
			-- write port
			addr_a => addr_wr_slv,
			q_a => open,
			data_a => din,
			we_a => we,
			-- read port
			addr_b => addr_rd_slv,
			q_b => dout,
			data_b => ( others => '0' ),
			we_b => '0'
		);

	-- process to create registers
	regs_proc : process( clk )
	begin
		if rising_edge( clk ) then
			if rst_n = '0' then
				regs <= c_regs_reset;
			else
				regs <= next_regs;
			end if;
		end if;
	end process regs_proc;
	
	-- write-enable
	we <= push and not regs.full;
	addr_rd_slv <= std_logic_vector( regs.ptr_rd );
	addr_wr_slv <= std_logic_vector( regs.ptr_rd ) when ( push = '1' and pop = '1' ) else std_logic_vector( regs.ptr_wr );
	
	-- combinational logic of stack
	comb_proc : process( regs, push, pop )
	begin
		-- default value for registers is to keep old value, except for write enable
		next_regs <= regs;
		
		-- when full, ignore pushes
		-- when empty, ignore pops
		if push = '1' then
			if pop = '0' then
				if regs.full = '0' then
					next_regs.ptr_wr <= regs.ptr_wr + 1;
					next_regs.ptr_rd <= regs.ptr_wr;
					
					-- can't be empty if we're pushing
					next_regs.empty <= '0';
					
					-- will it be full after this push?
					if regs.ptr_wr = ( c_stack_size - 1 ) then
						next_regs.full <= '1';
						next_regs.ptr_wr <= regs.ptr_wr;
					else
						next_regs.full <= '0';
					end if;
				end if;
			end if;
		elsif pop = '1' then
			if regs.empty = '0' then
				next_regs.ptr_rd <= regs.ptr_rd - 1;
				next_regs.ptr_wr <= regs.ptr_rd;
				
				-- can't be full if we're popping
				next_regs.full <= '0';
				
				-- will it be empty after this pop?
				if regs.ptr_rd = 0 then
					next_regs.empty <= '1';
					next_regs.ptr_rd <= regs.ptr_rd;
				else
					next_regs.empty <= '0';
				end if;
			end if;
		end if;
		
	end process comb_proc;

end Behavioral;
