library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_decoder is
-- Port ( );
end test_decoder;

architecture test_decoder_behavioral of test_decoder is

    component Decoder
    port (
        Rd : in std_logic_vector(3 downto 0);
        Op : in std_logic_vector(1 downto 0);
        Funct : in std_logic_vector(5 downto 0);
        MCycleFunct : in std_logic_vector(3 downto 0);
        IsShiftReg : in std_logic;
        PCS : out std_logic;
        RegW : out std_logic;
        MemW : out std_logic;
        InterruptControlW : out std_logic;
        MemtoReg : out std_logic;
        ALUSrc : out std_logic;
        ImmSrc : out std_logic_vector(1 downto 0);
        ShamtSrc : out std_logic_vector(1 downto 0);
        RegSrc : out std_logic_vector(2 downto 0);
        ALUResultSrc : out std_logic;
        NoWrite : out std_logic;
        ALUControl : out std_logic_vector(3 downto 0);
        MCycleS : out std_logic;
        MCycleOp : out std_logic_vector(1 downto 0);
        FlagW : out std_logic_vector(2 downto 0);
        isArithmeticDP : out std_logic);
    end component;

    signal t_Rd : std_logic_vector(3 downto 0);
    signal t_Op : std_logic_vector(1 downto 0);
    signal t_Funct : std_logic_vector(5 downto 0);
    signal t_MCycleFunct : std_logic_vector(3 downto 0);
    signal t_IsShiftReg : std_logic;
    signal t_PCS : std_logic;
    signal t_RegW : std_logic;
    signal t_MemW : std_logic;
    signal t_InterruptControlW : std_logic;
    signal t_MemtoReg : std_logic;
    signal t_ALUSrc : std_logic;
    signal t_ImmSrc : std_logic_vector(1 downto 0);
    signal t_ShamtSrc : std_logic_vector(1 downto 0);
    signal t_RegSrc : std_logic_vector(2 downto 0);
    signal t_ALUResultSrc : std_logic;
    signal t_NoWrite : std_logic;
    signal t_ALUControl : std_logic_vector(3 downto 0);
    signal t_MCycleS : std_logic;
    signal t_MCycleOp : std_logic_vector(1 downto 0);
    signal t_FlagW : std_logic_vector(2 downto 0);
    signal t_isArithmeticDP : std_logic;

