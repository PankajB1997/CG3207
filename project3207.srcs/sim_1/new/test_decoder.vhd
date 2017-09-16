----------------------------------------------------------------------------------
-- Company: 
-- Engineer: (c) CG3207 2017-18 Semester 1 Team #26
-- 
-- Create Date: 16.09.2017 15:09:37
-- Design Name: 
-- Module Name: test_decoder - decoder_test_behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
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
        Rd         => t_Rd,
        Op         => t_Op,
        Funct      => t_Funct,
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
        
        
            
    end process;
    
end decoder_test_behavioral;
