----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: (c) Rajesh Panicker
--
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: Decoder
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: Decoder Module
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

entity Decoder is port(
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
end Decoder;

architecture Decoder_arch of Decoder is
    signal ALUOp 			   : std_logic;
    signal Branch 			   : std_logic;
    signal RdEquals15          : std_logic;
    signal RegW_Internal       : std_logic;
    signal MemW_Internal       : std_logic;
    signal FlagW_Internal      : std_logic_vector (1 downto 0);
    signal Illegal_MainDecoder : std_logic;
    signal Illegal_ALUDecoder  : std_logic;
    signal Illegal_Instruction : std_logic;
begin

    -- Logic for Main Decoder
    main_decoder: process (Op) begin    
        case Op is
           -- Branch instruction
           when "10" => 
               Branch <= '1';
               MemtoReg <= '0';
               MemW_Internal <= '0';
               ALUSrc <= '1';
               ImmSrc <= "10";
               RegW_Internal <= '0';
               RegSrc(0) <= '1';
               ALUOp <= '0';
               Illegal_MainDecoder <= '0';
           -- Memory Instruction
           when "01" => 
               -- STR
               if Funct(0) = '0' then
                   Branch <= '0';
                   MemW_Internal <= '1';
                   ALUSrc <= '1';
                   ImmSrc <= "01";
                   RegW_Internal <= '0';
                   RegSrc <= "10";
                   ALUOp <= '0';
                   Illegal_MainDecoder <= '0';
               -- LDR
               else
                   Branch <= '0';
                   MemtoReg <= '1';
                   MemW_Internal <= '0';
                   ALUSrc <= '1';
                   ImmSrc <= "01";
                   RegW_Internal <= '1';
                   RegSrc(0) <= '0';
                   ALUOp <= '0';
                   Illegal_MainDecoder <= '0';
               end if;
           -- Data Processing Instruction
           when "00" => 
               -- DP Reg
               if Funct(5) = '0' then
                   Branch <= '0';
                   MemtoReg <= '0';
                   MemW_Internal <= '0';
                   ALUSrc <= '0';
                   RegW <= '1';
                   RegW_Internal <= '1';
                   RegSrc <= "00";
                   ALUOp <= '1';
                   Illegal_MainDecoder <= '0';
               -- DP Imm
               else
                   Branch <= '0';
                   MemtoReg <= '0';
                   MemW_Internal <= '0';
                   ALUSrc <= '1';
                   ImmSrc <= "00";
                   RegW_Internal <= '1';
                   RegSrc(0) <= '0';
                   ALUOp <= '1';
                   Illegal_MainDecoder <= '0';
               end if;
           when others =>
               PCS <= '-';
               MemtoReg <= '-';
               ALUSrc <= '-';
               ImmSrc <= "--";
               RegSrc <= "--";
               NoWrite <= '-';
               ALUControl  <= "--";
               Illegal_MainDecoder <= '1';
        end case;
    end process;
    
    -- Logic for ALU Decoder
    alu_decoder: process (Funct) begin
        case ALUOp is 
            -- Not a DP Instruction
            when '0' =>
                ALUControl <= "00";
                FlagW_Internal <= "00";
                Illegal_ALUDecoder <= '0';
            -- DP Instruction
            when '1' =>
                case Funct (4 downto 1) is
                    -- ADD Instruction
                    when "0100" =>
                        Illegal_ALUDecoder <= '0';
                        ALUControl <= "00";
                        -- ALU flags should be saved
                        if Funct(0)='1' then
                            FlagW_Internal <= "11";
                        -- ALU flags should not be saved
                        else FlagW_Internal <= "00";
                        end if;
                    -- SUB Instruction
                    when "0010" =>
                        Illegal_ALUDecoder <= '0';
                        ALUControl <= "01";
                        -- ALU flags should be saved
                        if Funct(0)='1' then
                            FlagW_Internal <= "11";
                        -- ALU flags should not be saved                            
                        else FlagW_Internal <= "00";
                        end if;
                    -- AND Instruction
                    when "0000" =>
                        Illegal_ALUDecoder <= '0';
                        ALUControl <= "10";
                        -- ALU flags should be saved
                        if Funct(0)='1' then
                            FlagW_Internal <= "10";
                        -- ALU flags should not be saved
                        else FlagW_Internal <= "00";
                        end if;
                    -- ORR Instruction
                    when "1100" =>
                        Illegal_ALUDecoder <= '0';
                        ALUControl <= "11";
                        -- ALU flags should be saved
                        if Funct(0)='1' then
                            FlagW_Internal <= "10";
                        -- ALU flags should not be saved
                        else FlagW_Internal <= "00";
                        end if;
                    when others => 
                        PCS <= '-';
                        MemtoReg <= '-';
                        ALUSrc <= '-';
                        ImmSrc <= "--";
                        RegSrc <= "--";
                        NoWrite <= '-';
                        ALUControl  <= "--";
                        Illegal_ALUDecoder <= '1';
                end case;
            when others => 
                PCS <= '-';
                MemtoReg <= '-';
                ALUSrc <= '-';
                ImmSrc <= "--";
                RegSrc <= "--";
                NoWrite <= '-';
                ALUControl  <= "--";
                Illegal_ALUDecoder <= '1';
        end case;    
    end process;
    
    -- PC Logic
    pc_logic: process (Rd) begin
        if Rd = "1111" then
            RdEquals15 <= '1';
        else RdEquals15 <= '0';
        end if;
        PCS <= ((RdEquals15 and RegW_Internal) or Branch) and (not Illegal_Instruction);
    end process;
    
    Illegal_Instruction <= Illegal_MainDecoder or Illegal_ALUDecoder;

    -- If instruction is not illegal, then store the write values
    RegW <= RegW_Internal and (not Illegal_Instruction);
    MemW <= MemW_Internal and (not Illegal_Instruction);
    FlagW <= FlagW_Internal when (Illegal_Instruction = '0') else "00";
    
end Decoder_arch;