begin

    test_decoder_module: Decoder
    port map (
        -- Inputs
        Rd => t_Rd,
        Op => t_Op,
        Funct => t_Funct,
        MCycleFunct => t_MCycleFunct,
        IsShiftReg => t_IsShiftReg,
        -- Outputs
        PCS => t_PCS,
        RegW => t_RegW,
        MemW => t_MemW,
        InterruptControlW => t_InterruptControlW,
        MemtoReg => t_MemtoReg,
        ALUSrc => t_ALUSrc,
        ImmSrc => t_ImmSrc,
        ShamtSrc => t_ShamtSrc,
        RegSrc => t_RegSrc,
        ALUResultSrc => t_ALUResultSrc,
        NoWrite => t_NoWrite,
        ALUControl => t_ALUControl,
        MCycleS => t_MCycleS,
        MCycleOp => t_MCycleOp,
        FlagW => t_FlagW,
        isArithmeticDP => t_isArithmeticDP
    );

    stim_proc: process begin

        -- Set initial values for inputs
        t_Rd <= (others => '0'); t_Op <= (others => '0'); t_Funct <= (others => '0'); t_IsShiftReg <= '0'; t_MCycleFunct <= (others => '0');
        wait for 5 ns;

        -- Note: Most of the tests require MCycleFunct to be something other than 1001.

        -- Test case 1: Branch (B) Instruction
        t_Op <= "10"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='1' and t_RegW='0' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ImmSrc="10" and t_ShamtSrc="00" and t_RegSrc="0-1" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="000") report "Failed Decoder Test Case 1" severity error;

        -- Test case 2: Memory (STR) Instruction
        t_Rd <= "0001"; t_Op <= "01"; t_Funct(0) <= '0'; t_Funct(3) <= '1'; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='0' and t_MemW='1' and t_ALUSrc='1' and t_ImmSrc="01" and t_ShamtSrc="00" and t_RegSrc="010" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="000") report "Failed Decoder Test Case 2" severity error;

        -- Test case 2.1: Memory (STR) Instruction with negative offset
        t_Rd <= "0001"; t_Op <= "01"; t_Funct(0) <= '0'; t_Funct(3) <= '0'; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS ='0' and t_RegW='0' and t_MemW='1' and t_ALUSrc='1' and t_ImmSrc="01" and t_ShamtSrc="00" and t_RegSrc="010" and t_NoWrite='0' and t_ALUControl="0010" and t_FlagW="000") report "Failed Decoder Test 2.1" severity error;

        -- Test case 3: Memory (LDR) Instruction
        t_Rd <= "0010"; t_Op <= "01"; t_Funct(0) <= '1'; t_Funct(3) <= '1'; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='1' and t_ALUSrc='1' and t_ImmSrc="01" and t_ShamtSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="000") report "Failed Decoder Test Case 3" severity error;

        -- Test case 3.1: Memory (LDR) Instruction with negative offset
        t_Rd <= "0010"; t_Op <= "01"; t_Funct(0) <= '1'; t_Funct(3) <= '0'; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='1' and t_ALUSrc='1' and t_ImmSrc="01" and t_ShamtSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0010" and t_FlagW="000") report "Failed Decoder Test Case 3.1" severity error;

        -- Test case 4: Memory Instruction with Rd = 15
        t_Rd <= "1111"; t_Op <= "01"; t_Funct(0) <= '1'; t_Funct(3) <= '1'; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='1' and t_RegW='1' and t_MemW='0' and t_MemtoReg='1' and t_ALUSrc='1' and t_ImmSrc="01" and t_ShamtSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="000") report "Failed Decoder Test Case 4" severity error;

        -- Test case 5: DP Reg (ADD) Instruction
        t_Rd <= "0011"; t_Op <= "00"; t_Funct <= "001000"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="000" and t_isArithmeticDP='1') report "Failed Decoder Test Case 5" severity error;

        -- Test case 6: DP Reg (ADDS) Instruction
        t_Rd <= "0100"; t_Op <= "00"; t_Funct <= "001001"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="11" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 6" severity error;

        -- Test case 7: DP Reg (SUB) Instruction
        t_Rd <= "0101"; t_Op <= "00"; t_Funct <= "000100"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0010" and t_FlagW="000" and t_isArithmeticDP='1') report "Failed Decoder Test Case 7" severity error;

        -- Test case 8: DP Reg (SUBS) Instruction
        t_Rd <= "0110"; t_Op <= "00"; t_Funct <= "000101"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="11" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0010" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 8" severity error;

        -- Test case 9: DP Reg (AND) Instruction
        t_Rd <= "0111"; t_Op <= "00"; t_Funct <= "000000"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0000" and t_FlagW="000" and t_isArithmeticDP='0') report "Failed Decoder Test Case 9" severity error;

        -- Test case 10: DP Reg (ANDS) Instruction
        t_Rd <= "1000"; t_Op <= "00"; t_Funct <= "000001"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="11" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0000" and t_FlagW="110" and t_isArithmeticDP='0') report "Failed Decoder Test Case 10" severity error;

        -- Test case 11: DP Reg (ORR) Instruction
        t_Rd <= "1001"; t_Op <= "00"; t_Funct <= "011000"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="1100" and t_FlagW="000" and t_isArithmeticDP='0') report "Failed Decoder Test Case 11" severity error;

        -- Test case 12: DP Reg (ORRS) Instruction
        t_Rd <= "1010"; t_Op <= "00"; t_Funct <= "011001"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="11" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="1100" and t_FlagW="110" and t_isArithmeticDP='0') report "Failed Decoder Test Case 12" severity error;

        -- Test case 13: DP Reg (EORS) Instruction
        t_Rd <= "0001"; t_Op <= "00"; t_Funct <= "000011"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0001" and t_FlagW="110" and t_isArithmeticDP='0') report "Failed Decoder Test Case 13" severity error;

        -- Test case 14: DP Reg (EOR) Instruction
        t_Rd <= "0001"; t_Op <= "00"; t_Funct <= "000010"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="11" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0001" and t_FlagW="000" and t_isArithmeticDP='0') report "Failed Decoder Test Case 14" severity error;

        -- Test case 15: DP Reg (TST) Instruction
        t_Rd <= "0010"; t_Op <= "00"; t_Funct <= "010001"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='1' and t_ALUControl="1000" and t_FlagW="110" and t_isArithmeticDP='0') report "Failed Decoder Test Case 15" severity error;

        -- Test case 16: DP Reg (TEQ) Instruction
        t_Rd <= "0011"; t_Op <= "00"; t_Funct <= "010011"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="11" and t_RegSrc="000" and t_NoWrite='1' and t_ALUControl="1001" and t_FlagW="110" and t_isArithmeticDP='0') report "Failed Decoder Test Case 16" severity error;

        -- Test case 17: DP Reg (MOVS) Instruction
        t_Rd <= "0100"; t_Op <= "00"; t_Funct <= "011011"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="1101" and t_FlagW="110" and t_isArithmeticDP='0') report "Failed Decoder Test Case 17" severity error;

        -- Test case 18: DP Reg (MOV) Instruction
        t_Rd <= "0100"; t_Op <= "00"; t_Funct <= "011010"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="11" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="1101" and t_FlagW="000" and t_isArithmeticDP='0') report "Failed Decoder Test Case 18" severity error;

        -- Test case 19: DP Reg (BICS) Instruction
        t_Rd <= "0101"; t_Op <= "00"; t_Funct <= "011101"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="1110" and t_FlagW="110" and t_isArithmeticDP='0') report "Failed Decoder Test Case 19" severity error;

        -- Test case 20: DP Reg (BIC) Instruction
        t_Rd <= "0101"; t_Op <= "00"; t_Funct <= "011100"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="11" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="1110" and t_FlagW="000" and t_isArithmeticDP='0') report "Failed Decoder Test Case 20" severity error;

        -- Test case 21: DP Reg (MVNS) Instruction
        t_Rd <= "0110"; t_Op <= "00"; t_Funct <= "011111"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="1111" and t_FlagW="110" and t_isArithmeticDP='0') report "Failed Decoder Test Case 21" severity error;

        -- Test case 22: DP Reg (MVN) Instruction
        t_Rd <= "0110"; t_Op <= "00"; t_Funct <= "011110"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="11" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="1111" and t_FlagW="000" and t_isArithmeticDP='0') report "Failed Decoder Test Case 22" severity error;

        -- Test case 23: DP Imm (ADD) Instruction
        t_Rd <= "1011"; t_Op <= "00"; t_Funct <= "101000"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="000" and t_isArithmeticDP='1') report "Failed Decoder Test Case 23" severity error;

        -- Test case 24: DP Imm (ADDS) Instruction
        t_Rd <= "1100"; t_Op <= "00"; t_Funct <= "101001"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 24" severity error;

        -- Test case 25: DP Imm (SUB) Instruction
        t_Rd <= "1101"; t_Op <= "00"; t_Funct <= "100100"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0010" and t_FlagW="000" and t_isArithmeticDP='1') report "Failed Decoder Test Case 25" severity error;

        -- Test case 26: DP Imm (SUBS) Instruction
        t_Rd <= "1110"; t_Op <= "00"; t_Funct <= "100101"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0010" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 26" severity error;

        -- Test case 27: DP Imm (AND) Instruction
        t_Rd <= "0001"; t_Op <= "00"; t_Funct <= "100000"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0000" and t_FlagW="000" and t_isArithmeticDP='0') report "Failed Decoder Test Case 27" severity error;

        -- Test case 28: DP Imm (ANDS) Instruction
        t_Rd <= "0010"; t_Op <= "00"; t_Funct <= "100001"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0000" and t_FlagW="110" and t_isArithmeticDP='0') report "Failed Decoder Test Case 28" severity error;

        -- Test case 29: DP Imm (ORR) Instruction
        t_Rd <= "0011"; t_Op <= "00"; t_Funct <= "111000"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="1100" and t_FlagW="000" and t_isArithmeticDP='0') report "Failed Decoder Test Case 29" severity error;

        -- Test case 30: DP Imm (ORRS) Instruction
        t_Rd <= "0100"; t_Op <= "00"; t_Funct <= "111001"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="1100" and t_FlagW="110" and t_isArithmeticDP='0') report "Failed Decoder Test Case 30" severity error;

        -- Test case 31: DP Reg (CMP) Instruction
        t_Rd <= "0101"; t_Op <= "00"; t_Funct <= "010101"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='1' and t_ALUControl="1010" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 31" severity error;

        -- Test case 32: DP Imm (CMP) Instruction
        t_Rd <= "0110"; t_Op <= "00"; t_Funct <= "110101"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='1' and t_ALUControl="1010" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 32" severity error;

        -- Test case 33: DP Reg (CMN) Instruction
        t_Rd <= "0100"; t_Op <= "00"; t_Funct <= "010111"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='1' and t_ALUControl="1011" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 33" severity error;

        -- Test case 34: DP Imm (CMN) Instruction
        t_Rd <= "1000"; t_Op <= "00"; t_Funct <= "110111"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='1' and t_ALUControl="1011" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 34" severity error;

        -- Test case 35: DP Reg (RSB) Instruction
        t_Rd <= "1001"; t_Op <= "00"; t_Funct <= "000110"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0011" and t_FlagW="000" and t_isArithmeticDP='1') report "Failed Decoder Test Case 35" severity error;

        -- Test case 36: DP Reg (RSBS) Instruction
        t_Rd <= "0010"; t_Op <= "00"; t_Funct <= "000111"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="11" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0011" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 36" severity error;

        -- Test case 37: DP Imm (RSC) Instruction
        t_Rd <= "0101"; t_Op <= "00"; t_Funct <= "101110"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0111" and t_FlagW="000" and t_isArithmeticDP='1') report "Failed Decoder Test Case 37" severity error;

        -- Test case 38: DP Imm (RSCS) Instruction
        t_Rd <= "1010"; t_Op <= "00"; t_Funct <= "101111"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0111" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 38" severity error;

        -- Test case 39: DP Imm (SBC) Instruction
        t_Rd <= "1011"; t_Op <= "00"; t_Funct <= "101100"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0110" and t_FlagW="000" and t_isArithmeticDP='1') report "Failed Decoder Test Case 39" severity error;

        -- Test case 40: DP Reg (SBCS) Instruction
        t_Rd <= "1110"; t_Op <= "00"; t_Funct <= "001101"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="11" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0110" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 40" severity error;

        -- Test case 41: DP Reg (ADC) Instruction
        t_Rd <= "0000"; t_Op <= "00"; t_Funct <= "001010"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0101" and t_FlagW="000" and t_isArithmeticDP='1') report "Failed Decoder Test Case 41" severity error;

        -- Test case 42: DP Imm (ADCS) Instruction
        t_Rd <= "0011"; t_Op <= "00"; t_Funct <= "101011"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0101" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 42" severity error;

        -- Test case 43: DP Reg Instruction with Rd = 15
        t_Rd <= "1111"; t_Op <= "00"; t_Funct <= "010101"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='1' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="01" and t_RegSrc="000" and t_NoWrite='1' and t_ALUControl="1010" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 43" severity error;

        -- Test case 44: DP Imm Instruction with Rd = 15
        t_Rd <= "1111"; t_Op <= "00"; t_Funct <= "110101"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='1' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ShamtSrc="10" and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='1' and t_ALUControl="1010" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 44" severity error;

        -- Test case 45.1: DP (MUL) Instruction
        t_Rd <= "----"; t_Op <= "00"; t_Funct <= "000000"; t_MCycleFunct <= "1001"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="00" and t_RegSrc="100" and t_NoWrite='0' and t_FlagW="000" and t_ALUResultSrc='1' and t_MCycleS='1' and t_MCycleOp="01") report "Failed Decoder Test Case 45.1" severity error;

        -- Test case 45.2: DP (MUL) Instruction
        -- S flag set, but MUL does not set any flags.
        t_Rd <= "----"; t_Op <= "00"; t_Funct <= "000001"; t_MCycleFunct <= "1001"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="00" and t_RegSrc="100" and t_NoWrite='0' and t_FlagW="000" and t_ALUResultSrc='1' and t_MCycleS='1' and t_MCycleOp="01") report "Failed Decoder Test Case 45.2" severity error;

        -- Test case 46.1: DP (DIV) Instruction
        t_Rd <= "----"; t_Op <= "00"; t_Funct <= "000010"; t_MCycleFunct <= "1001"; t_IsShiftReg <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="00" and t_RegSrc="100" and t_NoWrite='0' and t_FlagW="000" and t_ALUResultSrc='1' and t_MCycleS='1' and t_MCycleOp="11") report "Failed Decoder Test Case 46.1" severity error;

        -- Test case 46.2: DP (DIV) Instruction
        -- S flag set, but DIV does not set any flags.
        t_Rd <= "----"; t_Op <= "00"; t_Funct <= "000011"; t_MCycleFunct <= "1001"; t_IsShiftReg <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_ShamtSrc="00" and t_RegSrc="100" and t_NoWrite='0' and t_FlagW="000" and t_ALUResultSrc='1' and t_MCycleS='1' and t_MCycleOp="11") report "Failed Decoder Test Case 46.2" severity error;

        wait;

    end process;

end test_decoder_behavioral;
