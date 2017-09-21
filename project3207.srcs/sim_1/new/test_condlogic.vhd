----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.09.2017 15:26:56
-- Design Name: 
-- Module Name: test_condlogic - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


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
    
    signal CLK      : std_logic;
    signal PCS      : std_logic;
    signal RegW     : std_logic;
    signal NoWrite  : std_logic;
    signal MemW     : std_logic;
    signal FlagW    : std_logic_vector (1 downto 0);
    signal Cond     : std_logic_vector (3 downto 0);
    signal ALUFlags : std_logic_vector (3 downto 0);
    signal PCSrc    : std_logic;
    signal RegWrite : std_logic;
    signal MemWrite : std_logic;
    
    constant ClkPeriod : time := 1ns;
begin

    uut: CondLogic
    port map (
        CLK      => CLK,
        PCS      => PCS,
        RegW     => RegW,
        NoWrite  => NoWrite,
        MemW     => MemW,
        FlagW    => FlagW,
        Cond     => Cond,
        ALUFlags => ALUFlags,
        PCSrc    => PCSrc,
        RegWrite => RegWrite,
        MemWrite => MemWrite
    );
    
    clk_process: process begin
        CLK <= '1';
        wait for ClkPeriod / 2;  --for 0.5 ns signal is '1'.
        CLK <= '0';
        wait for ClkPeriod / 2;  --for next 0.5 ns signal is '0'.
    end process;
    
    stim_proc: process begin
        -- Set initial value for inputs.
        PCS <= '0';
        RegW <= '0';
        NoWrite <= '0';
        MemW <= '0';
        FlagW <= "00";
        Cond <= "0000";
        ALUFlags <= "0000";
        
        -- Inputs will be changed and checked between clock edges to avoid indeterminate behaviour at the edge.
        wait for ClkPeriod / 2;
        
        -- For 'always' condition, incoming true signals are transferred out 'immediately'.
        PCS <= '1'; RegW <= '1'; MemW <= '1'; Cond <= "1110";
        wait for ClkPeriod / 10;
        assert (PCSrc = '1' and RegWrite = '1' and MemWrite = '1') report "Failed: always transfers true signals" severity error;
        
        wait for ClkPeriod * 9 / 10;
        
        -- For 'always' condition, incoming false signals are transferred out 'immediately'.
        PCS <= '0'; RegW <= '0'; MemW <= '0'; Cond <= "1110";
        wait for ClkPeriod / 10;
        assert (PCSrc = '0' and RegWrite = '0' and MemWrite = '0') report "Failed: always transfers false signals" severity error;
        
        wait for ClkPeriod * 9 / 10;
        
        -- For 'always' condition, NoWrite prevents RegWrite from being true.
        RegW <= '1'; NoWrite <= '1'; Cond <= "1110";
        wait for ClkPeriod / 10;
        assert (RegWrite = '0') report "Failed: nowrite disables regwrite" severity error;
        
        wait for ClkPeriod * 9 / 10;
        NoWrite <= '0'; -- reset to 0
        
        -- For some false condition, signals are all false.
        -- Flags initialised to false, so EQ condition will be false (Z != 1).
        PCS <= '1'; RegW <= '1'; MemW <= '1'; Cond <= "0000";
        wait for ClkPeriod / 10;
        assert (PCSrc = '0' and RegWrite = '0' and MemWrite = '0') report "Failed: false condition causes outputs to be false (1)" severity error;
        
        wait for ClkPeriod * 9 / 10;
        
        -- For some true condition, signals are transferred correctly.
        -- Flags initialised to false, so NEQ condition will be true (Z == 0).
        PCS <= '1'; RegW <= '1'; MemW <= '1'; Cond <= "0001";
        wait for ClkPeriod / 10;
        assert (PCSrc = '1' and RegWrite = '1' and MemWrite = '1') report "Failed: true condition causes outputs to be true (1)" severity error;
        
        wait for ClkPeriod * 9 / 10;
        
        -- Change flag state.
        ALUFlags <= "1111"; FlagW <= "11";
        wait for ClkPeriod;
        
        -- Assert flags have changed state by checking signals have transferred correctly depending on condition.
        -- Flags are all true, so EQ condition will be true (Z == 1);
        PCS <= '1'; RegW <= '1'; MemW <= '1'; Cond <= "0000";
        wait for ClkPeriod / 10;
        assert (PCSrc = '1' and RegWrite = '1' and MemWrite = '1') report "Failed: true condition causes outputs to be true (2)" severity error;
        wait for ClkPeriod / 10;
        -- Flags are all true, so NEQ condition will be false (Z != 0)
        PCS <= '1'; RegW <= '1'; MemW <= '1'; Cond <= "0001";
        wait for ClkPeriod / 10;
        assert (PCSrc = '0' and RegWrite = '0' and MemWrite = '0') report "Failed: false condition causes outputs to be false (2)" severity error;
        
        wait for ClkPeriod * 7 / 10;
        
        -- Assert flags are only changed after clock edge.
        -- Change flag state.
        ALUFlags <= "0000"; FlagW <= "11";
        wait for ClkPeriod / 10;
        -- Flags should still be true, so EQ will be true (Z == 1).
        PCS <= '1'; RegW <= '1'; MemW <= '1'; Cond <= "0000";
        wait for ClkPeriod / 10;
        assert (PCSrc = '1' and RegWrite = '1' and MemWrite = '1') report "Failed: flags only change on clock edge (1)" severity error;
        wait for ClkPeriod * 4 / 10; -- 1 / 10 ClkPeriods after edge.
        -- Flags should be false, so EQ will be false (Z != 1).
        assert (PCSrc = '0' and RegWrite = '0' and MemWrite = '0') report "Failed: flags only change on clock edge (2)" severity error;
        
        wait for ClkPeriod * 4 / 10;
        
        -- Assert that N and Z flags are not written when FlagW(0) is false.
        ALUFlags <= "1100"; FlagW <= "01";
        wait for ClkPeriod;
        -- Flags should still be false, so NEQ will be true (Z == 0).
        PCS <= '1'; RegW <= '1'; MemW <= '1'; Cond <= "0001";
        wait for ClkPeriod / 10;
        assert (PCSrc = '1' and RegWrite = '1' and MemWrite = '1') report "Failed: N and Z don't change when flag is false" severity error;
        
        wait for ClkPeriod * 9 / 10;
        
        -- Assert that C and V flags are not written when FlagW(1) is false.
        ALUFlags <= "0011"; FlagW <= "10";
        wait for ClkPeriod;
        -- Flags should still be false, so VC (no overflow) will be true (V == 0).
        PCS <= '1'; RegW <= '1'; MemW <= '1'; Cond <= "0111";
        wait for ClkPeriod / 10;
        assert (PCSrc = '1' and RegWrite = '1' and MemWrite = '1') report "Failed: N and Z don't change when flag is false" severity error;
        
        wait for ClkPeriod * 9 / 10;
        
        wait;
    end process; 

end test_condlogic_behavioral;
