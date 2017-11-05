library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity InterruptControl is
port (
    DivByZeroInterrupt : in std_logic;
    IsInterruptRaised : out std_logic;
    InterruptHandlerAddress : out std_logic_vector(31 downto 0)
);
end InterruptControl;

architecture InterruptControl_arch of InterruptControl is

begin

    IsInterruptRaised <= DivByZeroInterrupt;
    InterruptHandlerAddress <= x"00000020";

end InterruptControl_arch;
