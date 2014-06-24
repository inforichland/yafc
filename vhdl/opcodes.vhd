library IEEE;
use IEEE.STD_LOGIC_1164.all;

package opcodes is

	subtype fcode is std_logic_vector( 3 downto 0 );
	constant f_add : fcode := "0001";       -- +
	constant f_sub : fcode := "0010";       -- -
	constant f_out : fcode := "0011";       -- output port
	constant f_jmp : fcode := "0100";       -- jump
	constant f_sla : fcode := "0101";       -- 2* (arithmetic)
	constant f_sra : fcode := "0110";       -- 2/ (arithmetic)
	constant f_0br : fcode := "0111";       -- 0branch
	constant f_dup : fcode := "1000";       -- dup
	constant f_not : fcode := "1001";       -- not
	constant f_1br : fcode := "1010";       -- not 0branch
	constant f_lds : fcode := "1011";       -- @
	constant f_put : fcode := "1100";       -- !
	constant f_dtr : fcode := "1101";       -- >R
	constant f_pop : fcode := "1110";       -- drop
    constant f_rtd : fcode := "1111";       -- <R

end opcodes;

package body opcodes is
end opcodes;
