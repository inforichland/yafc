----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:44:13 05/29/2014 
-- Design Name: 
-- Module Name:    prog_mem - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.common.all;

entity ram is
	port( 
		CLK  : in std_logic;
		WE   : in std_logic;
		EN   : in std_logic;
		ADDR : in addr;
		DI   : in word;
		DO   : out word
	);
end ram;

architecture syn of ram is
	-- data types
	constant c_ram_size : positive := 2**13-1;
	type ram_t is array( c_ram_size downto 0 ) of word;
	 
	-- signals
	signal ram : ram_t := ( others => ( others => '0' ) );
begin

   process (CLK)
    begin
        if CLK'event and CLK = '1' then
            if EN = '1' then
                if WE = '1' then
                    RAM( to_integer( unsigned( ADDR ) ) ) <= DI;
                end if;
                DO <= RAM( to_integer( unsigned( ADDR ) ) ) ;
            end if;
        end if;
    end process;

end syn;
