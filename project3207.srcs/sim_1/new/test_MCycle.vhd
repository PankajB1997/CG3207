----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: Rajesh Panicker
--
-- Create Date: 10/13/2015 06:49:10 PM
-- Module Name: ALU
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: Testbench for Multicycle Operations Module
--
-- Dependencies: MCycle
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--    (c) Rajesh Panicker
--    License terms : --    You are free to use this code as long as you
--        (i) DO NOT post it on any public repository;
--        (ii) use it only for educational purposes;
--        (iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--        (iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--        (v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--        (vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------

library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned vMCyclees
--USE ieee.numeric_std.ALL;

entity test_mcycle is
--  Port ( );
end test_mcycle;

architecture test_mcycle_behavioral of test_mcycle is

    -- Component Declaration for the Unit Under Test (UUT)

    component MCycle
    port (
        CLK : in std_logic;
        RESET : in std_logic;
        Start : in std_logic;
        MCycleOp : in std_logic_vector(1 downto 0);
        Operand1 : in std_logic_vector(3 downto 0);
        Operand2 : in std_logic_vector(3 downto 0);
        ALUResult : in std_logic_vector(3 downto 0);
        ALUCarryFlag : in std_logic;
        ALUSrc1 : out std_logic_vector(3 downto 0);
        ALUSrc2 : out std_logic_vector(3 downto 0);
        ALUControl : out std_logic_vector(1 downto 0);
        Result1 : out std_logic_vector(3 downto 0);
        Result2 : out std_logic_vector(3 downto 0);
        Busy : out std_logic
    );
    end component;

    --Inputs
    signal t_CLK : std_logic := '0';
    signal t_RESET : std_logic := '0';
    signal t_Start : std_logic := '0';
    signal t_MCycleOp : std_logic_vector(1 downto 0) := (others => '0');
    signal t_Operand1 : std_logic_vector(3 downto 0) := (others => '0');
    signal t_Operand2 : std_logic_vector(3 downto 0) := (others => '0');
    signal t_ALUResult : std_logic_vector(3 downto 0) := (others => '0');
    signal t_ALUCarryFlag : std_logic := '0';

    --Outputs
    signal t_ALUSrc1 : std_logic_vector(3 downto 0) := (others => '0');
    signal t_ALUSrc2 : std_logic_vector(3 downto 0) := (others => '0');
    signal t_ALUControl : std_logic_vector(1 downto 0) := (others => '0');
    signal t_Result1 : std_logic_vector(3 downto 0);
    signal t_Result2 : std_logic_vector(3 downto 0);
    signal t_Busy : std_logic;

    -- Clock period definitions
    constant ClkPeriod : time := 1 ns;
    
    -- Other internal signals
    signal Sum : std_logic_vector(4 downto 0) := (others => '0');
    signal Diff : std_logic_vector(4 downto 0) := (others => '0');

begin

	-- Instantiate the Unit Under Test (UUT)
    test_mcycle_module: MCycle port map (
        -- Inputs
        CLK => t_CLK,
        RESET => t_RESET,
        Start => t_Start,
        MCycleOp => t_MCycleOp,
        Operand1 => t_Operand1,
        Operand2 => t_Operand2,
        ALUResult => t_ALUResult,
        ALUCarryFlag => t_ALUCarryFlag,
        -- Outputs
        ALUSrc1 => t_ALUSrc1,
        ALUSrc2 => t_ALUSrc2,
        ALUControl => t_ALUControl,
        Result1 => t_Result1,
        Result2 => t_Result2,
        Busy => t_Busy
    );
    
    Sum <= ('0' & t_ALUSrc1) + ('0' & t_ALUSrc2);
    Diff <=  ('0' & t_ALUSrc1) + ('0' & (not t_ALUSrc2)) + "00001";
    t_ALUResult <= Sum(3 downto 0)
                   when t_ALUControl = "00"
                   else Diff(3 downto 0);
    t_ALUCarryFlag <= Sum(4)
                      when t_ALUControl = "00"
                      else Diff(4);

    -- Clock generation
    clk_process: process begin
        t_CLK <= '1';
        wait for ClkPeriod / 2;
        t_CLK <= '0';
        wait for ClkPeriod / 2;
    end process;

    stim_proc: process begin
        -- Set initial value for inputs.
        t_RESET <= '1';

        -- Inputs will be changed and checked between clock edges to avoid indeterminate behaviour at the edge.
        -- Each test case will start at x.5 ns, where x is 0, 1, 2... This is to keep track of where the clock is
        -- since some of the tests will be using the clock.
        wait for ClkPeriod / 2;

        -- Before time = ClkPeriod, some signals may be U or X. That is expected, as the processor is only reset
        -- at the first clock edge, and this is when the PC is set to 0. Before this, PC is indeterminate.

        -- RESET = 0 to set PC to 0.
        t_RESET <= '0';
        wait for ClkPeriod;

        -- Tests for multiplication start below

        -- Multiplication Test Case 1: Checking (-1)*(-1); Result1: 1, Result2: 0 (i.e. product 1)
        t_MCycleOp <= "00";
        t_Operand1 <= "1111";
        t_Operand2 <= "1111";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0001" and t_Result2 = "0000") report "Failed MCycle Multiplication Test Case 1" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Multiplication Test Case 2: Checking (+2)*(+3); Result1: 6, Result2: 0 (i.e. product 6)
        t_Operand1 <= "0010";
        t_Operand2 <= "0011";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0110" and t_Result2 = "0000") report "Failed MCycle Multiplication Test Case 2" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Multiplication Test Case 3: Checking (-8)*(+6); Result1: 0, Result2: 13 in unsigned notation (i.e. product -48)
        t_Operand1 <= "1000";
        t_Operand2 <= "0110";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0000" and t_Result2 = "1101") report "Failed MCycle Multiplication Test Case 3" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Multiplication Test Case 4: Checking (+7)*(-3); Result1: 11, Result2: 14 in unsigned notation (i.e. product -21)
        t_Operand1 <= "0111";
        t_Operand2 <= "1101";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "1011" and t_Result2 = "1110") report "Failed MCycle Multiplication Test Case 4" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Multiplication Test Case 5: Checking (-8)*(-8); Result1: 8, Result2: 0 in unsigned notation (i.e. product 64)
        t_Operand1 <= "1000";
        t_Operand2 <= "1000";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0000" and t_Result2 = "0100") report "Failed MCycle Multiplication Test Case 5" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Multiplication Test Case 6: Checking 15*15; Result1: 1, Result2: 14 (i.e. product 225)
        t_MCycleOp <= "01";
        t_Operand1 <= "1111";
        t_Operand2 <= "1111";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0001" and t_Result2 = "1110") report "Failed MCycle Multiplication Test Case 6" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Multiplication Test Case 7: Checking 1*1; Result1: 1, Result2: 0 (i.e. product 1)
        t_Operand1 <= "0001";
        t_Operand2 <= "0001";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0001" and t_Result2 = "0000") report "Failed MCycle Multiplication Test Case 7" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Multiplication Test Case 8: Checking 1*15; Result1: 15, Result2: 0 (i.e. product 15)
        t_Operand1 <= "0001";
        t_Operand2 <= "1111";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "1111" and t_Result2 = "0000") report "Failed MCycle Multiplication Test Case 8" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Multiplication Test Case 9: Checking 15*1; Result1: 15, Result2: 0 (i.e. product 15)
        t_Operand1 <= "1111";
        t_Operand2 <= "0001";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "1111" and t_Result2 = "0000") report "Failed MCycle Multiplication Test Case 9" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Multiplication Test Case 10: Checking 6*7; Result1: 12, Result2: 2 (i.e. product 42)
        t_Operand1 <= "0110";
        t_Operand2 <= "0111";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "1010" and t_Result2 = "0010") report "Failed MCycle Multiplication Test Case 10" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Tests for division start below

        -- Division Test Case 1: Checking 13/2; Quotient: 6, Remainder: 1
        t_MCycleOp <= "11";
        t_Operand1 <= "1101";
        t_Operand2 <= "0010";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0110" and t_Result2 = "0001") report "Failed MCycle Division Test Case 1" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Division Test Case 2: Checking 15/15; Quotient: 1, Remainder: 0
        t_Operand1 <= "1111";
        t_Operand2 <= "1111";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0001" and t_Result2 = "0000") report "Failed MCycle Division Test Case 2" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Division Test Case 3: Checking 1/15; Quotient: 0, Remainder: 1
        t_Operand1 <= "0001";
        t_Operand2 <= "1111";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0000" and t_Result2 = "0001") report "Failed MCycle Division Test Case 3" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Division Test Case 4: Checking 15/1; Quotient: 15, Remainder: 0
        t_Operand1 <= "1111";
        t_Operand2 <= "0001";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "1111" and t_Result2 = "0000") report "Failed MCycle Division Test Case 4" severity error;
        wait for 3 * (ClkPeriod / 2);

        -- Division Test Case 5: Checking 2/10; Quotient: 0, Remainder: 2
        t_Operand1 <= "0010";
        t_Operand2 <= "1010";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0000" and t_Result2 = "0010") report "Failed MCycle Division Test Case 5" severity error;
        wait for 3 * (ClkPeriod / 2);
        
        --Division (Signed) Test Case 6: Checking 2/-6; Quotient: 0 , Remainder: -2
        t_MCycleOp <= "10";
        t_Operand1 <= "0010";
        t_Operand2 <= "1010";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0000" and t_Result2 = "1110") report "Failed MCycle Division Test Case 6" severity error;
        wait for 3 * (ClkPeriod / 2);
       
        -- Division (Signed) Test Case 7: Checking -6/3; Quotient: -2 , Remainder: 0
        t_Operand1 <= "1010"; --"0110";
        t_Operand2 <= "0011";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "1110" and t_Result2 = "0000") report "Failed MCycle Division Test Case 7" severity error;
        wait for 3 * (ClkPeriod / 2);
        
        -- Division (Signed) Test Case 8: Checking -8/-4; Quotient: 2 , Remainder: 0
        t_Operand1 <= "1000";
        t_Operand2 <= "1100";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0010" and t_Result2 = "0000") report "Failed MCycle Division Test Case 8" severity error;
        wait for 3 * (ClkPeriod / 2);
      
        -- Division (Signed) Test Case 9: Checking -7/-1; Quotient: 7 , Remainder: 0
        t_Operand1 <= "1001";
        t_Operand2 <= "1111";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0111" and t_Result2 = "0000") report "Failed MCycle Division Test Case 9" severity error;
        wait for 3 * (ClkPeriod / 2);
       
        -- Division (Signed) Test Case 10: Checking 7/4; Quotient: 1 , Remainder: 3
        t_Operand1 <= "0111";
        t_Operand2 <= "0100";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0001" and t_Result2 = "0011") report "Failed MCycle Division Test Case 10" severity error;
        wait for 3 * (ClkPeriod / 2);
        
         -- Division (Signed) Test Case 11: Checking 1/-5; Quotient: 0 , Remainder: -1
        t_Operand1 <= "0001";
        t_Operand2 <= "1011";
        t_Start <= '1';
        wait for ClkPeriod * 2;
        t_Start <= '0';
        wait until t_Busy = '0';
        wait for ClkPeriod / 2;
        assert (t_Result1 = "0000" and t_Result2 = "1111") report "Failed MCycle Division Test Case 11" severity error;
        wait for 3 * (ClkPeriod / 2);
        
        wait;

    end process;

end test_mcycle_behavioral;
