----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:47:30 05/26/2014 
-- Design Name: 
-- Module Name:    cpu - Behavioral 
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

entity cpu is
	port (
		clk				: in	std_logic;
		rst_n				: in	std_logic;
		out0				: out word;
		out1				: out	word
	);
end cpu;

architecture structural of cpu is
	-- data stack signals
	signal dpush : std_logic ;
	signal dpop : std_logic ;
	signal dtos_sel : std_logic_vector( 1 downto 0 ) ;
	signal dtos_in : word ;
	signal dnos_sel : std_logic_vector( 1 downto 0 ) ;
	signal dnos_in : word ;
	signal dstk_sel : std_logic ;
	signal dtos : word ;
	signal dnos : word ;
	--signal dros : word ;
	-- return stack signals
	signal rpush : std_logic;
	signal rpop : std_logic;
	signal rtos_in : word;
	signal rtos_sel : std_logic;
	signal rtos	: word;
	-- ALU signals
	signal alu_op : std_logic_vector( 4 downto 0 );
	signal alu_a : word;
	signal alu_b : word;
	signal alu_c : word;
	signal alu_carryout : std_logic;
	-- program memory
	signal insn : word;
	signal pc_out : addr;
	-- RAM signals
	signal mem_sel : std_logic := '0';
	signal mem_addr : addr;
	signal mem_wr, mem_rd : word;
	-- I/O signals
	signal io_wr : word;
	-- PC signals
	signal pc_en, pc_ld : std_logic := '0';
	signal pc, pc_next : addr := ( others => '0' );
begin

	-- assign outputs
	out0 <= mem_wr;
	out1 <= io_wr;

	-- Program Counter
	process( clk ) 
	begin
		if rising_edge( clk ) then
			if rst_n = '0' then 
				pc <= ( others => '0' );
			elsif pc_en = '1' then
				if pc_ld = '1' then
					pc <= pc_next;
				else 
					pc <= std_logic_vector( unsigned( pc ) + 1 );
				end if;
			end if;
		end if;
	end process; 

	-- program memory ROM
	Inst_prog_mem: prog_mem PORT MAP(
		clk => clk,
		--en => '1',
		addr => pc,
		data => insn
	);
	
	-- working memory (RAM)
	Inst_ram: ram PORT MAP(
		CLK => clk,
		WE => mem_sel,
		EN => '1',
		ADDR => mem_addr,
		DI => mem_wr,
		DO => mem_rd
	);

	-- Arithmetic/Logic Unit
	Inst_alu: alu PORT MAP(
		code	=> alu_op,
		a 		=> alu_a,
		b 		=> alu_b,
		c 		=> alu_c,
		co 	=> open --alu_carryout
	);

	-- main controller / instruction decoder
	Inst_control: control PORT MAP(
		-- program counter
		insn 			=> insn,
		pc_en			=> pc_en,
		pc_ld			=> pc_ld,
		pc_next		=> pc_next,
		-- data stack
		N1 			=> dtos,
		N2 			=> dnos,
		R 				=> rtos,
		dpush 		=> dpush,
		dpop 			=> dpop,
		dtos_sel 	=> dtos_sel,
		dtos_in 		=> dtos_in,
		dnos_sel 	=> dnos_sel,
		dnos_in 		=> dnos_in,
		dstk_sel 	=> dstk_sel,
		-- return stack
		rpush 		=> rpush,
		rpop 			=> rpop,
		rtos_in 		=> rtos_in,
		rtos_sel 	=> rtos_sel,
		-- ALU
		alu_op 		=> alu_op,
		alu_a 		=> alu_a,
		alu_b 		=> alu_b,
		alu_in		=> alu_c,
		-- RAM
		mem_rd 		=> mem_rd,
		mem_wr 		=> mem_wr,
		mem_sel 		=> mem_sel,
		mem_addr 	=> mem_addr,
		-- I/O space
		io_rd 		=> ( others => '0' ),
		io_wr 		=> io_wr,
		io_sel 		=> open,
		io_addr 		=> open
	);

	-- Data stack
	Inst_data_stack: data_stack PORT MAP(
		clk 		=> clk,
		rst_n 	=> rst_n,
		push 		=> dpush,
		pop 		=> dpop,
		tos_sel 	=> dtos_sel,
		tos_in 	=> dtos_in,
		nos_sel 	=> dnos_sel,
		nos_in 	=> dnos_in,
		stk_sel 	=> dstk_sel,
		tos 		=> dtos,
		nos 		=> dnos,
		ros 		=> open --dros
	);

	-- Return stack
	Inst_return_stack: return_stack PORT MAP(
		clk 		=> clk,
		rst_n 	=> rst_n,
		push 		=> rpush,
		pop 		=> rpop,
		tos_in 	=> rtos_in,
		tos_sel 	=> rtos_sel,
		tos 		=> rtos
	);

end structural;
