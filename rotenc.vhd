library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity rotenc is
  port(
    CLK : in std_logic;
    reset    : in std_logic;
    A        : in std_logic;
    B        : in std_logic;
    
    TL       : out std_logic;
    TR       : out std_logic
  );
end rotenc;



architecture rotenc_a of rotenc is

type state_type is (s00,
                    sR00,
                    sL00,
                    sw00,
                    s11,
                    sR11,
                    sL11,
                    sw11);

signal state, nxt_state : state_type;
signal rot_A, rot_B     : std_logic;
signal rot_ab           : std_logic_vector(1 downto 0);

begin
  
  rot_ab <= rot_A & rot_B;
  
  --p_filter : process(CLOCK_50)
  --begin

  --  if CLOCK_50'event and CLOCK_50='1' then
  --   rot_ab <= A&B;
  --    case rot_ab is
  --      when "00" => rot_A <= '0';
  --      when "11" => rot_A <= '1';
  --      when "10" => rot_B <= '0';
  --      when "01" => rot_B <= '1';
  --      when others => 
  --   end case;
  --  end if;

  --end process;






  ------------------------------------
  -- p_next_state
  ------------------------------------
  p_next_state: process(state, rot_ab)
  begin
    nxt_state <= state;

    case state is


    ------------------------------------
    -- s00
    ------------------------------------
      when s00 =>
        case rot_ab is
          when "00"   => nxt_state <= s00;
          when "01"   => nxt_state <= sL00;
          when "10"   => nxt_state <= sR00;
          when "11"   => nxt_state <= s11;
          when others => nxt_state <= s00;
        end case;


    ------------------------------------
    -- s11
    ------------------------------------
      when s11 =>
        case rot_ab is
          when "00"   => nxt_state <= s00;
          when "01"   => nxt_state <= sR11;
          when "10"   => nxt_state <= sL11;
          when "11"   => nxt_state <= s11;
          when others => nxt_state <= s11;
        end case;


    ------------------------------------
    -- sR00 sL00
    ------------------------------------
      when sR00 | sL00 => nxt_state <= sW11;


    ------------------------------------
    -- sR11 sL11
    ------------------------------------
      when sR11 | sL11 => nxt_state <= sW00;


    ------------------------------------
    -- sW00
    ------------------------------------
      when sW00 =>
        if rot_ab = "00" then
          nxt_state <= s00;
        end if;


    ------------------------------------
    -- sW11
    ------------------------------------
      when sW11 =>
        if rot_ab = "11" then
          nxt_state <= s11;
        end if;
 
      end case;

  end process;  -- p_next_state





  
  ------------------------------------
  -- p_state_reg
  ------------------------------------
  p_state_reg: process(CLK, reset)
  begin

  if reset = '0' then
    state <= s00;
    TL <= '0';
    TR <= '0';

  elsif(CLK='1' and CLK'event) then
    state <= nxt_state;
    TL <= '0';
    TR <= '0';

    case nxt_state is
      when sR00 | sR11 => TR <= '1';
      when sL00 | sL11 => TL <= '1';
      when others =>
    end case;
  end if;

  end process;  -- p_state_reg



end rotenc_a;