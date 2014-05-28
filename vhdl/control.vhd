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
use ieee.numeric_std.all;

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
		alu_b		: out	word;
		-- CPU busses
		pc_out	: out	std_logic_vector( 12 downto 0 );
		insn_in	: in	word;
		mem_rd	: in	word;
		mem_wr	: out	word;
		mem_sel	: out	std_logic;
		mem_addr	: out	addr;
		io_rd		: in	word;
		io_wr		: out	word;
		io_sel	: out	std_logic;
		io_addr	: out	addr		
	);
end control;

architecture Behavioral of control is
	signal is_lit, is_jmp, is_cjmp, is_call, is_alu : boolean := false;
	
	signal pc, next_pc : std_logic_vector( 12 downto 0 ) := ( others => '0' );
	signal pc_load : std_logic := '0';
begin

	is_lit <= insn( 15 ) = '1';
	is_jmp <= insn( 15 downto 13 ) = "000";
	is_cjmp <= insn( 15 downto 13 ) = "001";
	is_call <= insn( 15 downto 13 ) = "010";
	is_alu <= insn( 15 downto 13 ) = "011";
	
	-- PC register
	pc_proc : process( clk ) 
	begin
		if rising_edge( clk ) then
			if rst_n = '0' then 
				pc <= (others => '0');
			elsif pc_load = '1' then
				pc <= next_pc;
			else 
				pc <= std_logic_vector( unsigned( pc ) + 1 );
			end if;
		end if;
	end process pc_proc;

	-- push
	-- pop
	-- swap
	-- rot
	-- nip		( a b c -- a c )
	-- tuck		( 
	-- dup		( a -- a a )
	-- over		( a b -- a b a )
	-- nrot (-rot)
	
	-- the main CPU control signals
	control_proc : process( is_lit, is_jmp, is_cjmp, is_call, is_alu, insn, N1, N2, N3, R )
		variable stk_code : std_logic_vector( 6 downto 0 );
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
		pc_load	<= '0';
	
		if is_lit then		-- 15-bit literal zero-extended to 16 bits
			dtos_in <= '0' & insn( 14 downto 0 );
			dtos_sel <= "11";
			dnos_sel <= "01";
			dpush <= '1';
		elsif is_jmp then		-- 13-bit address
			-- load new PC
			pc_load <= '1';
			next_pc <= insn( 12 downto 0 );
		elsif is_cjmp then	-- "0branch" (conditional jump - jump if N1 is 0)
			-- check status value and maybe load new PC
			if N1 = "0000000000000000" then
				pc_load <= '1';
				next_pc <= insn( 12 downto 0 );
			end if;
		elsif is_call then	
			-- push "next" PC onto stack, load new PC
			dpush 		<= '1';
			dtos_in 		<= unsigned( pc ) + 1;
			pc_load 		<= '1';
			next_pc 		<= insn( 12 downto 0 );
		elsif is_alu then
			alu_op 	<= insn( 12 downto 8 );
			alu_a 	<= N2;		-- next on stack
			alu_b 	<= N1;		-- top of stack
			if insn( 7 ) = '1' then			-- pop R to PC		(return from subroutine)
				rpop <= '1';
				next_pc <= R( 12 downto 0 );
				pc_load <= '1';
			end if;
			
			-- the stack code
			stk_code := insn( 6 downto 0 );
			
			case stk_code is
				when "0000000" =>		-- push
					dtos_in <= c_1;
					dtos_sel <= "11";
					dnos_sel <= "01";
					dstk_sel <= '0';
					dpush <= '1';
				
				when "0000001" =>		-- swap
					dtos_sel <= "01";
					dnos_sel <= "01";
				
				when "0000010" =>		-- drop
					dtos_sel <= "01";
					dnos_sel <= "10";
					dpop <= '1';
				
				when "0000011" =>		-- rot
					dtos_sel <= "10";
					dnos_sel <= "01";
					dstk_sel <= '0';
					dpush <= '1';
					dpop <= '1';

				when "0000100" =>		--	nrot
					dtos_sel <= "01";
					dnos_sel <= "10";
					dstk_sel <= '1';
					dpush <= '1';
					dpop <= '1';
			
				when "0000101" =>		-- nip
					dtos_sel <= "00";
					dnos_sel <= "10";
					dstk_sel <= '0';
					dpop <= '1';

				when "0000110" =>		-- tuck
					dtos_sel <= "00";
					dnos_sel <= "00";
					dstk_sel <= '1';
					dpush <= '1';

				when "0000111" =>		-- dup
					dtos_sel <= "00";
					dnos_sel <= "01";
					dstk_sel <= '0';
					dpush <= '1';

				when "0001000" =>		-- over
					dtos_sel <= "01";
					dnos_sel <= "01";
					dstk_sel <= '0';
					dpush <= '1';
				
				when "0001001" =>		-- >R
					dtos_sel <= "01";
					dnos_sel <= "10";
					dpop <= '1';
					rpush <= '1';
					rtos_in <= N1;

				when "001010" =>		-- R>
					rpop <= '1';
					rtos_in <= "10";
					
					dtos_in <= c_1;
					dtos_sel <= "11";
					dnos_sel <= "01";
					dstk_sel <= '0';
					dpush <= '1';

				-- NOP
				when others =>
					null;

				-- RAM read			n1 -> [n1] (data in ram at address n1 replaces the top of the stack
				-- RAM write		n2 -> [n1] (data in N2 stored into address in N1)
				-- I/O read			n1 -> [n1] (data in I/O space at address n1 replaces the top of the stack)
				-- I/O write		n2 -> [n1] (data in n2 placed at address n1 in I/O space)
			end case;
		else	 -- NOP
			null;
		end if;
	end process control_proc;
	
end Behavioral;
