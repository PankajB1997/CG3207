library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
entity test_top is
--  Port ( );
end test_top;

architecture test_top_behavioral of test_top is
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    component TOP
        generic (
            CLK_DIV_BITS : integer);
        port (
            DIP : in std_logic_vector(15 downto 0);
            PB : in std_logic_vector(3 downto 0);
            LED : out std_logic_vector(15 downto 0);
            TX : out std_logic;
            RX : in std_logic;
            PAUSE : in std_logic;
            RESET : in std_logic;
            CLK_undiv : in std_logic);
    end component;
    
    --Inputs
    signal t_DIP : std_logic_vector(15 downto 0) := (others => '0');
    signal t_PB : std_logic_vector(3 downto 0) := (others => '0');
    signal t_RX : std_logic := '0';
    signal t_PAUSE : std_logic := '0';
    signal t_RESET : std_logic := '0';
    signal t_CLK_undiv : std_logic := '0';
    
    --Outputs
    signal t_LED : std_logic_vector(15 downto 0);
    signal t_TX : std_logic;
    
    -- Clock period definitions
    constant ClkUndivPeriod : time := 0.5 ns;
    constant ClkPeriod : time := ClkUndivPeriod * 2;
 
begin
    -- Instantiate the Unit Under Test (UUT)
    test_top_module: TOP 
    generic map (
        CLK_DIV_BITS => 1
    )
    port map (
        -- Inputs
        DIP => t_DIP,
        PB => t_PB,
        RX => t_RX,
        PAUSE => t_PAUSE,
        RESET => t_RESET,
        CLK_undiv => t_CLK_undiv,
        LED => t_LED,
        TX => t_TX
    );

   -- Clock process definitions
   clk_process: process begin
        t_CLK_undiv <= '1';
        wait for ClkUndivPeriod / 2;
        t_CLK_undiv <= '0';
        wait for ClkUndivPeriod / 2;
   end process;
 
   -- Test instructions for the TOP module will come from using hex2rom on an
   -- asm program. These instructions can be found in TOP.vhd inside the
   -- INSTR_MEM constant. This test file verifies that the program defined by
   -- those instructions executes in the expected manner.

   -- Stimulus process
   stim_proc: process begin
        t_RESET <= '0'; -- Reset is active low.
        -- Hold reset state for 1 ClkPeriod.
        wait for ClkPeriod;
        
        -- Set initial value for inputs.
        t_RESET <= '1'; t_PAUSE <= '0'; t_DIP <= x"0000"; t_PB <= x"0";
        
        -- Processor should start cycling, looking for input.
        wait for ClkPeriod * 9;
        
        -- Enter 7 as input1.
        t_DIP <= x"0007"; t_PB <= x"8";
        
        -- Processor should take input1 and start cycling, looking for button to turn off.
        wait for ClkPeriod * 12;
        
        -- Turn off button.
        t_PB <= x"0";
        
        -- Processor should start cycling, looking for inputs.
        wait for ClkPeriod * 9;
        
        -- Do the same for other inputs.
        -- Use Add.
        t_DIP <= x"0001"; t_PB <= x"8";
        wait for ClkPeriod * 12;
        t_PB <= x"0";
        wait for ClkPeriod * 9;
        
        -- Enter 5 as input2.
        t_DIP <= x"0005"; t_PB <= x"8";
        wait for ClkPeriod * 12;
        t_PB <= x"0";
        wait for ClkPeriod * 9;
        
        wait for ClkPeriod * 9;
        -- Leds should now show 7 + 5 = 12 = 0xc in the first 8 bits.
        
        wait;
    end process;
end test_top_behavioral;
