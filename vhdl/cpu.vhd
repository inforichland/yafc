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

use work.common.all;

entity cpu is
	port (
		clk				: in	std_logic;
		rst_n				: in	std_logic
	);
end cpu;

architecture Behavioral of cpu is
	-- data stack signals
	signal dpush : std_logic ;
	signal dpop : std_logic ;
	signal dtos_sel : std_logic ;
	signal dtos_in : std_logic ;
	signal dnos_sel : std_logic ;
	signal dnos_in : std_logic ;
	signal dstk_sel : std_logic ;
	signal dtos : word ;
	signal dnos : word ;
	signal dros : word ;
	-- return stack signals
	signal rpush : std_logic;
	signal rpop : std_logic;
	signal rtos_in : word;
	signal rtos_sel : std_logic;
	signal alu_op : std_logic_vector( 6 downto 0 );
	signal alu_a : word;
	signal alu_b : word;
	signal alu_c : word;
	signal alu_carryout : word;
begin

--	Inst_alu: alu PORT MAP(
		code => alu_op,
		a => alu_a,
		b => alu_b,
		c => alu_c,
		co => alu_carryout
	);

--Inst_control: control PORT MAP(
--		clk => ,
--		rst_n => ,
--		insn => ,
--		N1 => ,
--		N2 => ,
--		N3 => ,
--		R => ,
		dpush => dpush,
		dpop => dpop,
		dtos_sel => dtos_sel,
		dtos_in => dtos_in,
		dnos_sel => dnos_sel,
		dnos_in => dnos_in,
		dstk_sel => dstk_sel,
		rpush => rpush,
		rpop => rpop,
		rtos_in => rtos_in,
		rtos_sel => rtos_sel,
		alu_op => alu_op,
		alu_a => alu_a,
		alu_b => alu_b,
--		pc_out => ,
--		insn_in => ,
--		mem_rd => ,
--		mem_wr => ,
--		mem_sel => ,
--		mem_addr => ,
--		io_rd => ,
--		io_wr => ,
--		io_sel => ,
--		io_addr => 
--	);

--	Inst_data_stack: data_stack PORT MAP(
--		clk => ,
--		rst_n => ,
--		push => ,
--		pop => ,
--		tos_sel => ,
--		tos_in => ,
--		nos_sel => ,
--		nos_in => ,
--		stk_sel => ,
--		tos => ,
--		nos => ,
--		ros => 
--	);

--	Inst_return_stack: return_stack PORT MAP(
--		clk => ,
--		rst_n => ,
--		push => ,
--		pop => ,
--		tos_in => ,
--		tos_sel => ,
--		tos => 
--	);

end Behavioral;

