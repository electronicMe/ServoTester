--subtype elements is std_logic_vector(15 downto 0);
--type 16bit_array is array (0 to 127) of elements;
--signal arr : 16bit_array ;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity ServoTester is
port (
	CLOCK_50 : in  std_logic;
	SW       : in  std_logic_vector(3  downto 0);
	LED      : out std_logic_vector(7  downto 0);
	GPIO_0   : out std_logic_vector(33 downto 0);
	GPIO_1   : out std_logic_vector(33 downto 0)
);
end ServoTester;



architecture ServoTester_a of ServoTester is

	--type vector_2 is array (natural range <>, natural range <>) of std_logic;

	signal s_RESET          : std_logic;

	signal s_pwmSignal      : std_logic_vector(7 downto 0);
	signal s_activateServo  : std_logic_vector(7 downto 0);
	
	signal s_TL, s_TR       : std_logic;
	signal s_debouncedGPIO1 : std_logic_vector(31 downto 0);
	
 signal s_LUT            : std_logic_vector(9 downto 0);
	--signal s_LUT            : vector_2(7 downto 0, 9 downto 0); -- (servo ID, bit index)
 signal s_dutycycle      : std_logic_vector(9 downto 0);
	--signal s_dutycycle      : vector_2(7 downto 0, 9 downto 0); -- (servo ID, bit index)
	
	signal s_TICK           : std_logic;
  signal s_counter        : std_logic_vector(11 downto 0);
	--signal s_counter        : vector_2(7 downto 0, 11 downto 0); -- (servo ID, bit index)
	
	--signal s_centerCorrection : integer;

begin



																					
																					
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@--
	--========================================================================--
	-- SIGNALS                                                                --
	--========================================================================--
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@--

	
	s_RESET   <= '1';
	
	--s_dutycycle <= "0111111111";
	s_activateServo <= "11111111";
	
	
	
	--========================================================================--
	-- servo output                                                           --
	--========================================================================--
	
	GPIO_1(6)  <= (SW(0) XOR (s_pwmSignal(0) AND s_activateServo(0)));    -- S1
	GPIO_0(24) <= (SW(0) XOR (s_pwmSignal(1) AND s_activateServo(1)));    -- S2
	
	LED(0)    <= (SW(0) XOR (s_pwmSignal(0) AND s_activateServo(0)));    -- S1
	LED(1)    <= (SW(0) XOR (s_pwmSignal(1) AND s_activateServo(1)));    -- S2
	LED(2) <= '1';
	LED(3) <= '0';
	LED(4) <= '1';
	LED(5) <= '0';
	LED(6) <= '1';
	LED(7) <= '0';
	
	
	
	
	--50000
	--s_centerCorrection <= (to_integer(signed(SW)) * 1000);



																					
																					
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@--
	--========================================================================--
	-- SUPPORTING COMPONENTS                                                  --
	--========================================================================--
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@--
	
	
	
	
	--========================================================================--
	-- PRESCALER                                                              --
	--========================================================================--
	
	prescaler: entity work.prescaler(prescaler_a)	generic map (scale          => 40000)
																	port map    (CLK            => CLOCK_50,
																	             RESET_n        => s_RESET,
																					 TICK           => s_TICK
																	            );
	
	
	
	--========================================================================--
	-- COUNTERS                                                               --
	--========================================================================--
	
	counter_1: entity work.counter(counter_a)			generic map (max_g          => 4096,               -- maximum number
																					 outBit_g       => s_counter'length, -- number of output bit
																					 initialValue_g => 0                   -- the initial value after reset
																					)
																	port map		(CLK            => s_TICK,
																					 RESET_n        => s_RESET,
																					 TC             => s_counter--(0)
																					);
	
	
	
	--========================================================================--
	-- LOOK UP TABLES                                                         --
	--========================================================================--
	
	SinusLUT_1: entity work.SinusLUT(SinusLUT_a)		port map		(LUT_IN         => s_counter,--(0),
																					 LUT_OUT        => s_LUT--(0)
																					);



																					
																					
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@--
	--========================================================================--
	-- SERVOS                                                                 --
	--========================================================================--
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@--
	
	
	
	servo_1: entity work.PWMServo(PWMServo_a)			generic map (invertHorn_g => '1',
																					 centerCorr_g => 16000 )
																	port map		(CLK          => CLOCK_50,
																					 RESET_n      => s_RESET,
																					 DUTYCYCLE    => s_LUT,
	
																					 PWMOut       => s_pwmSignal(0)
																					);
	
	
	
	servo_2: entity work.PWMServo(PWMServo_a)			generic map (invertHorn_g => '0',
																					 centerCorr_g => 88000 )
																	port map		(CLK          => CLOCK_50,
																					 RESET_n      => s_RESET,
																					 DUTYCYCLE    => s_LUT,
	
																					 PWMOut       => s_pwmSignal(1)
																					);


end ServoTester_a;
