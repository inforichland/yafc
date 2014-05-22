----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:42:46 05/21/2014 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
	port( 
		code 	: in  STD_LOGIC_VECTOR (3 downto 0);
		a 		: in  STD_LOGIC_VECTOR (15 downto 0);
		b 		: in  STD_LOGIC_VECTOR (15 downto 0);
		c 		: out STD_LOGIC_VECTOR (15 downto 0);
		co		: out	std_logic
	);
end alu;

architecture Behavioral of alu is
begin

	process( code, a, b )
		variable as, bs, cs : signed( 16 downto 0 );
		variable au, bu, cu : unsigned( 16 downto 0 );
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
			when "0000" => c <= not a;										-- not
			when "0001" => c <= a and b;									-- and
			when "0010" => c <= a or b;									-- or
			when "0011" => c <= a xor b;									-- xor
			when "0100" => c <= a nand b;									-- nand
			when "0101" => c <= a nor b;									-- nor
			when "0110" => c <= a xnor b;									-- xnor
			when "0111" => c <= '0' & a( 15 downto 1 ); 				-- right shift
			when "1000" => c <= a( 14 downto 0 ) & '0';				-- left shift
			
			-- signed arithemetic
			when "1001" => 													-- addition
				cs := as + bs;
				co <= cs( 16 );
				c <= std_logic_vector( cs( 15 downto 0 ) );
			when "1010" => 													-- subtraction
				cs := as - bs;
				co <= cs( 16 );
				c <= std_logic_vector( cs( 15 downto 0 ) );
			when "1011" => 													-- two's complement invert
				cs := ( not as ) + 1;
				c <= std_logic_vector( cs( 15 downto 0 ) );
			when "1100" =>	c <= a( 15 ) & a( 15 downto 1 );			-- arithmetic right shift
			when "1101" =>	c <= a( 14 downto 0 ) & '0';				-- arithmetic left shift			
			
			-- unsigned arithmetic
			when "1110" =>														-- addition
				cu := au + bu;
				co <= cu( 16 );
				c <= std_logic_vector( cu( 15 downto 0 ) );
			when "1111" =>														-- subtraction
				cu := au - bu;
				co <= cu( 16 );
				c <= std_logic_vector( cu( 15 downto 0 ) );
			
			when others => c <= ( others => '0' );						-- logical zero
		end case;
	end process;

end Behavioral;
