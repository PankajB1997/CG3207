library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_regfile is
-- Port ( );
end test_regfile;

architecture test_regfile_behavioral of test_regfile is

    component RegFile
    port (
        CLK : in std_logic;
        WE3 : in std_logic;
        A1  : in std_logic_vector (3 downto 0);
        A2  : in std_logic_vector (3 downto 0);
        A3  : in std_logic_vector (3 downto 0);
        WD3 : in std_logic_vector (31 downto 0);
        R15 : in std_logic_vector (31 downto 0);
        RD1 : out std_logic_vector (31 downto 0);
        RD2 : out std_logic_vector (31 downto 0));
    end component;

    signal t_CLK : std_logic;
    signal t_WE3 : std_logic;
    signal t_A1  : std_logic_vector (3 downto 0);
    signal t_A2  : std_logic_vector (3 downto 0);
    signal t_A3  : std_logic_vector (3 downto 0);
    signal t_WD3 : std_logic_vector (31 downto 0);
    signal t_R15 : std_logic_vector (31 downto 0);
    signal t_RD1 : std_logic_vector (31 downto 0);
    signal t_RD2 : std_logic_vector (31 downto 0);

    constant ClkPeriod : time := 1 ns;
begin

    test_regfile_module : RegFile
    port map (
        -- Inputs
        CLK => t_CLK,
        WE3 => t_WE3,
        A1  => t_A1,
        A2  => t_A2,
        A3  => t_A3,
        WD3 => t_WD3,
        R15 => t_R15,
        -- Outputs
        RD1 => t_RD1,
        RD2 => t_RD2
    );

    clk_process: process begin
        t_CLK <= '1';
        wait for ClkPeriod / 2;  -- for 0.5 ns signal is '1'.
        t_CLK <= '0';
        wait for ClkPeriod / 2;  -- for next 0.5 ns signal is '0'.
    end process;

    stim_proc: process begin

        -- Set initial values for inputs
        t_WE3 <= '0'; t_A1 <= x"0"; t_A2 <= x"0"; t_A3 <= x"0"; t_WD3 <= (others => '0'); t_R15 <= (others => '0');

        -- Test case 1: Checking if a value is not written to destination register when write is disabled
        t_A3 <= x"0"; t_WD3 <= x"00FF00FF"; t_WE3 <= '1';
        wait for ClkPeriod / 6;
        t_WE3 <= '0';
        wait for ClkPeriod / 6;
        t_A1 <= x"0";
        assert (t_RD1 = x"00FF00FF") report "Failed RegFile Test Case 1.1" severity error;
        wait for ClkPeriod / 3;
        assert (t_RD1 = x"00FF00FF") report "Failed RegFile Test Case 1.2" severity error;

        wait for ClkPeriod / 3;

        -- Test case 2: Checking if the value stored in source register denoted by A1 is successfully copied into RD1
        -- Store a value in R3 and add R3 as first source register
        t_A3 <= x"3"; t_WD3 <= x"F0F0F0F0"; t_WE3 <= '1';
        t_A1 <= x"3";
        wait for ClkPeriod / 2;
        -- Check if R3 value is successfully copied into RD1
        assert (t_RD1 = x"F0F0F0F0") report "Failed RegFile Test Case 2" severity error;

        wait for ClkPeriod / 2;

        -- Test case 3: Checking if the value stored in source register denoted by A2 is successfully copied into RD2
        -- Testing A2 -> RD2 connection combinationally and not as a clocked process
        t_A2 <= x"0";
        wait for ClkPeriod / 10;
        -- Check if R5 value is successfully copied into RD2
        assert (t_RD2 = x"00FF00FF") report "Failed RegFile Test Case 3" severity error;

        wait for ((ClkPeriod * 9) / 10);

        -- Test case 4: Checking if values written to both source registers are simultaneously copied to RD1 and RD2
        -- Store values in registers R6 and R8 and add them as first and second source registers respectively
        t_A3 <= x"6"; t_WD3 <= x"0000FFFF"; t_WE3 <= '1';
        wait for ClkPeriod / 4;
        t_A3 <= x"8"; t_WD3 <= x"FF00FF00"; t_WE3 <= '1';
        wait for ClkPeriod / 2;
        t_A1 <= x"6"; t_A2 <= x"8";
        wait for ClkPeriod / 2;
        assert (t_RD1 = x"0000FFFF" and t_RD2 = x"FF00FF00") report "Failed RegFile Test Case 4" severity error;

        wait for ClkPeriod / 4;

        -- Test case 5: Testing if R15 value shows up at RD1 when A1 points to R15
        t_R15 <= x"F0FF0FF0"; t_A1 <= x"F";
        wait for ClkPeriod / 2;
        assert (t_RD1 = x"F0FF0FF0") report "Failed RegFile Test Case 5" severity error;

        wait for ClkPeriod / 2;

        -- Test case 6: Testing if R15 gets directly written by RegFile - shouldn't be allowed
        -- Write a value to R15
        t_A3 <= x"F"; t_WD3 <= x"0FF00FF0"; t_WE3 <= '1';
        -- point first source register to R15 to check its value at RD1
        t_A1 <= x"F";
        wait for ClkPeriod / 2;
        -- asserting R15 to still have the same value that was set to it in the previous case
        assert (t_RD1 = x"F0FF0FF0") report "Failed RegFile Test Case 6" severity error;

        wait for ClkPeriod / 2;

        wait;

    end process;

end test_regfile_behavioral;
