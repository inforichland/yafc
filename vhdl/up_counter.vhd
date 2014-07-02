-- binary up-counter
--  async reset, sync load, ce

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common.all;

entity up_counter is

  generic (
    g_reset_value : address
  );

  port (
    clk		  : in std_logic;
    rst_n	  : in std_logic;
    inc	    : in std_logic;
    load    : in std_logic;
    d       : in address;
    q		    : out address
  );

end entity;

architecture rtl of up_counter is
  signal cntr : unsigned( c_address_width-1 downto 0 ) := unsigned( g_reset_value );
begin

  -- Assign outputs
  q <= std_logic_vector( cntr );
  
  -- create the counter
  process( clk, rst_n )
  begin
    if rst_n = '0' then
      cntr <= unsigned( g_reset_value );
    elsif( rising_edge( clk ) ) then
      if load = '1' then
        cntr <= unsigned( d );
      elsif inc = '1' then
        cntr <= cntr + 1;
      end if;
    end if;
  end process;

end rtl;
