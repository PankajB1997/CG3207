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
        -- Each test case will start at x.5 ns, where x is 0, 1, 2... This is to keep track of where the clock is
        -- since some of the tests will be using the clock.
        wait for ClkPeriod / 2;

        -- Before time = ClkPeriod, some signals may be U or X. That is expected, as the processor is only reset
        -- at the first clock edge, and this is when the PC is set to 0. Before this, PC is indeterminate.

        -- RESET = 1 to set PC to 0.
        t_RESET <= '1';
        wait for ClkPeriod;

        -- Test case 1: Check that PC starts off as 0
        assert (t_PC = x"00000000") report "Failed ARM Test Case 1" severity error;
        t_RESET <= '0';

        -- Test case 2: Load 3 into register - LDR R0, [R15]
        -- R15 is used as the base register since it's the only register with a determined value.
        -- The rest of the registers are uninitialized. The value of R15 doesn't actually matter
        -- here since the value read from memory is supplied as an input. ALUResult will be the
        -- value of R15, which is PC + 8.
        -- PC will still be 0 as clock edge not yet reached.
        t_Instr <= x"E" & "01" & "011001" & x"F" & x"0" & x"000";
        t_ReadData <= x"00000003";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '0' and t_ALUResult = x"00000008") report "Failed ARM Test Case 2.1" severity error;
        wait for ClkPeriod * 9 / 10;
        -- PC should have incremented at clock edge.
        assert (t_PC = x"00000004") report "Failed ARM Test Case 2.2" severity error;

        -- Test Case 3.1: Add register with immediate - ADD R1, R0, #5
        t_Instr <= x"E" & "00" & "1" & x"4" & "0" & x"0" & x"1" & x"0" & x"05";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '0' and t_ALUResult = x"00000008") report "Failed ARM Test Case 3.1" severity error;

        wait for ClkPeriod * 9 / 10;

        --Test Case 3.2: Add register with immediate shifts -- ADD R2, R1, R0, LSL #2
        -- ALUResult is R1 + R0 << 2 = 8 + 3 << 2 = 20 = 0x14
        t_Instr <= x"E" & "00" & "0" & x"4" & "0" & x"1" & x"2" & "00010" & "00" & "0" & x"0";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '0' and t_ALUResult = x"00000014") report "Failed ARM Test Case 3.2" severity error;

        wait for ClkPeriod * 9 / 10;

        -- Test Case 4: Store register value into memory, does not happen due to condition - STREQ R0, [R1, #12]
        -- Also tests immediate offset in STR.
        -- Flags should all start off as 0, so EQ will fail
        -- ALUResult should be R1 + 12 = 20 = 0x14
        t_Instr <= x"0" & "01" & "011000" & x"1" & x"0" & x"00c";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '0' and t_ALUResult = x"00000014" and t_WriteData = x"00000003") report "Failed ARM Test Case 4" severity error;

        wait for ClkPeriod * 9 / 10;

        -- Test Case 5: AND two registers and update flags: ANDS R15, R1, R0
        -- ALUResult = 3 & 8 = 0
        -- R15 is being written into, so PC should update to 0
        t_Instr <= x"E" & "00" & "0" & x"0" & "1" & x"1" & x"F" & "00000" & "00" & "0" & x"0";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '0' and t_ALUResult = x"00000000") report "Failed ARM Test Case 5.1" severity error;

        wait for ClkPeriod * 9 / 10;
        assert (t_PC = x"00000000") report "Failed ARM Test Case 5.2" severity error;

        -- Test Case 6.1: Same store operation as above but happens this time - STREQ R0, [R1, #12]
        -- Also tests immediate offset in STR.
        -- Z should be 1 after previous instruction, so EQ will pass
        -- ALUResult should be R1 + 12 = 20 = 0x14
        t_Instr <= x"0" & "01" & "011000" & x"1" & x"0" & x"00c";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '1' and t_ALUResult = x"00000014" and t_WriteData = x"00000003") report "Failed ARM Test Case 6.1" severity error;

        wait for ClkPeriod * 9 / 10;

        -- Test Case 6.2: STR with negative offset: STR R2, [R1, #-4]
        -- ALUResult should be R1 - 4 = 4 = 0x4
        t_Instr <= x"E" & "01" & "010000" & x"1" & x"2" & x"004";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '1' and t_ALUResult = x"00000004" and t_WriteData = x"00000014") report "Failed ARM Test Case 6.2" severity error;

        wait for ClkPeriod * 9 / 10;
        assert (t_PC = x"00000008") report "Failed ARM Test Case 6.3" severity error;

        -- Test case 7: Branch instruction - B LABEL
        -- LABEL is specified relative to PC, here PC is forced to move forward 5 instructions.
        -- To do so, offset must be 3, since it is taken relative to PC + 8
        -- PC was 8 after previous instruction. So new value will be 8 + 20 = 0x1C
        t_Instr <= x"E" & "10" & "10" & x"000003";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '0' and t_ALUResult = x"0000001C") report "Failed ARM Test Case 7.1" severity error;

        wait for ClkPeriod * 9 / 10;
        assert (t_PC = x"0000001C") report "Failed ARM Test Case 7.2" severity error;

        -- Test case 8: Branch instruction with negative offset - B LABEL
        -- This time offset will be -4, to send the PC back 2 instructions.
        -- New value of PC will be 28 - 8 = 0x14
        t_Instr <= x"E" & "10" & "10" & x"FFFFFC";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '0' and t_ALUResult = x"00000014") report "Failed ARM Test Case 8.1" severity error;

        wait for ClkPeriod * 9 / 10;
        assert (t_PC = x"00000014") report "Failed ARM Test Case 8.2" severity error;

        -- Test case 9: Multiply two registers - MUL R3, R2, R1
        -- R3 = R2 * R1 = 0x14 * 0x8 = 0x70
        t_Instr <= x"E" & "00" & '0' & x"0" & '0' & x"3" & x"0" & x"1" & x"9" & x"2";
        -- Wait until PC increments.
        wait until t_PC = x"00000018";
        assert (t_MemWrite = '0' and t_ALUResult = x"000000a0") report "Failed ARM Test Case 9" severity error;

        wait for ClkPeriod / 2;

        -- Test case 10: Divide two registers - DIV R4, R3, R2 (MLA R4, R3, R2, R-)
        -- R4 = R3 * R2 = 0xa0 / 0x14 = 0x8
        t_Instr <= x"E" & "00" & '0' & x"1" & '0' & x"4" & x"0" & x"2" & x"9" & x"3";
        -- Wait until PC increments.
        wait until t_PC = x"0000001C";
        assert (t_MemWrite = '0' and t_ALUResult = x"00000008") report "Failed ARM Test Case 10" severity error;

        wait for ClkPeriod / 2;

        -- Test case 11: Multiply a register by itself - MUL R1, R1, R1
        -- R1 = R1 * R1 = 0x8 / 0x8 = 0x40
        t_Instr <= x"E" & "00" & '0' & x"0" & '0' & x"1" & x"0" & x"1" & x"9" & x"1";
        -- Wait until PC increments.
        wait until t_PC = x"00000020";
        assert (t_MemWrite = '0' and t_ALUResult = x"00000040") report "Failed ARM Test Case 11" severity error;

        wait for ClkPeriod / 2;

        -- Test case 12: Reverse subtract values with carry - RSC R4, R1, #48 (hex)
        -- R4 = 48 - R1 - NOT Carry = 0x48 - 0x40 - 1 = 0x7
        t_Instr <= x"E" & "00" & '1' & x"7" & '0' & x"1" & x"4" & x"0" & x"48";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '0' and t_ALUResult = x"00000007") report "Failed ARM Test Case 12.1" severity error;

        wait for ClkPeriod * 9 / 10;
        assert (t_PC = x"00000024") report "Failed ARM Test Case 12.2" severity error;
        
        -- Test case 13: TST two registers and update flags: TST R0, #12
        -- R0 = 3 = 0011
        -- #12 = 1100
        -- R0 AND #12 = 0011 AND 1100 = 0000
        -- Z flag is set
        t_Instr <= x"E" & "00" & '1' & x"8" & '1' & x"0" & x"0" & x"0" & x"0" & x"C";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '0') report "Failed ARM Test Case 13" severity error;
   
        wait for ClkPeriod * 9 / 10;
         
        -- Test case 14: Check if Z flag was set after the previous TST operation : ADDEQ R5, R0, #1
        -- R5 = R0 + #1 happens only if Z flag was set in the previous operation
        -- ALUResult = R5 = 3 + 1 = 4
        -- Hence, ALUResult = 4 only if Z flag was set in the previous operation (which was TST)
        t_Instr <= x"0" & "00" & '1' & x"4" & '0' & x"0" & x"5" & x"0" & x"0" & x"1";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '0' and t_ALUResult = x"00000004") report "Failed ARM Test Case 14" severity error;
            
        wait for ClkPeriod * 9 / 10;

        -- Test Case 15: MOV the contents of one register into another register: MOV R7, R2
        -- ALUResult = 0x14
        t_Instr <= x"E" & "00" & "0" & x"D" & "0" & x"0" & x"7" & "00000" & "00" & "0" & x"2";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '0' and t_ALUResult = x"00000014") report "Failed ARM Test Case 15" severity error;

        wait for ClkPeriod * 9 / 10;
        
        -- Test Case 16: BICS two registers and update flags: BICS R8, R4, R0
        -- R4 = 7, R0 = 3
        -- ALUResult = R4 AND (not R0) = 0111 AND (not 0011) = 0111 AND 1100 = 0100 = 4
        t_Instr <= x"E" & "00" & "0" & x"E" & "1" & x"4" & x"8" & "00000" & "00" & "0" & x"0";
        wait for ClkPeriod / 10;
        assert (t_MemWrite = '0' and t_ALUResult = x"00000004") report "Failed ARM Test Case 16" severity error;
   
        wait;

    end process;

end test_arm_behavioral;