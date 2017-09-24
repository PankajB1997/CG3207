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
        port (CLK       : in std_logic;
              RESET     : in std_logic;
              Instr     : in std_logic_vector (31 downto 0);
              ReadData  : in std_logic_vector (31 downto 0);
              MemWrite  : out std_logic;
              PC        : out std_logic_vector (31 downto 0);
              ALUResult : out std_logic_vector (31 downto 0);
              WriteData : out std_logic_vector (31 downto 0));
    end component;

    signal t_CLK       : std_logic;
    signal t_RESET     : std_logic;
    signal t_Instr     : std_logic_vector (31 downto 0);
    signal t_ReadData  : std_logic_vector (31 downto 0);
    signal t_MemWrite  : std_logic;
    signal t_PC        : std_logic_vector (31 downto 0);
    signal t_ALUResult : std_logic_vector (31 downto 0);
    signal t_WriteData : std_logic_vector (31 downto 0);

    constant ClkPeriod : time := 1ns;
begin

    test_arm_module : ARM
    port map (
        -- Inputs
        CLK       => CLK,
        RESET     => RESET,
        Instr     => Instr,
        ReadData  => ReadData,
        -- Output
        MemWrite  => MemWrite,
        PC        => PC,
        ALUResult => ALUResult,
        WriteData => WriteData
    );
    
    clk_process: process begin
        t_CLK <= '1';
        wait for ClkPeriod / 2;  --for 0.5 ns signal is '1'.
        t_CLK <= '0';
        wait for ClkPeriod / 2;  --for next 0.5 ns signal is '0'.
    end process;
    
    stim_proc: process begin
        -- Set initial value for inputs.
        t_RESET <= '0';
        t_Instr <= (others => '0');
        t_ReadData <= (others => '0');
        
        -- Inputs will be changed and checked between clock edges to avoid indeterminate behaviour at the edge.
        -- Each test case will start at x.5 ns, where x is 0, 1, 2... This is to keep track of where the clock is
        -- since some of the tests will be using the clock.
        wait for ClkPeriod / 2;
        
        -- Test case 1: 
    end process;

end test_arm_behavioral;