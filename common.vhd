library IEEE;
use IEEE.STD_LOGIC_1164.all;

package common is
	constant c_word_width : integer := 16;
	constant c_word_msb   : integer := c_word_width - 1;
	constant c_stack_size : integer := 32;

	subtype word is std_logic_vector( c_word_msb downto 0 );
	
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
