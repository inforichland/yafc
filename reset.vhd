library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reset is
    Port ( clk : in  STD_LOGIC;
           rst_i : in  STD_LOGIC;
           rst_o : out STD_LOGIC);
end reset;

architecture Behavioral of reset is
begin

	-- asynchronously asserted, synchronously deasserted reset signal
	reset_gen : process( clk, rst_i )
	begin
		if rst_i = '0' then
			rst_o <= '0';
		elsif rising_edge( clk ) then
			rst_o <= '1';
		end if;
	end process reset_gen;

end Behavioral;
