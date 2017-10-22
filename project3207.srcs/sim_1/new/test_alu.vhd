library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_alu is
--  Port ( );
end test_alu;

architecture test_alu_behavioral of test_alu is
    component ALU
    port (Src_A : in std_logic_vector (31 downto 0);
          Src_B : in std_logic_vector (31 downto 0);
          ALUControl : in std_logic_vector (3 downto 0);
          CarryFlag : in std_logic;
          ALUResult : out std_logic_vector (31 downto 0);
          ALUFlags : out std_logic_vector (3 downto 0));
    end component;

    signal t_Src_A : std_logic_vector (31 downto 0);
    signal t_Src_B : std_logic_vector (31 downto 0);
    signal t_ALUControl : std_logic_vector (3 downto 0);
    signal t_CarryFlag : std_logic;
    signal t_ALUResult : std_logic_vector (31 downto 0);
    signal t_ALUFlags : std_logic_vector (3 downto 0);
begin
    test_alu_module : ALU port map (
        -- Inputs
        Src_A => t_Src_A,
        Src_B => t_Src_B,
        ALUControl => t_ALUControl,
        CarryFlag => t_CarryFlag,
        -- Outputs
        ALUResult => t_ALUResult,
        ALUFlags => t_ALUFlags
    );

    stim_proc: process begin
        -- Set initial value for inputs.
        t_Src_A <= (others => '0'); t_Src_B <= (others => '0'); t_ALUControl <= (others => '0'); t_CarryFlag <= '0';
        wait for 1 ns;

        -- Test case 1: Add two numbers
        -- Input carry flag is 1, but answer should be the same since we're doing ADD, not ADC
        -- All flags are zero.
        t_Src_A <= x"00000005"; t_Src_B <= x"00000013"; t_CarryFlag <= '1'; t_ALUControl <= "0100";
        wait for 1 ns;
        assert (t_ALUResult = x"00000018" and t_ALUFlags = "0000") report "Failed ALU Test Case 1" severity error;

        -- Test case 2: Subtract positive number from negative number
        -- -3 - (+7) = -10
        -- Output carry flag is 1 since there is no borrow in the unsigned subtraction.
        t_Src_A <= x"FFFFFFFD"; t_Src_B <= x"00000007"; t_CarryFlag <= '0'; t_ALUControl <= "0010";
        wait for 1 ns;
        assert (t_ALUResult = x"FFFFFFF6" and t_ALUFlags = "1010") report "Failed ALU Test Case 2" severity error;

        -- Test case 3: Subtract unsigned numbers causes borrow
        -- 3 - 7 = -4
        -- Sets carry bit to 0 (NOT borrow).
        t_Src_A <= x"00000003"; t_Src_B <= x"00000007"; t_ALUControl <= "0010";
        wait for 1 ns;
        assert (t_ALUResult = x"FFFFFFFC" and t_ALUFlags = "1000") report "Failed ALU Test Case 3" severity error;

        -- Test case 4: Add signed numbers causes overflow
        t_Src_A <= x"7FFFFFFF"; t_Src_B <= x"00000001"; t_ALUControl <= "0100";
        wait for 1 ns;
        assert (t_ALUResult = x"80000000" and t_ALUFlags = "1001") report "Failed ALU Test Case 4" severity error;

        -- Test case 5: AND numbers results in 0
        t_Src_A <= x"0F0F0F0F"; t_Src_B <= x"F0F0F0F0"; t_ALUControl <= "0000";
        wait for 1 ns;
        assert (t_ALUResult = x"00000000" and t_ALUFlags = "0100") report "Failed ALU Test Case 5" severity error;

        -- Test case 6: Reverse subtract two numbers
        -- 7 - 5 = 2
        -- Carry flag is asserted as there is no borrow.
        t_Src_A <= x"00000005"; t_Src_B <= x"00000007"; t_ALUControl <= "0011";
        wait for 1 ns;
        assert (t_ALUResult = x"00000002" and t_ALUFlags = "0010") report "Failed ALU Test Case 6" severity error;

        -- Test case 7: Compare Negative two numbers (CMN)
        -- All flags are zero.
        t_Src_A <= x"00000005"; t_Src_B <= x"00000013"; t_ALUControl <= "1011";
        wait for 1 ns;
        assert (t_ALUResult = x"00000018" and t_ALUFlags = "0000") report "Failed ALU Test Case 7" severity error;

        -- Test case 8: Compare two numbers (CMP)
        -- 8 - 3 = 5
        -- Carry flag is asserted as there is no borrow.
        t_Src_A <= x"00000008"; t_Src_B <= x"00000003"; t_ALUControl <= "1010";
        wait for 1 ns;
        assert (t_ALUResult = x"00000005" and t_ALUFlags = "0010") report "Failed ALU Test Case 8" severity error;

        -- Test case 9: Add two numbers with carry
        -- 5 + (-6) + 1 = 0
        -- Zero flag and carry flag is asserted.
        t_Src_A <= x"00000005"; t_Src_B <= x"FFFFFFFA"; t_CarryFlag <= '1'; t_ALUControl <= "0101";
        wait for 1 ns;
        assert (t_ALUResult = x"00000000" and t_ALUFlags = "0110") report "Failed ALU Test Case 9" severity error;

        -- Test case 10: Subtract two numbers with carry
        -- 7 - 5 - NOT 1 = 2
        -- Carry flag is asserted as there is no borrow.
        t_Src_A <= x"00000007"; t_Src_B <= x"00000005"; t_CarryFlag <= '1'; t_ALUControl <= "0110";
        wait for 1 ns;
        assert (t_ALUResult = x"00000002" and t_ALUFlags = "0010") report "Failed ALU Test Case 10" severity error;

        -- Test case 11: Reverse subtract two numbers with carry
        -- 7 - 5 - NOT 1 = 2
        -- Carry flag is asserted as there is no borrow.
        t_Src_A <= x"00000005"; t_Src_B <= x"00000007"; t_CarryFlag <= '1'; t_ALUControl <= "0111";
        wait for 1 ns;
        assert (t_ALUResult = x"00000002" and t_ALUFlags = "0010") report "Failed ALU Test Case 11" severity error;

        wait;

    end process;

end test_alu_behavioral;
