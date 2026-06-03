library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Full_Adder is
    port(x, y, cin : in std_logic; -- entity의 input은 x, y, cin
    sum : out std_logic;
    cout : out std_logic);  -- entity의 output은 sum, cout
end Full_Adder;

architecture Behavioral of Full_Adder is

begin -- Full Adder에서 sum과 cout의 논리식 
    sum <= cin xor (x xor y);
    cout <= (x and y) or (x and cin) or (y and cin);

end Behavioral;
