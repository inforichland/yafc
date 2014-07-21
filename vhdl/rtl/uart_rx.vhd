library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
	port (
		clk				    : in	std_logic ;
		din				    : in	std_logic ;
    uart_in_regs  : in  uart_in_regs_t;
		uart_out_regs : out uart_out_regs_t
	);
end uart_rx;


architecture Behavioral of uart_rx is
	signal bit_counter 	: unsigned( 3 downto 0 ) := ( others => '0' ) ;
	signal tick_counter	: unsigned( 15 downto 0 ) := ( others => '0' ) ;
	signal sr				: std_logic_vector( 7 downto 0 ) ; -- 8 data
	
	type state_t is ( st_idle, st_start_bit, st_edge, st_midbit, st_sample, st_stop_bit );
	signal state, state_next : state_t := st_idle;
	
	-- half-bit period tick generation
	signal tick_reset : std_logic := '1';
	signal tick : std_logic := '0';
	
	signal din_prev : std_logic := '1';
	signal busy_i : std_logic := '0';
	signal err_i : std_logic := '0';
	
	signal sample_counter : std_logic_vector( 3 downto 0 ) := "0000";
	signal samples : std_logic_vector( 2 downto 0 ) := "000";

begin

	tick_gen : process( clk )
	begin
		if rising_edge( clk ) then
			tick <= '0'; -- default value
		
			if tick_reset = '1' then
				tick_counter <= ( others => '0' ) ;
			else
				tick_counter <= tick_counter + 1;
				if tick_counter = to_unsigned( baud_divider, 16 ) then
					tick_counter <= ( others => '0' ) ;
					tick <= '1'; -- generate pulse
				end if ;
			end if ;
		end if ;
	end process ;

	-- UART receive state machine
	FSM : process (clk)
   begin
   
		if rising_edge( clk ) then
			-- latch new state
			state <= state_next;
			busy <= busy_i;
			err <= err_i;
			
			-- default values
			done <= '0';
			tick_reset <= '0';
			busy_i <= '0';
			
			case( state ) is
				-- wait for start bit
				when st_idle =>
					tick_reset <= '1';
					bit_counter <= ( others => '0' );
					
					-- start bit
					if( din = '0' ) and ( din_prev = '1' ) then
						state_next <= st_start_bit;
						tick_reset <= '0';
						busy_i <= '1';
					end if ;

				-- ensure start bit is correct
				when st_start_bit =>
					busy_i <= '1';
					
					-- this is the middle of the start bit period
					if tick = '1' then
						if din = '0' then
							state_next <= st_edge;
						else	-- framing error
							state_next <= st_idle;
							err_i <= '1';
						end if ;
					end if;

				-- synchronize to bit edges
				when st_edge =>
					busy_i <= '1';
				
					-- wait for half-bit tick
					if tick = '1' then
						if( bit_counter = "1000" ) then
							state_next <= st_stop_bit;
						else
							state_next <= st_midbit;
						end if ;
					end if;
				
				-- sample mid-bit period
				when st_midbit =>	
					busy_i <= '1';
				
					-- wait for half-bit tick
					if tick = '1' then
						state_next <= st_sample;
						sample_counter <= "0001";
						samples <= "111";
					end if ;

				-- sample at mid-bit until we get 3 samples in a row that match
				when st_sample =>
					busy_i <= '1';
					if sample_counter = "1000" then
						if( samples = "000" ) or ( samples = "111" ) then
							sr <= samples( 0 ) & sr( sr'high downto 1 ) ;	-- shift in the new bit (LSB first)
							bit_counter <= bit_counter + 1;
							state_next <= st_edge;
							sample_counter <= "0000";
						else
							sample_counter <= "0001";
						end if ;
					else
						samples <= din & samples( 2 downto 1 ); -- shift in new sample
						sample_counter <= sample_counter( 2 downto 0 ) & "0";
					end if ;
					

				-- if the stop bit is valid halfway through (in st_midbit), we'll assume it's ok 
				--  (this way we can reliably get full baud[1])
				--
				--  [1] theoretically speaking...
				when st_stop_bit =>
					busy_i <= '1';
					
					-- midway through stop-bit period
					if tick = '1' then
						if din = '1' then -- if it's a stop bit, set the outputs
							busy_i <= '0';
							dout <= sr;
							done <= '1';
							err_i <= '0';		-- if we successfully received a character, then clear any errors
						else
							err_i <= '1'; -- overflow error
						end if;
						
						tick_reset <= '1';
						state_next <= st_idle;
					end if;
					
			end case;
			
			-- save current 'din' into previous value
			din_prev <= din;
			
      end if;
   end process;

end Behavioral;
