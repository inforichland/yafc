--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:37:26 05/21/2014
-- Design Name:   
-- Module Name:   C:/Users/Tim/Documents/Source/yafc/alu_tb.vhd
-- Project Name:  yafc
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: alu
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY alu_tb IS
END alu_tb;
 
ARCHITECTURE behavior OF alu_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         code : IN  std_logic_vector(3 downto 0);
         a : IN  std_logic_vector(15 downto 0);
         b : IN  std_logic_vector(15 downto 0);
         c : OUT  std_logic_vector(15 downto 0);
         co : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal mode : std_logic_vector(1 downto 0) := (others => '0');
   signal code : std_logic_vector(3 downto 0) := (others => '0');
   signal a : std_logic_vector(15 downto 0) := (others => '0');
   signal b : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal c : std_logic_vector(15 downto 0);
   signal co : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          code => code,
          a => a,
          b => b,
          c => c,
          co => co
        );

   -- Stimulus process
   stim_proc: process
   begin		
		-- signed addition
		code <= "1001";
		a <= "0001110001110001";
		b <= "0010011000100110";
		wait for 1ps;
		assert co = '0' report "Invalid carry for signed add" severity error;
		assert c = "0100001010010111" report "Invalid signed add" severity error;
		
		-- signed subtraction
		code <= "1010";
		wait for 1ps;
		assert co = '1' report "Invalid carry for signed sub" severity error;
		assert c = "1111011001001011" report "Invalid signed sub" severity error;
		
		-- signed negate
		code <= "1011";
		wait for 1ps;
		assert co = '0' report "Invalid carry for signed negate" severity error;
		assert c = "1110001110001111" report "Invalid signed negate" severity error;
		
		-- arithmetic right shift
		code <= "1100";
		a <= "1001110001110001";
		b <= "0010011000100110";
		wait for 1ps;
		assert co = '0' report "Invalid carry for arithmetic right shift" severity error;
		assert c = "1100111000111000" report "Invalid arithmetic right shift" severity error;

		-- arithmetic left shift
		code <= "1101";
		wait for 1ps;
		assert co = '0' report "Invalid carry for arithmetic left shift" severity error;
		assert c = "0011100011100010" report "Invalid arithmetic left shift" severity error;

		-- unsigned add
		code <= "1110";
		a <= "1001110001110001";
		b <= "0010011000100110";
		wait for 1ps;
		assert co = '0' report "Invalid carry for unsigned add" severity error;
		assert c = "1100001010010111" report "Invalid unsigned add" severity error;
		
		-- unsigned sub
		a <= "0010011000100110";
		b <= "1001110001110001";
		wait for 1ps;
		assert co = '0' report "Invalid carry for unsigned sub" severity error;
		assert c = "1000100110110101" report "Invalid unsigned sub" severity error;
		
      wait;
   end process;

END;
