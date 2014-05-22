----------------------------------------------------------------------------------
-- Engineer: Tim Wawrzynczak
-- 
-- Design Name:		ALU
-- Module Name:		alu - Behavioral 
-- Project Name:		YAFC
-- Target Devices:	Xilinx Spartan-6
-- Tool versions:		ISE 14.7
-- Description: 		ALU for a 16-bit Forth CPU
--
-- Dependencies: N/A
--
-- Additional Comments: 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

use work.opcodes.all;

entity alu is
	port( 
		code 	: in  STD_LOGIC_VECTOR (4 downto 0);
		a 		: in  STD_LOGIC_VECTOR (15 downto 0);
		b 		: in  STD_LOGIC_VECTOR (15 downto 0);
		c 		: out STD_LOGIC_VECTOR (15 downto 0);
		co		: out	std_logic
	);
end alu;

architecture Behavioral of alu is
	constant c_true 	: word := ( others => '1' );
	constant c_false	: word := ( others => '0' );
begin

	process( code, a, b )
		variable as, bs, cs : signed( 16 downto 0 );
		variable au, bu, cu : unsigned( 16 downto 0 );
		variable rel : boolean;
	begin
		-- default
		co <= '0';
	
		-- convert inputs to signed and unsigned
		as := a( 15 ) & signed( a );
		bs := b( 15 ) & signed( b );
		au := '0' & unsigned( a );
		bu := '0' & unsigned( b );
		case code is
			-- logical
			when alu_not 	=> c <= not a;									-- not
			when alu_and 	=> c <= a and b;									-- and
			when alu_or 	=> c <= a or b;									-- or
			when alu_xor	=> c <= a xor b;									-- xor
			when alu_nand	=> c <= a nand b;									-- nand
			when alu_nor	=> c <= a nor b;									-- nor
			when alu_xnor	=> c <= a xnor b;									-- xnor
			when alu_ls		=> c <= '0' & a( 15 downto 1 ); 				-- right shift
			when alu_rs		=> c <= a( 14 downto 0 ) & '0';				-- left shift
			
			-- signed arithemetic
			when alu_sadd => 													-- addition
				cs := as + bs;
				co <= cs( 16 );
				c <= std_logic_vector( cs( 15 downto 0 ) );
			when alu_ssub => 													-- subtraction
				cs := as - bs;
				co <= cs( 16 );
				c <= std_logic_vector( cs( 15 downto 0 ) );
			when alu_sneg => 													-- two's complement invert
				cs := ( not as ) + 1;
				c <= std_logic_vector( cs( 15 downto 0 ) );
			when alu_srs =>	c <= a( 15 ) & a( 15 downto 1 );			-- arithmetic right shift
			when alu_lrs =>	c <= a( 14 downto 0 ) & '0';				-- arithmetic left shift			
			
			-- unsigned arithmetic
			when alu_uadd =>														-- addition
				cu := au + bu;
				co <= cu( 16 );
				c <= std_logic_vector( cu( 15 downto 0 ) );
			when alu_usub =>														-- subtraction
				cu := au - bu;
				co <= cu( 16 );
				c <= std_logic_vector( cu( 15 downto 0 ) );
			
			-- relational
			when alu_lt =>														-- <
				rel := as < bs;
				if rel then	c <= c_true; else	c <= c_false end if;
			
			when alu_gt =>														-- >
				rel := as > bs;
				if rel then	c <= c_true; else	c <= c_false end if;
			
			when alu_lte =>														-- <=
				rel := as <= bs;
				if rel then	c <= c_true; else	c <= c_false end if;
			
			when alu_gte =>														-- >=
				rel := as >= bs;
				if rel then	c <= c_true; else	c <= c_false end if;
			
			when alu_eq =>														-- =
				rel := a = b;
				if rel then	c <= c_true; else	c <= c_false end if;
			
			when alu_ult =>														-- U<
				rel := au < bu;
				if rel then	c <= c_true; else	c <= c_false end if;
			
			when alu_ugt =>														-- U>
				rel := au > bu;
				if rel then	c <= c_true; else	c <= c_false end if;
			
			when alu_ulte =>														-- U<=
				rel := au <= bu;
				if rel then	c <= c_true; else	c <= c_false end if;
			
			when alu_ugte =>														-- U>=
				rel := au >= bu;
				if rel then	c <= c_true; else	c <= c_false end if;
			
			when others => c <= ( others => '0' );							-- logical zero
		end case;
	end process;

end Behavioral;
