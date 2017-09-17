----------------------------------------------------------------------------------
-- Company:
-- Engineer: (c) CG3207 2017-18 Semester 1 Team #26
--
-- Create Date: 16.09.2017 15:09:37
-- Design Name:
-- Module Name: test_decoder - decoder_test_behavioral
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: Test Decoder Module
--
-- Dependencies: NIL
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v)	acknowledge that the program was written based on the microarchitecture described in the book Digital Design and Computer Architecture, ARM Edition by Harris and Harris;
--		(vi) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vii) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_decoder is
--  Port ( );
end test_decoder;

architecture decoder_test_behavioral of test_decoder is

    component Decoder is port(
        Rd         : in 	std_logic_vector(3 downto 0);
        Op         : in 	std_logic_vector(1 downto 0);
        Funct      : in 	std_logic_vector(5 downto 0);
        PCS        : out	std_logic;
        RegW       : out	std_logic;
        MemW       : out	std_logic;
        MemtoReg   : out	std_logic;
        ALUSrc     : out	std_logic;
        ImmSrc     : out	std_logic_vector(1 downto 0);
        RegSrc     : out	std_logic_vector(1 downto 0);
        NoWrite    : out	std_logic;
        ALUControl : out	std_logic_vector(1 downto 0);
        FlagW      : out	std_logic_vector(1 downto 0)
    );
    end component;

    signal t_Rd             : std_logic_vector(3 downto 0);
    signal t_Op             : std_logic_vector(1 downto 0);
    signal t_Funct          : std_logic_vector(5 downto 0);
    signal t_PCS            : std_logic;
    signal t_RegW           : std_logic;
    signal t_MemW           : std_logic;
    signal t_MemtoReg       : std_logic;
    signal t_ALUSrc         : std_logic;
    signal t_ImmSrc         : std_logic_vector(1 downto 0);
    signal t_RegSrc         : std_logic_vector(1 downto 0);
    signal t_NoWrite        : std_logic;
    signal t_ALUControl     : std_logic_vector(1 downto 0);
    signal t_FlagW          : std_logic_vector(1 downto 0);

