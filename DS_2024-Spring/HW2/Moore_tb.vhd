library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity  Seq_Detector_Moore_TB is
end Seq_Detector_Moore_TB;

architecture Behavioral of Seq_Detector_Moore_TB is
    component Seq_Detector_Moore is
        port (
            CLK : in std_logic;
            RESET : in std_logic;
            X : in std_logic;
            Z : out std_logic);
    end component;

    signal CLK : std_logic;
    signal RESET : std_logic;
    signal X, Z : std_logic;
begin
    SD : Seq_Detector_Moore port map (CLK=>CLK, RESET=>RESET, X=>X, Z=>Z);
    
    rst_operation : process
    begin
        RESET <= '0';
        wait for 15ns;

        RESET <= '1';
        wait for 80ns;

        RESET <= '0';
        wait for 10ns;

        RESET <= '1';
        wait;
    end process;

    clk_operation : process
    begin
        CLK <= '1';
        wait for 5ns;

        CLK <= '0';
        wait for 5ns;
    end process;

    input_operation : process
    begin
        X <= '1';
        wait for 25ns;

        X <= '0';
        wait for 10ns;

        X <= '1';
        wait for 10ns;

        X <= '0';
        wait for 10ns;

        X <= '1';
        wait for 10ns;

        X <= '0';
        wait for 10ns;

        X <= '1';
        wait for 10ns;

        X <= '0';
        wait for 10ns;
        
        X <= '1';
        wait for 10ns;

        X <= '0';
        wait for 10ns;

        X <= '1';
        wait for 10ns;

        X <= '0';
        wait for 10ns;

        X <= '1';
        wait for 10ns;

        X <= '0';
        wait;
    end process;
end Behavioral;