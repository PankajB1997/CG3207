library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_condlogic is
--  Port ( );
end test_condlogic;

architecture test_condlogic_behavioral of test_condlogic is
    component CondLogic
        port (CLK      : in std_logic;
              PCS      : in std_logic;
              RegW     : in std_logic;
              NoWrite  : in std_logic;
              MemW     : in std_logic;
              FlagW    : in std_logic_vector (1 downto 0);
              Cond     : in std_logic_vector (3 downto 0);
              ALUFlags : in std_logic_vector (3 downto 0);
              PCSrc    : out std_logic;
              RegWrite : out std_logic;
              MemWrite : out std_logic);
    end component;

    signal t_CLK      : std_logic;
    signal t_PCS      : std_logic;
    signal t_RegW     : std_logic;
    signal t_NoWrite  : std_logic;
    signal t_MemW     : std_logic;
    signal t_FlagW    : std_logic_vector (1 downto 0);
    signal t_Cond     : std_logic_vector (3 downto 0);
    signal t_ALUFlags : std_logic_vector (3 downto 0);
    signal t_PCSrc    : std_logic;
    signal t_RegWrite : std_logic;
    signal t_MemWrite : std_logic;

    constant ClkPeriod : time := 1ns;
begin

    test_condlogic_module: CondLogic
    port map (
        CLK      => t_CLK,
        PCS      => t_PCS,
        RegW     => t_RegW,
        NoWrite  => t_NoWrite,
        MemW     => t_MemW,
        FlagW    => t_FlagW,
        Cond     => t_Cond,
        ALUFlags => t_ALUFlags,
        PCSrc    => t_PCSrc,
        RegWrite => t_RegWrite,
        MemWrite => t_MemWrite
    );

    clk_process: process begin
        t_CLK <= '1';
        wait for ClkPeriod / 2;  --for 0.5 ns signal is '1'.
        t_CLK <= '0';
        wait for ClkPeriod / 2;  --for next 0.5 ns signal is '0'.
    end process;

    stim_proc: process begin
        -- Set initial value for inputs.
        t_PCS <= '0';
        t_RegW <= '0';
        t_NoWrite <= '0';
        t_MemW <= '0';
        t_FlagW <= "00";
        t_Cond <= "0000";
        t_ALUFlags <= "0000";

        -- Inputs will be changed and checked between clock edges to avoid indeterminate behaviour at the edge.
        -- Each test case will start at x.5 ns, where x is 0, 1, 2... This is to keep track of where the clock is
        -- since some of the tests will be using the clock.
        wait for ClkPeriod / 2;

        -- Test case 1:
        -- For 'always' condition, incoming true signals are transferred out 'immediately'.
        t_PCS <= '1'; t_RegW <= '1'; t_MemW <= '1'; t_Cond <= "1110";
        wait for ClkPeriod / 10;
        assert (t_PCSrc = '1' and t_RegWrite = '1' and t_MemWrite = '1') report "Failed CondLogic Test Case 1" severity error;

        wait for ClkPeriod * 9 / 10;

        -- Test case 2:
        -- For 'always' condition, incoming false signals are transferred out 'immediately'.
        t_PCS <= '0'; t_RegW <= '0'; t_MemW <= '0'; t_Cond <= "1110";
        wait for ClkPeriod / 10;
        assert (t_PCSrc = '0' and t_RegWrite = '0' and t_MemWrite = '0') report "Failed CondLogic Test Case 2" severity error;

        wait for ClkPeriod * 9 / 10;

        -- Test case 3:
        -- For 'always' condition, t_NoWrite prevents t_RegWrite from being true.
        t_RegW <= '1'; t_NoWrite <= '1'; t_Cond <= "1110";
        wait for ClkPeriod / 10;
        assert (t_RegWrite = '0') report "Failed CondLogic Test Case 3" severity error;

        wait for ClkPeriod * 9 / 10;
        t_NoWrite <= '0'; -- reset to 0

        -- Test case 4:
        -- For some false condition, signals are all false.
        -- Flags initialised to false, so EQ condition will be false (Z != 1).
        t_PCS <= '1'; t_RegW <= '1'; t_MemW <= '1'; t_Cond <= "0000";
        wait for ClkPeriod / 10;
        assert (t_PCSrc = '0' and t_RegWrite = '0' and t_MemWrite = '0') report "Failed CondLogic Test Case 4" severity error;

        wait for ClkPeriod * 9 / 10;

        -- Test case 5:
        -- For some true condition, signals are transferred correctly.
        -- Flags initialised to false, so NEQ condition will be true (Z == 0).
        t_PCS <= '1'; t_RegW <= '1'; t_MemW <= '1'; t_Cond <= "0001";
        wait for ClkPeriod / 10;
        assert (t_PCSrc = '1' and t_RegWrite = '1' and t_MemWrite = '1') report "Failed CondLogic Test Case 5" severity error;

        wait for ClkPeriod * 9 / 10;

        -- Change flag state.
        t_ALUFlags <= "1111"; t_FlagW <= "11";
        wait for ClkPeriod;

        -- Test case 6:
        -- Assert flags have changed state by checking signals have transferred correctly depending on condition.
        -- Flags are all true, so EQ condition will be true (Z == 1);
        t_PCS <= '1'; t_RegW <= '1'; t_MemW <= '1'; t_Cond <= "0000";
        wait for ClkPeriod / 10;
        assert (t_PCSrc = '1' and t_RegWrite = '1' and t_MemWrite = '1') report "Failed CondLogic Test Case 6.1" severity error;
        wait for ClkPeriod / 10;
        -- Flags are all true, so NEQ condition will be false (Z != 0)
        t_PCS <= '1'; t_RegW <= '1'; t_MemW <= '1'; t_Cond <= "0001";
        wait for ClkPeriod / 10;
        assert (t_PCSrc = '0' and t_RegWrite = '0' and t_MemWrite = '0') report "Failed CondLogic Test Case 6.2" severity error;

        wait for ClkPeriod * 7 / 10;

        -- Test case 7:
        -- Assert flags are only changed after clock edge.
        -- Change flag state.
        t_ALUFlags <= "0000"; t_FlagW <= "11";
        wait for ClkPeriod / 10;
        -- Flags should still be true, so EQ will be true (Z == 1).
        t_PCS <= '1'; t_RegW <= '1'; t_MemW <= '1'; t_Cond <= "0000";
        wait for ClkPeriod / 10;
        assert (t_PCSrc = '1' and t_RegWrite = '1' and t_MemWrite = '1') report "Failed CondLogic Test Case 7.1" severity error;
        wait for ClkPeriod * 4 / 10; -- 1 / 10 ClkPeriods after edge.
        -- Flags should be false, so EQ will be false (Z != 1).
        assert (t_PCSrc = '0' and t_RegWrite = '0' and t_MemWrite = '0') report "Failed CondLogic Test Case 7.2" severity error;

        wait for ClkPeriod * 4 / 10;

        -- Test case 8:
        -- Assert that N and Z flags are not written when t_FlagW(0) is false.
        t_ALUFlags <= "1100"; t_FlagW <= "01";
        wait for ClkPeriod;
        -- Flags should still be false, so NEQ will be true (Z == 0).
        t_PCS <= '1'; t_RegW <= '1'; t_MemW <= '1'; t_Cond <= "0001";
        wait for ClkPeriod / 10;
        assert (t_PCSrc = '1' and t_RegWrite = '1' and t_MemWrite = '1') report "Failed CondLogic Test Case 8" severity error;

        wait for ClkPeriod * 9 / 10;

        -- Test case 9:
        -- Assert that C and V flags are not written when t_FlagW(1) is false.
        t_ALUFlags <= "0011"; t_FlagW <= "10";
        wait for ClkPeriod;
        -- Flags should still be false, so VC (no overflow) will be true (V == 0).
        t_PCS <= '1'; t_RegW <= '1'; t_MemW <= '1'; t_Cond <= "0111";
        wait for ClkPeriod / 10;
        assert (t_PCSrc = '1' and t_RegWrite = '1' and t_MemWrite = '1') report "Failed CondLogic Test Case 9" severity error;

        wait for ClkPeriod * 9 / 10;

        wait;
    end process;

end test_condlogic_behavioral;
