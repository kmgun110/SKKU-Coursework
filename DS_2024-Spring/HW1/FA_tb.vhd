library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Full_Adder_tb is
end Full_Adder_tb;

architecture Behavioral of Full_Adder_tb is
    component Full_Adder port(  -- 앞서 설계한 Full_Adder의 component 불러옴
        x, y, cin : in std_logic;
        sum : out std_logic;
        cout : out std_logic); 
    end component;   
    
    signal X : std_logic :='0';   -- X, Y, Cin의 초기값 설정
    signal Y : std_logic :='1';
    signal Cin : std_logic :='1';
    signal Sum, Cout : std_logic; 
    
begin
    uut : Full_Adder port map (
        x => X,   -- 불러온 Full_Adder의 component를 선언한 signal에 할당
        y => Y,
        cin => Cin,
        sum => Sum,
        cout => Cout);
stim_proc : process
    begin
    X <= '1'; 
    Y <= '1';  
    wait for 10ns;  
    Cin <= '0';  -- 10ns 이후 Cin = 0
    wait for 10ns;
    X <= '0';  -- 10ns 이후 X = 0, Y = 0, Cin = 1
    Y <= '0';
    Cin <= '1';
    wait for 10ns;
    Cin <= '0';   -- 10ns 이후 Cin = 0
    wait for 10ns;
    X <= '1';   -- 10ns 이후 X = 1, Y =1 0
    Y <= '0';
    wait for 10ns;   -- 10ns 이후 process문의 처음으로 돌아감
  end process;
  
end Behavioral;
