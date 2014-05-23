----------------------------------------------------------------------------------
-- Engineer: Tim Wawrzynczak
-- 
-- Design Name:		Control
-- Module Name:		control - Behavioral 
-- Project Name:		YAFC
-- Target Devices:	Xilinx Spartan-6
-- Tool versions:		ISE 14.7
-- Description: 		Control module for 16-bit Forth CPU
--
-- Dependencies: N/A
--
-- Additional Comments: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.common.all;

entity control is
	port( 
		-- control
		clk 		: in  STD_LOGIC;
		rst_n 	: in  STD_LOGIC;
		-- inputs from other modules
		insn 		: in  STD_LOGIC_VECTOR (15 downto 0);
		N1			: in	word;
		N2			: in	word;
		N3			: in	word;
		R			: in	word;
		-- Data stack signals
		dpush		: out std_logic;
		dpop		: out	std_logic;
		dtos_sel	: out	std_logic_vector( 1 downto 0 );
		dtos_in	: out	word;
		dnos_sel	: out	std_logic_vector( 1 downto 0 );
		dnos_in	: out	word;
		dstk_sel	: out	std_logic;
		-- return stack signals
		rpush		: out std_logic;
		rpop		: out	std_logic;
		rtos_in	: out	word;
		rtos_sel	: out	std_logic;
		-- ALU signals
		alu_op	: out	std_logic_vector( 4 downto 0 );
		alu_a		: out	word;
		alu_b		: out	word
	);
end control;

architecture Behavioral of control is
	signal is_lit, is_jmp, is_cjmp, is_call, is_alu : boolean := false;
begin

	is_lit <= insn( 15 ) = '1';
	is_jmp <= insn( 15 downto 13 ) = "000";
	is_cjmp <= insn( 15 downto 13 ) = "001";
	is_call <= insn( 15 downto 13 ) = "010";
	is_alu <= insn( 15 downto 13 ) = "011";
	
	process( is_lit, is_jmp, is_cjmp, is_call, is_alu, insn, N1, N2, N3, R )
	begin
		-- default values for control signals
		dpush 	<= '0';
		dpop 		<= '0';
		dtos_sel	<= "00";
		dtos_in	<= ( others => '0' );
		dnos_sel	<= "00";
		dnos_in 	<= ( others => '0' );
		dstk_sel <= '0';
		rpush 	<= '0';
		rpop		<= '0';
		rtos_in	<= ( others => '0' );
		rtos_sel	<= '0';
		alu_op 	<= ( others => '1' );
		alu_a		<= ( others => '0' );
		alu_b		<= ( others => '0' );
	
		if is_lit then		-- 15-bit literal zero-extended to 16 bits
			dtos_in <= '0' & insn( 14 downto 0 );
			dtos_sel <= "11";
			dnos_sel <= "01";
			dpush <= '1';
		elsif is_jmp then		-- 13-bit address
			-- TODO: control signal to load new PC
		elsif is_cjmp then	-- "0branch" (conditional jump - jump if N1 is 0)
			-- TODO: check status value and maybe load new PC
		elsif is_call then
			-- TODO: push current PC onto stack, load new PC
		elsif is_alu then
			alu_op <= insn( 12 downto 8 );
			alu_a <= N2;		-- next on stack
			alu_b <= N1;		-- top of stack
			if insn( 7 ) = '1' then
				null; -- copy R to PC		(return from subroutine)
			end if;
			if insn( 6 ) = '1' then
				null; -- copy N1 to R		(>R)
			end if;
			if insn( 5 ) = '1' then
				null; -- RAM read     n1 -> [n1] (data in ram at address n1 replaces the top of the stack
			end if;
			if insn( 4 ) = '1' then
				null; -- RAM write     n2 -> [n1] (data in N2 stored into address in N1)
			end if;
			if insn( 3 ) = '1' then
				null; -- I/O read			n1 -> [n1] (data in I/O space at address n1 replaces the top of the stack)
			end if;
			if insn( 2 ) = '1' then
				null;	-- I/O write		n2 -> [n1] (data in n2 placed at address n1 in I/O space)
			end if;
			if insn( 1 ) = '1' then
				null;
			end if;
			if insn( 0 ) = '1' then
				null;
			end if;
		else	 -- NOP
			null;
		end if;
	end process;
		

end Behavioral;
