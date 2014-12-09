library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_arith.ALL;
use ieee.std_logic_unsigned.ALL;
--==================================================================================
entity debounce is
  generic(clock_period    : time :=  20 ns;
          sample_period   : time := 500 us;
          mintime_pressed : time :=  10 ms);
  port (
        CLK        :  in std_logic;
        BUTTON_in  :  in std_logic;
        BUTTON_out : out std_logic
       );
end debounce;
--==================================================================================
--==================================================================================
architecture rtl of debounce is
  -- Synchronization
  signal bsync0, bsync1 : std_logic;
  -- Sample pulse
  constant sample_count_max_c : natural := sample_period / clock_period - 1; 
  signal   sample_counter     : natural range 0 to sample_count_max_c;
  signal   sample_pulse       : std_logic;
  -- Debouncer
  constant debounce_count_max_c : natural := mintime_pressed / sample_period - 1;
  signal   debounce_counter     : natural range 0 to debounce_count_max_c;
begin
  ----------------------------------------------------------------------------------
  ButtonSync: process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      bsync0 <= not BUTTON_in;
      bsync1 <= bsync0;
    end if;
  end process ButtonSync;
  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  SampleGen: process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      if (sample_counter = sample_count_max_c) then
        sample_counter <=  0;
        sample_pulse   <= '1';
      else
        sample_counter <= sample_counter + 1;
        sample_pulse   <= '0';
      end if;
    end if;
  end process SampleGen;
  ----------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------
  Debouncer: process(CLK)
  begin
    if (CLK'event and CLK = '1') then
      if (bsync1 = '0') then
        debounce_counter <=  0;
        BUTTON_out       <= '0';
      elsif (sample_pulse = '1') then
        if (debounce_counter = debounce_count_max_c) then
          BUTTON_out <= '1';
        else
          debounce_counter <= debounce_counter + 1;
        end if;
      end if;
    end if;
  end process Debouncer;
  ----------------------------------------------------------------------------------
end rtl;
--==================================================================================