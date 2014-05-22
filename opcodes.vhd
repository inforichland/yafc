library IEEE;
use IEEE.STD_LOGIC_1164.all;

package opcodes is

	constant alu_not	: std_logic_vector( 4 downto 0 ) := "00000";
	constant alu_and	: std_logic_vector( 4 downto 0 ) := "00001";
	constant alu_or	: std_logic_vector( 4 downto 0 ) := "00010";
	constant alu_xor	: std_logic_vector( 4 downto 0 ) := "00011";
	constant alu_nand	: std_logic_vector( 4 downto 0 ) := "00100";
	constant alu_nor	: std_logic_vector( 4 downto 0 ) := "00101";
	constant alu_xnor	: std_logic_vector( 4 downto 0 ) := "00110";
	constant alu_rs	: std_logic_vector( 4 downto 0 ) := "00111";
	constant alu_ls	: std_logic_vector( 4 downto 0 ) := "01000";
	constant alu_sadd	: std_logic_vector( 4 downto 0 ) := "01001";
	constant alu_ssub	: std_logic_vector( 4 downto 0 ) := "01010";
	constant alu_sneg	: std_logic_vector( 4 downto 0 ) := "01011";
	constant alu_srs	: std_logic_vector( 4 downto 0 ) := "01100";
	constant alu_sls	: std_logic_vector( 4 downto 0 ) := "01101";
	constant alu_uadd	: std_logic_vector( 4 downto 0 ) := "01110";
	constant alu_usub	: std_logic_vector( 4 downto 0 ) := "01111";
	constant alu_lt	: std_logic_vector( 4 downto 0 ) := "10000";
	constant alu_gt	: std_logic_vector( 4 downto 0 ) := "10001";
	constant alu_lte	: std_logic_vector( 4 downto 0 ) := "10010";
	constant alu_gte	: std_logic_vector( 4 downto 0 ) := "10011";
	constant alu_eq	: std_logic_vector( 4 downto 0 ) := "10100";
	constant alu_ult	: std_logic_vector( 4 downto 0 ) := "10101";
	constant alu_ugt	: std_logic_vector( 4 downto 0 ) := "10110";
	constant alu_ulte	: std_logic_vector( 4 downto 0 ) := "10111";
	constant alu_ugte	: std_logic_vector( 4 downto 0 ) := "11000";

end opcodes;

package body opcodes is
end opcodes;
