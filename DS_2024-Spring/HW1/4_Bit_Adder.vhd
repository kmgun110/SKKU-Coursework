library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Adder_4bit is
    port (x, y: in std_logic_vector(3 downto 0);   -- entity의 input은 x, y, cin
    cin : in std_logic;                             -- 이 떄, x, y는 4-bit vector
    sum : out std_logic_vector(3 downto 0);   -- entity의 output은 sum, cout
    cout : out std_logic);                     -- 이 때, sum은 4-bit vector
end Adder_4bit;

architecture Behavioral of Adder_4bit is
component Full_Adder   -- Full_Adder의 component를 불러옴
    port (x, y, cin : in std_logic;
    sum, cout : out std_logic);
end component;

signal c : std_logic_vector(3 downto 1);   -- 각 Full Adder의 cout을 bit vector로 선언

begin
    FA0: Full_Adder port map(x(0), y(0), cin, sum(0), c(1));   -- 첫번째 Full Adder
    FA1: Full_Adder port map(x(1), y(1), c(1), sum(1), c(2));   -- 두번째 Full Adder
    FA2: Full_Adder port map(x(2), y(2), c(2), sum(2), c(3));   -- 세번째 Full Adder
    FA3: Full_Adder port map(x(3), y(3), c(3), sum(3), cout);   -- 네번째 Full Adder
end Behavioral;
