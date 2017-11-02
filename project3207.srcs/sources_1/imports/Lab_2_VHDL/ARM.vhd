----------------------------------------------------------------------------------
-- Company: NUS -- Engineer: (c) Rajesh Panicker
--
-- Create Date: 09/23/2015 06:49:10 PM
-- Module Name: ARM -- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: ARM Module
--
-- Dependencies: NIL --
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: The interface (entity) SHOULD NOT be modified. The implementation (architecture) can be modified
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

-- R15 is not stored
-- Save waveform file and add it to the project
-- Reset and launch simulation if you add interal signals to the waveform window

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ARM is
port (
    CLK : in std_logic;
    RESET : in std_logic;
    -- Interrupt : in std_logic;  -- for optional future use
    Instr : in std_logic_vector(31 downto 0);
    ReadData : in std_logic_vector(31 downto 0);
    MemWrite : out std_logic;
    PC : out std_logic_vector(31 downto 0);
    ALUResult : out std_logic_vector(31 downto 0);
    WriteData : out std_logic_vector(31 downto 0)
);
end ARM;

architecture ARM_arch of ARM is

    component HazardUnit is
    port (
        RA1D : in std_logic_vector(3 downto 0);
        RA1E : in std_logic_vector(3 downto 0);
        RA2D : in std_logic_vector(3 downto 0);
        RA2E : in std_logic_vector(3 downto 0);
        RA2M : in std_logic_vector(3 downto 0);
        RA3D : in std_logic_vector(3 downto 0);
        RA3E : in std_logic_vector(3 downto 0);
        WA4E : in std_logic_vector(3 downto 0);
        WA4M : in std_logic_vector(3 downto 0);
        WA4W : in std_logic_vector(3 downto 0);
        RegWriteM : in std_logic;
        RegWriteW : in std_logic;
        MemWriteM : in std_logic;
        MemToRegE : in std_logic;
        MemToRegW : in std_logic;
        ALUResultM : in std_logic_vector(31 downto 0);
        ResultW : in std_logic_vector(31 downto 0);
        ToForwardD1E : out std_logic;
        ToForwardD2E : out std_logic;
        ToForwardD3E : out std_logic;
        ToForwardWriteDataM : out std_logic;
        ForwardD1E : out std_logic_vector(31 downto 0);
        ForwardD2E : out std_logic_vector(31 downto 0);
        ForwardD3E : out std_logic_vector(31 downto 0);
        ForwardWriteDataM : out std_logic_vector(31 downto 0);
        StallF : out std_logic;
        StallD : out std_logic;
        FlushE : out std_logic
    );
    end component HazardUnit;

    component RegFile is
    port (
        CLK : in std_logic;
        WE4 : in std_logic;
        A1 : in std_logic_vector(3 downto 0);
        A2 : in std_logic_vector(3 downto 0);
        A3 : in std_logic_vector(3 downto 0);
        A4 : in std_logic_vector(3 downto 0);
        WD4 : in std_logic_vector(31 downto 0);
        R15 : in std_logic_vector(31 downto 0);
        RD1 : out std_logic_vector(31 downto 0);
        RD2 : out std_logic_vector(31 downto 0);
        RD3 : out std_logic_vector(31 downto 0)
    );
    end component RegFile;

    component Extend is
    port (
        ImmSrc : in std_logic_vector(1 downto 0);
        InstrImm : in std_logic_vector(23 downto 0);
        ExtImm : out std_logic_vector(31 downto 0)
    );
    end component Extend;

    component Decoder is
    port (
        Rd : in std_logic_vector(3 downto 0);
        Op : in std_logic_vector(1 downto 0);
        Funct : in std_logic_vector(5 downto 0);
        MCycleFunct : in std_logic_vector(3 downto 0);
        IsShiftReg : in std_logic;
        PCS : out std_logic;
        RegW : out std_logic;
        MemW : out std_logic;
        MemtoReg : out std_logic;
        ALUSrc : out std_logic;
        ImmSrc : out std_logic_vector(1 downto 0);
        RegSrc : out std_logic_vector(2 downto 0);
        ShamtSrc : out std_logic_vector(1 downto 0);
        ALUResultSrc : out std_logic;
        NoWrite : out std_logic;
        ALUControl : out std_logic_vector(3 downto 0);
        MCycleStart : out std_logic;
        MCycleOp : out std_logic_vector(1 downto 0);
        FlagW : out std_logic_vector(2 downto 0);
        isArithmeticDP : out std_logic
    );
    end component Decoder;

    component CondLogic is
    port (
        CLK : in std_logic;
        PCS : in std_logic;
        RegW : in std_logic;
        NoWrite : in std_logic;
        MemW : in std_logic;
        FlagW : in std_logic_vector(2 downto 0);
        Cond : in std_logic_vector(3 downto 0);
        FinalFlags : in std_logic_vector(3 downto 0);
        PCSrc : out std_logic;
        RegWrite : out std_logic;
        MemWrite : out std_logic;
        CarryFlag : out std_logic
    );
    end component CondLogic;

    component Shifter is
    port (
        Sh : in std_logic_vector(1 downto 0);
        Shamt5 : in std_logic_vector(4 downto 0);
        ShIn : in std_logic_vector(31 downto 0);
        ShOut : out std_logic_vector(31 downto 0);
        ShifterCarry : out std_logic
    );
    end component Shifter;

    component ALU is
    port (
        Src_A : in std_logic_vector(31 downto 0);
        Src_B : in std_logic_vector(31 downto 0);
        ALUControl : in std_logic_vector(3 downto 0);
        CarryFlag : in std_logic;
        ALUResult : out std_logic_vector(31 downto 0);
        ALUFlags : out std_logic_vector(3 downto 0)
    );
    end component ALU;

    component MCycle is
    generic (
        width : integer
    );
    port (
        CLK : in std_logic;
        RESET : in std_logic;
        Start : in std_logic;
        MCycleOp : in std_logic_vector (1 downto 0);
        Operand1 : in std_logic_vector (width-1 downto 0);
        Operand2 : in std_logic_vector (width-1 downto 0);
        ALUResult : in std_logic_vector (width - 1 downto 0);
        ALUCarryFlag : in std_logic;
        ALUSrc1 : out std_logic_vector (width - 1 downto 0);
        ALUSrc2 : out std_logic_vector (width - 1 downto 0);
        ALUControl : out std_logic_vector (3 downto 0);
        Result1 : out std_logic_vector (width-1 downto 0);
        Result2 : out std_logic_vector (width-1 downto 0);
        Busy : out std_logic
    );
    end component MCycle;

    component ProgramCounter is
    port (
        CLK : in std_logic;
        RESET : in std_logic;
        WE_PC : in std_logic; -- write enable
        PC_IN : in std_logic_vector(31 downto 0);
        PC : out std_logic_vector(31 downto 0)
    );
    end component ProgramCounter;


    -------------------------------------------
    -- Fetch signals  -------------------------
    -------------------------------------------

    -- Inputs
    signal PCF : std_logic_vector(31 downto 0);

    -- Instruction Memory signals
    -- signal PCF : std_logic_vector(31 downto 0);
    signal InstrF : std_logic_vector(31 downto 0);

    -- Internal
    signal PCPlus4F : std_logic_vector(31 downto 0);

    -- Outputs
    -- signal InstrF : std_logic_vector(31 downto 0);
    -- signal PCPlus4F : std_logic_vector(31 downto 0);


    -------------------------------------------
    -- Decode signals  ------------------------
    -------------------------------------------

    -- Inputs
    signal InstrD : std_logic_vector(31 downto 0) := x"00000000";
    signal PCPlus8D : std_logic_vector(31 downto 0) := x"00000000"; -- Same as PCPlus4F due to delaying

    -- RegFile signals
    -- Note that some of these are in Writeback.
    signal RA1D : std_logic_vector(3 downto 0);
    signal RA2D : std_logic_vector(3 downto 0);
    signal RA3D : std_logic_vector(3 downto 0);
    signal R15D : std_logic_vector(31 downto 0);
    signal RD1D : std_logic_vector(31 downto 0);
    signal RD2D : std_logic_vector(31 downto 0);
    signal RD3D : std_logic_vector(31 downto 0);

    -- Extend signals
    signal ImmSrcD : std_logic_vector(1 downto 0);
    signal InstrImmD : std_logic_vector(23 downto 0);
    signal ExtImmD : std_logic_vector(31 downto 0);

    -- Decoder signals
    signal RdD : std_logic_vector(3 downto 0);
    signal OpD : std_logic_vector(1 downto 0);
    signal FunctD : std_logic_vector(5 downto 0);
    signal MCycleFunctD : std_logic_vector(3 downto 0);
    signal IsShiftRegD : std_logic;
    signal PCSD : std_logic;
    signal RegWD : std_logic;
    signal MemWD : std_logic;
    signal MemtoRegD : std_logic;
    signal ALUSrcD : std_logic;
    -- signal ImmSrcD : std_logic_vector(1 downto 0);
    signal RegSrcD : std_logic_vector(2 downto 0);
    signal ALUResultSrcD : std_logic;
    signal ShamtSrcD : std_logic_vector(1 downto 0);
    signal NoWriteD : std_logic;
    signal MCycleStartD : std_logic;
    signal MCycleOpD : std_logic_vector(1 downto 0);
    signal ALUControlD : std_logic_vector(3 downto 0);
    signal FlagWD : std_logic_vector(2 downto 0);
    signal isArithmeticDPD : std_logic;

    -- Internal
    signal CondD : std_logic_vector(3 downto 0);
    signal WA4D : std_logic_vector(3 downto 0);
    signal ShTypeD : std_logic_vector(1 downto 0);
    signal Shamt5D : std_logic_vector(4 downto 0);
    signal ShInD : std_logic_vector(31 downto 0);

    -- Outputs
    -- signal PCSD : std_logic;
    -- signal RegWD : std_logic;
    -- signal MemWD : std_logic;
    -- signal FlagWD : std_logic_vector(2 downto 0);
    -- signal ALUControlD : std_logic_vector(3 downto 0);
    -- signal MemToRegD : std_logic;
    -- signal ALUSrcD : std_logic;
    -- signal ALUResultSrcD : std_logic;
    -- signal ShamtSrcD : std_logic_vector(1 downto 0);
    -- signal NoWriteD : std_logic;
    -- signal MCycleStartD : std_logic;
    -- signal MCycleOpD : std_logic_vector(1 downto 0);
    -- signal isArithmeticDPD : std_logic;
    -- signal RA1D : std_logic_vector(3 downto 0) := x"0";
    -- signal RA2D : std_logic_vector(3 downto 0) := x"0";
    -- signal RA3D : std_logic_vector(3 downto 0) := x"0";
    -- signal RD1D : std_logic_vector(31 downto 0);
    -- signal RD2D : std_logic_vector(31 downto 0);
    -- signal RD3D : std_logic_vector(31 downto 0);
    -- signal ExtImmD : std_logic_vector(31 downto 0);
    -- signal CondD : std_logic_vector(3 downto 0);
    -- signal WA4D : std_logic_vector(3 downto 0);
    -- signal ShTypeD : std_logic_vector(1 downto 0);
    -- signal Shamt5D : std_logic_vector(4 downto 0);


    -------------------------------------------
    -- Execute signals  -----------------------
    -------------------------------------------

    -- Inputs
    signal PCSE : std_logic := '0';
    signal RegWE : std_logic := '0';
    signal MemWE : std_logic := '0';
    signal FlagWE : std_logic_vector(2 downto 0) := "000";
    signal ALUControlE : std_logic_vector(3 downto 0) := "0000";
    signal MemToRegE : std_logic := '0';
    signal ALUSrcE : std_logic := '0';
    signal ALUResultSrcE : std_logic := '0';
    signal ShamtSrcE : std_logic_vector(1 downto 0);
    signal NoWriteE : std_logic := '0';
    signal MCycleStartE : std_logic := '0';
    signal MCycleOpE : std_logic_vector(1 downto 0) := "00";
    signal isArithmeticDPE : std_logic := '0';
    signal RA1E : std_logic_vector(3 downto 0) := x"0";
    signal RA2E : std_logic_vector(3 downto 0) := x"0";
    signal RA3E : std_logic_vector(3 downto 0) := x"0";
    signal RD1E : std_logic_vector(31 downto 0) := x"00000000";
    signal RD2E : std_logic_vector(31 downto 0) := x"00000000";
    signal RD3E : std_logic_vector(31 downto 0) := x"00000000";
    signal ExtImmE : std_logic_vector(31 downto 0) := x"00000000";
    signal CondE : std_logic_vector(3 downto 0) := "0000";
    signal WA4E : std_logic_vector(3 downto 0) := "0000";
    signal ShTypeE : std_logic_vector(1 downto 0) := "00";
    signal Shamt5E : std_logic_vector(4 downto 0) := "00000";

    -- CondLogic signals
    -- signal PCSE : std_logic;
    -- signal RegWE : std_logic;
    -- signal NoWriteE : std_logic;
    -- signal MemWE : std_logic;
    -- signal FlagWE : std_logic_vector(2 downto 0);
    -- signal CondE : std_logic_vector(3 downto 0);
    signal FinalFlagsE : std_logic_vector(3 downto 0);
    signal PCSrcE : std_logic;
    signal RegWriteE : std_logic;
    signal MemWriteE : std_logic;
    signal CarryFlagE : std_logic;

    -- Shifter signals
    -- signal ShTypeE : std_logic_vector(1 downto 0);
    signal FinalShamt5E : std_logic_vector(4 downto 0);
    signal ShInE : std_logic_vector(31 downto 0);
    signal ShOutE : std_logic_vector(31 downto 0);
    signal ShifterCarryE : std_logic;

    -- ALU signals
    signal Src_AE : std_logic_vector(31 downto 0);
    signal Src_BE : std_logic_vector(31 downto 0);
    signal ALUFinalControlE : std_logic_vector(3 downto 0);  -- From Decoder or MCycle.
    -- signal CarryFlagE : std_logic;
    signal ALUResultE : std_logic_vector(31 downto 0); -- name for internal signal -> output can't be read
    signal ALUFlagsE : std_logic_vector(3 downto 0);

    -- MCycle signals
    -- signal MCycleStartE : std_logic;
    -- signal MCycleOpE : std_logic_vector(1 downto 0);
    signal Operand1E : std_logic_vector(31 downto 0);
    signal Operand2E : std_logic_vector(31 downto 0);
    signal MCycleALUResultE : std_logic_vector(31 downto 0);
    signal MCycleALUCarryFlagE : std_logic;
    signal MCycleALUSrc1E : std_logic_vector(31 downto 0);
    signal MCycleALUSrc2E : std_logic_vector(31 downto 0);
    signal MCycleALUControlE : std_logic_vector (3 downto 0);
    signal MCycleResultE : std_logic_vector(31 downto 0);
    signal MCycleResultUnusedE : std_logic_vector(31 downto 0);
    signal MCycleBusyE : std_logic;

    -- Internal
    signal ToForwardD1E : std_logic;
    signal ToForwardD2E : std_logic;
    signal ToForwardD3E : std_logic;
    signal ToForwardWriteDataM : std_logic;
    signal ForwardD1E : std_logic_vector(31 downto 0);
    signal ForwardD2E : std_logic_vector(31 downto 0);
    signal ForwardD3E : std_logic_vector(31 downto 0);
    signal ForwardWriteDataM : std_logic_vector(31 downto 0);
    signal FinalRD1E : std_logic_vector(31 downto 0);
    signal FinalRD2E : std_logic_vector(31 downto 0);
    signal FinalRD3E : std_logic_vector(31 downto 0);
    signal OpResultE : std_logic_vector(31 downto 0);  -- Either ALU's or MCycle's result.
    signal WriteDataE : std_logic_vector(31 downto 0);

    -- Outputs
    -- signal RA2E : std_logic_vector(3 downto 0);
    -- signal PCSrcE : std_logic;
    -- signal RegWriteE : std_logic;
    -- signal MemWriteE : std_logic;
    -- signal MemToRegE : std_logic;
    -- signal OpResultE : std_logic_vector(31 downto 0);
    -- signal WriteDataE : std_logic_vector(31 downto 0);
    -- signal WA4E : std_logic_vector(3 downto 0);


    -------------------------------------------
    -- Memory signals  ------------------------
    -------------------------------------------

    -- Inputs
    signal RA2M : std_logic_vector(3 downto 0) := x"0";
    signal PCSrcM : std_logic := '0';
    signal RegWriteM : std_logic := '0';
    signal MemWriteM : std_logic := '0';
    signal MemToRegM : std_logic := '0';
    signal OpResultM : std_logic_vector(31 downto 0) := x"00000000";
    signal WriteDataM : std_logic_vector(31 downto 0) := x"00000000";
    signal WA4M : std_logic_vector(3 downto 0) := "0000";

    -- Data memory signals
    -- ALUResult
    -- WriteData
    -- MemWrite
    signal ReadDataM : std_logic_vector(31 downto 0);
    signal FinalWriteDataM : std_logic_vector(31 downto 0);

    -- Outputs
    -- signal PCSrcM : std_logic;  -- Carried straight through
    -- signal RegWriteM : std_logic;  -- Carried straight through
    -- signal MemToRegM : std_logic;  -- Carried straight through
    -- signal OpResultM : std_logic_vector(31 downto 0);  -- Carried straight through
    -- signal ReadDataM : std_logic_vector(31 downto 0);
    -- signal WA4M : std_logic_vector(3 downto 0);  -- Carried straight through


    -------------------------------------------
    -- Writeback signals  ---------------------
    -------------------------------------------

    -- Inputs
    signal PCSrcW : std_logic := '0';
    signal RegWriteW : std_logic := '0';
    signal MemToRegW : std_logic := '0';
    signal OpResultW : std_logic_vector(31 downto 0) := x"00000000";
    signal ReadDataW : std_logic_vector(31 downto 0) := x"00000000";
    signal WA4W : std_logic_vector(3 downto 0) := "0000";

    -- RegFile signals
    signal WE4W : std_logic;
    -- signal WA4W : std_logic_vector(3 downto 0);
    signal WD4W : std_logic_vector(31 downto 0);

    -- ProgramCounter signals
    signal PC_INW : std_logic_vector(31 downto 0);
    signal WE_PCW : std_logic;
    signal PCW : std_logic_vector(31 downto 0);

    -- Internal
    signal ResultW : std_logic_vector(31 downto 0);

    -- Outputs
    -- signal PCW : std_logic_vector(31 downto 0);


    -------------------------------------------
    -- HazardUnit signals  --------------------
    -------------------------------------------

    -- Inputs
    -- signal RA1E : std_logic_vector(3 downto 0);
    -- signal RA2E : std_logic_vector(3 downto 0);
    -- signal RA3E : std_logic_vector(3 downto 0);
    -- signal WA4M : std_logic_vector(3 downto 0);
    -- signal WA4W : std_logic_vector(3 downto 0);
    -- signal RegWriteM : std_logic;
    -- signal RegWriteW : std_logic;
    -- signal OpResultM : std_logic_vector(31 downto 0);
    -- signal ResultW : std_logic_vector(31 downto 0);

    -- Outputs
    -- signal ToForwardD1E : std_logic;
    -- signal ToForwardD2E : std_logic;
    -- signal ToForwardD3E : std_logic;
    -- signal ToForwardWriteDataM : std_logic;
    -- signal ForwardD1E : std_logic_vector(31 downto 0);
    -- signal ForwardD2E : std_logic_vector(31 downto 0);
    -- signal ForwardD3E : std_logic_vector(31 downto 0);
    -- signal ForwardWriteDataM : std_logic_vector(31 downto 0);

