library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Seq_Detector_Moore is
    port (
    CLK : in std_logic;                 -- input : CLK, RESET, X
    RESET : in std_logic;
    X : in std_logic; 
    Z : out std_logic                   -- output : Z
    );
end Seq_Detector_Moore;

architecture Behavioral of Seq_Detector_Moore is
    type states is (s0, s1, s2, s3, s4);             -- 5 states
    signal state, next_state : states;
begin
-- state transition
    process (RESET, CLK)
    begin
        if (RESET = '0') then                          -- if RESET = 0 (low active), state = s0
        state <= s0;
        elsif (CLK = '1' and CLK' event) then                    -- rising edge of CLK, state = next state
        state <= next_state;
        end if;
    end process;

-- outputs    
    process (state)                         -- sensitivity-list of output is state
    begin
        case state is
        when s0 => Z <= '0';                -- present state = s0, output = 0
        when s1 => Z <= '0';                -- present state = s1, output = 0
        when s2 => Z <= '0';                -- present state = s2, output = 0
        when s3 => Z <= '0';                -- present state = s3, output = 0
        when s4 => Z <= '1';                -- present state = s4, output = 1
        end case;
    end process;

-- next state    
    process (state, X)                    -- sensitivity-list of next state is state and X
    begin
        case state is
        when s0 =>                            -- present state = s0
         if X = '0' then next_state <= s0;
         else next_state <= s1;
         end if;
        when s1 =>                            -- present state = s1
         if X = '0' then next_state <= s2;
         else next_state <= s1;
         end if;
        when s2 =>                            -- present state = s2
         if X = '0' then next_state <= s0;
         else next_state <= s3;
         end if;
        when s3 =>                            -- present state = s3
         if X = '0' then next_state <= s4;
         else next_state <= s1;
         end if;
        when s4 =>                            -- present state = s4    
         if X = '0' then next_state <= s0;
         else next_state <= s3;
         end if;   
        end case;
    end process;                    
end Behavioral;
