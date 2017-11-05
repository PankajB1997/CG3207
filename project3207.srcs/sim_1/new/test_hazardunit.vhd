library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_hazardunit is
--  Port ( );
end test_hazardunit;

architecture test_hazardunit_behavioral of test_hazardunit is

    component HazardUnit
    port (
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
        MCycleBusyE : in std_logic;
        MCycleStartE : in std_logic;
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
        StallE : out std_logic;
        FlushD : out std_logic;
        FlushE : out std_logic;
        FlushM : out std_logic);
    end component;

    signal t_RA1D : std_logic_vector(3 downto 0);
    signal t_RA1E : std_logic_vector(3 downto 0);
    signal t_RA2D : std_logic_vector(3 downto 0);
    signal t_RA2E : std_logic_vector(3 downto 0);
    signal t_RA2M : std_logic_vector(3 downto 0);
    signal t_RA3D : std_logic_vector(3 downto 0);
    signal t_RA3E : std_logic_vector(3 downto 0);
    signal t_WA4E : std_logic_vector(3 downto 0);
    signal t_WA4M : std_logic_vector(3 downto 0);
    signal t_WA4W : std_logic_vector(3 downto 0);
    signal t_RegWriteE : std_logic;
    signal t_RegWriteM : std_logic;
    signal t_RegWriteW : std_logic;
    signal t_MemWriteD : std_logic;
    signal t_MemWriteM : std_logic;
    signal t_MemToRegE : std_logic;
    signal t_MemToRegW : std_logic;
    signal t_PCSrcE : std_logic;
    signal t_PCSrcW : std_logic;
    signal t_ALUResultE : std_logic_vector(31 downto 0);
    signal t_ALUResultM : std_logic_vector(31 downto 0);
    signal t_ResultW : std_logic_vector(31 downto 0);
    signal t_MCycleBusyE : std_logic;
    signal t_MCycleStartE : std_logic;
    signal t_ToForwardD1E : std_logic;
    signal t_ToForwardD2E : std_logic;
    signal t_ToForwardD3E : std_logic;
    signal t_ToForwardWriteDataM : std_logic;
    signal t_ToForwardPC_INW : std_logic;
    signal t_ForwardD1E : std_logic_vector(31 downto 0);
    signal t_ForwardD2E : std_logic_vector(31 downto 0);
    signal t_ForwardD3E : std_logic_vector(31 downto 0);
    signal t_ForwardWriteDataM : std_logic_vector(31 downto 0);
    signal t_ForwardPC_INW : std_logic_vector(31 downto 0);
    signal t_StallF : std_logic;
    signal t_StallD : std_logic;
    signal t_StallE : std_logic;
    signal t_FlushD : std_logic;
    signal t_FlushE : std_logic;
    signal t_FlushM : std_logic;

