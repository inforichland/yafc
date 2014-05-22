library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common.all;

entity dram is
	generic (
		depth	: integer
	);
	port( 
		clk		: in std_logic;
		we			: in std_logic;
		addr_wr	: in std_logic_vector( 4 downto 0 );
		addr_rd	: in std_logic_vector( 4 downto 0 );
		din		: in word;
		dout		: out word
	);
end dram;

architecture behavioral of dram is
    type ram_t is array( depth-1 downto 0 ) of word;
    signal ram : ram_t := ( others => ( others => '0' ) );
begin

	-- reading from the RAM
	read_behavior : process( addr_rd, ram )
		variable index : integer := 31;
	begin
		index := to_integer( unsigned( addr_rd ) );
		dout <= ram( index );
	end process read_behavior;

	-- writing to the RAM
	write_behavior : process( clk )
		variable index : integer := 31;
	begin
		if rising_edge( clk ) then
			if we = '1' then
				index := to_integer( unsigned( addr_wr ) );
				ram( index ) <= din;
			end if;
		end if;		
	end process write_behavior;

end behavioral;
