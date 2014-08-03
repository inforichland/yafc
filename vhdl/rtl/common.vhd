library IEEE;
use IEEE.STD_LOGIC_1164.all;

use work.uart_pkg.all;
use work.gpio_pkg.all;

package common is
  -- Constants
  constant c_word_width : integer := 16;
  constant c_word_msb   : integer := c_word_width - 1;
  constant c_stack_size : integer := 32;
  constant c_address_width : integer := 13;

  -- Data types
  subtype word is std_logic_vector( c_word_msb downto 0 );
  subtype address is std_logic_vector( c_address_width-1 downto 0 );
  
  type io_write_ctrl is record
    io_addr       : address;
    io_write      : word;
    io_we         : std_logic;
  end record;
  
  type io_read_ctrl is record
    io_addr       : address;
    io_read       : word;
    io_re         : std_logic;
  end record;

  -- input pins to peripheral bus
  type peri_in_pins_t is record
    uart_in_pins    : uart_in_pins_t;
    gpio_in_pins    : gpio_in_pins_t;
  end record;
  
  -- output pins from peripheral bus
  type peri_out_pins_t is record
    uart_out_pins   : uart_out_pins_t;
    gpio_out_pins   : gpio_out_pins_t;
  end record;
  
  -- functions
  function or_vector( s : std_logic_vector ) return std_logic;
  function log2( n : natural ) return natural;

  -- ALU operations
  type alu_results_t is record
    add_result : word;
    sub_result : word;
    sll_result : word;
    srl_result : word;
    eq_result  : word;
    or_result  : word;
    and_result : word;
  end record;

end common;

package body common is

  -- OR reduction of a vector
  function or_vector( s : std_logic_vector ) return std_logic is
    variable res : std_logic := '0';
  begin
    for i in s'range loop
      res := res or s( i );
    end loop;
    return res;
  end function or_vector;

  -- log base 2 of 'n'
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
