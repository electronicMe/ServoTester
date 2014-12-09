library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.ALL;



entity PWMServo is
generic (
	frequency_g     : natural   :=       20; -- typ       20, in ns
	periode_g       : natural   := 20000000; -- typ 20000000, in ns, must be devidable by frequency_g
	minOn_g         : natural   :=  1000000; -- typ  1000000, in ns, must be devidable by frequency_g, must be smaller than maxOn_g
	maxOn_g         : natural   :=  2000000; -- typ  2000000, in ns, must be devidable by frequency_g, must be bigger than minOn_g
	
	invertHorn_g    : std_logic :=      '0'; -- typ '0', if '1', servo horn angle will be inverted
	centerCorr_g    : integer   :=        0; -- typ 0, in ns, used to correct the center of the servo horn. Modifies the on periode additive.
	
	resolution_g    : natural   :=     1024; -- typ 1024, numeric value of resolution
	resolutionBit_g : natural   :=       10  -- typ   10, bit value of resolution
);
port (
	CLK       : in std_logic;
	RESET_n   : in std_logic;
	DUTYCYCLE : in std_logic_vector(resolutionBit_g - 1 downto 0);
	
	PWMOut    : out std_logic
);
end PWMServo;



architecture PWMServo_a of PWMServo is

type state_type is (sON, sOFF);

signal periodeTimer: natural range 0 to periode_g; -- contains the time of the periode in ns
signal onTimer     : natural range 0 to maxOn_g;   -- contains the time of the on time in ns

signal outState      : state_type;

begin

	p_state: process(RESET_n, CLK)
	begin
	
		if (RESET_n = '0') then
			
			periodeTimer <= 0;
			onTimer      <= 0;
			outState     <= sOFF;
			
		else
			if ((CLK = '1') AND (CLK'event)) then
				
				periodeTimer <= periodeTimer + frequency_g;
				onTimer      <= onTimer      + frequency_g;
				
				if (periodeTimer >= periode_g) then
					-- periode is over. reset counters
					periodeTimer <= 0;
					onTimer      <= 0;
					outState     <= sON;
				else
					
					-- if output is on, check if ON periode is probably over
					if (outState = sON) then
					
						-- check if ON periode is over
						if (onTimer > minOn_g) then
						
							-- minimum on time is over. check if dutycycle is over
							if (invertHorn_g = '0') then
								if (onTimer > (((((maxOn_g - minOn_g) / resolution_g) * to_integer(unsigned(DUTYCYCLE))) + minOn_g) + centerCorr_g)) then
									-- on periode is over
									outState <= sOFF;
								end if;
							else
								if (onTimer > (((((maxOn_g - minOn_g) / resolution_g) * (resolution_g - to_integer(unsigned(DUTYCYCLE)))) + minOn_g) + centerCorr_g)) then
									-- on periode is over
									outState <= sOFF;
								end if;
							end if;
							
						end if;
						
					end if;
				end if;
			
			end if;
		end if;
	
	end process;
	
	
	
	p_PWM: process(outState)
	begin
	
		case outState is
			when sON => PWMOut <= '1';
			when others => PWMOut <= '0';
		end case;
		
	end process;

end architecture;


