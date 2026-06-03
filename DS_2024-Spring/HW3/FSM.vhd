library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TAIL_LIGHT is
    port(
        CLK : in std_logic;                       
        RESET : in std_logic;
        BREAK : in std_logic;
        LEFT : in std_logic;
        RIGHT : in std_logic;
        LED : out std_logic_vector(7 downto 0)
    );    
end TAIL_LIGHT;

architecture Behavioral of TAIL_LIGHT is
    signal state : std_logic_vector(2 downto 0);
    signal next_state : std_logic_vector(2 downto 0);
begin
    --state transition
    process(CLK, RESET)
      begin
        if(RESET = '0') then 
          state <= "000";
        elsif(CLK = '1' and CLK'event) then
          state <= next_state;
          end if;
    end process;
    
    --led out
    process(state)
      begin
        if(state = "000") then     
          LED <= "00000000";          -- if state is 'reset', led is 00000000
        elsif(state = "001") then
          LED <= "10000001";          -- if state is 'ready', led is 10000001
        elsif(state = "010") then
          LED <= "11111111";          -- if state is 'break', led is 11111111
        elsif(state = "011") then
          LED <= "11110000";          -- if state is 'left', led is 11110000
        elsif(state = "100") then
          LED <= "00001111";          -- if state is 'right', led is 00001111
        end if;
    end process;
    
    --next state
    process(RESET, BREAK, LEFT, RIGHT, state)
      begin
        if(state = "000") then      -- reset
          if(RESET = '0') then next_state <= "000";    -- reset = 0, next state = reset
          else next_state <= "001";                    -- reset = 1, next state = ready
          end if;
        elsif(state = "001") then    -- ready
          if(RESET = '0') then next_state <= "000";    -- reset = 0, next state = reset
          elsif(BREAK = '1') then next_state <= "010"; -- reset = 1 & break = 1, next state = break
          elsif(LEFT = '1' and RIGHT = '0') then next_state <= "011";
                                  -- reset = 1 & break = 0 & left = 1 & right = 0, next state = left
          elsif(LEFT = '0' and RIGHT = '1') then next_state <= "100";
                                  -- reset = 1 & break = 0 & left = 0 & right 1, next state = right
          else next_state <= "001";                    -- other case, next state = ready
          end if;    
        elsif(state = "010") then    -- break
          if(RESET = '0') then next_state <= "000";    -- reset = 0, next state = reset 
          elsif(BREAK = '1') then next_state <= "010"; -- reset = 1 & break = 1, next state = break
          else next_state <= "001";                    -- other case, next state = ready
          end if;
        elsif(state = "011") then    -- left
          if(RESET = '0') then next_state <= "000";   -- reset = 0, next state = reset
          elsif(BREAK = '1') then next_state <= "010";-- reset = 1 & break = 1, next state = break
          elsif(LEFT = '1') then next_state <= "011"; 
                                          -- reset = 1 & break = 0 & left = 1, next state = left
          elsif(LEFT = '0') then next_state <= "001";
                                          -- reset = 1 & break = 0 & left = 0, next state = ready
          end if; 
        elsif(state = "100") then    -- right
           if(RESET = '0') then next_state <= "000";  -- reset = 0, next state = reset
          elsif(BREAK = '1') then next_state <= "010";-- reset = 1 & break = 1, next state = break
          elsif(RIGHT = '1') then next_state <= "100";
                                          -- reset = 1 & break = 0 & right = 1, next state = right
          elsif(RIGHT = '0') then next_state <= "001";
                                          -- reset = 1 & break = 0 & right = 0, next state = ready
          end if; 
        end if;
    end process;
end Behavioral;
