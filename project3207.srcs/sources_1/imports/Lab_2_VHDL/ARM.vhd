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

    component RegFile is
    port (
        CLK : in std_logic;
        WE3 : in std_logic;
        A1 : in std_logic_vector(3 downto 0);
        A2 : in std_logic_vector(3 downto 0);
        A3 : in std_logic_vector(3 downto 0);
        WD3 : in std_logic_vector(31 downto 0);
        R15 : in std_logic_vector(31 downto 0);
        RD1 : out std_logic_vector(31 downto 0);
        RD2 : out std_logic_vector(31 downto 0)
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

--     -- CondLogic signals
--     signal FinalFlags : std_logic_vector(3 downto 0);
--     signal CarryFlag : std_logic;
--
--     -- Shifter signals
--     signal ShOut : std_logic_vector(31 downto 0);
--     signal ShifterCarry : std_logic;
--
--     -- ALU signals
--     signal Src_A : std_logic_vector(31 downto 0);
--     signal Src_B : std_logic_vector(31 downto 0);
--     signal ALUResult_sig : std_logic_vector(31 downto 0); -- name for internal signal -> output can't be read
--     signal ALUFlags : std_logic_vector(3 downto 0);
--
--     -- MCycle signals
--     -- signal CLK : std_logic;
--     -- signal RESET : std_logic;
--     signal MCycleStart : std_logic;
--     signal MCycleOp : std_logic_vector(1 downto 0);
--     signal Operand1 : std_logic_vector(31 downto 0);
--     signal Operand2 : std_logic_vector(31 downto 0);
--     signal MCycleALUResult : std_logic_vector(31 downto 0);
--     signal MCycleALUCarryFlag : std_logic;
--     signal MCycleALUSrc1 : std_logic_vector(31 downto 0);
--     signal MCycleALUSrc2 : std_logic_vector(31 downto 0);
--     signal MCycleALUControl : std_logic_vector (3 downto 0);
--     signal MCycleResult : std_logic_vector(31 downto 0);
--     signal MCycleResultUnused : std_logic_vector(31 downto 0);
--     signal MCycleBusy : std_logic;
--
--     signal OpResult : std_logic_vector(31 downto 0);  -- Either ALU's or MCycle's result.
--     signal Result : std_logic_vector(31 downto 0);  -- Either OpResult or Memory value.
--     signal ALUFinalControl : std_logic_vector(3 downto 0);  -- From Decoder or MCycle.

    -------------------------------------------
    -- Fetch signals  -------------------------
    -------------------------------------------

    -- Inputs
    signal PC_INF : std_logic_vector(31 downto 0);
    signal WE_PCF : std_logic;

    -- ProgramCounter signals
    -- signal PC_INF : std_logic_vector(31 downto 0);
    -- signal WE_PCF : std_logic;
    signal PCF : std_logic_vector(31 downto 0);

    -- Instruction Memory signals
    -- signal PCF : std_logic_vector(31 downto 0);
    signal InstrF : std_logic_vector(31 downto 0);

    -- Internal
    signal PCPlus4F : std_logic_vector(31 downto 0);
    signal PCPlus8F : std_logic_vector(31 downto 0);

    -- Outputs
    -- signal InstrF : std_logic_vector(31 downto 0);
    -- signal PCPlus8F : std_logic_vector(31 downto 0);


    -------------------------------------------
    -- Decode signals  ------------------------
    -------------------------------------------

    -- Inputs
    signal InstrD : std_logic_vector(31 downto 0);
    signal PCPlus8D : std_logic_vector(31 downto 0);

    -- RegFile signals
    signal WE3W : std_logic;  -- TODO: Move to Writeback
    signal RA1D : std_logic_vector(3 downto 0);
    signal RA2D : std_logic_vector(3 downto 0);
    signal WA3W : std_logic_vector(3 downto 0);
    signal WD3W : std_logic_vector(31 downto 0);
    signal R15D : std_logic_vector(31 downto 0);
    signal RD1D : std_logic_vector(31 downto 0);
    signal RD2D : std_logic_vector(31 downto 0);

    -- Extend signals
    signal ImmSrcD : std_logic_vector(1 downto 0);
    signal InstrImmD : std_logic_vector(23 downto 0);
    signal ExtImmD : std_logic_vector(31 downto 0);

    -- Decoder signals
    signal RdD : std_logic_vector(3 downto 0);
    signal OpD : std_logic_vector(1 downto 0);
    signal FunctD : std_logic_vector(5 downto 0);
    signal MCycleFunctD : std_logic_vector(3 downto 0);
    signal PCSD : std_logic;
    signal RegWD : std_logic;
    signal MemWD : std_logic;
    signal MemtoRegD : std_logic;
    signal ALUSrcD : std_logic;
    -- signal ImmSrcD : std_logic_vector(1 downto 0);
    signal RegSrcD : std_logic_vector(2 downto 0);
    signal ALUResultSrcD : std_logic;
    signal NoWriteD : std_logic;
    signal MCycleStartD : std_logic;
    signal MCycleOpD : std_logic_vector(1 downto 0);
    signal ALUControlD : std_logic_vector(3 downto 0);
    signal FlagWD : std_logic_vector(2 downto 0);
    signal isArithmeticDPD : std_logic;

    -- Internal
    signal CondD : std_logic_vector(3 downto 0);
    signal WA3D : std_logic_vector(3 downto 0);
    signal ShTypeD : std_logic_vector(1 downto 0);
    signal Shamt5D : std_logic_vector(4 downto 0);

    -- Outputs
    -- signal PCSD : std_logic;
    -- signal RegWD : std_logic;
    -- signal MemWD : std_logic;
    -- signal FlagWD : std_logic_vector(2 downto 0);
    -- signal ALUControlD : std_logic_vector(3 downto 0);
    -- signal MemToRegD : std_logic;
    -- signal ALUSrcD : std_logic;
    -- signal ALUResultSrcD : std_logic;
    -- signal NoWriteD : std_logic;
    -- signal MCycleStartD : std_logic;
    -- signal MCycleOpD : std_logic_vector(1 downto 0);
    -- signal isArithmeticDPD : std_logic;
    -- signal RD1D : std_logic_vector(31 downto 0);
    -- signal RD2D : std_logic_vector(31 downto 0);
    -- signal CondD : std_logic_vector(3 downto 0);
    -- signal WA3D : std_logic_vector(3 downto 0);
    -- signal ExtImmD : std_logic_vector(31 downto 0);
    -- signal ShTypeD : std_logic_vector(1 downto 0);
    -- signal Shamt5D : std_logic_vector(4 downto 0);


--     -- Execute signals
--
--     -- Execute inputs
--     signal PCSE : std_logic;
--     signal RegWE : std_logic;
--     signal MemWE : std_logic;
--     signal FlagWE : std_logic_vector(2 downto 0);
--     signal ALUControlE : std_logic_vector(3 downto 0);
--     signal MemToRegE : std_logic;
--     signal ALUSrcE : std_logic;
--     signal ALUResultSrcE : std_logic;
--     signal NoWriteE : std_logic;
--     signal MCycleStartE : std_logic;
--     signal MCycleOpE : std_logic_vector(1 downto 0);
--     signal isArithmeticDPE : std_logic;
--     signal CondE : std_logic_vector(3 downto 0);
--     signal RD1E : std_logic_vector(31 downto 0);
--     signal RD2E : std_logic_vector(31 downto 0);
--     signal WA3E : std_logic_vector(3 downto 0);
--     signal ExtImmE : std_logic_vector(31 downto 0);
--     signal ShTypeE : std_logic_vector(1 downto 0);
--     signal Shamt5E : std_logic_vector(4 downto 0);
--
--     -- Execute internal
--     -- signal SrcAE : std_logic_vector(31 downto 0);
--     -- signal SrcBE : std_logic_vector(31 downto 0);
--     -- signal ALUFlagsE : std_logic_vector(3 downto 0);
--
--     -- Execute outputs
--     signal PCSrcE : std_logic;
--     signal RegWriteE : std_logic;
--     signal MemWriteE : std_logic;
--     -- signal MemToRegE : std_logic;  -- Carried straight through
--     signal ALUResultE : std_logic_vector(31 downto 0);
--     signal WriteDataE : std_logic_vector(31 downto 0);
--     -- signal WA3E : std_logic_vector(3 downto 0);  -- Carried straight through
--
--
--     -- Memory signals
--
--     -- Memory inputs
--     signal PCSrcM : std_logic;
--     signal RegWriteM : std_logic;
--     signal MemWriteM : std_logic;
--     signal MemToRegM : std_logic;
--     signal ALUResultM : std_logic_vector(31 downto 0);
--     signal WriteDataM : std_logic_vector(31 downto 0);
--     signal WA3M : std_logic_vector(3 downto 0);
--
--     -- Memory internal
--
--     -- Memory outputs
--     -- signal PCSrcM : std_logic;  -- Carried straight through
--     -- signal RegWriteM : std_logic;  -- Carried straight through
--     -- signal MemToRegM : std_logic;  -- Carried straight through
--     -- signal ALUResultM : std_logic_vector(31 downto 0);  -- Carried straight through
--     signal ReadDataM : std_logic_vector(31 downto 0);
--     -- signal WA3M : std_logic_vector(3 downto 0);  -- Carried straight through
--
--
--     -- Writeback signals
--
--     -- Writeback inputs
--     signal PCSrcW : std_logic;
--     signal RegWriteW : std_logic;
--     signal MemToRegW : std_logic;
--     signal ALUResultW : std_logic_vector(31 downto 0);
--     signal ReadDataW : std_logic_vector(31 downto 0);
--     signal WA3W : std_logic_vector(3 downto 0);
--
--     -- Writeback internal
--     signal ResultW : std_logic_vector(31 downto 0);
--     signal WE3W : std_logic;
--
--     -- Writeback outputs
--     signal PC_INW : std_logic_vector(31 downto 0);

    -- CondLogic signals
    -- signal CLK : std_logic;
    signal PCS : std_logic;
    signal RegW : std_logic;
    signal NoWrite : std_logic;
    signal MemW : std_logic;
    signal FlagW : std_logic_vector(2 downto 0);
    signal Cond : std_logic_vector(3 downto 0);
    signal FinalFlags : std_logic_vector(3 downto 0);
    signal PCSrc : std_logic;
    signal RegWrite : std_logic;
    -- signal MemWrite : std_logic;
    signal CarryFlag : std_logic;

    -- Shifter signals
    signal Sh : std_logic_vector(1 downto 0);
    signal Shamt5 : std_logic_vector(4 downto 0);
    signal ShIn : std_logic_vector(31 downto 0);
    signal ShOut : std_logic_vector(31 downto 0);
    signal ShifterCarry : std_logic;

    -- ALU signals
    signal Src_A : std_logic_vector(31 downto 0);
    signal Src_B : std_logic_vector(31 downto 0);
    signal ALUControl : std_logic_vector(3 downto 0);
    -- signal CarryFlag : std_logic;
    signal ALUResult_sig : std_logic_vector(31 downto 0); -- name for internal signal -> output can't be read
    signal ALUFlags : std_logic_vector(3 downto 0);

    -- MCycle signals
    -- signal CLK : std_logic;
    -- signal RESET : std_logic;
    signal MCycleStart : std_logic;
    signal MCycleOp : std_logic_vector(1 downto 0);
    signal Operand1 : std_logic_vector(31 downto 0);
    signal Operand2 : std_logic_vector(31 downto 0);
    signal MCycleALUResult : std_logic_vector(31 downto 0);
    signal MCycleALUCarryFlag : std_logic;
    signal MCycleALUSrc1 : std_logic_vector(31 downto 0);
    signal MCycleALUSrc2 : std_logic_vector(31 downto 0);
    signal MCycleALUControl : std_logic_vector (3 downto 0);
    signal MCycleResult : std_logic_vector(31 downto 0);
    signal MCycleResultUnused : std_logic_vector(31 downto 0);
    signal MCycleBusy : std_logic;

    -- Other internal signals
    signal OpResult : std_logic_vector(31 downto 0);  -- Either ALU's or MCycle's result.
    signal Result : std_logic_vector(31 downto 0);  -- Either OpResult or Memory value.
    signal ALUFinalControl : std_logic_vector(3 downto 0);  -- From Decoder or MCycle.

begin

    -------------------------------------------
    -- Fetch connections  ---------------------
    -------------------------------------------

    -- Inputs
    PC_INF <= Result when PCSrc = '1' else PCPlus4F;  -- TODO: Move to writeback
    WE_PCF <= not MCycleBusy;

    -- ProgramCounter inputs
    -- PC_INF
    -- WE_PCF

    -- Instruction Memory inputs (and outputs)
    PC <= PCF;  -- Goes outside ARM
    InstrF <= Instr;  -- Comes from outside ARM

    -- Internal
    PCPlus4F <= PCF + 4;
    PCPlus8F <= PCPlus4F + 4;


    -------------------------------------------
    -- Decode connections  --------------------
    -------------------------------------------

    -- Inputs
    InstrD <= InstrF;
    PCPlus8D <= PCPlus8F;

    -- RegFile inputs
    WE3W <= RegWrite and not MCycleBusy;  -- TODO: Move to Writeback stage
    RA1D <= x"F"
            when RegSrcD(0) = '1'
            else InstrD(11 downto 8)  -- Rs for MUL/DIV.
                when RegSrcD(2) = '1'
                else InstrD(19 downto 16);  -- Rn otherwise.
    RA2D <= InstrD(15 downto 12) when RegSrcD(1) = '1' else InstrD(3 downto 0);
    WA3W <= WA3D;  -- TODO: This should change
    WD3W <= Result;  -- TODO: Move to Writeback stage
    R15D <= PCPlus8D;

    -- Extend inputs
    InstrImmD <= InstrD(23 downto 0);
    -- ImmSrc connected directly to Decoder output

    -- Decoder inputs
    RdD <= InstrD(15 downto 12);
    OpD <= InstrD(27 downto 26);
    FunctD <= InstrD(25 downto 20);
    MCycleFunctD <= InstrD(7 downto 4);

    -- Internal
    CondD <= InstrD(31 downto 28);
    WA3D <= InstrD(19 downto 16)  -- Rd for MUL/DIV is 19 downto 16.
            when RegSrcD(2) = '1'
            else InstrD(15 downto 12);
    ShTypeD <= InstrD(6 downto 5);
    Shamt5D <= InstrD(11 downto 7);


--     -- Execute connections
--
--     -- Execute inputs
--     PCSE <= PCSD;
--     RegWE <= RegWD;
--     MemWE <= MemWD;
--     FlagWE <= FlagWD;
--     ALUControlE <= ALUControlD;
--     ALUResultSrcE <= ALUResultSrcD;
--     MemToRegE <= MemToRegD;
--     ALUSrcE <= ALUSrcD;
--     CondD <= CondE;
--     RD1E <= RD1D;
--     RD2E <= RD2D;
--     WA3E <= WA3D;
--     ExtImmE <= ExtImmD;
--     ShTypeD <= ShTypeE;
--     Shamt5D <= Shamt5E;
--
--     -- Execute internal
--
--     -- ALU
--     Src_A <= MCycleALUSrc1 when MCycleBusy = '1' else RD1E;
--     Src_B <= MCycleALUSrc2
--              when MCycleBusy = '1'
--              else ExtImmE
--                   when ALUSrcE = '1'
--                   else ShOut; --to enable DP instructions with shift operation
--     ALUFinalControl <= MCycleALUControl when MCycleBusy = '1' else ALUControlE;
--
--     -- CondLogic
--     FinalFlags (3 downto 2) <= ALUFlags (3 downto 2);
--     FinalFlags(1) <= ShifterCarry when isArithmeticDPE = '0' else ALUFlags(1);
--     FinalFlags(0) <= ALUFlags(0);
--
--     -- Execute outputs
--     ALUResultE <= MCycleResult when ALUResultSrcE = '1' else ALUResult_sig;
--     WriteDataE <= RD2E;
--
--
--     -- Memory connections
--
--     -- Memory inputs
--     PCSrcM <= PCSrcE;
--     RegWriteM <= RegWriteE;
--     MemWriteM <= MemWriteE;
--     MemToRegM <= MemToRegE;
--     ALUResultM <= ALUResultE;
--     WriteDataM <= WriteDataE;
--     WA3M <= WA3E;
--
--     -- Memory internal
--     ALUResult <= ALUResultM;  -- Goes outside ARM
--     WriteData <= WriteDataM;  -- Goes outside ARM
--     MemWrite <= MemWriteM;  -- Goes outside ARM
--
--     -- Memory outputs
--     ReadDataM <= ReadData;
--
--
--     -- Writeback connections
--
--     -- Writeback inputs
--     PCSrcW <= PCSrcM;
--     RegWriteW <= RegWriteM;
--     MemToRegW <= MemToRegM;
--     ALUResultW <= ALUResultM;
--     ReadDataW <= ReadDataM;
--     WA3W <= WA3W;
--
--     -- Writeback internal
--     ResultW <= ReadDataW when MemToRegW = '1' else ALUResultW;
--     WE3 <= RegWriteW and not MCycleBusy;
--
--     -- PC inputs
--     PC_INW <= ResultW when PCSrcW = '1' else PCPlus4F;
--
--
    -- Port maps
    RegFile1: RegFile
    port map(
        CLK => CLK,
        WE3 => WE3W,
        A1 => RA1D,
        A2 => RA2D,
        A3 => WA3W,
        WD3 => WD3W,
        R15 => R15D,
        RD1 => RD1D,
        RD2 => RD2D
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
        PCS => PCSD,
        RegW => RegWD,
        MemW => MemWD,
        MemtoReg => MemtoRegD,
        ALUSrc => ALUSrcD,
        ImmSrc => ImmSrcD,
        RegSrc => RegSrcD,
        ALUResultSrc => ALUResultSrcD,
        NoWrite => NoWriteD,
        MCycleStart => MCycleStartD,
        MCycleOp => MCycleOpD,
        ALUControl => ALUControlD,
        FlagW => FlagWD,
        isArithmeticDP => isArithmeticDPD
    );
--
--     CondLogic1: CondLogic
--     port map (
--         CLK => CLK,
--         PCS => PCSrcE,
--         RegW => RegWE,
--         NoWrite => NoWriteE,
--         MemW => MemWE,
--         FlagW => FlagWE,
--         Cond => CondE,
--         FinalFlags => FinalFlags,
--         PCSrc => PCSrcE,
--         RegWrite => RegWriteE,
--         MemWrite => MemWriteE,
--         CarryFlag => CarryFlag
--     );
--
--     Shifter1: Shifter
--     port map (
--         Sh => ShTypeE,
--         Shamt5 => Shamt5E,
--         ShIn => RD2E,
--         ShOut => ShOut,
--         ShifterCarry => ShifterCarry
--     );
--
--     ALU1: ALU
--     port map(
--         Src_A => Src_A,
--         Src_B => Src_B,
--         ALUControl => ALUFinalControl,
--         CarryFlag => CarryFlag,
--         ALUResult => ALUResult_sig,
--         ALUFlags => ALUFlags
--     );
--
--     MCycle1: MCycle
--     generic map (
--         width => 32
--     )
--     port map (
--         CLK => CLK,
--         RESET => RESET,
--         Start => MCycleStart,
--         MCycleOp => MCycleOp,
--         Operand1 => RD2E,  -- Switch around operators to facilitate divsion.
--         Operand2 => RD1E,
--         ALUResult => ALUResult_sig,
--         ALUCarryFlag => ALUFlags(1),
--         ALUSrc1 => MCycleALUSrc1,
--         ALUSrc2 => MCycleALUSrc2,
--         ALUControl => MCycleALUControl,
--         Result1 => MCycleResult,
--         Result2 => MCycleResultUnused,
--         Busy => MCycleBusy
--     );

    ProgramCounter1: ProgramCounter
    port map(
        CLK => CLK,
        RESET => RESET,
        WE_PC => WE_PCF,
        PC_IN => PC_INF,
        PC => PCF
    );

    -- Datapath connections

    -- ALU inputs
    Src_A <= MCycleALUSrc1 when MCycleBusy = '1' else RD1D;
    Src_B <= MCycleALUSrc2
             when MCycleBusy = '1'
             else ExtImmD
                  when ALUSrcD = '1'
                  else ShOut; --to enable DP instructions with shift operation
    ALUFinalControl <= MCycleALUControl when MCycleBusy = '1' else ALUControlD;
    -- CarryFlag connected already

    -- MCycle inputs
    -- Rm comes from RD2, while Rs comes from RD1. Division should do Rm/Rs, so
    -- Operand1 for Division should be RD2. Switching it around makes no
    -- difference to Multiplication.
    Operand1 <= RD2D;
    Operand2 <= RD1D;
    MCycleALUResult <= ALUResult_sig;
    MCycleALUCarryFlag <= ALUFlags(1);

    -- Shifter inputs
    Sh <= ShTypeD;
    Shamt5 <= Shamt5D;
    ShIn <= RD2D;

    -- Data Memory inputs
    OpResult <= MCycleResult when ALUResultSrcD = '1' else ALUResult_sig;
    ALUResult <= OpResult;
    WriteData <= RD2D;
    -- MemW connected already

    -- Data Memory outputs
    Result <= ReadData when MemToRegD = '1' else OpResult;

    -- Conditional logic inputs
    -- Cond <= CondD;
    FinalFlags(3 downto 2) <= ALUFlags(3 downto 2);
    FinalFlags(1) <= ShifterCarry when isArithmeticDPD = '0' else ALUFlags(1);
    FinalFlags(0) <= ALUFlags(0);


    -- Port maps
    CondLogic1: CondLogic
    port map (
        CLK => CLK,
        PCS => PCSD,
        RegW => RegWD,
        NoWrite => NoWriteD,
        MemW => MemWD,
        FlagW => FlagWD,
        Cond => CondD,
        FinalFlags => FinalFlags,
        PCSrc => PCSrc,
        RegWrite => RegWrite,
        MemWrite => MemWrite,
        CarryFlag => CarryFlag
    );

    Shifter1: Shifter
    port map (
        Sh => ShTypeD,
        Shamt5 => Shamt5D,
        ShIn => ShIn,
        ShOut => ShOut,
        ShifterCarry => ShifterCarry
    );

    ALU1: ALU
    port map(
        Src_A => Src_A,
        Src_B => Src_B,
        ALUControl => ALUFinalControl,
        CarryFlag => CarryFlag,
        ALUResult => ALUResult_sig,
        ALUFlags => ALUFlags
    );

    MCycle1: MCycle
    generic map (
        width => 32
    )
    port map (
        CLK => CLK,
        RESET => RESET,
        Start => MCycleStartD,
        MCycleOp => MCycleOpD,
        Operand1 => Operand1,
        Operand2 => Operand2,
        ALUResult => MCycleALUResult,
        ALUCarryFlag => MCycleALUCarryFlag,
        ALUSrc1 => MCycleALUSrc1,
        ALUSrc2 => MCycleALUSrc2,
        ALUControl => MCycleALUControl,
        Result1 => MCycleResult,
        Result2 => MCycleResultUnused,
        Busy => MCycleBusy
    );

end ARM_arch;
