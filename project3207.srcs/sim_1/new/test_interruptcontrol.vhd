library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_interruptcontrol is
-- Port ( );
end test_interruptcontrol;

architecture test_interruptcontrol_behavioral of test_interruptcontrol is

    component InterruptControl is
    port (
        DivByZeroInterrupt : in std_logic;
        IsInterruptRaised : out std_logic;
        InterruptHandlerAddress : out std_logic_vector(31 downto 0)
    );
    end component InterruptControl;

    signal t_DivByZeroInterrupt : std_logic;
    signal t_IsInterruptRaised : std_logic;
    signal t_InterruptHandlerAddress : std_logic_vector(31 downto 0);

begin

    test_interruptcontrol_module: InterruptControl
    port map (
        -- Inputs
        DivByZeroInterrupt => t_DivByZeroInterrupt,
        -- Outputs
        IsInterruptRaised => t_IsInterruptRaised,
        InterruptHandlerAddress => t_InterruptHandlerAddress
    );

    stim_proc: process begin

        -- Set initial values for inputs
        t_DivByZeroInterrupt <= '0';

        -- Test Case 1: Check if DivByZeroInterrupt is raised, it causes an interrupt signal to be raised
        t_DivByZeroInterrupt <= '1';
        wait for 5 ns;
        assert (t_IsInterruptRaised = '1' and t_InterruptHandlerAddress = x"00000020") report "Failed InterruptControl Test Case 1" severity error;

        wait;

    end process;

end test_interruptcontrol_behavioral;
