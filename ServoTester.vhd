--subtype elements is std_logic_vector(15 downto 0);
--type 16bit_array is array (0 to 127) of elements;
--signal arr : 16bit_array ;


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity ServoTester is
port (
	CLOCK_50 : in  std_logic;
	SW       : in  std_logic_vector(9 downto 0);
	KEY      : in  std_logic_vector(2 downto 0);
	LEDG     : out std_logic_vector(9 downto 0);
	GPIO_0   : in  std_logic_vector(2 downto 0);
	GPIO_1   : out std_logic_vector(31 downto 0)
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

	
	s_RESET   <= SW(0);
	
	--s_dutycycle <= "0111111111";
	s_activateServo <= "11111111";
	
	
	
	--========================================================================--
	-- servo output                                                           --
	--========================================================================--
	
	GPIO_1(23) <= (SW(2) XOR (s_pwmSignal(0) AND s_activateServo(0)));    -- S1
	GPIO_1(22) <= (SW(2) XOR (s_pwmSignal(1) AND s_activateServo(1)));    -- S2
	GPIO_1(25) <= (SW(2) XOR (s_pwmSignal(2) AND s_activateServo(2)));    -- S3
	GPIO_1(24) <= (SW(2) XOR (s_pwmSignal(3) AND s_activateServo(3)));    -- S4
	GPIO_1(27) <= (SW(2) XOR (s_pwmSignal(4) AND s_activateServo(4)));    -- S5
	GPIO_1(26) <= (SW(2) XOR (s_pwmSignal(5) AND s_activateServo(5)));    -- S6
	GPIO_1(29) <= (SW(2) XOR (s_pwmSignal(6) AND s_activateServo(6)));    -- S7
	GPIO_1(28) <= (SW(2) XOR (s_pwmSignal(7) AND s_activateServo(7)));    -- S8
	
	
	
	--========================================================================--
	-- LED output (debug)                                                     --
	--========================================================================--
	
	LEDG(0)    <= (SW(2) XOR (s_pwmSignal(0) AND s_activateServo(0)));
	LEDG(1)    <= (SW(2) XOR (s_pwmSignal(1) AND s_activateServo(1)));
	LEDG(2)    <= (SW(2) XOR (s_pwmSignal(2) AND s_activateServo(2)));
	LEDG(3)    <= (SW(2) XOR (s_pwmSignal(3) AND s_activateServo(3)));
	LEDG(4)    <= (SW(2) XOR (s_pwmSignal(4) AND s_activateServo(4)));
	LEDG(5)    <= (SW(2) XOR (s_pwmSignal(5) AND s_activateServo(5)));
	LEDG(6)    <= (SW(2) XOR (s_pwmSignal(6) AND s_activateServo(6)));
	LEDG(7)    <= (SW(2) XOR (s_pwmSignal(7) AND s_activateServo(7)));
	
	
	
	
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
	
	
	
	--counter_2: entity work.counter(counter_a)			generic map (max_g          => 4096,               -- maximum number
	--																				 outBit_g       => s_counter'length, -- number of output bit
	--																				 initialValue_g => 2048                -- the initial value after reset
	--																				)
	--																port map		(CLK            => s_TICK,
	--																				 RESET_n        => s_RESET,
	--																				 TC             => s_counter--(1)
	--																				);
	
	
	
	--========================================================================--
	-- LOOK UP TABLES                                                         --
	--========================================================================--
	
	SinusLUT_1: entity work.SinusLUT(SinusLUT_a)		port map		(LUT_IN         => s_counter,--(0),
																					 LUT_OUT        => s_LUT--(0)
																					);
	
	
	
	--SinusLUT_2: entity work.SinusLUT(SinusLUT_a)		port map		(LUT_IN         => s_counter,--(1),
	--																				 LUT_OUT        => s_LUT--(1)
	--																				);



																					
																					
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@--
	--========================================================================--
	-- SERVOS                                                                 --
	--========================================================================--
	--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@--
	
	
	
	servo_1: entity work.PWMServo(PWMServo_a)			generic map (invertHorn_g => '1',
																					 centerCorr_g => 16000 )
																	port map		(CLK          => CLOCK_50,
																					 RESET_n      => s_RESET,
																					 DUTYCYCLE    => s_dutycycle,--(0),
	
																					 PWMOut       => s_pwmSignal(0)
																					);
	
	
	
	servo_2: entity work.PWMServo(PWMServo_a)			generic map (invertHorn_g => '0',
																					 centerCorr_g => 88000 )
																	port map		(CLK          => CLOCK_50,
																					 RESET_n      => s_RESET,
																					 DUTYCYCLE    => s_dutycycle,--(1),
	
																					 PWMOut       => s_pwmSignal(1)
																					);
	
	
	
	servo_3: entity work.PWMServo(PWMServo_a)			generic map (invertHorn_g => '1',
																					 centerCorr_g => 8000 )
																	port map		(CLK          => CLOCK_50,
																					 RESET_n      => s_RESET,
																					 DUTYCYCLE    => s_dutycycle,--(2),
	
																					 PWMOut       => s_pwmSignal(2)
																					);
	
	
	
	servo_4: entity work.PWMServo(PWMServo_a)			generic map (invertHorn_g => '0',
																					 centerCorr_g => 48000 )
																	port map		(CLK          => CLOCK_50,
																					 RESET_n      => s_RESET,
																					 DUTYCYCLE    => s_dutycycle,--(3),
	
																					 PWMOut       => s_pwmSignal(3)
																					);
	
	
	
	servo_5: entity work.PWMServo(PWMServo_a)			generic map (invertHorn_g => '1',
																					 centerCorr_g => 15000 )
																	port map		(CLK          => CLOCK_50,
																					 RESET_n      => s_RESET,
																					 DUTYCYCLE    => s_dutycycle,--(4),
	
																					 PWMOut       => s_pwmSignal(4)
																					);
	
	
	
	servo_6: entity work.PWMServo(PWMServo_a)			generic map (invertHorn_g => '0',
																					 centerCorr_g => 56000 )
																	port map		(CLK          => CLOCK_50,
																					 RESET_n      => s_RESET,
																					 DUTYCYCLE    => s_dutycycle,--(5),
	
																					 PWMOut       => s_pwmSignal(5)
																					);
	
	
	
	servo_7: entity work.PWMServo(PWMServo_a)			generic map (invertHorn_g => '1',
																					 centerCorr_g => 48000 )
																	port map		(CLK          => CLOCK_50,
																					 RESET_n      => s_RESET,
																					 DUTYCYCLE    => s_dutycycle,--(6),
	
																					 PWMOut       => s_pwmSignal(6)
																					);
	
	
	
	servo_8: entity work.PWMServo(PWMServo_a)			generic map (invertHorn_g => '0',
																					 centerCorr_g => 60000 )
																	port map		(CLK          => CLOCK_50,
																					 RESET_n      => s_RESET,
																					 DUTYCYCLE    => s_dutycycle,--(7),
	
																					 PWMOut       => s_pwmSignal(7)
																					);
	
	
	
	p_dutycycle : process (SW(1), s_LUT)
	begin
	
		if (SW(1) = '0') then
			s_dutycycle <= "0111111111";
			--s_dutycycle(1) <= "0111111111";
			--s_dutycycle(2) <= "0111111111";
			--s_dutycycle(3) <= "0111111111";
			--s_dutycycle(4) <= "0111111111";
			--s_dutycycle(5) <= "0111111111";
			--s_dutycycle(6) <= "0111111111";
			--s_dutycycle(7) <= "0111111111";
		else
			s_dutycycle <= s_LUT;
			--s_dutycycle(1) <= s_LUT(1);
			--s_dutycycle(2) <= s_LUT(2);
			--s_dutycycle(3) <= s_LUT(3);
			--s_dutycycle(4) <= s_LUT(4);
			--s_dutycycle(5) <= s_LUT(5);
			--s_dutycycle(6) <= s_LUT(6);
			--s_dutycycle(7) <= s_LUT(7);
		end if;
		
	end process;

																		
	
	
end ServoTester_a;
