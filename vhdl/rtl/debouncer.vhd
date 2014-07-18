library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity debouncer is
  port ( 
    clk : in  STD_LOGIC;
    reset : in  STD_LOGIC;
    input : in  STD_LOGIC;
    output : out  STD_LOGIC
    );
end debouncer;

architecture Behavioral of debouncer is
  signal sync_d, sync_q : std_logic_vector( 1 downto 0 ) := "00" ;
  signal counter_d, counter_q : unsigned( 18 downto 0 ) := ( others => '0' ) ;
begin

  output <= '1' when ( counter_q = "1111111111111111111" ) else '0' ;

  -- standard double input flop to synchronize the input
  sync : process( input, sync_d( 0 ) )
  begin
    sync_d( 0 ) <= input ;
    sync_d( 1 ) <= sync_d( 0 ) ;
  end process sync ;
  
  -- debounce the input
  debounce : process( counter_q, sync_q( 1 ) )
  begin
    counter_d <= counter_q + 1 ;
    
    -- hold the counter in saturation
    if( counter_q = "1111111111111111111" ) then
      counter_d <= counter_q ;
    end if ;
    
    -- but reset if the synced input goes low
    if( sync_q( 1 ) = '0' ) then
      counter_d <= ( others => '0' ) ;
    end if ;
    
  end process debounce ;

  -- create registers
  registers : process( clk )
  begin
    if rising_edge( clk ) then
      if( reset = '1' ) then
        sync_q <= "00" ;
        counter_q <= ( others => '0' ) ;
      else
        sync_q <= sync_d ;
        counter_q <= counter_d ;
      end if ;
    end if ;
  end process registers;

end Behavioral;
