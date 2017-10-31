library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HazardUnit is
port(
    RA1E : in std_logic_vector(3 downto 0);
    RA2E : in std_logic_vector(3 downto 0);
    -- TODO: Add RA3E for Reg shifted Reg
    WA3M : in std_logic_vector(3 downto 0);
    WA3W : in std_logic_vector(3 downto 0);
    RegWriteM : in std_logic;
    RegWriteW : in std_logic;
    ALUResultM : in std_logic_vector(31 downto 0);
    ResultW : in std_logic_vector(31 downto 0);
    ToForwardD1E : out std_logic;
    ToForwardD2E : out std_logic;
    ForwardD1E : out std_logic_vector(31 downto 0);
    ForwardD2E : out std_logic_vector(31 downto 0)
);
end HazardUnit;

architecture Hazard_arch of HazardUnit is
    signal Match1EM : std_logic;
    signal Match2EM : std_logic;
    signal Match1EW : std_logic;
    signal Match2EW : std_logic;
begin
    Match1EM <= '1' when (RA1E = WA3M and RegWriteM = '1') else '0';
    Match1EW <= '1' when (RA1E = WA3W and RegWriteW = '1') else '0';

    Match2EM <= '1' when (RA2E = WA3M and RegWriteM = '1') else '0';
    Match2EW <= '1' when (RA2E = WA3W and RegWriteW = '1') else '0';

    ToForwardD1E <= Match1EM or Match1EW;
    ForwardD1E <= ALUResultM when Match1EM = '1' else ResultW;

    ToForwardD2E <= Match2EM or Match2EW;
    ForwardD2E <= ALUResultM when Match2EM = '1' else ResultW;
end Hazard_arch;
