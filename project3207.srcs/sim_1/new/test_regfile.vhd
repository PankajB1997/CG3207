library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_regfile is
-- Port ( );
end test_regfile;

architecture test_regfile_behavioral of test_regfile is

    component RegFile is port (
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
        WE3 <= '0'; A1 <= (others => '0'); A2 <= (others => '0'); A3 <= (others => '0'); WD3 <= (others => '0'); R15 <= (others => '0');

        

        wait;

    end process;

end test_regfile_behavioral;
