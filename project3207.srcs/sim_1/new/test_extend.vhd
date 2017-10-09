library ieee;
use ieee.std_logic_1164.all;

entity test_extend is
-- Port ( );
end test_extend;

architecture test_extend_behavioral of test_extend is

    component Extend
    port (
        ImmSrc : in std_logic_vector (1 downto 0);
        InstrImm : in std_logic_vector (23 downto 0);
        ExtImm : out std_logic_vector (31 downto 0));
    end component;

    signal t_ImmSrc : std_logic_vector (1 downto 0);
    signal t_InstrImm : std_logic_vector (23 downto 0);
    signal t_ExtImm : std_logic_vector (31 downto 0);

begin

    test_extend_module: Extend
    port map (
        -- Inputs
        ImmSrc   => t_ImmSrc,
        InstrImm => t_InstrImm,
        -- Outputs
        ExtImm   => t_ExtImm
    );

    stim_proc: process begin
    
        -- Set initial values for inputs
        t_ImmSrc <= (others => '0'); t_InstrImm <= (others => '0');
        
        wait for 5 ns;
        
        -- Test case 1: DP instructions
        -- Imm value = 8
        t_ImmSrc <= "00"; t_InstrImm <= x"000008"; 
        wait for 5 ns;
        assert (t_ExtImm = x"00000008") report "Failed Extend Test Case 1" severity error;
        
        -- Test case 2: LDR/STR instructions
        -- Imm value = 16
        t_ImmSrc <= "01"; t_InstrImm <= x"000010";
        wait for 5 ns;
        assert (t_ExtImm = x"00000010") report "Failed Extend Test Case 2" severity error;
        
        -- Test case 3.1: Branch instructions (positive imm)
        -- Imm value = 6
        -- The output has to be x"00000018" as it is the result (sign-extended x"000006") << 2 
        -- The binary value of the output will be the (MSB of the input duplicated 6 times & the original InstrImm binary value & 2 '0' bits)
        t_ImmSrc <= "10"; t_InstrImm <= x"000006";
        wait for 5 ns;
        assert (t_ExtImm = x"00000018") report "Failed Extend Test Case 3.1" severity error;
        
        -- Test case 3.2: Branch instructions (negative imm)
        -- Imm value = -7340032 (in its 2's complement)
        -- The output has to be x"fe400000" as it is the result of (sign-extended x"900000") << 2 
        -- The binary value of the output will be the (MSB of the input duplicated 6 times & the original InstrImm binary value & 2 '0' bits)
        t_ImmSrc <= "10"; t_InstrImm <= x"900000";
        wait for 5 ns;
        assert (t_ExtImm = x"fe400000") report "Failed Extend Test Case 3.2" severity error; 
        
        wait;
         
    end process;

end test_extend_behavioral;
