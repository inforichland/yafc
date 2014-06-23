-- binary up-counter
--  async reset, sync load, ce

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity up_counter is

	generic
	(
		WIDTH : positive;
        RESET_VALUE : unsigned( 9 downto 0 )
	);

	port
	(
		clk		  : in std_logic;
		rst_n	  : in std_logic;
		inc	      : in std_logic;
        load      : in std_logic;
        d         : in std_logic_vector( WIDTH-1 downto 0 );
		q		  : out std_logic_vector( WIDTH-1 downto 0 )
	);

end entity;

architecture rtl of up_counter is
    signal cntr : unsigned( WIDTH-1 downto 0 ) := RESET_VALUE;
begin

    -- Assign outputs
    q <= std_logic_vector( cntr );
    
    -- create the counter
	process( clk, rst_n )
	begin
        if rst_n = '0' then
            cntr <= RESET_VALUE;
		elsif( rising_edge( clk ) ) then
			if load = '1' then
                cntr <= unsigned( d );
            elsif inc = '1' then
				cntr <= cntr + 1;
			end if;
		end if;
	end process;

end rtl;
