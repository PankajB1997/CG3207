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
--	(c) Rajesh Panicker
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned vMCyclees
--USE ieee.numeric_std.ALL;

ENTITY test_MCycle IS
END test_MCycle;

ARCHITECTURE behavior OF test_MCycle IS

  -- Component Declaration for the Unit Under Test (UUT)

  COMPONENT MCycle
  PORT(
       CLK : IN  std_logic;
       RESET : IN  std_logic;
       Start : IN  std_logic;
       MCycleOp : IN  std_logic_vector(1 downto 0);
       Operand1 : IN  std_logic_vector(3 downto 0);
       Operand2 : IN  std_logic_vector(3 downto 0);
       Result1 : OUT  std_logic_vector(3 downto 0);
       Result2 : OUT  std_logic_vector(3 downto 0);
       Busy : OUT  std_logic
      );
  END COMPONENT;

   --Inputs
   signal t_CLK : std_logic := '0';
   signal t_RESET : std_logic := '0';
   signal t_Start : std_logic := '0';
   signal t_MCycleOp : std_logic_vector(1 downto 0) := (others => '0');
   signal t_Operand1 : std_logic_vector(3 downto 0) := (others => '0');
   signal t_Operand2 : std_logic_vector(3 downto 0) := (others => '0');

  	--Outputs
   signal t_Result1 : std_logic_vector(3 downto 0);
   signal t_Result2 : std_logic_vector(3 downto 0);
   signal t_Busy : std_logic;

   -- Clock period definitions
   constant ClkPeriod : time := 10 ns;

BEGIN

	-- Instantiate the Unit Under Test (UUT)
  test_mcycle_module: MCycle PORT MAP (
    -- Inputs
    CLK => t_CLK,
    RESET => t_RESET,
    Start => t_Start,
    MCycleOp => t_MCycleOp,
    Operand1 => t_Operand1,
    Operand2 => t_Operand2,
    -- Outputs
    Result1 => t_Result1,
    Result2 => t_Result2,
    Busy => t_Busy
  );

  -- Clock generation
  clk_process: process begin
    t_CLK <= '0';
    wait for ClkPeriod/2;
    t_CLK <= '1';
    wait for ClkPeriod/2;
  end process;

  stim_proc: process begin

    -- Hold reset state for 100 ns.
    wait for 10 ns;

    t_MCycleOp <= "00";
    t_Operand1 <= "1111";
    t_Operand2 <= "1111";
    t_Start <= '1';
    wait until t_Busy = '0';
    wait for 10 ns;
    t_Start <= '0';
    wait for 10 ns;

    t_Operand1 <= "1110";
    t_Operand2 <= "1111";
    t_Start <= '1';
    wait until t_Busy = '0';
    wait for 10 ns;
    t_Start <= '0';
    wait for 10 ns;

    t_MCycleOp <= "01";
    t_Operand1 <= "1111";
    t_Operand2 <= "1111";
    t_Start <= '1';
    wait until t_Busy = '0';
    wait for 10 ns;
    t_Start <= '0';
    wait for 10 ns;

    t_Operand1 <= "1110";
    t_Operand2 <= "1111";
    t_Start <= '1';
    wait until t_Busy = '0';
    wait for 10 ns;
    t_Start <= '0';
    wait for 10 ns;

    -- Tests for division start below

    -- Division Test Case 1: Checking 13/2; Quotient: 6, Remainder: 1
    t_MCycleOp <= "11";
    t_Operand1 <= "1101";
    t_Operand2 <= "0010";
    t_Start <= '1';
    wait until t_Busy = '0';
    wait for 10 ns;
    t_Start <= '0';
    wait for 10 ns;
    assert (t_Result1 = "0110" and t_Result2 = "0001") report "Failed MCycle Division Test Case 1" severity error;

    -- Division Test Case 2: Checking 15/15; Quotient: 1, Remainder: 0
    t_Operand1 <= "1111";
    t_Operand2 <= "1111";
    t_Start <= '1';
    wait until t_Busy = '0';
    wait for 10 ns;
    t_Start <= '0';
    wait for 10 ns;
    assert (t_Result1 = "0001" and t_Result2 = "0000") report "Failed MCycle Division Test Case 2" severity error;

    -- Division Test Case 3: Checking 1/15; Quotient: 0, Remainder: 1
    t_Operand1 <= "0001";
    t_Operand2 <= "1111";
    t_Start <= '1';
    wait until t_Busy = '0';
    wait for 10 ns;
    t_Start <= '0';
    wait for 10 ns;
    assert (t_Result1 = "0000" and t_Result2 = "0001") report "Failed MCycle Division Test Case 3" severity error;

    -- Division Test Case 4: Checking 15/1; Quotient: 15, Remainder: 0
    t_Operand1 <= "1111";
    t_Operand2 <= "0001";
    t_Start <= '1';
    wait until t_Busy = '0';
    wait for 10 ns;
    t_Start <= '0';
    wait for 10 ns;
    assert (t_Result1 = "1111" and t_Result2 = "0000") report "Failed MCycle Division Test Case 4" severity error;

    -- Division Test Case 5: Checking 2/10; Quotient: 0, Remainder: 2
    t_Operand1 <= "0010";
    t_Operand2 <= "1010";
    t_Start <= '1';
    wait until t_Busy = '0';
    wait for 10 ns;
    t_Start <= '0';
    wait for 10 ns;
    assert (t_Result1 = "0000" and t_Result2 = "0010") report "Failed MCycle Division Test Case 5" severity error;

    wait;

  end process;

END;
