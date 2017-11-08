library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_arm is
--  Port ( );
end test_arm;

architecture test_arm_behavioral of test_arm is
    component ARM
    port (CLK : in std_logic;
          RESET : in std_logic;
          Instr : in std_logic_vector (31 downto 0);
          ReadData : in std_logic_vector (31 downto 0);
          MemWrite : out std_logic;
          PC : out std_logic_vector (31 downto 0);
          ALUResult : out std_logic_vector (31 downto 0);
          WriteData : out std_logic_vector (31 downto 0));
    end component;

    signal t_CLK : std_logic;
    signal t_RESET : std_logic;
    signal t_Instr : std_logic_vector (31 downto 0);
    signal t_ReadData : std_logic_vector (31 downto 0);
    signal t_MemWrite : std_logic;
    signal t_PC : std_logic_vector (31 downto 0);
    signal t_ALUResult : std_logic_vector (31 downto 0);
    signal t_WriteData : std_logic_vector (31 downto 0);

    constant ClkPeriod : time := 1ns;
begin

    test_arm_module : ARM port map (
        -- Inputs
        CLK => t_CLK,
        RESET => t_RESET,
        Instr => t_Instr,
        ReadData => t_ReadData,
        -- Outputs
        MemWrite => t_MemWrite,
        PC => t_PC,
        ALUResult => t_ALUResult,
        WriteData => t_WriteData
    );

    clk_process: process begin
        t_CLK <= '1';
        wait for ClkPeriod / 2;  --for 0.5 ns signal is '1'.
        t_CLK <= '0';
        wait for ClkPeriod / 2;  --for next 0.5 ns signal is '0'.
    end process;

    stim_proc: process begin
        -- Set initial value for inputs.
        t_RESET <= '0'; t_Instr <= (others => '0'); t_ReadData <= (others => '0');

        -- Inputs will be changed and checked between clock edges to avoid indeterminate behaviour at the edge.
        -- Each test Case will start at x.5 ns, where x is 0, 1, 2... This is to keep track of where the clock is
        -- since some of the tests will be using the clock.
        wait for ClkPeriod / 2;

        -- Before time = ClkPeriod, some signals may be U or X. That is expected, as the processor is only reset
        -- at the first clock edge, and this is when the PC is set to 0. Before this, PC is indeterminate.

        -- RESET = 1 to set PC to 0.
        t_RESET <= '1';
        wait for ClkPeriod;

        -- Test Case 1: Check that PC starts off as 0
        assert (t_PC = x"00000000") report "Failed ARM Test Case 1" severity error;
        t_RESET <= '0';

        -- Add 1 ClkPeriod between instructions with Load and Use hazard.
        -- Wait 2 cycles after instruction causing a control hazard since it
        -- .
        -- MUL/DIV tests commented out since they require stalling.
        -- Assertions for outputs of an instruction to data memory are made in Memory stage,
        -- 3 clock periods after feeding the instruction into the processor.
        -- Assertions for outputs of an instruction to instruction memory are made in the
        -- Memory stage, 3 clock periods after feeding the instruction into the processor,
        -- as this is when the forwarded BTA is latched into the PC.

        -- Test Case 2: Load 3 into register - LDR R0, [R15]
        -- R15 is used as the base register since it's the only register with a determined value.
        -- The rest of the registers are uninitialized. The value of R15 doesn't actually matter
        -- here since the value read from memory is supplied as an input. ALUResult will be the
        -- value of R15, which is PC + 8.
        -- PC will still be 0 as clock edge not yet reached.
        t_Instr <= x"E" & "01" & "011001" & x"F" & x"0" & x"000";
        wait for ClkPeriod;

        -- PC should have incremented at clock edge.
        assert (t_PC = x"00000004") report "Failed ARM Test Case 2.1" severity error;

        -- Test Case 3: Add register with small rotated immediate - ADD R1, R0, #5
        -- R1 = R0 + 5 = 3 + 5 = 8
        -- Potential load and use hazard with previous instruction.
        t_Instr <= x"E" & "00" & "1" & x"4" & "0" & x"0" & x"1" & x"0" & x"05";
        wait for ClkPeriod;

        -- Test Case 4: Add register with large immediate - ADD R8, R1, #500
        -- R8 = 8 + 500 = 508 = 0x1FC
        -- Since immediate is large, it will have to be represented as a rotated immediate.
        -- Potential data hazard with previous instruction.
        t_Instr <= x"E" & "00" & "1" & x"4" & "0" & x"1" & x"8" & x"F" & x"7D";
        wait for ClkPeriod;

        t_ReadData <= x"00000003";
        assert (t_MemWrite = '0' and t_ALUResult = x"00000008") report "Failed ARM Test Case 2.2" severity error;

        wait for ClkPeriod;  -- Wait to account for stalling due to Load and Use in TC3.

        -- Test Case 5: Add register with immediate shifts -- ADD R2, R1, R0, LSL #2
        -- R2 = R1 + R0 << 2 = 8 + 3 << 2 = 20 = 0x14
        -- Potential data hazard with instruction before previous.
        t_Instr <= x"E" & "00" & "0" & x"4" & "0" & x"1" & x"2" & "00010" & "00" & "0" & x"0";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000008") report "Failed ARM Test Case 3" severity error;

        -- Test Case 6: Subtract register with register shifted register as Src2 -- SUB R2, R2, R2, LSR R0
        -- R2 = R2 - R2 >> R0 = 20 - 20 >> 3 = 18 = 0x12
        -- Potential data hazard with previous instruction.
        t_Instr <= x"E" & "00" & "0" & x"2" & "0" & x"2" & x"2" & x"0" & "0" & "01" & "1" & x"2";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"000001FC") report "Failed ARM Test Case 4" severity error;

        -- Test Case 7: Store register value into memory, does not happen due to condition - STREQ R0, [R1, #12]
        -- Also tests immediate offset in STR.
        -- Flags should all start off as 0, so EQ will fail
        -- ALUResult should be R1 + 12 = 20 = 0x14
        -- No hazard with previous instruction.
        t_Instr <= x"0" & "01" & "011000" & x"1" & x"0" & x"00C";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000014") report "Failed ARM Test Case 5" severity error;

        -- Test Case 8: AND two registers and update flags: ANDS R15, R1, R0
        -- R15 = 3 & 8 = 0
        -- R15 is being written into, so PC should update to 0
        -- No hazard with previous instruction.
        t_Instr <= x"E" & "00" & "0" & x"0" & "1" & x"1" & x"F" & "00000" & "00" & "0" & x"0";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000012") report "Failed ARM Test Case 6" severity error;

        -- ADD R0, R0, R0
        -- Should get flushed due to control hazard, and not execute.
        -- Thus R0 is still 3 for Test Case 9.
        t_Instr <= x"E" & "00" & "0" & x"4" & "0" & x"0" & x"0" & "00000" & "00" & "0" & x"0";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000014" and t_WriteData = x"00000003") report "Failed ARM Test Case 7" severity error;

        -- ADD R1, R1, R1
        -- Should get flushed due to control hazard, and not execute.
        -- Thus R1 is still 8 for Test Case 9.
        t_Instr <= x"E" & "00" & "0" & x"4" & "0" & x"1" & x"1" & "00000" & "00" & "0" & x"1";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000000") report "Failed ARM Test Case 8.1" severity error;
        assert (t_PC = x"00000000") report "Failed ARM Test Case 8.2" severity error;

        -- Test Case 9: Same store operation as above but happens this time - STREQ R0, [R1, #12]
        -- Also tests immediate offset in STR.
        -- Z should be 1 after previous instruction, so EQ will pass
        -- ALUResult should be R1 + 12 = 20 = 0x14
        -- Control hazard with previous instruction.
        t_Instr <= x"0" & "01" & "011000" & x"1" & x"0" & x"00C";
        wait for ClkPeriod;

        -- Test Case 10: STR with negative offset: STR R2, [R1, #-4]
        -- ALUResult should be R1 - 4 = 4 = 0x4
        -- No hazard with previous instruction.
        t_Instr <= x"E" & "01" & "010000" & x"1" & x"2" & x"004";
        wait for ClkPeriod;

        -- Test Case 11: Branch instruction - B LABEL
        -- Assert that PC was 8 after previous instruction.
        -- No hazard with previous instruction.
        assert (t_PC = x"00000008") report "Failed ARM Test Case 11.1" severity error;

        -- LABEL is specified relative to PC, here PC is forced to move forward 5 instructions.
        -- To do so, offset must be 3, since it is taken relative to PC + 8
        -- PC was 8 after previous instruction. So new value will be 8 + 20 = 0x1C
        t_Instr <= x"E" & "10" & "10" & x"000003";
        wait for ClkPeriod;

        assert (t_MemWrite = '1' and t_ALUResult = x"00000014" and t_WriteData = x"00000003") report "Failed ARM Test Case 9" severity error;
        wait for ClkPeriod;

        assert (t_MemWrite = '1' and t_ALUResult = x"00000004" and t_WriteData = x"00000012") report "Failed ARM Test Case 10.1" severity error;
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"0000001C") report "Failed ARM Test Case 11.2" severity error;
        assert (t_PC = x"0000001C") report "Failed ARM Test Case 11.3" severity error;

        -- Test Case 12: Branch instruction with negative offset - B LABEL
        -- This time offset will be -4, to send the PC back 2 instructions.
        -- New value of PC will be 28 - 8 = 0x14
        -- Control hazard with previous instruction.
        t_Instr <= x"E" & "10" & "10" & x"FFFFFC";
        wait for ClkPeriod;

        wait for ClkPeriod * 2;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000014") report "Failed ARM Test Case 12.1" severity error;
        assert (t_PC = x"00000014") report "Failed ARM Test Case 12.2" severity error;

        -- Test Case 13: Multiply two registers - MUL R11, R2, R1
        -- R11 = R2 * R1 = 0x12 * 0x8 = 0x90
        t_Instr <= x"E" & "00" & '0' & x"0" & '0' & x"B" & x"0" & x"1" & x"9" & x"2";
        wait for ClkPeriod;

        -- Test Case 14: Divide two registers - DIV R11, R11, R2 (MLA R11, R11, R2, R-)
        -- R11 = R11 / R2 = 0x90 / 0x12 = 0x8
        t_Instr <= x"E" & "00" & '0' & x"1" & '0' & x"B" & x"0" & x"2" & x"9" & x"B";
        wait for ClkPeriod;

        -- Test Case 15: Multiply a register by itself - MUL R11, R11, R11
        -- R11 = R11 * R11 = 0x8 * 0x8 = 0x40
        t_Instr <= x"E" & "00" & '0' & x"0" & '0' & x"B" & x"0" & x"B" & x"9" & x"B";

        -- Wait until PC increments for Test Case 13
        wait until t_PC = x"00000020";
        assert (t_MemWrite = '0' and t_ALUResult = x"00000090") report "Failed ARM Test Case 13" severity error;

        wait for ClkPeriod / 2;

        -- Test Case 16: Reverse subtract values with carry - RSC R4, R1, #16
        -- R4 = 16 - R1 - NOT Carry = 0x10 - 0x8 - 1 = 0x7
        -- Control hazard with previous instruction.
        t_Instr <= x"E" & "00" & '1' & x"7" & '0' & x"1" & x"4" & x"0" & x"10";

        -- Wait until PC increments for Test Case 14
        wait until t_PC = x"00000024";
        assert (t_MemWrite = '0' and t_ALUResult = x"00000008") report "Failed ARM Test Case 14" severity error;

        wait for ClkPeriod / 2;

        -- Test Case 17: TST a register and immediate operand. Also update flags - TST R0, #12
        -- R0 AND 12 = 3 AND 12 = 0
        -- Z flag is set
        -- No hazard with previous instruction.
        t_Instr <= x"E" & "00" & '1' & x"8" & '1' & x"0" & x"0" & x"0" & x"0" & x"C";

        -- Wait until PC increments for Test Case 15
        wait until t_PC = x"00000028";
        assert (t_MemWrite = '0' and t_ALUResult = x"00000040") report "Failed ARM Test Case 15" severity error;

        wait for ClkPeriod / 2;

        -- Test Case 18: Check if Z flag was set after the previous TST operation - STREQ R4, [R2, #12]
        -- MemWrite = 1 only if Z flag was set
        -- ALUResult = R2 + 12 = 0x12 + 0xC = 0x1E
        -- Potential data hazard with instruction before previous.
        t_Instr <= x"0" & "01" & "011000" & x"2" & x"4" & x"0" & x"0" & "1100";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000007") report "Failed ARM Test Case 16.1" severity error;

        -- Test Case 19: MOV the contents of one register into another register - MOV R7, R2
        -- R7 = R2 = 0x12
        -- No hazard with previous instruction.
        t_Instr <= x"E" & "00" & "0" & x"D" & "0" & x"0" & x"7" & "00000" & "00" & "0" & x"2";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000000") report "Failed ARM Test Case 17" severity error;

        -- Test Case 20: BICS two registers and update flags - BICS R8, R4, R0 LSR #1
        -- R8 = R4 AND (not (R0 >> 1)) = 0b0111 AND (not (0b0011 >> 1)) = 0b0111 AND 0b1110 = 0b0110 = 6
        -- Carry Flags should be set to 1 as the bit shifted out of R0 was 1.
        -- No hazard with previous instruction.
        t_Instr <= x"E" & "00" & "0" & x"E" & "1" & x"4" & x"8" & "00001" & "01" & "0" & x"0";
        wait for ClkPeriod;

        assert (t_MemWrite = '1' and t_ALUResult = x"0000001E" and t_WriteData = x"00000007") report "Failed ARM Test Case 18" severity error;

        -- Test Case 21: ADC two registers to check that Carry Flag was set - ADC R5, R4, R0
        -- R5 = R4 + R0 + Carry = 7 + 3 + 1 = 11.
        -- No hazard with previous instruction.
        t_Instr <= x"E" & "00" & "0" & x"5" & "0" & x"4" & x"5" & "00000" & "00" & "0" & x"0";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000012") report "Failed ARM Test Case 19" severity error;

        -- Test Case 22: MOVS two registers with such values that the Carry Flag is set to 0, then test this with ADC
        -- MOVS R4, R0
        -- R4 = R0
        -- Carry Flag set to 0
        -- No hazard with previous instruction.
        t_Instr <= x"E" & "00" & "0" & x"D" & "1" & x"0" & x"4" & "00000" & "00" & "0" & x"0";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000006") report "Failed ARM Test Case 20" severity error;

        -- ADC R5, R4, R0
        -- R5 = R4 + R0 + Carry = 3 + 3 + 0 = 6.
        -- Potential data hazard with previous instruction.
        t_Instr <= x"E" & "00" & "0" & x"5" & "0" & x"4" & x"5" & "00000" & "00" & "0" & x"0";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"0000000B") report "Failed ARM Test Case 21" severity error;

        -- Test Case 23: DP instruction which does not happen, followed by DP instruction which depends on the previous.
        -- SUBCS R5, R4, R0
        -- Does not execute, since Carry Flag is 0, so R5 remains 6.
        t_Instr <= x"2" & "00" & "0" & x"2" & "0" & x"4" & x"5" & "00000" & "00" & "0" & x"0";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000003") report "Failed ARM Test Case 22.1" severity error;

        -- ADD R6, R5, R5
        -- R6 = R5 + R5 = 6 + 6 = 0xC
        -- There should be no data hazard with previous instruction, as it doesn't execute.
        t_Instr <= x"E" & "00" & "0" & x"4" & "0" & x"5" & x"6" & "00000" & "00" & "0" & x"5";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000006") report "Failed ARM Test Case 22.2" severity error;

        -- Test Case 24: Data hazard for RA3 with previous two instructions.
        -- ADD R6, R5, #2
        -- R6 = R5 + 2 = 6 + 2 = 8
        -- No data hazard with previous instruction.
        t_Instr <= x"E" & "00" & "1" & x"4" & "0" & x"5" & x"6" & x"002";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000000") report "Failed ARM Test Case 23.1" severity error;

        -- ADD R7, R5, R5 LSL R6
        -- R7 = R5 + R5 << R6 = 6 + 6 << 8 = 0x606
        -- Data hazard with previous two instructions. Should get value from previous.
        t_Instr <= x"E" & "00" & "0" & x"4" & "0" & x"5" & x"7" & x"6" & "0" & "00" & "1" & x"5";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"0000000C") report "Failed ARM Test Case 23.2" severity error;

        -- Test Case 25: Test Mem-Mem copy in situation where load is not executed.
        -- LDRCS R6, [R5]
        -- ALUResult = R5 = 6
        -- ReadData is 2, but R6 should not update, remaining 8.
        -- No data hazard with previous instruction.
        t_Instr <= x"2" & "01" & "011001" & x"5" & x"6" & x"000";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000008") report "Failed ARM Test Case 24.1" severity error;

        -- STR R6, [R5]
        -- ALUResult = R5 = 6
        -- WriteData = R6 = 8
        -- No data hazard with previous instruction since it is not executed.
        t_Instr <= x"E" & "01" & "011000" & x"5" & x"6" & x"000";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000606") report "Failed ARM Test Case 24.2" severity error;

        -- Test Case 26: Test that Mem-Mem copy works.
        -- LDR R6, [R5]
        -- ALUResult = R5 = 6
        -- ReadData is 2, so R6 should become 2.
        -- No data hazard with previous instruction.
        t_Instr <= x"E" & "01" & "011001" & x"5" & x"6" & x"000";
        wait for ClkPeriod;

        t_ReadData <= x"00000002";
        assert (t_MemWrite = '0' and t_ALUResult = x"00000006") report "Failed ARM Test Case 25.1" severity error;

        -- STR R6, [R5]
        -- ALUResult = R5 = 6
        -- WriteData = R6 = 2
        -- Data hazard (Mem-Mem copy) with previous instruction.
        t_Instr <= x"E" & "01" & "011000" & x"5" & x"6" & x"000";
        wait for ClkPeriod;

        assert (t_MemWrite = '1' and t_ALUResult = x"00000006" and t_WriteData = x"00000008") report "Failed ARM Test Case 25.2" severity error;

        -- Test Case 27: Test Load and Use where LDR does not execute. There should be no need to wait.
        -- LDRCS R6, [R5]
        -- ALUResult = R5 = 6
        -- ReadData is 9, but R6 should remain 2.
        -- No data hazard with previous instruction.
        t_Instr <= x"2" & "01" & "011001" & x"5" & x"6" & x"000";
        wait for ClkPeriod;

        t_ReadData <= x"00000002";
        assert (t_MemWrite = '0' and t_ALUResult = x"00000006") report "Failed ARM Test Case 26.1" severity error;

        -- ADD R5, R6, R6
        -- ALUResult = R6 + R6 = 2 + 2 = 4
        -- No data hazard with previous instruction since it does not execute.
        t_Instr <= x"E" & "00" & "0" & x"4" & "0" & x"6" & x"5" & "00000" & "00" & "0" & x"6";
        wait for ClkPeriod;

        assert (t_MemWrite = '1' and t_ALUResult = x"00000006" and t_WriteData = x"00000002") report "Failed ARM Test Case 26.2" severity error;

        -- Test Case 28: Test Control Hazard when Branch is not taken.
        -- BCS LABEL
        t_Instr <= x"2" & "10" & "10" & x"000003";
        wait for ClkPeriod;

        t_ReadData <= x"00000009";
        assert (t_MemWrite = '0' and t_ALUResult = x"00000006") report "Failed ARM Test Case 27.1" severity error;

        -- ADD R5, R6, R6
        -- No control hazard with previous instruction since it does not execute.
        -- Thus, ALUResult = R6 + R6 = 2 + 2 = 4.
        -- If the control hazard had occured, then this instruction would be flushed
        -- and the instruction would be AND R0, R0, R0 = 3.
        t_Instr <= x"E" & "00" & "0" & x"4" & "0" & x"6" & x"5" & "00000" & "00" & "0" & x"6";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000004") report "Failed ARM Test Case 27.2" severity error;

        -- Test Case 29: Test Branching from Memory.
        -- LDR R15, [R0]
        -- ReadData is 8, so PC should become 8
        -- ALUResult = R0 = 3
        -- No hazard with previous instruction.
        t_Instr <= x"E" & "01" & "011001" & x"0" & x"F" & x"000";
        wait for ClkPeriod;

        t_Instr <= x"00000000";
        wait for ClkPeriod;  -- No assertion to be made for branch instruction.

        assert (t_MemWrite = '0' and t_ALUResult = x"00000004") report "Failed ARM Test Case 28" severity error;
        wait for ClkPeriod;

        t_ReadData <= x"00000008";
        assert (t_MemWrite = '0' and t_ALUResult = x"00000003") report "Failed ARM Test Case 29.1" severity error;

        -- ADD R0, R0, R0
        -- Should get flushed due to control hazard, and not execute.
        -- Thus R0 should remain 3.
        t_Instr <= x"E" & "00" & "0" & x"4" & "0" & x"0" & x"0" & "00000" & "00" & "0" & x"0";
        wait for ClkPeriod * 2;

        assert (t_PC = x"00000008") report "Failed ARM Test Case 29.2" severity error;

        -- MOV R0, R0
        -- R0 = 3
        -- Testing that previous ADD instruction did indeed get flushed.
        t_Instr <= x"E" & "00" & "0" & x"D" & "0" & x"0" & x"0" & "00000" & "00" & "0" & x"0";
        wait for ClkPeriod;

        -- Test Case 30: Multiply instruction that does not execute - MULCS R11, R11, R11
        -- R11 = R11 * R11 = 0x8 * 0x8 = 0x40
        t_Instr <= x"2" & "00" & '0' & x"0" & '0' & x"B" & x"0" & x"B" & x"9" & x"B";
        wait for ClkPeriod;

        -- MOV R0, R0
        -- This instruction should not have to wait as the MUL instruction above should not execute.
        -- ALUResult = R0 = 3
        t_Instr <= x"E" & "00" & "0" & x"D" & "1" & x"0" & x"0" & "00000" & "00" & "0" & x"0";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000003") report "Failed ARM Test Case 29.3" severity error;
        assert (t_PC = x"00000014") report "Failed ARM Test Case 31.1" severity error;

        -- Test Case 31: Handle Div by 0 interrupt.
        -- BL LABEL
        -- Should put PC + 8 + 0xC << 2 = 0x14 + 8 + 12 << 2 = 0x4C.
        t_Instr <= x"E" & "10" & "11" & x"00000C";
        wait for ClkPeriod;

        -- No assertion for MUL instruction.

        -- STR R13, [R-], #0
        -- Store intruction handler in R13 for Div By 0 interrupt.
        t_Instr <= x"E" & "01" & "001000" & x"0" & x"D" & x"000";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000003") report "Failed ARM Test Case 30" severity error;

        -- MOV R0, #0
        -- Store 0 in R0 for Division By 0.
        t_Instr <= x"E" & "00" & "1" & x"D" & "0" & x"0" & x"0" & x"0" & x"00";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"0000004C") report "Failed ARM Test Case 31.2" severity error;
        assert (t_PC = x"00000020") report "Failed ARM Test Case 31.3" severity error;

        -- DIV R2, R1, R0
        -- Should have division by 0 error.
        -- Should store PC + 4 = 0x24 into R14.
        t_Instr <= x"E" & "00" & '0' & x"1" & '0' & x"2" & x"0" & x"0" & x"9" & x"1";
        wait for ClkPeriod;

        assert (t_MemWrite = '0') report "Failed ARM Test Case 31.4" severity error;

        -- MOV R5, #8
        -- Should not execute due to interrupt above.
        -- R5 should remain 4
        t_Instr <= x"E" & "00" & "1" & x"D" & "0" & x"5" & x"0" & x"0" & x"08";
        wait for ClkPeriod;

        -- MOV R4, #8
        -- Should not execute due to interrupt above.
        -- R4 should remain 3
        t_Instr <= x"E" & "00" & "1" & x"D" & "0" & x"4" & x"0" & x"0" & x"08";
        wait for ClkPeriod;

        -- Load interrupt handler into PC.
        assert (t_PC = x"0000004C") report "Failed ARM Test Case 31.5" severity error;
        -- ALUResult is PC + 4 of the interrupted instruction.
        assert (t_MemWrite = '0' and t_ALUResult = x"00000024") report "Failed ARM Test Case 31.6" severity error;

        -- MOV R5, R5
        t_Instr <= x"E" & "00" & "0" & x"D" & "0" & x"0" & x"5" & "00000" & "00" & "0" & x"5";
        wait for ClkPeriod;

        -- MOV R4, R4
        t_Instr <= x"E" & "00" & "0" & x"D" & "0" & x"0" & x"4" & "00000" & "00" & "0" & x"4";
        wait for ClkPeriod;

        -- MOV R15, R14
        -- Should load back stored value of PC.
        t_Instr <= x"E" & "00" & "0" & x"D" & "0" & x"0" & x"F" & "00000" & "00" & "0" & x"E";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000004") report "Failed ARM Test Case 31.7" severity error;
        t_Instr <= x"00000000";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000003") report "Failed ARM Test Case 31.8" severity error;
        t_Instr <= x"00000000";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000024") report "Failed ARM Test Case 31.9" severity error;
        assert (t_PC = x"00000024") report "Failed ARM Test Case 31.10" severity error;
        t_Instr <= x"00000000";
        wait for ClkPeriod;



        assert (t_PC = x"00000028") report "Failed ARM Test Case 32.1" severity error;

        -- Test Case 32: Handle Div by 0 interrupt.
        -- BL LABEL
        -- Should put PC + 8 + 0xC << 2 = 0x28 + 8 + 12 << 2 = 0x60.
        t_Instr <= x"E" & "10" & "11" & x"00000C";
        wait for ClkPeriod;

        -- No assertion for MUL instruction.

        -- STR R13, [R-], #1
        -- Store intruction handler in R13 for Div By 0 interrupt.
        t_Instr <= x"E" & "01" & "001000" & x"0" & x"D" & x"001";
        wait for ClkPeriod;

        -- assert (t_MemWrite = '0' and t_ALUResult = x"00000003") report "Failed ARM Test Case 30" severity error;

        -- MOV R0, #0
        -- Store 0 in R0 for Division By 0.
        t_Instr <= x"E" & "00" & "1" & x"D" & "0" & x"0" & x"0" & x"0" & x"00";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000060") report "Failed ARM Test Case 32.2" severity error;
        assert (t_PC = x"00000034") report "Failed ARM Test Case 32.3" severity error;

        -- DIV R2, R1, R0
        -- Should have division by 0 error.
        -- Should store PC + 4 = 0x24 into R14.
        t_Instr <= x"E" & x"C000000";
        wait for ClkPeriod;

        assert (t_MemWrite = '0') report "Failed ARM Test Case 32.4" severity error;

        -- MOV R5, #8
        -- Should not execute due to interrupt above.
        -- R5 should remain 4
        t_Instr <= x"E" & "00" & "1" & x"D" & "0" & x"5" & x"0" & x"0" & x"08";
        wait for ClkPeriod;

        -- MOV R4, #8
        -- Should not execute due to interrupt above.
        -- R4 should remain 3
        t_Instr <= x"E" & "00" & "1" & x"D" & "0" & x"4" & x"0" & x"0" & x"08";
        wait for ClkPeriod;

        -- Load interrupt handler into PC.
        assert (t_PC = x"00000060") report "Failed ARM Test Case 32.5" severity error;
        -- ALUResult is PC + 4 of the interrupted instruction.
        assert (t_MemWrite = '0' and t_ALUResult = x"00000038") report "Failed ARM Test Case 32.6" severity error;

        -- MOV R5, R5
        t_Instr <= x"E" & "00" & "0" & x"D" & "0" & x"0" & x"5" & "00000" & "00" & "0" & x"5";
        wait for ClkPeriod;

        -- MOV R4, R4
        t_Instr <= x"E" & "00" & "0" & x"D" & "0" & x"0" & x"4" & "00000" & "00" & "0" & x"4";
        wait for ClkPeriod;

        -- MOV R15, R14
        -- Should load back stored value of PC.
        t_Instr <= x"E" & "00" & "0" & x"D" & "0" & x"0" & x"F" & "00000" & "00" & "0" & x"E";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000004") report "Failed ARM Test Case 32.7" severity error;
        t_Instr <= x"00000000";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000003") report "Failed ARM Test Case 32.8" severity error;
        t_Instr <= x"00000000";
        wait for ClkPeriod;

        assert (t_MemWrite = '0' and t_ALUResult = x"00000038") report "Failed ARM Test Case 32.9" severity error;
        assert (t_PC = x"00000038") report "Failed ARM Test Case 32.10" severity error;
        t_Instr <= x"00000000";
        wait for ClkPeriod;

        wait;

    end process;

end test_arm_behavioral;
