library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Adder_4bit_tb is
end Adder_4bit_tb;

architecture Behavioral of Adder_4bit_tb is
    component Adder_4bit port (   -- 앞서 설계한 Adder_4bit의 component 불러옴
      x, y : in std_logic_vector(3 downto 0);
      cin : in std_logic; 
      sum : out std_logic_vector(3 downto 0);
      cout : out std_logic);
  end component;
  
  signal X : std_logic_vector(3 downto 0); 
  signal Y : std_logic_vector(3 downto 0);
  signal Cin : std_logic; 
  signal Sum : std_logic_vector(3 downto 0); 
  signal Cout : std_logic; 
      
begin
    uut : Adder_4bit port map (
      x => X,   -- 불러온 Adder_4bit의 component를 앞서 선언한 signal에 할당
      y => Y,
      cin => Cin,
      sum => Sum,
      cout => Cout);
stim_proc : process
    begin
    X <= "1111";
    Y <= "0001";
    Cin <= '1';
    wait for 10ns;
    Cin <= '0';
    wait for 10ns;
    X <= "0101";
    Y <= "1110";
    wait for 10ns;
    X <= "1100";
    Y <= "0111";
    Cin <= '1';
    wait for 10ns;
    X <= "1111";
    Y <= "1111";
    wait for 10ns;
    X <= "0110";
    Y <= "1001";
    Cin <= '0';
    wait for 10ns;   -- 10ns 이후 process문의 처음으로 돌아감
  end process;
    
end Behavioral;
