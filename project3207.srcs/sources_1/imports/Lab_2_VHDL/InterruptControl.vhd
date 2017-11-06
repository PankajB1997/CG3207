library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InterruptControl is
port (
    CLK : in std_logic;
    DivByZeroInterrupt : in std_logic;
    -- Add more interrupt(s)
    InterruptNumber : in std_logic_vector(0 downto 0);
    WriteEnable : in std_logic;
    WriteHandlerAddress : in std_logic_vector(31 downto 0);
    IsInterruptRaised : out std_logic;
    InterruptHandlerAddress : out std_logic_vector(31 downto 0)
);
end InterruptControl;

architecture InterruptControl_arch of InterruptControl is
    type HandlerAddressBank_type is array (0 to 1) of std_logic_vector(31 downto 0);
    signal HandlerAddressBank : HandlerAddressBank_type := (x"00000020", x"00000000");
begin

    IsInterruptRaised <= DivByZeroInterrupt;
    InterruptHandlerAddress <= HandlerAddressBank(0)
                               when DivByZeroInterrupt = '1'
                               else HandlerAddressBank(1);

    process(CLK)
    begin
        if CLK'event and CLK = '1' then
            if WriteEnable = '1' then
                HandlerAddressBank(to_integer(unsigned(InterruptNumber))) <= WriteHandlerAddress;
            end if;
        end if;
    end process;

end InterruptControl_arch;
