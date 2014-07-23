library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.common.all;

package opcodes is

  -- literal
  -- jump
  -- 0branch
  -- 1branch
  -- function

  subtype mcode is std_logic_vector( 1 downto 0 );
  constant m_func : mcode := "00";
  constant m_jump : mcode := "01";
  constant m_0bra : mcode := "10";
  constant m_call : mcode := "11";

  -- TODO: reorganize these
  subtype fcode is std_logic_vector( 4 downto 0 );
  constant f_nop : fcode := "00000";    -- NOP
  constant f_add : fcode := "00001";       -- +
  constant f_sub : fcode := "00010";       -- -
--  constant f_out : fcode := "00011";       -- output port
  constant f_sla : fcode := "00100";       -- 2* (arithmetic)
  constant f_sra : fcode := "00101";       -- 2/ (arithmetic)
  constant f_dup : fcode := "00110";       -- dup
  constant f_not : fcode := "00111";       -- not
  constant f_ftc : fcode := "01000";       -- @
  constant f_str : fcode := "01001";       -- !
  constant f_dtr : fcode := "01010";       -- >R
  constant f_pop : fcode := "01011";       -- drop
  constant f_rtd : fcode := "01100";       -- <R
  constant f_rot : fcode := "01101";		  -- rot
  constant f_nrt : fcode := "01110";		  -- -rot (nrot)
  constant f_swp : fcode := "01111";		  -- swap
  constant f_nip : fcode := "10000";		  -- nip
  constant f_tck : fcode := "10001";		  -- tuck
  constant f_ovr : fcode := "10010";		  -- over
  constant f_equ : fcode := "10011";      -- equals (=)
  -- I/O bus
  constant f_ioo : fcode := "10100";      -- IO!
  constant f_ioi : fcode := "10101";      -- IO@

  -- Subcodes (single bit mask in an instruction word)
  constant s_ret : integer range 0 to word'length := 7;

end opcodes;

package body opcodes is
end opcodes;
