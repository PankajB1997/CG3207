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
			Rd			: in 	std_logic_vector(3 downto 0);
			Op			: in 	std_logic_vector(1 downto 0);
			Funct		: in 	std_logic_vector(5 downto 0);
			PCS			: out	std_logic;
			RegW		: out	std_logic;
			MemW		: out	std_logic;
			MemtoReg	: out	std_logic;
			ALUSrc		: out	std_logic;
			ImmSrc		: out	std_logic_vector(1 downto 0);
			RegSrc		: out	std_logic_vector(1 downto 0);
			NoWrite		: out	std_logic;
			ALUControl	: out	std_logic_vector(1 downto 0);
			FlagW		: out	std_logic_vector(1 downto 0)
			);
end Decoder;

architecture Decoder_arch of Decoder is
	signal ALUOp 			: std_logic;
	signal Branch 			: std_logic;
	signal RegW_Result      : std_logic;
	signal RdEquals15       : std_logic;
begin

	process (Op, Funct) begin
	
        -- logic for Main Decoder
        case Op is
           -- if Branch instruction
           when "10" => 
               Branch <= '1';
               MemtoReg <= '0';
               MemW <= '0';
               ALUSrc <= '1';
               ImmSrc <= "10";
               RegW <= '0';
               RegW_Result <= '0';
               RegSrc(0) <= '1';
               ALUOp <= '0';
           -- if Memory Instruction
           when "01" => 
               -- if STR
               if Funct(0) = '0' then
                   Branch <= '0';
                   MemW <= '1';
                   ALUSrc <= '1';
                   ImmSrc <= "01";
                   RegW <= '0';
                   RegW_Result <= '0';
                   RegSrc <= "10";
                   ALUOp <= '0';
               -- else if LDR
               else
                   Branch <= '0';
                   MemtoReg <= '1';
                   MemW <= '0';
                   ALUSrc <= '1';
                   ImmSrc <= "01";
                   RegW <= '1';
                   RegW_Result <= '1';
                   RegSrc(0) <= '0';
                   ALUOp <= '0';
               end if;
           -- if Data Processing Instruction
           when "00" => 
               -- if DP Reg
               if Funct(5) = '0' then
                   Branch <= '0';
                   MemtoReg <= '0';
                   MemW <= '0';
                   ALUSrc <= '0';
                   RegW <= '1';
                   RegW_Result <= '1';
                   RegSrc <= "00";
                   ALUOp <= '1';
               -- else if DP Imm
               else
                   Branch <= '0';
                   MemtoReg <= '0';
                   MemW <= '0';
                   ALUSrc <= '1';
                   ImmSrc <= "00";
                   RegW <= '1';
                   RegW_Result <= '1';
                   RegSrc(0) <= '0';
                   ALUOp <= '1';
               end if;
           when others => null;
        end case;
    
        -- logic for ALU Decoder
        case ALUOp is 
            -- if not a DP Instruction
            when '0' =>
                ALUControl <= "00";
                FlagW <= "00";
            -- if DP Instruction
            when '1' =>
                case Funct (4 downto 1) is
                    -- if ADD Instruction
                    when "0100" =>
                        ALUControl <= "00";
                        -- if ALU flags should be saved
                        if Funct(0)='1' then
                            FlagW <= "11";
                        -- else if ALU flags should not be saved
                        else FlagW <= "00";
                        end if;
                    -- if SUB Instruction
                    when "0010" =>
                        ALUControl <= "01";
                        -- if ALU flags should be saved
                        if Funct(0)='1' then
                            FlagW <= "11";
                        -- else if ALU flags should not be saved                            
                        else FlagW <= "00";
                        end if;
                    -- if AND Instruction
                    when "0000" =>
                        ALUControl <= "10";
                        -- if ALU flags should be saved
                        if Funct(0)='1' then
                            FlagW <= "10";
                        -- else if ALU flags should not be saved
                        else FlagW <= "00";
                        end if;
                    -- if ORR Instruction
                    when "1100" =>
                        ALUControl <= "11";
                        -- if ALU flags should be saved
                        if Funct(0)='1' then
                            FlagW <= "10";
                        -- else if ALU flags should not be saved
                        else FlagW <= "00";
                        end if;
                    when others => null;
                end case;
            when others => null;
        end case;    
        
        -- PC Logic
        if Rd = "1111" then
            RdEquals15 <= '1';
        else RdEquals15 <= '0';
        end if;
        PCS <= (RdEquals15 and RegW_Result) or Branch;
    end process;
end Decoder_arch;
