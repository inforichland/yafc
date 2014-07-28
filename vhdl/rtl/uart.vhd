library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.common.all;
use work.uart_pkg.all;

entity uart is
    generic (
        CLOCK_FREQ : integer;
        BAUD       : integer
        );
    port (
        -- control
        clk      : in  std_logic;
        rst_n    : in  std_logic;
        -- Peripheral bus signals
        regs_in  : in  uart_in_regs_t;
        regs_out : out uart_out_regs_t;
        pins_in  : in  uart_in_pins_t;
        pins_out : out uart_out_pins_t
        );
end uart;

architecture Behavioral of uart is
    -- constants
    constant DIVIDER     : integer                      := (CLOCK_FREQ / BAUD) - 1;
    -- TX signals
    signal   strobe      : std_logic;
    signal   tx_sr       : std_logic_vector(9 downto 0) := (others => '1');
    signal   tx_bitcount : integer range 0 to 10        := 10;
    signal   tx_divider  : integer range 0 to DIVIDER   := DIVIDER;
    signal   tx_data     : std_logic_vector(7 downto 0) := (others => '0');
    signal   tx_busy_reg : std_logic;
    signal   tx_busy_i   : std_logic;
    -- RX signals
    signal   sample_sr   : std_logic_vector(3 downto 0) := "0000";
    signal   rx_sr       : std_logic_vector(7 downto 0) := (others => '0');
    signal   rx_bitcount : integer range 0 to 9         := 9;
    signal   rx_divider  : integer range 0 to DIVIDER;
    signal   rx          : std_logic;
    signal   rx_busy_reg : std_logic;
    signal   rx_busy_i   : std_logic;
begin

    ---------------------------------------------------------------------------
    -- Peripheral bus connections
    ---------------------------------------------------------------------------

    -- Assign register inputs
    strobe  <= regs_in.start;
    tx_data <= regs_in.tx_data;

    -- Assign register outputs
    regs_out.rx_busy <= rx_busy_reg;
    regs_out.tx_busy <= tx_busy_reg;
    regs_out.rx_data <= rx_sr;

    -- inputs pins
    rx <= pins_in.rx;

    -- output pins
    pins_out.tx <= tx_sr(0);

    ---------------------------------------------------------------------------
    -- UART logic
    ---------------------------------------------------------------------------

    -- create registers for busy signals
    regs_proc : process (clk)
    begin  -- process regs_proc
        if rising_edge(clk) then
            tx_busy_reg <= tx_busy_i;
            rx_busy_reg <= rx_busy_i;
        end if;
    end process regs_proc;

    -- comnbinational logic for 'busy' signals
    tx_busy_i <= '1' when (strobe = '1' or tx_bitcount /= 10) else '0';
    rx_busy_i <= '1' when (rx_bitcount /= 9)                  else '0';

    -- TX process
    TX_PROC : process(clk)
    begin
        if rising_edge(clk) then
            if (strobe = '1') then
                tx_sr       <= "1" & tx_data & "0";  -- set up data
                tx_divider  <= 0;                    -- set up clock divider
                tx_bitcount <= 0;                    -- set up bit counter
            else
                if (tx_divider /= DIVIDER) then
                    tx_divider <= tx_divider + 1;        -- divide the clock
                else
                    if (tx_bitcount /= 10) then
                        tx_divider  <= 0;
                        tx_bitcount <= tx_bitcount + 1;
                        tx_sr       <= "1" & tx_sr(9 downto 1);
                    end if;
                end if;
            end if;
        end if;
    end process TX_PROC;

    -- RX process
    RX_PROC : process(clk)
    begin
        if rising_edge(clk) then
            sample_sr <= sample_sr(2 downto 0) & rx;  -- read incoming sample
            if (rx_bitcount /= 9) then
                if (rx_divider /= DIVIDER) then
                    rx_divider <= rx_divider + 1;
                elsif (sample_sr = "1111" or sample_sr = "0000") then
                    rx_divider  <= 0;
                    rx_bitcount <= rx_bitcount + 1;
                    rx_sr       <= sample_sr(3) & rx_sr(7 downto 1);
                end if;
            else
                if (sample_sr = "1100") then          -- start bit
                                                      -- starting the count at halfway through a bit period
                                                      -- will align the sampling to the middle of the bit period
                    rx_divider  <= DIVIDER / 2;
                    rx_bitcount <= 0;
                end if;
            end if;
        end if;
    end process RX_PROC;

end Behavioral;
