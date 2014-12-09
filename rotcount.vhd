library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity rotcount is
	generic (
		max    : natural; -- maximum number
		outBit : natural -- number of output bit
	);
port(
		clk  : in std_logic;
		reset: in std_logic;
		PB   : in std_logic;
		TL   : in std_logic;
		TR   : in std_logic;

		TC   : out std_logic_vector(outBit-1 downto 0)
	);
end rotcount;



architecture rotcount_a of rotcount is

signal   counter: natural range 0 to max;

begin

    p_count: process(clk, reset)
        begin

            if(reset='0') then counter <= 0;
            elsif clk'event and (clk='1') then

                if(TL='1') then

                    if counter = 0 then
                        counter <= max;
                    else
                        counter <= counter - 1;
                    end if;

                elsif (TR='1') then

                    if counter = max then
                        counter <= 0;
                    else
                        counter <= counter + 1;
                    end if;

                elsif (PB='1') then

                    counter <= 0;

                end if;

            end if;

        end process;

    TC <= std_logic_vector(to_unsigned(counter,TC'length));

end rotcount_a;
