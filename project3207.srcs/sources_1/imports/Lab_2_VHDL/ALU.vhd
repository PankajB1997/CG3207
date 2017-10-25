----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: (c) Rajesh Panicker
--
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: ALU
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: ALU Module
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

entity ALU is
port(
    Src_A : in std_logic_vector(31 downto 0);
    Src_B : in std_logic_vector(31 downto 0);
    ALUControl : in std_logic_vector(3 downto 0);
    CarryFlag : in std_logic;
    ALUResult : out std_logic_vector(31 downto 0);
    ALUFlags : out std_logic_vector(3 downto 0)
);
end ALU;


architecture ALU_arch of ALU is
    signal S_wider : std_logic_vector(32 downto 0);
    signal Src_A_comp : std_logic_vector(32 downto 0);
    signal Src_B_comp : std_logic_vector(32 downto 0);
    signal ALUResult_i : std_logic_vector(31 downto 0);
    signal C_0 : std_logic_vector(32 downto 0);
    signal N, Z, C, V : std_logic;
begin
    S_wider <= std_logic_vector(unsigned(Src_A_comp) + unsigned(Src_B_comp) + unsigned(C_0));
    process(Src_A, Src_B, ALUControl, S_wider)
    begin
        C_0 <= (others => '0'); -- default value, will help avoid latches
        Src_A_comp <= '0' & Src_A;
        Src_B_comp <= '0' & Src_B;
        V <= '0';
        case ALUControl is
            when "0000" | "1000" =>  -- AND | TST
                ALUResult_i <= Src_A and Src_B;
            when "0001" | "1001" =>  -- EOR | TEQ
                ALUResult_i <= Src_A xor Src_B;
            when "0010" | "1010" =>  -- SUB | CMP
                C_0(0) <= '1';
                Src_B_comp <= '0' & not Src_B;
                ALUResult_i <= S_wider(31 downto 0);
                V <= (Src_A(31) xor  Src_B(31))  and (Src_B(31) xnor S_wider(31));
            when "0011" =>  -- RSB
                C_0(0) <= '1';
                Src_A_comp <= '0' & not Src_A;
                ALUResult_i <= S_wider(31 downto 0);
                V <= (Src_A(31) xor  Src_B(31))  and (Src_A(31) xnor S_wider(31));
            when "0100" | "1011" =>  -- ADD | CMN
                ALUResult_i <= S_wider(31 downto 0);
                V <= (Src_A(31) xnor  Src_B(31))  and (Src_B(31) xor S_wider(31));
            when "0101" =>  -- ADC
                ALUResult_i <= S_wider(31 downto 0);
                C_0(0) <= CarryFlag;
                V <= (Src_A(31) xnor  Src_B(31))  and (Src_B(31) xor S_wider(31));
            when "0110" =>  -- SBC
                -- Subtract NOT carry means if carry is 0, then CIn is 0, else it is 1.
                C_0(0) <= CarryFlag;
                Src_B_comp <= '0' & not Src_B;
                ALUResult_i <= S_wider(31 downto 0);
                V <= (Src_A(31) xor  Src_B(31))  and (Src_B(31) xnor S_wider(31));
            when "0111" =>  -- RSC
                -- Subtract NOT carry means if carry is 0, then CIn is 0, else it is 1.
                C_0(0) <= CarryFlag;
                Src_A_comp <= '0' & not Src_A;
                ALUResult_i <= S_wider(31 downto 0);
                V <= (Src_A(31) xor  Src_B(31))  and (Src_A(31) xnor S_wider(31));
            when "1100" =>  -- ORR
                ALUResult_i <= Src_A or Src_B;
            when "1101" =>  -- MOV
                ALUResult_i <= Src_B;
            when "1110" =>  -- BIC
                ALUResult_i <= Src_A and (not Src_B);
            when "1111" =>  -- MVN
                ALUResult_i <= not Src_B;
            when others =>
                ALUResult_i <= Src_B;
        end case;
    end process;

    N <= ALUResult_i(31);
    Z <= '1' when ALUResult_i = x"00000000" else '0';
    C <= S_wider(32);
    ALUResult <= ALUResult_i;
    ALUFlags <= N & Z & C & V;
end ALU_arch;