begin

    -------------------------------------------
    -- Fetch connections  ---------------------
    -------------------------------------------

    -- Inputs
    PCF <= PCW;

    -- Instruction Memory inputs (and outputs)
    PC <= PCF;  -- Goes outside ARM
    InstrF <= Instr;  -- Comes from outside ARM

    -- Internal
    PCPlus4F <= PCF + 4;


    -------------------------------------------
    -- Decode connections  --------------------
    -------------------------------------------

    -- Inputs
    process(CLK)
    begin
        if CLK'event and CLK = '1' then
            InstrD <= InstrF;
        end if;
    end process;
    PCPlus8D <= PCPlus4F;

    -- RegFile inputs
    RA1D <= x"F"
            when RegSrcD(0) = '1'
            else InstrD(11 downto 8)  -- Rs for MUL/DIV.
                when RegSrcD(2) = '1'
                else InstrD(19 downto 16);  -- Rn otherwise.
    RA2D <= InstrD(15 downto 12) when RegSrcD(1) = '1' else InstrD(3 downto 0);
    RA3D <= InstrD(11 downto 8);
    R15D <= PCPlus8D;

    -- Extend inputs
    InstrImmD <= InstrD(23 downto 0);
    -- ImmSrc connected directly to Decoder output

    -- Decoder inputs
    RdD <= InstrD(15 downto 12);
    OpD <= InstrD(27 downto 26);
    FunctD <= InstrD(25 downto 20);
    MCycleFunctD <= InstrD(7 downto 4);
    IsShiftRegD <= InstrD(4);

    -- Internal
    CondD <= InstrD(31 downto 28);
    WA4D <= InstrD(19 downto 16)  -- Rd for MUL/DIV is 19 downto 16.
            when RegSrcD(2) = '1'
            else InstrD(15 downto 12);
    ShTypeD <= "11" when ALUSrcD = '1' else InstrD(6 downto 5);
    Shamt5D <= InstrD(11 downto 7) when ShamtSrcD = "01"
               else InstrD(11 downto 8) & '0' when ShamtSrcD = "10"
               else RD3D(4 downto 0) when ShamtSrcD = "11"
               else "00000";


    -------------------------------------------
    -- Execute connections  -------------------
    -------------------------------------------

    -- Inputs
    process(CLK)
    begin
        if CLK'event and CLK = '1' then
            PCSE <= PCSD;
            RegWE <= RegWD;
            MemWE <= MemWD;
            FlagWE <= FlagWD;
            ALUControlE <= ALUControlD;
            MemToRegE <= MemToRegD;
            ALUSrcE <= ALUSrcD;
            ALUResultSrcE <= ALUResultSrcD;
            ShamtSrcE <= ShamtSrcD;
            NoWriteE <= NoWriteD;
            MCycleStartE <= MCycleStartD;
            MCycleOpE <= MCycleOpD;
            isArithmeticDPE <= isArithmeticDPD;
            RA1E <= RA1D;
            RA2E <= RA2D;
            RA3E <= RA3D;
            RD1E <= RD1D;
            RD2E <= RD2D;
            RD3E <= RD3D;
            ExtImmE <= ExtImmD;
            CondE <= CondD;
            WA4E <= WA4D;
            ShTypeE <= ShTypeD;
            Shamt5E <= Shamt5D;
        end if;
    end process;

    -- CondLogic inputs
    -- PCSE
    -- RegWE
    -- NoWriteE
    -- MemWE
    -- FlagWE
    -- CondE
    FinalFlagsE(3 downto 2) <= ALUFlagsE(3 downto 2);
    FinalFlagsE(1) <= ShifterCarryE when isArithmeticDPE = '0' else ALUFlagsE(1);
    FinalFlagsE(0) <= ALUFlagsE(0);

    -- Shifter inputs
    -- ShTypeE
    FinalShamt5E <= FinalRD3E(4 downto 0) when ShamtSrcE = "11" else Shamt5E;
    ShInE <= ExtImmE when ALUSrcE = '1' else FinalRD2E;

    -- ALU inputs
    Src_AE <= MCycleALUSrc1E when MCycleBusyE = '1' else FinalRD1E;
    Src_BE <= MCycleALUSrc2E when MCycleBusyE = '1'
              else ShOutE; -- to enable DP instructions with shift operation
    ALUFinalControlE <= MCycleALUControlE when MCycleBusyE = '1' else ALUControlE;
    -- CarryFlagE

    -- MCycle inputs
    -- MCycleStartE
    -- MCycleOpE
    -- Rm comes from RD2, while Rs comes from RD1. Division should do Rm/Rs, so
    -- Operand1 for Division should be RD2. Switching it around makes no
    -- difference to Multiplication.
    Operand1E <= FinalRD2E;
    Operand2E <= FinalRD1E;
    MCycleALUResultE <= ALUResultE;
    MCycleALUCarryFlagE <= ALUFlagsE(1);

    -- Internal
    FinalRD1E <= RD1E when ToForwardD1E = '0' else ForwardD1E;
    FinalRD2E <= RD2E when ToForwardD2E = '0' else ForwardD2E;
    FinalRD3E <= RD3E when ToForwardD3E = '0' else ForwardD3E;
    OpResultE <= MCycleResultE when ALUResultSrcE = '1' else ALUResultE;
    WriteDataE <= FinalRD2E;


    -------------------------------------------
    -- Memory connections  --------------------
    -------------------------------------------

    -- Inputs
    process(CLK)
    begin
        if CLK'event and CLK = '1' then
            RA2M <= RA2E;
            PCSrcM <= PCSrcE;
            RegWriteM <= RegWriteE;
            MemWriteM <= MemWriteE;
            MemToRegM <= MemToRegE;
            OpResultM <= OpResultE;
            WriteDataM <= WriteDataE;
            WA4M <= WA4E;
        end if;
    end process;

    -- Data Memory inputs (and outputs)
    ALUResult <= OpResultM;  -- Goes outside ARM
    WriteData <= FinalWriteDataM;  -- Goes outside ARM
    MemWrite <= MemWriteM;  -- Goes outside ARM
    ReadDataM <= ReadData;  -- Comes from outside ARM

    -- Internal
    FinalWriteDataM <= WriteDataM when ToForwardWriteDataM = '0' else ForwardWriteDataM;

    -------------------------------------------
    -- Writeback connections  -----------------
    -------------------------------------------

    -- Inputs
    process(CLK)
    begin
        if CLK'event and CLK = '1' then
            PCSrcW <= PCSrcM;
            RegWriteW <= RegWriteM;
            MemToRegW <= MemToRegM;
            OpResultW <= OpResultM;
            ReadDataW <= ReadDataM;
            WA4W <= WA4M;
        end if;
    end process;

    -- RegFile inputs
    WE4W <= RegWriteW and not MCycleBusyE;
    -- WA4W
    WD4W <= ResultW;

    -- ProgramCounter inputs
    PC_INW <= ResultW when PCSrcW = '1' else PCPlus4F;
    WE_PCW <= not MCycleBusyE;

    -- Internal
    ResultW <= ReadDataW when MemToRegW = '1' else OpResultW;


    -- Port maps

    HazardUnit1: HazardUnit
    port map(
        RA1D => RA1D,
        RA1E => RA1E,
        RA2D => RA2D,
        RA2E => RA2E,
        RA2M => RA2M,
        RA3D => RA3D,
        RA3E => RA3E,
        WA4E => WA4E,
        WA4M => WA4M,
        WA4W => WA4W,
        RegWriteM => RegWriteM,
        RegWriteW => RegWriteW,
        MemWriteM => MemWriteM,
        MemToRegE => MemToRegE,
        MemToRegW => MemToRegW,
        ALUResultM => OpResultM,
        ResultW => ResultW,
        ToForwardD1E => ToForwardD1E,
        ToForwardD2E => ToForwardD2E,
        ToForwardD3E => ToForwardD3E,
        ToForwardWriteDataM => ToForwardWriteDataM,
        ForwardD1E => ForwardD1E,
        ForwardD2E => ForwardD2E,
        ForwardD3E => ForwardD3E,
        ForwardWriteDataM => ForwardWriteDataM
    );

    ProgramCounter1: ProgramCounter
    port map(
        CLK => CLK,
        RESET => RESET,
        WE_PC => WE_PCW,
        PC_IN => PC_INW,
        PC => PCW
    );

    RegFile1: RegFile
    port map(
        CLK => CLK,
        WE4 => WE4W,
        A1 => RA1D,
        A2 => RA2D,
        A3 => RA3D,
        A4 => WA4W,
        WD4 => WD4W,
        R15 => R15D,
        RD1 => RD1D,
        RD2 => RD2D,
        RD3 => RD3D
    );

    Extend1: Extend
    port map(
        ImmSrc => ImmSrcD,
        InstrImm => InstrImmD,
        ExtImm => ExtImmD
    );

    Decoder1: Decoder
    port map(
        Rd => RdD,
        Op => OpD,
        Funct => FunctD,
        MCycleFunct => MCycleFunctD,
        IsShiftReg => IsShiftRegD,
        PCS => PCSD,
        RegW => RegWD,
        MemW => MemWD,
        MemtoReg => MemtoRegD,
        ALUSrc => ALUSrcD,
        ImmSrc => ImmSrcD,
        ShamtSrc => ShamtSrcD,
        RegSrc => RegSrcD,
        ALUResultSrc => ALUResultSrcD,
        NoWrite => NoWriteD,
        MCycleStart => MCycleStartD,
        MCycleOp => MCycleOpD,
        ALUControl => ALUControlD,
        FlagW => FlagWD,
        isArithmeticDP => isArithmeticDPD
    );

    CondLogic1: CondLogic
    port map (
        CLK => CLK,
        PCS => PCSE,
        RegW => RegWE,
        NoWrite => NoWriteE,
        MemW => MemWE,
        FlagW => FlagWE,
        Cond => CondE,
        FinalFlags => FinalFlagsE,
        PCSrc => PCSrcE,
        RegWrite => RegWriteE,
        MemWrite => MemWriteE,
        CarryFlag => CarryFlagE
    );

    Shifter1: Shifter
    port map (
        Sh => ShTypeE,
        Shamt5 => FinalShamt5E,
        ShIn => ShInE,
        ShOut => ShOutE,
        ShifterCarry => ShifterCarryE
    );

    ALU1: ALU
    port map(
        Src_A => Src_AE,
        Src_B => Src_BE,
        ALUControl => ALUFinalControlE,
        CarryFlag => CarryFlagE,
        ALUResult => ALUResultE,
        ALUFlags => ALUFlagsE
    );

    MCycle1: MCycle
    generic map (
        width => 32
    )
    port map (
        CLK => CLK,
        RESET => RESET,
        Start => MCycleStartE,
        MCycleOp => MCycleOpE,
        Operand1 => Operand1E,
        Operand2 => Operand2E,
        ALUResult => MCycleALUResultE,
        ALUCarryFlag => MCycleALUCarryFlagE,
        ALUSrc1 => MCycleALUSrc1E,
        ALUSrc2 => MCycleALUSrc2E,
        ALUControl => MCycleALUControlE,
        Result1 => MCycleResultE,
        Result2 => MCycleResultUnusedE,
        Busy => MCycleBusyE
    );

end ARM_arch;
