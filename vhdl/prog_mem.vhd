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
use ieee.std_logic_textio.all;

use std.textio.all;
use work.common.all;

entity prog_mem is
	port( 
		clk		: in std_logic;
      addr 		: in addr;
      data 		: out word
	);
end prog_mem;

architecture syn of prog_mem is
	-- data types
	constant c_rom_size : positive := 2**13-1;
	type rom_t is array( c_rom_size downto 0 ) of word;
	 
	-- functions
	impure function read_rom_data( filename : in string ) return rom_t is                                                   
		FILE rom_file : text is in filename;
		variable L : line;                         
		variable rom_temp : rom_t;
	begin                                                        
		for I in rom_t'range loop                                  
			readline( rom_file, L );                             
			read( L, rom_temp( I ) );                                  
		end loop;

		return rom_temp;
	end function; 
	
	-- signals
	constant rom : rom_t := ( 0 => "0000000000000001",
									1 => "0000000000000010",
									2 => "0000000000000011",
									3 => "0000000000000100",
									others => ( others => '0' ) );
	--attribute KEEP : string;
	--attribute KEEP of rom : constant is "TRUE";
	signal rdata : word;
begin

	rdata <= rom( to_integer( unsigned( addr ) ) );

	process( clk )
	begin
		if rising_edge( clk ) then
			data <= rdata;
		end if;
	end process;

end syn;