begin

    test_hazardunit_module: HazardUnit
    port map (
        -- Inputs
        RA1D => t_RA1D,
        RA1E => t_RA1E,
        RA2D => t_RA2D,
        RA2E => t_RA2E,
        RA2M => t_RA2M,
        RA3D => t_RA3D,
        RA3E => t_RA3E,
        WA4E => t_WA4E,
        WA4M => t_WA4M,
        WA4W => t_WA4W,
        RegWriteE => t_RegWriteE,
        RegWriteM => t_RegWriteM,
        RegWriteW => t_RegWriteW,
        MemWriteD => t_MemWriteD,
        MemWriteM => t_MemWriteM,
        MemToRegE => t_MemToRegE,
        MemToRegW => t_MemToRegW,
        PCSrcE => t_PCSrcE,
        PCSrcW => t_PCSrcW,
        ALUResultE => t_ALUResultE,
        ALUResultM => t_ALUResultM,
        ResultW => t_ResultW,
        MCycleBusyE => t_MCycleBusyE,
        MCycleStartE => t_MCycleStartE,
        -- Outputs
        ToForwardD1E => t_ToForwardD1E,
        ToForwardD2E => t_ToForwardD2E,
        ToForwardD3E => t_ToForwardD3E,
        ToForwardWriteDataM => t_ToForwardWriteDataM,
        ToForwardPC_INW => t_ToForwardPC_INW,
        ForwardD1E => t_ForwardD1E,
        ForwardD2E => t_ForwardD2E,
        ForwardD3E => t_ForwardD3E,
        ForwardWriteDataM => t_ForwardWriteDataM,
        ForwardPC_INW => t_ForwardPC_INW,
        StallF => t_StallF,
        StallD => t_StallD,
        StallE => t_StallE,
        FlushD => t_FlushD,
        FlushE => t_FlushE,
        FlushM => t_FlushM
    );

    stim_proc: process begin

        -- Set initial values for inputs
        t_RA1D <= (others => '0'); t_RA1E <= (others => '0'); t_RA2D <= (others => '0'); t_RA2E <= (others => '0'); t_RA2M <= (others => '0'); t_RA3D <= (others => '0'); t_RA3E <= (others => '0'); t_WA4E <= (others => '0'); t_WA4M <= (others => '0'); t_WA4W <= (others => '0'); t_RegWriteE <= '0'; t_RegWriteM <= '0'; t_RegWriteW <= '0'; t_MemWriteD <= '0'; t_MemWriteM <= '0'; t_MemToRegE <= '0'; t_MemToRegW <= '0'; t_PCSrcE <= '0'; t_PCSrcW <= '0'; t_ALUResultE <= (others => '0'); t_ALUResultM <= (others => '0'); t_ResultW <= (others => '0'); t_MCycleBusyE <= '0'; t_MCycleStartE <= '0';
        wait for 5 ns;

        -------------------------------------------------------------------
        -- Tests for Read After Write (RAW) data hazard -------------------
        -------------------------------------------------------------------

        -- Note: No matter what, one of the values will be output, but the
        -- ToForwardDxE bits will be 0 if no forwarding is to occur.
        -- If there is no match, ResultW will be forwarded by default.

        -- Test Case 1: Registers read and written are different, no forwarding.
        t_RA1E <= x"1"; t_RA2E <= x"2"; t_RA3E <= x"3"; t_WA4M <= x"4"; t_WA4W <= x"5"; t_RegWriteM <= '1'; t_RegWriteW <= '1'; t_ALUResultM <= x"00000001"; t_ResultW <= x"00000002";
        wait for 5 ns;
        assert (t_ToForwardD1E = '0' and t_ToForwardD2E = '0' and t_ToForwardD3E = '0' and t_ForwardD1E = x"00000002" and t_ForwardD2E = x"00000002" and t_ForwardD3E = x"00000002") report "Failed HazardUnit Test Case 1" severity error;

        -- Test Case 2: Registers match, but not written, so no forwarding.
        t_RA1E <= x"1"; t_RA2E <= x"2"; t_RA3E <= x"1"; t_WA4M <= x"1"; t_WA4W <= x"2"; t_RegWriteM <= '0'; t_RegWriteW <= '0'; t_ALUResultM <= x"00000001"; t_ResultW <= x"00000002";
        wait for 5 ns;
        assert (t_ToForwardD1E = '0' and t_ToForwardD2E = '0' and t_ToForwardD3E = '0' and t_ForwardD1E = x"00000002" and t_ForwardD2E = x"00000002" and t_ForwardD3E = x"00000002") report "Failed HazardUnit Test Case 2" severity error;

        -- Test Case 3: One register matches with Memory, is forwarded.
        t_RA1E <= x"1"; t_RA2E <= x"2"; t_RA3E <= x"4"; t_WA4M <= x"2"; t_WA4W <= x"3"; t_RegWriteM <= '1'; t_RegWriteW <= '1'; t_ALUResultM <= x"00000001"; t_ResultW <= x"00000002";
        wait for 5 ns;
        assert (t_ToForwardD1E = '0' and t_ToForwardD2E = '1' and t_ToForwardD3E = '0' and t_ForwardD1E = x"00000002" and t_ForwardD2E = x"00000001" and t_ForwardD3E = x"00000002") report "Failed HazardUnit Test Case 3" severity error;

        -- Test Case 4: One register matches with Writeback, is forwarded.
        t_RA1E <= x"1"; t_RA2E <= x"2"; t_RA3E <= x"4"; t_WA4M <= x"3"; t_WA4W <= x"1"; t_RegWriteM <= '1'; t_RegWriteW <= '1'; t_ALUResultM <= x"00000001"; t_ResultW <= x"00000002";
        wait for 5 ns;
        assert (t_ToForwardD1E = '1' and t_ToForwardD2E = '0' and t_ToForwardD3E = '0' and t_ForwardD1E = x"00000002" and t_ForwardD2E = x"00000002" and t_ForwardD3E = x"00000002") report "Failed HazardUnit Test Case 4" severity error;

        -- Test Case 5: One register matches with Writeback, one matches with Memory.
        t_RA1E <= x"1"; t_RA2E <= x"2"; t_RA3E <= x"3"; t_WA4M <= x"2"; t_WA4W <= x"3"; t_RegWriteM <= '1'; t_RegWriteW <= '1'; t_ALUResultM <= x"00000001"; t_ResultW <= x"00000002";
        wait for 5 ns;
        assert (t_ToForwardD1E = '0' and t_ToForwardD2E = '1' and t_ToForwardD3E = '1' and t_ForwardD1E = x"00000002" and t_ForwardD2E = x"00000001" and t_ForwardD3E = x"00000002") report "Failed HazardUnit Test Case 5" severity error;

        -- Test Case 6: Register matches with both Memory and Writeback, ALUResultM forwarded.
        t_RA1E <= x"1"; t_RA2E <= x"2"; t_RA3E <= x"3"; t_WA4M <= x"3"; t_WA4W <= x"3"; t_RegWriteM <= '1'; t_RegWriteW <= '1'; t_ALUResultM <= x"00000001"; t_ResultW <= x"00000002";
        wait for 5 ns;
        assert (t_ToForwardD1E = '0' and t_ToForwardD2E = '0' and t_ToForwardD3E = '1' and t_ForwardD1E = x"00000002" and t_ForwardD2E = x"00000002" and t_ForwardD3E = x"00000001") report "Failed HazardUnit Test Case 6" severity error;

        -------------------------------------------------------------------
        -- Tests for Mem-Mem Copy data hazard -----------------------------
        -------------------------------------------------------------------

        -- Test Case 7: Registers match, but Memory Stage doesn't have STR
        t_RA2M <= x"1"; t_WA4W <= x"1"; t_MemWriteM <= '0'; t_MemToRegW <= '1'; t_RegWriteW <= '1'; t_ResultW <= x"00000011";
        wait for 5 ns;
        assert (t_ToForwardWriteDataM = '0' and t_ForwardWriteDataM = x"00000011") report "Failed HazardUnit Test Case 7" severity error;

        -- Test Case 8: Registers match, but Writeback Stage doesn't have LDR
        t_RA2M <= x"2"; t_WA4W <= x"2"; t_MemWriteM <= '1'; t_MemToRegW <= '0'; t_RegWriteW <= '1'; t_ResultW <= x"00001111";
        wait for 5 ns;
        assert (t_ToForwardWriteDataM = '0' and t_ForwardWriteDataM = x"00001111") report "Failed HazardUnit Test Case 8" severity error;

        -- Test Case 9: Registers match, but LDR is not executed
        t_RA2M <= x"3"; t_WA4W <= x"3"; t_MemWriteM <= '1'; t_MemToRegW <= '1'; t_RegWriteW <= '0'; t_ResultW <= x"00000000";
        wait for 5 ns;
        assert (t_ToForwardWriteDataM = '0' and t_ForwardWriteDataM = x"00000000") report "Failed HazardUnit Test Case 9" severity error;

        -- Test Case 10: Other conditions are met, but registers don't match
        t_RA2M <= x"4"; t_WA4W <= x"5"; t_MemWriteM <= '1'; t_MemToRegW <= '1'; t_RegWriteW <= '1'; t_ResultW <= x"11111111";
        wait for 5 ns;
        assert (t_ToForwardWriteDataM = '0' and t_ForwardWriteDataM = x"11111111") report "Failed HazardUnit Test Case 10" severity error;

        -- Test Case 11: Registers match and other conditions are also met
        t_RA2M <= x"6"; t_WA4W <= x"6"; t_MemWriteM <= '1'; t_MemToRegW <= '1'; t_RegWriteW <= '1'; t_ResultW <= x"10000000";
        wait for 5 ns;
        assert (t_ToForwardWriteDataM = '1' and t_ForwardWriteDataM = x"10000000") report "Failed HazardUnit Test Case 11" severity error;

        -------------------------------------------------------------------
        -- Tests for Load and Use data hazard -----------------------------
        -------------------------------------------------------------------

        -- Test Case 12: None of the Source Registers in Decode Stage same as the Register written in the Execute Stage
        t_RA1D <= x"1"; t_RA2D <= x"2"; t_RA3D <= x"3"; t_WA4E <= x"7"; t_MemToRegE <= '1'; t_RegWriteE <= '1'; t_MemWriteD <= '0';
        wait for 5 ns;
        assert (t_StallF = '0' and t_StallD = '0' and t_FlushE = '0') report "Failed HazardUnit Test Case 12" severity error;

        -- Test Case 13: Source Register 1 in Decode Stage is same as the Register written in the Execute Stage
        t_RA1D <= x"1"; t_RA2D <= x"2"; t_RA3D <= x"3"; t_WA4E <= x"1"; t_MemToRegE <= '1'; t_RegWriteE <= '1'; t_MemWriteD <= '0';
        wait for 5 ns;
        assert (t_StallF = '1' and t_StallD = '1' and t_FlushE = '1') report "Failed HazardUnit Test Case 13" severity error;

        -- Test Case 14: Source Register 2 in Decode Stage is same as the Register written in the Execute Stage
        t_RA1D <= x"1"; t_RA2D <= x"2"; t_RA3D <= x"3"; t_WA4E <= x"2"; t_MemToRegE <= '1'; t_RegWriteE <= '1'; t_MemWriteD <= '0';
        wait for 5 ns;
        assert (t_StallF = '1' and t_StallD = '1' and t_FlushE = '1') report "Failed HazardUnit Test Case 14" severity error;

        -- Test Case 15: Source Register 3 in Decode Stage is same as the Register written in the Execute Stage
        t_RA1D <= x"1"; t_RA2D <= x"2"; t_RA3D <= x"3"; t_WA4E <= x"3"; t_MemToRegE <= '1'; t_RegWriteE <= '1'; t_MemWriteD <= '0';
        wait for 5 ns;
        assert (t_StallF = '1' and t_StallD = '1' and t_FlushE = '1') report "Failed HazardUnit Test Case 15" severity error;

        -- Test Case 16: A Source Register in Decode Stage is same as the Register written in the Execute Stage, but no LDR in the Execute Stage
        t_RA1D <= x"1"; t_RA2D <= x"2"; t_RA3D <= x"3"; t_WA4E <= x"3"; t_MemToRegE <= '0'; t_RegWriteE <= '1'; t_MemWriteD <= '0';
        wait for 5 ns;
        assert (t_StallF = '0' and t_StallD = '0' and t_FlushE = '0') report "Failed HazardUnit Test Case 16" severity error;

        -- Test Case 17: A Source Register in Decode Stage is same as the Register written in the Execute Stage, but Register is not written in the Execute Stage
        t_RA1D <= x"1"; t_RA2D <= x"2"; t_RA3D <= x"3"; t_WA4E <= x"3"; t_MemToRegE <= '1'; t_RegWriteE <= '0'; t_MemWriteD <= '0';
        wait for 5 ns;
        assert (t_StallF = '0' and t_StallD = '0' and t_FlushE = '0') report "Failed HazardUnit Test Case 17" severity error;

        -- Test Case 18: A Source Register in Decode Stage is same as the Register written in the Execute Stage, but Decode Instruction is STR
        t_RA1D <= x"1"; t_RA2D <= x"2"; t_RA3D <= x"3"; t_WA4E <= x"3"; t_MemToRegE <= '1'; t_RegWriteE <= '0'; t_MemWriteD <= '1';
        wait for 5 ns;
        assert (t_StallF = '0' and t_StallD = '0' and t_FlushE = '0') report "Failed HazardUnit Test Case 18" severity error;

        ---------------------------------------------------------
        -- Tests for Control hazard -----------------------------
        ---------------------------------------------------------

        -- LDRStall is set to 0 at the end of the previous test; hence only the inputs below would affect the value of t_FlushE

        -- Test Case 19: PC Source is from ALU Result
        t_PCSrcE <= '1'; t_ALUResultE <= x"00001111";
        wait for 5 ns;
        assert (t_FlushD = '1' and t_FlushE = '1' and t_ToForwardPC_INW = '1' and t_ForwardPC_INW = x"00001111") report "Failed HazardUnit Test Case 19" severity error;

        -- Test Case 20: PC Source is not from ALU Result
        t_PCSrcE <= '0'; t_ALUResultE <= x"00000001";
        wait for 5 ns;
        assert (t_FlushD = '0' and t_FlushE = '0' and t_ToForwardPC_INW = '0' and t_ForwardPC_INW = x"00000001") report "Failed HazardUnit Test Case 20" severity error;

        wait;

    end process;

end test_hazardunit_behavioral;
