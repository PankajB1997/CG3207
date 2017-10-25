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
--    License terms : --    You are free to use this code as long as you
--        (i) DO NOT post it on any public repository;
--        (ii) use it only for educational purposes;
--        (iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--        (iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--        (v)    acknowledge that the program was written based on the microarchitecture described in the book Digital Design and Computer Architecture, ARM Edition by Harris and Harris;
--        (vi) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--        (vii) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Decoder is
port(
    Rd : in std_logic_vector(3 downto 0);
    Op : in std_logic_vector(1 downto 0);
    Funct : in std_logic_vector(5 downto 0);
    MCycleFunct : in std_logic_vector(3 downto 0);
    PCS : out std_logic;
    RegW : out std_logic;
    MemW : out std_logic;
    MemtoReg : out std_logic;
    ALUSrc : out std_logic;
    ImmSrc : out std_logic_vector(1 downto 0);
    RegSrc : out std_logic_vector(2 downto 0);
    ALUResultSrc : out std_logic;
    NoWrite : out std_logic;
    ALUControl : out std_logic_vector(3 downto 0);
    MCycleStart : out std_logic;
    MCycleOp : out std_logic_vector(1 downto 0);
    FlagW : out std_logic_vector(2 downto 0);
    isArithmeticDP : out std_logic
);
end Decoder;

architecture Decoder_arch of Decoder is
    signal ALUOp : std_logic_vector (1 downto 0);
    signal Branch : std_logic;
    signal RdEquals15 : std_logic;
    signal RegWInternal : std_logic;
    signal MemWInternal : std_logic;
    signal FlagWInternal : std_logic_vector (2 downto 0);
    signal IllegalMainDecoder : std_logic;
    signal IllegalALUDecoder : std_logic;
    signal IllegalInstruction : std_logic;
begin

    -- Logic for Main Decoder
    main_decoder: process (Op, Funct, MCycleFunct)
    begin
        IllegalMainDecoder <= '0';  -- Legal by default.

        case Op is
            -- Branch Instruction
            when "10" =>
                Branch <= '1';
                MemtoReg <= '0';
                MemWInternal <= '0';
                ALUSrc <= '1';
                ImmSrc <= "10";
                RegWInternal <= '0';
                RegSrc <= "0-1";
                ALUOp <= "11"; -- ADD always

            -- Memory Instruction
            when "01" =>
                Branch <= '0';
                ALUSrc <= '1';
                ImmSrc <= "01";
                if Funct(3) = '0' then -- U bit '0'
                    ALUOp <= "10"; -- LDR/STR with Negative offset
                else
                    ALUOp <= "11"; -- LDR/STR with Positive offset
                end if;

                -- STR Instruction
                if Funct(0) = '0' then
                    MemtoReg <= '-';
                    MemWInternal <= '1';
                    RegWInternal <= '0';
                    RegSrc <= "010";
                -- LDR Instruction
                else
                    MemtoReg <= '1';
                    MemWInternal <= '0';
                    RegWInternal <= '1';
                    RegSrc <= "0-0";
                end if;

            -- Data Processing Instruction
            when "00" =>
                Branch <= '0';
                MemtoReg <= '0';
                MemWInternal <= '0';
                RegWInternal <= '1';
                ALUOp <= "00";

                if MCycleFunct = "1001" and Funct(5) = '0' then
                    -- MUL/DIV Instruction
                    ALUSrc <= '0';
                    ImmSrc <= "--";
                    RegSrc <= "100";
                else
                    -- DP Reg Instruction
                    if Funct(5) = '0' then
                        ALUSrc <= '0';
                        ImmSrc <= "--";
                        RegSrc <= "000";
                    -- DP Imm Instruction
                    else
                        ALUSrc <= '1';
                        ImmSrc <= "00";
                        RegSrc <= "0-0";
                    end if;
                end if;

            -- Invalid Op
            when others =>
                Branch <= '-';
                MemtoReg <= '-';
                MemWInternal <= '-';
                ALUSrc <= '-';
                ImmSrc <= "--";
                RegWInternal <= '-';
                RegSrc <= "0--";
                ALUOp <= "--";
                IllegalMainDecoder <= '1';
        end case;
    end process;

    -- Logic for ALU Decoder
    alu_decoder: process (ALUOp, Funct, MCycleFunct)
    begin
        IllegalALUDecoder <= '0';  -- Legal by default.
        case ALUOp is
            -- Not a DP Instruction
            when "11" =>          -- LDR/STR with Positive offset; and Branch instruction
                FlagWInternal <= "000";
                NoWrite <= '0';
                ALUControl <= "0100";  -- ADD
                ALUResultSrc <= '0';
                MCycleStart <= '0';
                MCycleOp <= "--";
                isArithmeticDP <= '-';
            when "10" =>          -- LDR/STR with Negative offset
                FlagWInternal <= "000";
                NoWrite <= '0';
                ALUControl <= "0010";  -- SUB
                ALUResultSrc <= '0';
                MCycleStart <= '0';
                MCycleOp <= "--";
                isArithmeticDP <= '-';

            -- ALU operations for DP instructions
            when "00" =>
                NoWrite <= '0';  -- Should write by default.
                if MCycleFunct = "1001" and Funct(5) = '0' then
                    -- MUL/DIV instruction
                    ALUControl <= "----";  -- MCycle controls ALU.
                    ALUResultSrc <= '1';
                    MCycleStart <= '1';
                    FlagWInternal <= "000";
                    isArithmeticDP <= '-';
                    if Funct(1) = '0' then
                        -- MUL instruction
                        MCycleOp <= "01";
                    else
                        -- DIV instruction
                        MCycleOp <= "11";
                    end if;
                else
                    -- Not MUL/DIV
                    ALUResultSrc <= '0';
                    MCycleStart <= '0';
                    MCycleOp <= "--";
                    ALUControl <= Funct(4 downto 1);
                    isArithmeticDP <= '-';
                    case Funct (4 downto 1) is
                        -- ADC Instruction
                        when "0101" =>
                            FlagWInternal <= "111";
                            isArithmeticDP <= '1';
                        -- ADD Instruction
                        when "0100" =>
                            FlagWInternal <= "111";
                            isArithmeticDP <= '1';
                        -- AND Instruction
                        when "0000" =>
                            FlagWInternal <= "110";
                            isArithmeticDP <= '0';
                        -- BIC Instruction
                        when "1110" =>
                            FlagWInternal <= "110";
                            isArithmeticDP <= '0';
                        -- CMP Instruction
                        when "1010" =>
                            NoWrite <= '1';
                            FlagWInternal <= "111";
                            isArithmeticDP <= '1';
                        -- CMN Instruction
                        when "1011" =>
                            NoWrite <= '1';
                            FlagWInternal <= "111";
                            isArithmeticDP <= '1';
                        -- EOR Instruction
                        when "0001" =>
                            FlagWInternal <= "110";
                            isArithmeticDP <= '0';
                        -- MOV Instruction
                        when "1101" =>
                            FlagWInternal <= "110";
                            isArithmeticDP <= '0';
                        -- MVN Instruction
                        when "1111" =>
                            FlagWInternal <= "110";
                            isArithmeticDP <= '0';
                        -- ORR Instruction
                        when "1100" =>
                            FlagWInternal <= "110";
                            isArithmeticDP <= '0';
                        -- RSB Instruction
                        when "0011" =>
                            FlagWInternal <= "111";
                            isArithmeticDP <= '1';
                        -- RSC Instruction
                        when "0111" =>
                            FlagWInternal <= "111";
                            isArithmeticDP <= '1';
                        -- SBC Instruction
                        when "0110" =>
                            FlagWInternal <= "111";
                            isArithmeticDP <= '1';
                        -- SUB Instruction
                        when "0010" =>
                            FlagWInternal <= "111";
                            isArithmeticDP <= '1';
                        -- TEQ Instruction
                        when "1001" =>
                            NoWrite <= '1';
                            FlagWInternal <= "110";
                            isArithmeticDP <= '0';
                        -- TST Instruction
                        when "1000" =>
                            NoWrite <= '1';
                            FlagWInternal <= "110";
                            isArithmeticDP <= '0';
                        when others =>
                            NoWrite <= '-';
                            ALUControl  <= "----";
                            FlagWInternal <= "---";
                            isArithmeticDP <= '-';
                            IllegalALUDecoder <= '1';
                    end case;
                end if;
                if Funct(0) = '0' then  -- If S bit is 0, don't write to flags.
                    if Funct (4 downto 1) = "1000" or
                       Funct (4 downto 1) = "1001" or
                       Funct (4 downto 1) = "1010" or
                       Funct (4 downto 1) = "1011" then
                        -- These instructions must have S bit set, otherwise illegal.
                        NoWrite <= '-';
                        ALUControl  <= "----";
                        FlagWInternal <= "---";
                        IllegalALUDecoder <= '1';
                    else
                        FlagWInternal <= "000";
                    end if;
                end if;
            when others =>
                NoWrite <= '-';
                ALUControl  <= "----";
                FlagWInternal <= "---";
                ALUResultSrc <= '-';
                MCycleStart <= '-';
                MCycleOp <= "--";
                isArithmeticDP <= '-';
                IllegalALUDecoder <= '1';
        end case;
    end process;

    -- PC Logic
    pc_logic: process (Rd, RdEquals15, RegWInternal, Branch, IllegalInstruction) begin
        if Rd = "1111" then
            RdEquals15 <= '1';
        else
            RdEquals15 <= '0';
        end if;
        PCS <= ((RdEquals15 and RegWInternal) or Branch) and (not IllegalInstruction);
    end process;

    IllegalInstruction <= IllegalMainDecoder or IllegalALUDecoder;

    -- If instruction is illegal, don't write any values
    RegW <= RegWInternal and (not IllegalInstruction);
    MemW <= MemWInternal and (not IllegalInstruction);
    FlagW <= FlagWInternal when (IllegalInstruction = '0') else "000";

end Decoder_arch;
