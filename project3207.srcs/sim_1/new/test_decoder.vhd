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
        PCS : out std_logic;
        RegW : out std_logic;
        MemW : out std_logic;
        MemtoReg : out std_logic;
        ALUSrc : out std_logic;
        ImmSrc : out std_logic_vector(1 downto 0);
        RegSrc : out std_logic_vector(2 downto 0);
        ALUResultSrc : out std_logic;
        NoWrite : out std_logic;
        ALUControl : out std_logic_vector(3 downto 0);
        MCycleStart : out std_logic;
        MCycleOp : out std_logic_vector(1 downto 0);
        FlagW : out std_logic_vector(2 downto 0);
        isArithmeticDP : out std_logic);
    end component;

    signal t_Rd : std_logic_vector(3 downto 0);
    signal t_Op : std_logic_vector(1 downto 0);
    signal t_Funct : std_logic_vector(5 downto 0);
    signal t_MCycleFunct : std_logic_vector(3 downto 0);
    signal t_PCS : std_logic;
    signal t_RegW : std_logic;
    signal t_MemW : std_logic;
    signal t_MemtoReg : std_logic;
    signal t_ALUSrc : std_logic;
    signal t_ImmSrc : std_logic_vector(1 downto 0);
    signal t_RegSrc : std_logic_vector(2 downto 0);
    signal t_ALUResultSrc : std_logic;
    signal t_NoWrite : std_logic;
    signal t_ALUControl : std_logic_vector(3 downto 0);
    signal t_MCycleStart : std_logic;
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
        -- Outputs
        PCS => t_PCS,
        RegW => t_RegW,
        MemW => t_MemW,
        MemtoReg => t_MemtoReg,
        ALUSrc => t_ALUSrc,
        ImmSrc => t_ImmSrc,
        RegSrc => t_RegSrc,
        ALUResultSrc => t_ALUResultSrc,
        NoWrite => t_NoWrite,
        ALUControl => t_ALUControl,
        MCycleStart => t_MCycleStart,
        MCycleOp => t_MCycleOp,
        FlagW => t_FlagW,
        isArithmeticDP => t_isArithmeticDP
    );

    stim_proc: process begin

        -- Set initial values for inputs
        t_Rd <= (others => '0'); t_Op <= (others => '0'); t_Funct <= (others => '0'); t_MCycleFunct <= (others => '0');
        wait for 5 ns;

        -- Note: Most of the tests require MCycleFunct to be something other than 1001.

        -- Test case 1: Branch Instruction
        t_Op <= "10";
        wait for 5 ns;
        assert (t_PCS='1' and t_RegW='0' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ImmSrc="10" and t_RegSrc="0-1" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="000") report "Failed Decoder Test Case 1" severity error;

        -- Test case 2: Memory (STR) Instruction
        t_Rd <= "0001"; t_Op <= "01"; t_Funct(0) <= '0'; t_Funct(3) <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='0' and t_MemW='1' and t_ALUSrc='1' and t_ImmSrc="01" and t_RegSrc="010" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="000") report "Failed Decoder Test Case 2" severity error;

        -- Test case 2.1: Memory (STR) Instruction with negative offset
        t_Rd <= "0001"; t_Op <= "01"; t_Funct(0) <= '0'; t_Funct(3) <= '0';
        wait for 5 ns;
        assert (t_PCS ='0' and t_RegW='0' and t_MemW='1' and t_ALUSrc='1' and t_ImmSrc="01" and t_RegSrc="010" and t_NoWrite='0' and t_ALUControl="0010" and t_FlagW="000") report "Failed Decoder Test 2.1" severity error;

        -- Test case 3: Memory (LDR) Instruction
        t_Rd <= "0010"; t_Op <= "01"; t_Funct(0) <= '1'; t_Funct(3) <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='1' and t_ALUSrc='1' and t_ImmSrc="01" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="000") report "Failed Decoder Test Case 3" severity error;

        -- Test case 3.1: Memory (LDR) Instruction with negative offset
        t_Rd <= "0010"; t_Op <= "01"; t_Funct(0) <= '1'; t_Funct(3) <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='1' and t_ALUSrc='1' and t_ImmSrc="01" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0010" and t_FlagW="000") report "Failed Decoder Test Case 3.1" severity error;

        -- Test case 4: Memory Instruction with Rd = 15
        t_Rd <= "1111"; t_Op <= "01"; t_Funct(0) <= '1'; t_Funct(3) <= '1';
        wait for 5 ns;
        assert (t_PCS='1' and t_RegW='1' and t_MemW='0' and t_MemtoReg='1' and t_ALUSrc='1' and t_ImmSrc="01" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="000") report "Failed Decoder Test Case 4" severity error;

        -- Test case 5: DP Reg (ADD) Instruction
        t_Rd <= "0011"; t_Op <= "00"; t_Funct <= "001000";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="000" and t_isArithmeticDP='1') report "Failed Decoder Test Case 5" severity error;

        -- Test case 6: DP Reg (ADDS) Instruction
        t_Rd <= "0100"; t_Op <= "00"; t_Funct <= "001001";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 6" severity error;

        -- Test case 7: DP Reg (SUB) Instruction
        t_Rd <= "0101"; t_Op <= "00"; t_Funct <= "000100";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0010" and t_FlagW="000" and t_isArithmeticDP='1') report "Failed Decoder Test Case 7" severity error;

        -- Test case 8: DP Reg (SUBS) Instruction
        t_Rd <= "0110"; t_Op <= "00"; t_Funct <= "000101";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0010" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 8" severity error;

        -- Test case 9: DP Reg (AND) Instruction
        t_Rd <= "0111"; t_Op <= "00"; t_Funct <= "000000";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0000" and t_FlagW="000" and t_isArithmeticDP='0') report "Failed Decoder Test Case 9" severity error;

        -- Test case 10: DP Reg (ANDS) Instruction
        t_Rd <= "1000"; t_Op <= "00"; t_Funct <= "000001";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="0000" and t_FlagW="100" and t_isArithmeticDP='0') report "Failed Decoder Test Case 10" severity error;

        -- Test case 11: DP Reg (ORR) Instruction
        t_Rd <= "1001"; t_Op <= "00"; t_Funct <= "011000";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="1100" and t_FlagW="000" and t_isArithmeticDP='0') report "Failed Decoder Test Case 11" severity error;

        -- Test case 12: DP Reg (ORRS) Instruction
        t_Rd <= "1010"; t_Op <= "00"; t_Funct <= "011001";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="000" and t_NoWrite='0' and t_ALUControl="1100" and t_FlagW="100" and t_isArithmeticDP='0') report "Failed Decoder Test Case 12" severity error;

        -- Test case 13: DP Imm (ADD) Instruction
        t_Rd <= "1011"; t_Op <= "00"; t_Funct <= "101000";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="000" and t_isArithmeticDP='1') report "Failed Decoder Test Case 13" severity error;

        -- Test case 14: DP Imm (ADDS) Instruction
        t_Rd <= "1100"; t_Op <= "00"; t_Funct <= "101001";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0100" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 14" severity error;

        -- Test case 15: DP Imm (SUB) Instruction
        t_Rd <= "1101"; t_Op <= "00"; t_Funct <= "100100";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0010" and t_FlagW="000" and t_isArithmeticDP='1') report "Failed Decoder Test Case 15" severity error;

        -- Test case 16: DP Imm (SUBS) Instruction
        t_Rd <= "1110"; t_Op <= "00"; t_Funct <= "100101";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0010" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 16" severity error;

        -- Test case 17: DP Imm (AND) Instruction
        t_Rd <= "0001"; t_Op <= "00"; t_Funct <= "100000";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0000" and t_FlagW="000" and t_isArithmeticDP='0') report "Failed Decoder Test Case 17" severity error;

        -- Test case 18: DP Imm (ANDS) Instruction
        t_Rd <= "0010"; t_Op <= "00"; t_Funct <= "100001";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="0000" and t_FlagW="100" and t_isArithmeticDP='0') report "Failed Decoder Test Case 18" severity error;

        -- Test case 19: DP Imm (ORR) Instruction
        t_Rd <= "0011"; t_Op <= "00"; t_Funct <= "111000";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="1100" and t_FlagW="000" and t_isArithmeticDP='0') report "Failed Decoder Test Case 19" severity error;

        -- Test case 20: DP Imm (ORRS) Instruction
        t_Rd <= "0100"; t_Op <= "00"; t_Funct <= "111001";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='0' and t_ALUControl="1100" and t_FlagW="100" and t_isArithmeticDP='0') report "Failed Decoder Test Case 20" severity error;

        -- Test case 21: DP Reg (CMP) Instruction
        t_Rd <= "0101"; t_Op <= "00"; t_Funct <= "010101";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="000" and t_NoWrite='1' and t_ALUControl="1010" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 21" severity error;

        -- Test case 22: DP Imm (CMP) Instruction
        t_Rd <= "0110"; t_Op <= "00"; t_Funct <= "110101";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='1' and t_ALUControl="1010" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 22" severity error;

        -- Test case 23: DP Reg Instruction with Rd = 15
        t_Rd <= "1111"; t_Op <= "00"; t_Funct <= "010101";
        wait for 5 ns;
        assert (t_PCS='1' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="000" and t_NoWrite='1' and t_ALUControl="1010" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 23" severity error;

        -- Test case 24: DP Imm Instruction with Rd = 15
        t_Rd <= "1111"; t_Op <= "00"; t_Funct <= "110101";
        wait for 5 ns;
        assert (t_PCS='1' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ImmSrc="00" and t_RegSrc="0-0" and t_NoWrite='1' and t_ALUControl="1010" and t_FlagW="111" and t_isArithmeticDP='1') report "Failed Decoder Test Case 24" severity error;

        -- Test case 25.1: DP (MUL) Instruction
        t_Rd <= "----"; t_Op <= "00"; t_Funct <= "000000"; t_MCycleFunct <= "1001";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="100" and t_NoWrite='0' and t_FlagW="000" and t_ALUResultSrc='1' and t_MCycleStart='1' and t_MCycleOp="01") report "Failed Decoder Test Case 25.1" severity error;

        -- Test case 25.2: DP (MUL) Instruction
        -- S flag set, but MUL does not set any flags.
        t_Rd <= "----"; t_Op <= "00"; t_Funct <= "000001"; t_MCycleFunct <= "1001";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="100" and t_NoWrite='0' and t_FlagW="000" and t_ALUResultSrc='1' and t_MCycleStart='1' and t_MCycleOp="01") report "Failed Decoder Test Case 25.2" severity error;

        -- Test case 26.1: DP (DIV) Instruction
        t_Rd <= "----"; t_Op <= "00"; t_Funct <= "000010"; t_MCycleFunct <= "1001";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="100" and t_NoWrite='0' and t_FlagW="000" and t_ALUResultSrc='1' and t_MCycleStart='1' and t_MCycleOp="11") report "Failed Decoder Test Case 26.1" severity error;

        -- Test case 26.2: DP (DIV) Instruction
        -- S flag set, but DIV does not set any flags.
        t_Rd <= "----"; t_Op <= "00"; t_Funct <= "000011"; t_MCycleFunct <= "1001";
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='0' and t_RegSrc="100" and t_NoWrite='0' and t_FlagW="000" and t_ALUResultSrc='1' and t_MCycleStart='1' and t_MCycleOp="11") report "Failed Decoder Test Case 26.2" severity error;

        wait;

    end process;

end test_decoder_behavioral;
