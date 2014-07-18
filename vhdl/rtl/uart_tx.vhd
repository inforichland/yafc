library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
	generic (
		baud_divider	: integer	-- baud divider for bit clock
	);
	port (
		clk				: in	std_logic ;
		new_data			: in	std_logic ;
		din				: in	std_logic_vector( 7 downto 0 ) ;
		dout				: out	std_logic ;
		busy				: out	std_logic ;
		done				: out	std_logic 
	);
end uart_tx;

architecture Behavioral of uart_tx is
	signal bit_counter, next_bit_counter : unsigned( 3 downto 0 ) := ( others => '0' ) ;
	signal tick_counter : unsigned( 15 downto 0 ) := ( others => '0' ) ;
	
	signal tick_reset, tick_reset_i : std_logic := '1';
	
	type state_t is ( st_idle, st_start, st_tx, st_stop );
	signal state, next_state : state_t := st_idle;
	
	signal dout_i : std_logic := '0';
	signal done_i : std_logic := '0';
	signal sr, next_sr : std_logic_vector( 7 downto 0 ) := ( others => '1' );
	
	signal tick : std_logic := '0';
	signal busy_i : std_logic := '0';
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
	
	-- registers
	SYNC_PROC: process( clk )
   begin
      if rising_edge( clk ) then
			state <= next_state;
			dout <= dout_i;
			sr <= next_sr;
			bit_counter <= next_bit_counter;
			done <= done_i;
			tick_reset <= tick_reset_i;
			busy <= busy_i;
      end if;
   end process;
 
   --MEALY State-Machine - Outputs based on state and inputs
   OUTPUT_DECODE: process( state, tick, new_data, sr, bit_counter, din )
   begin
	
		-- default values (to prevent latches)
		next_sr <= ( others => '0' );
		next_bit_counter <= ( others => '0' );
		done_i <= '0';
	
		case( state ) is
			
			when st_tx =>
				busy_i <= '1';
				dout_i <= sr( 0 );
				tick_reset_i <= '0';
				
				if tick = '1' then
					next_sr <= "1" & sr( 7 downto 1 );
					next_bit_counter <= bit_counter + 1;
				else
					next_sr <= sr;
					next_bit_counter <= bit_counter;
				end if ;

			-- start bit
			when st_start =>
				next_sr <= sr;
				busy_i <= '1';
				tick_reset_i <= '0';
				dout_i <= '0';
			
			-- stop bit
			when st_stop =>
				busy_i <= '1';
				tick_reset_i <= '0';
				dout_i <= '1';

			-- idle
			when st_idle =>
				done_i <= '1';
				busy_i <= '0';
				tick_reset_i <= '1';
				dout_i <= 'Z'; -- tri-state
				
				if new_data = '1' then
					next_sr <= din;
					busy_i <= '1';
					done_i <= '0';
					tick_reset_i <= '0';
				end if ;
			
      end case;
   end process;
 
   NEXT_STATE_DECODE: process( state, new_data, bit_counter, tick )
   begin
      --declare default state for next_state to avoid latches
      next_state <= state;  --default is to stay in current state
      
      case( state ) is
         
			when st_idle =>
            if new_data = '1' then
               next_state <= st_start;
            end if;
				
         when st_tx =>
            if bit_counter = "1000" then
               next_state <= st_stop;
            end if;
         
			when st_start =>
				if tick = '1' then
					next_state <= st_tx;
				end if ;
				
			when st_stop =>
				if tick = '1' then
					next_state <= st_idle;
				end if;
			
         when others =>
            next_state <= st_idle;
      end case;      
   end process;
	
end Behavioral;
