library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_interruptcontrol is
-- Port ( );
end test_interruptcontrol;

architecture test_interruptcontrol_behavioral of test_interruptcontrol is

    component InterruptControl is
    port (
        CLK : in std_logic;
        DivByZeroInterrupt : in std_logic;
        WriteEnable : in std_logic;
        InterruptNumber : in std_logic_vector(0 downto 0);
        WriteHandlerAddress : in std_logic_vector(31 downto 0);
        IsInterruptRaised : out std_logic;
        InterruptHandlerAddress : out std_logic_vector(31 downto 0)
    );
    end component InterruptControl;

    signal t_CLK : std_logic;
    signal t_DivByZeroInterrupt : std_logic;
    signal t_WriteEnable : std_logic;
    signal t_InterruptNumber : std_logic_vector(0 downto 0);
    signal t_WriteHandlerAddress : std_logic_vector(31 downto 0);
    signal t_IsInterruptRaised : std_logic;
    signal t_InterruptHandlerAddress : std_logic_vector(31 downto 0);

    constant ClkPeriod : time := 1 ns;
begin

    test_interruptcontrol_module: InterruptControl
    port map (
        -- Inputs
        CLK => t_CLK,
        DivByZeroInterrupt => t_DivByZeroInterrupt,
        WriteEnable => t_WriteEnable,
        InterruptNumber => t_InterruptNumber,
        WriteHandlerAddress => t_WriteHandlerAddress,
        -- Outputs
        IsInterruptRaised => t_IsInterruptRaised,
        InterruptHandlerAddress => t_InterruptHandlerAddress
    );

    clk_process: process begin
        t_CLK <= '1';
        wait for ClkPeriod / 2;  -- for 0.5 ns signal is '1'.
        t_CLK <= '0';
        wait for ClkPeriod / 2;  -- for next 0.5 ns signal is '0'.
    end process;

    stim_proc: process begin
        -- Set initial values for inputs
        t_DivByZeroInterrupt <= '0'; t_InterruptNumber <= "0"; t_WriteEnable <= '0'; t_WriteHandlerAddress <= (others => '0');

        wait for ClkPeriod / 2;

        -- Test Case 1: Check if DivByZeroInterrupt is raised, it causes an interrupt signal to be raised
        t_DivByZeroInterrupt <= '1';
        wait for ClkPeriod / 10;
        assert (t_IsInterruptRaised = '1' and t_InterruptHandlerAddress = x"00000020") report "Failed InterruptControl Test Case 1" severity error;

        wait for ClkPeriod * 9 / 10;



        wait;

    end process;

end test_interruptcontrol_behavioral;
