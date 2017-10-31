library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_hazardunit is
--  Port ( );
end test_hazardunit;

architecture test_hazardunit_behavioral of test_hazardunit is

    component HazardUnit
    port (
        RA1E : in std_logic_vector(3 downto 0);
        RA2E : in std_logic_vector(3 downto 0);
        RA3E : in std_logic_vector(3 downto 0);
        WA3M : in std_logic_vector(3 downto 0);
        WA3W : in std_logic_vector(3 downto 0);
        RegWriteM : in std_logic;
        RegWriteW : in std_logic;
        ALUResultM : in std_logic_vector(31 downto 0);
        ResultW : in std_logic_vector(31 downto 0);
        ToForwardD1E : out std_logic;
        ToForwardD2E : out std_logic;
        ToForwardD3E : out std_logic;
        ForwardD1E : out std_logic_vector(31 downto 0);
        ForwardD2E : out std_logic_vector(31 downto 0);
        ForwardD3E : out std_logic_vector(31 downto 0));
    end component;

    signal t_RA1E : std_logic_vector(3 downto 0);
    signal t_RA2E : std_logic_vector(3 downto 0);
    signal t_RA3E : std_logic_vector(3 downto 0);
    signal t_WA3M : std_logic_vector(3 downto 0);
    signal t_WA3W : std_logic_vector(3 downto 0);
    signal t_RegWriteM : std_logic;
    signal t_RegWriteW : std_logic;
    signal t_ALUResultM : std_logic_vector(31 downto 0);
    signal t_ResultW : std_logic_vector(31 downto 0);
    signal t_ToForwardD1E : std_logic;
    signal t_ToForwardD2E : std_logic;
    signal t_ToForwardD3E : std_logic;
    signal t_ForwardD1E : std_logic_vector(31 downto 0);
    signal t_ForwardD2E : std_logic_vector(31 downto 0);
    signal t_ForwardD3E : std_logic_vector(31 downto 0);

