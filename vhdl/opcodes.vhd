library IEEE;
use IEEE.STD_LOGIC_1164.all;

package opcodes is

	subtype fcode is std_logic_vector( 3 downto 0 );
	constant f_add : fcode := "0001";
	constant f_sub : fcode := "0010";
	constant f_out : fcode := "0011";
	constant f_jmp : fcode := "0100";
	constant f_sla : fcode := "0101";
	constant f_sra : fcode := "0110";
	constant f_0br : fcode := "0111";
	constant f_dup : fcode := "1000";
	constant f_not : fcode := "1001";
	constant f_1br : fcode := "1010";
	constant f_lds : fcode := "1011";
	constant f_put : fcode := "1100";
	--constant f_sub : fcode := "1101";
	constant f_pop : fcode := "1110";

end opcodes;

package body opcodes is
end opcodes;
