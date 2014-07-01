library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common.all;

entity dpram_async is
  port (
    clk	: in	std_logic;
    we		: in	std_logic;
    waddr	: in	std_logic_vector( 4 downto 0 );
    raddr	: in	std_logic_vector( 4 downto 0 );
    din	: in	word;
    dout	: out	word
    );
end dpram_async;

architecture rtl of dpram_async is
  type ram_t is array( 31 downto 0 ) of word;
  signal ram : ram_t := ( others => ( others => '0' ) );
begin

  process( clk )
  begin
    if rising_edge( clk ) then
      if we = '1' then
        ram( to_integer( unsigned( waddr ) ) ) <= din;
      end if;
    end if;
  end process;

  dout <= ram( to_integer( unsigned( raddr ) ) );
end rtl;
