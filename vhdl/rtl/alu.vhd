library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.common.all;

entity alu is
  port (
    tos     : in    word;
    nos     : in    word;
    results : out   alu_results_t
    );
end alu;

architecture Behavioral of alu is
  signal alu_results : alu_results_t;
begin

  -- assign outputs
  results <= alu_results;

  -- where the magic happens... :-)
  alu_proc : process( tos, nos )
    variable not_shiftable : std_logic;
  begin
    
    -- arithmetic
    alu_results.add_result <= std_logic_vector( signed( nos ) + signed( tos ) );
    alu_results.sub_result <= std_logic_vector( signed( nos ) - signed( tos ) );

    -- logic
    not_shiftable := or_vector( tos( 15 downto 4 ) );
    if not_shiftable = '1' then
      alu_results.sll_result <= ( others => '0' );
      alu_results.srl_result <= ( others => '0' );
    else
      alu_results.sll_result <= std_logic_vector( shift_left( signed( nos ), to_integer( signed( tos ) ) ) );
      alu_results.srl_result <= std_logic_vector( shift_right( signed( nos ), to_integer( signed( tos ) ) ) );
    end if;
    
    alu_results.or_result   <= nos or tos;
    alu_results.and_result  <= nos and tos;
    
    -- relational
    if tos = nos then
      alu_results.eq_result <= ( others => '1' );
    else
      alu_results.eq_result <= ( others => '0' );
    end if;
    
  end process alu_proc;

end Behavioral;

