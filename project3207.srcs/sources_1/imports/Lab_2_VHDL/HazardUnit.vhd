library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity HazardUnit is
port(
    RA1D : in std_logic_vector(3 downto 0);
    RA1E : in std_logic_vector(3 downto 0);
    RA2D : in std_logic_vector(3 downto 0);
    RA2E : in std_logic_vector(3 downto 0);
    RA2M : in std_logic_vector(3 downto 0);
    RA3D : in std_logic_vector(3 downto 0);
    RA3E : in std_logic_vector(3 downto 0);
    WA4E : in std_logic_vector(3 downto 0);
    WA4M : in std_logic_vector(3 downto 0);
    WA4W : in std_logic_vector(3 downto 0);
    RegWriteE : in std_logic;
    RegWriteM : in std_logic;
    RegWriteW : in std_logic;
    MemWriteD : in std_logic;
    MemWriteM : in std_logic;
    MemToRegE : in std_logic;
    MemToRegW : in std_logic;
    PCSrcE : in std_logic;
    PCSrcW : in std_logic;
    ALUResultE : in std_logic_vector(31 downto 0);
    ALUResultM : in std_logic_vector(31 downto 0);
    ResultW : in std_logic_vector(31 downto 0);
    ToForwardD1E : out std_logic;
    ToForwardD2E : out std_logic;
    ToForwardD3E : out std_logic;
    ToForwardWriteDataM : out std_logic;
    ToForwardPC_INW : out std_logic;
    ForwardD1E : out std_logic_vector(31 downto 0);
    ForwardD2E : out std_logic_vector(31 downto 0);
    ForwardD3E : out std_logic_vector(31 downto 0);
    ForwardWriteDataM : out std_logic_vector(31 downto 0);
    ForwardPC_INW : out std_logic_vector(31 downto 0);
    StallF : out std_logic;
    StallD : out std_logic;
    FlushD : out std_logic;
    FlushE : out std_logic
);
end HazardUnit;

architecture Hazard_arch of HazardUnit is
    signal Match1EM : std_logic;
    signal Match1EW : std_logic;

    signal Match2EM : std_logic;
    signal Match2EW : std_logic;

    signal Match3EM : std_logic;
    signal Match3EW : std_logic;

    signal LDRStall : std_logic;
begin
    -- Resolve Read After Write (RAW) Data Hazard
    Match1EM <= '1' when (RA1E = WA4M and RegWriteM = '1') else '0';
    Match1EW <= '1' when (RA1E = WA4W and RegWriteW = '1') else '0';

    Match2EM <= '1' when (RA2E = WA4M and RegWriteM = '1') else '0';
    Match2EW <= '1' when (RA2E = WA4W and RegWriteW = '1') else '0';

    Match3EM <= '1' when (RA3E = WA4M and RegWriteM = '1') else '0';
    Match3EW <= '1' when (RA3E = WA4W and RegWriteW = '1') else '0';

    ToForwardD1E <= Match1EM or Match1EW;
    ForwardD1E <= ALUResultM when Match1EM = '1' else ResultW;

    ToForwardD2E <= Match2EM or Match2EW;
    ForwardD2E <= ALUResultM when Match2EM = '1' else ResultW;

    ToForwardD3E <= Match3EM or Match3EW;
    ForwardD3E <= ALUResultM when Match3EM = '1' else ResultW;

    -- Resolve Mem-Mem Copy Data Hazard
    ToForwardWriteDataM <= '1' when ((RA2M = WA4W) and (MemWriteM = '1') and (MemtoRegW = '1') and (RegWriteW = '1')) else '0';
    ForwardWriteDataM <= ResultW;

    -- Resolve Load and Use Data Hazard
    LDRStall <= '1' when ((
                             RA1D = WA4E or
                             (RA2D = WA4E and MemWriteD = '0') or
                             RA3D = WA4E
                          ) and
                          MemToRegE = '1' and
                          RegWriteE = '1')
                    else '0';
    StallF <= LDRStall;
    StallD <= LDRStall;

    -- Resolve Control Hazard
    FlushD <= PCSrcE;
    ToForwardPC_INW <= '1' when ((PCSrcE = '1') or (PCSrcW = '1' and MemToRegW = '1')) else '0';
    ForwardPC_INW <= ResultW when (PCSrcW = '1' and MemToRegW = '1') else ALUResultE;

    -- Used in Load and Use and Control Hazards
    FlushE <= '1' when (LDRStall = '1' or PCSrcE = '1') else '0';

end Hazard_arch;