begin

    test_hazardunit_module: HazardUnit
    port map (
        -- Inputs
        RA1E => t_RA1E,
        RA2E => t_RA2E,
        RA3E => t_RA3E,
        WA3M => t_WA3M,
        WA3W => t_WA3W,
        RegWriteM => t_RegWriteM,
        RegWriteW => t_RegWriteW,
        ALUResultM => t_ALUResultM,
        ResultW => t_ResultW,
        -- Outputs
        ToForwardD1E => t_ToForwardD1E,
        ToForwardD2E => t_ToForwardD2E,
        ToForwardD3E => t_ToForwardD3E,
        ForwardD1E => t_ForwardD1E,
        ForwardD2E => t_ForwardD2E,
        ForwardD3E => t_ForwardD3E
    );

    stim_proc: process begin

        -- Set initial values for inputs
        t_RA1E <= (others => '0'); t_RA2E <= (others => '0'); t_RA3E <= (others => '0'); t_WA3M <= (others => '0'); t_WA3W <= (others => '0'); t_RegWriteM <= '0'; t_RegWriteW <= '0'; t_ALUResultM <= (others => '0'); t_ResultW <= (others => '0');
        wait for 5 ns;

        -- Note: No matter what, one of the values will be output, but the
        -- ToForwardDxE bits will be 0 if no forwarding is to occur.
        -- If there is no match, ResultW will be forwarded by default.

        -- Test Case 1: Registers read and written are different, no forwarding.
        t_RA1E <= x"1"; t_RA2E <= x"2"; t_RA3E <= x"3"; t_WA3M <= x"4"; t_WA3W <= x"5"; t_RegWriteM <= '1'; t_RegWriteW <= '1'; t_ALUResultM <= x"00000001"; t_ResultW <= x"00000002";
        wait for 5 ns;
        assert (t_ToForwardD1E = '0' and t_ToForwardD2E = '0' and t_ToForwardD3E = '0' and t_ForwardD1E = x"00000002" and t_ForwardD2E = x"00000002" and t_ForwardD3E = x"00000002") report "Failed HazardUnit Test Case 1" severity error;

        -- Test Case 2: Registers match, but not written, so no forwarding.
        t_RA1E <= x"1"; t_RA2E <= x"2"; t_RA3E <= x"1"; t_WA3M <= x"1"; t_WA3W <= x"2"; t_RegWriteM <= '0'; t_RegWriteW <= '0'; t_ALUResultM <= x"00000001"; t_ResultW <= x"00000002";
        wait for 5 ns;
        assert (t_ToForwardD1E = '0' and t_ToForwardD2E = '0' and t_ToForwardD3E = '0' and t_ForwardD1E = x"00000002" and t_ForwardD2E = x"00000002" and t_ForwardD3E = x"00000002") report "Failed HazardUnit Test Case 2" severity error;

        -- Test Case 3: One register matches with Memory, is forwarded.
        t_RA1E <= x"1"; t_RA2E <= x"2"; t_RA3E <= x"4"; t_WA3M <= x"2"; t_WA3W <= x"3"; t_RegWriteM <= '1'; t_RegWriteW <= '1'; t_ALUResultM <= x"00000001"; t_ResultW <= x"00000002";
        wait for 5 ns;
        assert (t_ToForwardD1E = '0' and t_ToForwardD2E = '1' and t_ToForwardD3E = '0' and t_ForwardD1E = x"00000002" and t_ForwardD2E = x"00000001" and t_ForwardD3E = x"00000002") report "Failed HazardUnit Test Case 3" severity error;

        -- Test Case 4: One register matches with Writeback, is forwarded.
        t_RA1E <= x"1"; t_RA2E <= x"2"; t_RA3E <= x"4"; t_WA3M <= x"3"; t_WA3W <= x"1"; t_RegWriteM <= '1'; t_RegWriteW <= '1'; t_ALUResultM <= x"00000001"; t_ResultW <= x"00000002";
        wait for 5 ns;
        assert (t_ToForwardD1E = '1' and t_ToForwardD2E = '0' and t_ToForwardD3E = '0' and t_ForwardD1E = x"00000002" and t_ForwardD2E = x"00000002" and t_ForwardD3E = x"00000002") report "Failed HazardUnit Test Case 4" severity error;

        -- Test Case 5: One register matches with Writeback, one matches with Memory.
        t_RA1E <= x"1"; t_RA2E <= x"2"; t_RA3E <= x"3"; t_WA3M <= x"2"; t_WA3W <= x"3"; t_RegWriteM <= '1'; t_RegWriteW <= '1'; t_ALUResultM <= x"00000001"; t_ResultW <= x"00000002";
        wait for 5 ns;
        assert (t_ToForwardD1E = '0' and t_ToForwardD2E = '1' and t_ToForwardD3E = '1' and t_ForwardD1E = x"00000002" and t_ForwardD2E = x"00000001" and t_ForwardD3E = x"00000002") report "Failed HazardUnit Test Case 5" severity error;

        -- Test Case 6: Register matches with both Memory and Writeback, ALUResultM forwarded.
        t_RA1E <= x"1"; t_RA2E <= x"2"; t_RA3E <= x"3"; t_WA3M <= x"3"; t_WA3W <= x"3"; t_RegWriteM <= '1'; t_RegWriteW <= '1'; t_ALUResultM <= x"00000001"; t_ResultW <= x"00000002";
        wait for 5 ns;
        assert (t_ToForwardD1E = '0' and t_ToForwardD2E = '0' and t_ToForwardD3E = '1' and t_ForwardD1E = x"00000002" and t_ForwardD2E = x"00000002" and t_ForwardD3E = x"00000001") report "Failed HazardUnit Test Case 6" severity error;

        wait;

    end process;

end test_hazardunit_behavioral;
