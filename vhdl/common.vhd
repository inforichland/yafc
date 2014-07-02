library IEEE;
use IEEE.STD_LOGIC_1164.all;

package common is
  constant c_word_width : integer := 16;
  constant c_word_msb   : integer := c_word_width - 1;
  constant c_stack_size : integer := 32;
  constant c_address_width : integer := 13;

  subtype word is std_logic_vector( c_word_msb downto 0 );
  subtype address is std_logic_vector( c_address_width-1 downto 0 );
  
  function or_vector( s : std_logic_vector ) return std_logic;
  function log2( n : natural ) return natural;

  -- ALU operations
  type alu_results_t is record
    add_result : word;
    sub_result : word;
    sll_result : word;
    srl_result : word;
  end record;

end common;

package body common is

  function or_vector( s : std_logic_vector ) return std_logic is
    variable res : std_logic := '0';
  begin
    for i in s'range loop
      res := res or s( i );
    end loop;
    return res;
  end function or_vector;

  function log2( n : natural ) return natural is
    variable a : natural := n;
    variable log : natural := 0;
  begin
    for i in n downto 0 loop
      if a > 0 then
        log := log + 1;
      end if;
      a := a / 2;
    end loop;
    return log;
  end function log2;

end common;
