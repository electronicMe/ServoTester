library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity counter is
	generic (
		max_g          : natural;     -- maximum number
		outBit_g       : natural;     -- number of output bit
		initialValue_g : natural := 0 -- the initial value after reset
	);
port(
		CLK    : in  std_logic;
		RESET_n: in  std_logic;

		TC     : out std_logic_vector(outBit_g-1 downto 0)
	);
end counter;



architecture counter_a of counter is

signal counter: natural range 0 to max_g := initialValue_g;
begin

	p_count: process(CLK, RESET_n)
	begin

		if(RESET_n='0') then counter <= 0;
		elsif CLK'event and (CLK='1') then

			if (counter >= max_g) then
				counter <= 0;
			else
				counter <= counter + 1;
			end if;
		
		end if;
	
	end process;

	TC <= std_logic_vector(to_unsigned(counter,TC'length));

end counter_a;
