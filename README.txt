1. Design Sources:

(i) TOP.vhd - A high-level module that gives an overall structure of this microprocessor design, that takes in peripherals from the FPGA as input/output. The inputs PB, DIP indicate values provided as input for the software (which in our case, is a Calculator assembly program), CLK_undiv is the 100 MHz clock provided, TX (output) and RX (input) are unused as of now as they are for UART which is yet to be used and LED shows the result of the software, which includes the first 8 LEDs showing the CLK and PC values and the next 8 LEDs showing the output of the calculator program (eg. for an input "3 + 4" provided via DIPs and PB, the value 7 in binary system will be printed on the LEDs).

(ii) ARM.vhd - Constitutes all the datapath connections, connecting outputs from one module as inputs to another module.

(iii) Decoder.vhd - Based on the value of Destination Register (Rd), Instruction Type (Op) and Funct, this module outputs values for various flags used by multiplexers and modules alike.

(iv) CondLogic.vhd - Sets values for PCSrc, RegWrite and MemWrite using values of PCS, RegW and MemW returned from Decoder module. Also sets values for flags N, Z, C and V if needed.

(v) ALU.vhd - Performs four types of DP operations, namely ADD, SUB, AND and ORR.

(vi) Extend.vhd - Based on the type of instruction being executed (Memory, DP, or Branch), this module extends the immediate value provided as input (if any) to a 32-bit value, which is needed for further processing.

(vii) ProgramCounter.vhd - Controls the value of the PC and returns the address of next instruction.

(viii) RegFile.vhd - Based on input values A1 and A2 for source registers, it outputs the values stored in the same registers. Also, if write is enabled, it writes the given value to the destination register, denoted by register number given in A3.

(ix) Shifter.vhd - Performs four types of shifts on the input (the second operand), namely LSL, LSR, ASR and ROR, by the given shift amount.

(x) uart.vhd - Performs sending/receiving messages to/from UART.

2. Simulation Sources:

N.B.: We have added tests for even those modules which were provided to us (TOP, ALU, Extend, ProgramCounter, RegFile and Shifter) because we believe that changes made to these modules in Lab 3 and Lab 4 could potentially cause some existing features to stop functioning. As such, it will be useful to run these tests again after these labs to look for such fails, if any.

(i) test_top.vhd - Tests for TOP.vhd module

(ii) test_arm.vhd - Tests for ARM.vhd module

(iii) test_decoder.vhd - Tests for Decoder.vhd module

(iv) test_condlogic.vhd - Tests for CondLogic.vhd module

(v) test_alu.vhd - Tests for ALU.vhd module

(vi) test_extend.vhd - Tests for Extend.vhd module

(vii) test_programcounter.vhd - Tests for ProgramCounter.vhd module

(viii) test_regfile.vhd - Tests for RegFile.vhd module

(ix) test_shifter.vhd - Tests for Shifter.vhd module

3. Nexys4_Master.xdc - XDC file mapping peripherals from Nexys 4 FPGA to the design sources.

4. Calculator.s - Assembly code demonstrating various instructions implemented in Lab 2 for Memory, Data Processing and Branch Instruction Types. This software implements a calculator that is capable of performing addition and subtraction of two numbers.

5. TOP.bit - Bitstream file generated for programming Nexys 4 FPGA.