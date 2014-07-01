library IEEE;
use IEEE.STD_LOGIC_1164.all;

package opcodes is

  subtype fcode is std_logic_vector( 4 downto 0 );
  constant f_add : fcode := "00001";       -- +
  constant f_sub : fcode := "00010";       -- -
  constant f_out : fcode := "00011";       -- output port
  constant f_jmp : fcode := "00100";       -- jump
  constant f_sla : fcode := "00101";       -- 2* (arithmetic)
  constant f_sra : fcode := "00110";       -- 2/ (arithmetic)
  constant f_0br : fcode := "00111";       -- 0branch
  constant f_dup : fcode := "01000";       -- dup
  constant f_not : fcode := "01001";       -- not
  constant f_1br : fcode := "01010";       -- not 0branch
  constant f_lds : fcode := "01011";       -- @
  constant f_put : fcode := "01100";       -- !
  constant f_dtr : fcode := "01101";       -- >R
  constant f_pop : fcode := "01110";       -- drop
  constant f_rtd : fcode := "01111";       -- <R
  constant f_rot : fcode := "10000";		  -- rot
  constant f_nrt : fcode := "10001";		  -- -rot (nrot)\
  constant f_swp : fcode := "10010";		  -- swap
  constant f_nip : fcode := "10011";		  -- nip
  constant f_tck : fcode := "10100";		  -- tuck
  constant f_ovr : fcode := "10101";		  -- over

end opcodes;

package body opcodes is
end opcodes;
