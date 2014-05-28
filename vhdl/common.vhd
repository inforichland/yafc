library IEEE;
use IEEE.STD_LOGIC_1164.all;

package common is
	constant c_word_width : integer := 16;
	constant c_word_msb   : integer := c_word_width - 1;
	constant c_stack_size : integer := 32;

	subtype word is std_logic_vector( c_word_msb downto 0 );
	subtype addr is std_logic_vector( 12 downto 0 );
	
	COMPONENT alu
	PORT(
		code : IN std_logic_vector(4 downto 0);
		a : IN std_logic_vector(15 downto 0);
		b : IN std_logic_vector(15 downto 0);          
		c : OUT std_logic_vector(15 downto 0);
		co : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT control
	PORT(
		clk : IN std_logic;
		rst_n : IN std_logic;
		insn : IN std_logic_vector(15 downto 0);
		N1 : IN std_logic_vector(15 downto 0);
		N2 : IN std_logic_vector(15 downto 0);
		N3 : IN std_logic_vector(15 downto 0);
		R : IN std_logic_vector(15 downto 0);
		insn_in : IN std_logic_vector(15 downto 0);
		mem_rd : IN std_logic_vector(15 downto 0);
		io_rd : IN std_logic_vector(15 downto 0);          
		dpush : OUT std_logic;
		dpop : OUT std_logic;
		dtos_sel : OUT std_logic_vector(1 downto 0);
		dtos_in : OUT std_logic_vector(15 downto 0);
		dnos_sel : OUT std_logic_vector(1 downto 0);
		dnos_in : OUT std_logic_vector(15 downto 0);
		dstk_sel : OUT std_logic;
		rpush : OUT std_logic;
		rpop : OUT std_logic;
		rtos_in : OUT std_logic_vector(15 downto 0);
		rtos_sel : OUT std_logic;
		alu_op : OUT std_logic_vector(4 downto 0);
		alu_a : OUT std_logic_vector(15 downto 0);
		alu_b : OUT std_logic_vector(15 downto 0);
		pc_out : OUT std_logic_vector(12 downto 0);
		mem_wr : OUT std_logic_vector(15 downto 0);
		mem_sel : OUT std_logic;
		mem_addr : OUT std_logic_vector(12 downto 0);
		io_wr : OUT std_logic_vector(15 downto 0);
		io_sel : OUT std_logic;
		io_addr : OUT std_logic_vector(12 downto 0)
		);
	END COMPONENT;
	
	COMPONENT data_stack
	PORT(
		clk : IN std_logic;
		rst_n : IN std_logic;
		push : IN std_logic;
		pop : IN std_logic;
		tos_sel : IN std_logic_vector(1 downto 0);
		tos_in : IN std_logic_vector(15 downto 0);
		nos_sel : IN std_logic_vector(1 downto 0);
		nos_in : IN std_logic_vector(15 downto 0);
		stk_sel : IN std_logic;          
		tos : OUT std_logic_vector(15 downto 0);
		nos : OUT std_logic_vector(15 downto 0);
		ros : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	
	COMPONENT dram
	GENERIC(
		depth : integer
		);
	PORT(
		clk : IN std_logic;
		we : IN std_logic;
		addr_wr : IN std_logic_vector(4 downto 0);
		addr_rd : IN std_logic_vector(4 downto 0);
		din : IN std_logic_vector(15 downto 0);          
		dout : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	
	COMPONENT return_stack
	PORT(
		clk : IN std_logic;
		rst_n : IN std_logic;
		push : IN std_logic;
		pop : IN std_logic;
		tos_in : IN std_logic_vector(15 downto 0);
		tos_sel : IN std_logic;          
		tos : OUT std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	
	COMPONENT stack
	PORT(
		clk : IN std_logic;
		rst_n : IN std_logic;
		push : IN std_logic;
		pop : IN std_logic;
		din : IN std_logic_vector(15 downto 0);          
		dout : OUT std_logic_vector(15 downto 0);
		full : OUT std_logic;
		empty : OUT std_logic
		);
	END COMPONENT;
	
end common;

--package body common is
--end common;
