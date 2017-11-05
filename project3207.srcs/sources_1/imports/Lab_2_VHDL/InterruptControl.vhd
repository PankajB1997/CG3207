library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity InterruptControl is
port (
    DivByZeroInterrupt : in std_logic;
    IsInterruptRaised : out std_logic
);
end InterruptControl;

architecture InterruptControl_arch of InterruptControl is

begin

    IsInterruptRaised <= DivByZeroInterrupt;

end InterruptControl_arch;