begin

    test_decoder_module: Decoder port map (
        --Inputs
        Rd         => t_Rd,
        Op         => t_Op,
        Funct      => t_Funct,
        --Outputs
        PCS        => t_PCS,
        RegW       => t_RegW,
        MemW       => t_MemW,
        MemtoReg   => t_MemtoReg,
        ALUSrc     => t_ALUSrc,
        ImmSrc     => t_ImmSrc,
        RegSrc     => t_RegSrc,
        NoWrite    => t_NoWrite,
        ALUControl => t_ALUControl,
        FlagW      => t_FlagW
    );

    process begin

        -- Set initial values for inputs
        t_Rd <= "0000";
        t_Op <= "00";
        t_Funct <= "000000";

        -- Test case 1
        t_Op <= "10";
        wait for 5 ns;
        assert (t_PCS='1' and t_RegW='0' and t_MemW='0' and t_MemtoReg='0' and t_ALUSrc='1' and t_ImmSrc="10" and t_RegSrc(0)='1' and t_NoWrite='0' and t_ALUControl="00" and t_FlagW="00") report "Failed Decoder Test Case 1" severity error;

        -- Test case 2
        t_Op <= "01";
        t_Funct(0) <= '0';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='0' and t_MemW='1' and t_ALUSrc='1' and t_ImmSrc="01" and t_RegSrc="10" and t_NoWrite='0' and t_ALUControl="00" and t_FlagW="00") report "Failed Decoder Test Case 2" severity error;

        -- Test case 3
        t_Op <= "01";
        t_Funct(0) <= '1';
        wait for 5 ns;
        assert (t_PCS='0' and t_RegW='1' and t_MemW='0' and t_MemtoReg='1' and t_ALUSrc='1' and t_ImmSrc="01" and t_RegSrc(0)='0' and t_NoWrite='0' and t_ALUControl="00" and t_FlagW = "00") report "Failed Decoder Test Case 3" severity error;

        -- Test case 4
        t_Rd <= "1111";
        t_Op <= "01";
        t_Funct(0) <= '1';
        wait for 5 ns;
        assert (t_PCS='1' and t_RegW='1' and t_MemW='0' and t_MemtoReg='1' and t_ALUSrc='1' and t_ImmSrc="01" and t_RegSrc(0)='0' and t_NoWrite='0' and t_ALUControl="00" and t_FlagW="00") report "Failed Decoder Test Case 4" severity error;

        -- -- Test case 5
        -- t_Op <= "00";
        -- t_Funct(5) <= '0';
        -- wait for 1 ns;
        -- assert () report "Failed Decoder Test Case 5" severity error;
        --
        -- -- Test case 6
        -- t_ALUOp <= '0';
        -- wait for 1 ns;
        -- assert () report "Failed Decoder Test Case 6" severity error;
        --
        -- -- Test case 7
        -- t_ALUOp <= '1';
        -- t_Funct(4 downto 0) <= "01000";
        -- wait for 1 ns;
        -- assert () report "Failed Decoder Test Case 7" severity error;
        --
        -- -- Test case 8
        -- t_ALUOp <= '1';
        -- t_Funct(4 downto 0) <= "01001";
        -- wait for 1 ns;
        -- assert () report "Failed Decoder Test Case 8" severity error;
        --
        -- -- Test case 9
        -- t_ALUOp <= '1';
        -- t_Funct(4 downto 0) <= "00100";
        -- wait for 1 ns;
        -- assert () report "Failed Decoder Test Case 9" severity error;
        --
        -- -- Test case 10
        -- t_ALUOp <= '1';
        -- t_Funct(4 downto 0) <= "00101";
        -- wait for 1 ns;
        -- assert () report "Failed Decoder Test Case 10" severity error;
        --
        -- -- Test case 11
        -- t_ALUOp <= '1';
        -- t_Funct(4 downto 0) <= "00000";
        -- wait for 1 ns;
        -- assert () report "Failed Decoder Test Case 11" severity error;
        --
        -- -- Test case 12
        -- t_ALUOp <= '1';
        -- t_Funct(4 downto 0) <= "00001";
        -- wait for 1 ns;
        -- assert () report "Failed Decoder Test Case 12" severity error;
        --
        -- -- Test case 13
        -- t_ALUOp <= '1';
        -- t_Funct(4 downto 0) <= "11000";
        -- wait for 1 ns;
        -- assert () report "Failed Decoder Test Case 13" severity error;
        --
        -- -- Test case 14
        -- t_ALUOp <= '1';
        -- t_Funct(4 downto 0) <= "11001";
        -- wait for 1 ns;
        -- assert () report "Failed Decoder Test Case 14" severity error;
        --
        -- -- Test case 15
        -- t_Op <= "10";
        -- wait for 1 ns;
        -- assert () report "Failed Decoder Test Case 15" severity error;
        --
        -- t_Op <= "01";
        --
        -- -- Test case 16
        -- t_Rd <= "1111";
        -- t_RegW <= '0';
        -- assert () report "Failed Decoder Test Case 16" severity error;
        --
        -- -- Test case 17
        -- t_Rd <= "1111";
        -- t_RegW <= '1';
        -- assert () report "Failed Decoder Test Case 17" severity error;
        --
        -- -- Test case 18
        -- t_Rd <= "1101";
        -- t_RegW <= '1';
        -- assert () report "Failed Decoder Test Case 18" severity error;
        --
        -- t_Op <= "10";
        --
        -- -- Test case 19
        -- t_Rd <= "1101";
        -- t_RegW <= '1';
        -- assert () report "Failed Decoder Test Case 19" severity error;
        --
        -- -- Test case 20
        -- t_Rd <= "1111";
        -- t_RegW <= '1';
        -- assert () report "Failed Decoder Test Case 20" severity error;

        wait;

    end process;

end decoder_test_behavioral;
