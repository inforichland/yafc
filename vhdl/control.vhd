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
		-- inputs from other modules
		insn 		: in  STD_LOGIC_VECTOR (15 downto 0);
		N1			: in	word;
		N2			: in	word;
		R			: in	word;
		-- PC signals
		pc_en		: out	std_logic;
		pc_ld		: out	std_logic;
		pc_next	: out	addr;
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
		alu_in	: in	word;
		-- CPU busses
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
	signal is_lit, is_jmp, is_cjmp, is_call, is_alu : std_logic := '0';
begin

	-- assign outputs
	mem_wr 	<= ( others => '0' );
	mem_addr <= ( others => '0' );
	mem_sel 	<= '0';
	io_wr 	<= ( others => '0' );
	io_sel 	<= '0';
	io_addr 	<= ( others => '0' );

	-- instruction decoding
	is_lit	<= insn( 15 );
	is_jmp 	<= '1' when insn( 15 downto 13 ) = "000" else '0';
	is_cjmp 	<= '1' when insn( 15 downto 13 ) = "001" else '0';
	is_call 	<= '1' when insn( 15 downto 13 ) = "010" else '0';
	is_alu 	<= '1' when insn( 15 downto 13 ) = "011" else '0';

	-- for now, PC is always enabled
	pc_en <= '1';

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
	control_proc : process( is_lit, is_jmp, is_cjmp, is_call, is_alu, insn, N1, N2, R, alu_in, mem_rd, io_rd )
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
		pc_ld		<= '0';
		pc_next 	<= ( others => '0' );
	
		if is_lit = '1' then		-- 15-bit literal sign-extended to 16 bits
			dtos_in <= insn( 14 ) & insn( 14 downto 0 );
			dtos_sel <= "11";
			dnos_sel <= "01";
			dpush <= '1';
		elsif is_jmp = '1' then		-- 13-bit address
			-- load new PC
			pc_ld 	<= '1';
			pc_next 	<= insn( 12 downto 0 );
		elsif is_cjmp = '1' then	-- "0branch" (conditional jump - jump if N1 is 0)
			-- check status value and maybe load new PC
			if N1 = "0000000000000000" then
				pc_ld		<= '1';
				pc_next 	<= insn( 12 downto 0 );
			end if;
		elsif is_call = '1' then	
			-- push "next" PC onto stack, load new PC
			rpush 		<= '1';
			--rtos_in 		<= "000" & std_logic_vector( unsigned( pc ) + 1 );
			pc_ld			<= '1';
			pc_next 		<= insn( 12 downto 0 );
		elsif is_alu = '1' then
			alu_op 	<= insn( 12 downto 8 );
			alu_a 	<= N2;		-- next on stack
			alu_b 	<= N1;		-- top of stack
			if insn( 7 ) = '1' then			-- pop R to PC		(return from subroutine)
				rpop 		<= '1';
				pc_ld		<= '1';
				pc_next	<= R( 12 downto 0 );
			else
				-- the stack code
				stk_code := insn( 6 downto 0 );
				
				case stk_code is
					when "0000000" =>		-- push ALU result onto stack
						dtos_in <= alu_in;
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
					
					when "0001001" =>		-- >R	(from data stack to return stack)
						dtos_sel <= "01";
						dnos_sel <= "10";
						dpop <= '1';
						rpush <= '1';
						rtos_in <= N1;

					when "0001010" =>		-- R>	(from return stack to data stack)
						rpop <= '1';
						rtos_sel <= '1';
						
						dtos_in <= R;
						dtos_sel <= "11";
						dnos_sel <= "01";
						dstk_sel <= '0';
						dpush <= '1';

					when "0001011" =>		-- RAM read, push onto data stack
						dtos_in <= mem_rd;
						dtos_sel <= "11";
						dnos_sel <= "01";
						dstk_sel <= '0';
						dpush <= '1';
					
					when "0001100" =>		-- RAM write
						null;
					
					when "0001101" =>		-- I/O read
						dtos_in <= io_rd;
						dtos_sel <= "11";
						dnos_sel <= "01";
						dstk_sel <= '0';
						dpush <= '1';
						
					when "0001110" =>		-- I/O write
						null;
					
					-- NOP
					when others =>
						null;

					-- RAM read			n1 -> [n1] (data in ram at address n1 replaces the top of the stack
					-- RAM write		n2 -> [n1] (data in N2 stored into address in N1)
					-- I/O read			n1 -> [n1] (data in I/O space at address n1 replaces the top of the stack)
					-- I/O write		n2 -> [n1] (data in n2 placed at address n1 in I/O space)
				end case;
			end if;
		end if;
	end process control_proc;
	
end Behavioral;
