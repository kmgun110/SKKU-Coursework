library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Seq_Detector_Mealy is
    port (
    CLK : in std_logic;       -- input : CLK, RESET, X
    RESET : in std_logic;
    X : in std_logic;
    Z : out std_logic         -- output : Z
    );
end Seq_Detector_Mealy;

architecture Behavioral of Seq_Detector_Mealy is
    type states is (s0, s1, s2, s3);                   -- 4 state
    signal state, next_state : states;
begin
-- state transition
    process (RESET, CLK)
    begin
        if (RESET = '0') then         -- if RESET = 0 (low active), state = s0
        state <= s0;
        elsif (CLK = '1' and CLK' event) then          -- rising edge of CLK, state = next state
        state <= next_state;    
        end if;
    end process;
    
    process (state, X)
    begin    
       case state is
       when s0 =>                                        -- present state = s0
        if X = '0' then Z <= '0'; next_state <= s0;
        else Z <= '0'; next_state <= s1;
        end if;
       when s1 =>                                        -- presesnt state = s1
        if X = '0' then Z <= '0'; next_state <= s2;
        else Z <= '0'; next_state <= s1;
        end if;
       when s2 =>                                        -- present state = s2
        if X = '0' then Z <= '0'; next_state <= s0;
        else Z <= '0'; next_state <= s3;
        end if;
       when s3 =>                                        -- present state = s3
        if X = '0' then Z <= '1'; next_state <= s2;
        else Z <= '0'; next_state <= s1;
        end if;
        end case;
    end process;
end Behavioral;
