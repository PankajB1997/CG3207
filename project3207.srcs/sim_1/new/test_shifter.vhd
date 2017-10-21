library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity test_shifter is
-- Port ( );
end test_shifter;

architecture test_shifter_behavioral of test_shifter is

    component Shifter
    port (
        Sh : in std_logic_vector (1 downto 0);
        Shamt5 : in std_logic_vector (4 downto 0);
        ShIn : in std_logic_vector (31 downto 0);
        ShOut : out std_logic_vector (31 downto 0);
        Carry : out std_logic);
    end component;

    signal t_Sh : std_logic_vector (1 downto 0);
    signal t_Shamt5 : std_logic_vector (4 downto 0);
    signal t_ShIn : std_logic_vector (31 downto 0);
    signal t_ShOut : std_logic_vector (31 downto 0);
    signal t_Carry : std_logic;

begin

    test_shifter_module : Shifter port map (
        -- Inputs
        Sh => t_Sh,
        Shamt5 => t_Shamt5,
        ShIn => t_ShIn,
        -- Outputs
        ShOut => t_ShOut,
        Carry => t_Carry
    );

    stim_proc: process begin

        -- Set initial values for inputs
        t_Sh <= (others => '0'); t_Shamt5 <= (others => '0'); t_ShIn <= (others => '0');
        wait for 5 ns;

        -- Test case 1: LSL Operation
        t_Sh <= "00"; t_Shamt5 <= "00011"; t_ShIn <= x"00000003";
        wait for 5 ns;
        assert (t_ShOut = x"00000018" and t_Carry = '0') report "Failed Shifter Test Case 1" severity error;

        -- Test case 2: LSR Operation
        t_Sh <= "01"; t_Shamt5 <= "01000"; t_ShIn <= x"8000F000";
        wait for 5 ns;
        assert (t_ShOut = x"008000F0" and t_Carry = '0') report "Failed Shifter Test Case 2" severity error;

        -- Test case 3: ASR Operation
        t_Sh <= "10"; t_Shamt5 <= "00100"; t_ShIn <= x"8000F000";
        wait for 5 ns;
        assert (t_ShOut = x"F8000F00" and t_Carry = '0') report "Failed Shifter Test Case 3" severity error;

        -- Test case 4: ROR Operation
        t_Sh <= "11"; t_Shamt5 <= "10000"; t_ShIn <= x"0123ABCD";
        wait for 5 ns;
        assert (t_ShOut = x"ABCD0123" and t_Carry = '1') report "Failed Shifter Test Case 4" severity error;

        -- Test case 5: Zero Shift amount
        t_Sh <= "00"; t_Shamt5 <= "00000"; t_ShIn <= x"FFFF00FF";
        wait for 5 ns;
        assert (t_ShOut = x"FFFF00FF" and t_Carry = '0') report "Failed Shifter Test Case 5" severity error;

        -- Test case 6: LSL shift where some bits get shifted out and disappear
        t_Sh <= "00"; t_Shamt5 <= "10000"; t_ShIn <= x"FF00FF00";
        wait for 5 ns;
        assert (t_ShOut = x"FF000000" and t_Carry = '0') report "Failed Shifter Test Case 6" severity error;

        -- Test case 7: LSR shift where some bits get shifted out and disappear
        t_Sh <= "01"; t_Shamt5 <= "01000"; t_ShIn <= x"00FF00FF";
        wait for 5 ns;
        assert (t_ShOut = x"0000FF00" and t_Carry = '1') report "Failed Shifter Test Case 7" severity error;

        wait;

    end process;

end test_shifter_behavioral;
