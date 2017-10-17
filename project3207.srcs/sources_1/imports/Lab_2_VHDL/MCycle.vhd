----------------------------------------------------------------------------------
-- Company: NUS
-- Engineer: Rajesh Panicker
--
-- Create Date: 10/13/2015 06:49:10 PM
-- Module Name: ALU
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 (Artix 7 100T)
-- Tool Versions: Vivado 2015.2
-- Description: Multicycle Operations Module
--
-- Dependencies: NIL
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--    (c) Rajesh Panicker
--    License terms : --    You are free to use this code as long as you
--        (i) DO NOT post it on any public repository;
--        (ii) use it only for educational purposes;
--        (iii) accept the responsibility to ensure that your implementation does not violate any intellectual property of ARM Holdings or other entities.
--        (iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--        (v) send an email to rajesh.panicker@ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--        (vi) retain this notice in this file or any files derived from this.
----------------------------------------------------------------------------------

-- Assume that Operand1, Operand 2, MCycleOp will not change after Start is asserted until the next clock edge after Busy goes to '0'.
-- Start to be asserted by the control unit should assert this when an instruction with a multi-cycle operation is detected.
-- Start should be deasserted within 1 clock cycle after Busy goes low. Else, the MCycle unit will treat it as another operation.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MCycle is
generic (width : integer := 4); -- Keep this at 4 to verify your algorithms with 4 bit numbers (easier). When using MCycle as a component in ARM, generic map it to 32.
port (
    CLK : in std_logic;
    RESET : in std_logic;  -- Connect this to the reset of the ARM processor.
    Start : in std_logic;  -- Multi-cycle Enable. The control unit should assert this when an instruction with a multi-cycle operation is detected.
    MCycleOp : in std_logic_vector(1 downto 0); -- Multi-cycle Operation. "00" for signed multiplication, "01" for unsigned multiplication, "10" for signed division, "11" for unsigned division.
    Operand1 : in std_logic_vector(width - 1 downto 0); -- Multiplicand / Dividend
    Operand2 : in std_logic_vector(width - 1 downto 0); -- Multiplier / Divisor
    ALUResult : in std_logic_vector(width - 1 downto 0);
    ALUCarryFlag : in std_logic;
    ALUSrc1 : out std_logic_vector(width - 1 downto 0);
    ALUSrc2 : out std_logic_vector(width - 1 downto 0);
    ALUControl : out std_logic_vector(1 downto 0);
    Result1 : out std_logic_vector(width - 1 downto 0); -- LSW of Product / Quotient
    Result2 : out std_logic_vector(width - 1 downto 0); -- MSW of Product / Remainder
    Busy : out std_logic );  -- Set immediately when Start is set. Cleared when the Results become ready. This bit can be used to stall the processor while multi-cycle operations are on.
end MCycle;


architecture Arch_MCycle of MCycle is
    type states is (IDLE, COMPUTING);
    signal state, n_state : states := IDLE;
    signal done : std_logic;
begin

    idle_process : process (state, done, Start, RESET)
    begin

        -- <default outputs>
        Busy <= '0';
        n_state <= IDLE;

        --reset
        if RESET = '1' then
            n_state <= IDLE;
            --Busy <= '0';    --implicit
        else
            case state is
                when IDLE =>
                    if Start = '1' then
                        n_state <= COMPUTING;
                        Busy <= '1';
                    end if;
                when COMPUTING =>
                    if done = '1' then
                        n_state <= IDLE;
                        --Busy <= '0'; --implicit
                    else
                        n_state <= COMPUTING;
                        Busy <= '1';
                    end if;
            end case;
        end if;
    end process;

    computing_process : process (CLK) -- process which does the actual computation
        variable count : std_logic_vector(7 downto 0) := (others => '0'); -- assuming no computation takes more than 256 cycles.
        variable shifted_multiplier : std_logic_vector(width - 1 downto 0) := (others => '0');
        variable shifted_multiplicand : std_logic_vector(2 * width - 1 downto 0) := (others => '0');
        variable shifted_dividend : std_logic_vector(2 * width downto 0) := (others => '0');
        variable shifted_divisor : std_logic_vector(width downto 0) := (others => '0');
    begin
        if (CLK'event and CLK = '1') then
            -- n_state = COMPUTING and state = IDLE implies we are just transitioning into COMPUTING
            if RESET = '1' or (n_state = COMPUTING and state = IDLE) then
                count := (others => '0');
                shifted_multiplier := Operand1;
                shifted_multiplicand := (2 * width - 1 downto width => '0') & Operand2;
                shifted_dividend := (2 * width downto width + 1 => '0') & Operand1 & '0';
                divisor := Operand2;
            end if;
            done <= '0';

            if MCycleOp(1) = '0' then -- Multiply
                -- MCycleOp(0) = '0' takes 'width + 5' cycles to execute, returns signed(Operand1) * signed(Operand2)
                -- MCycleOp(0) = '1' takes 'width + 1' cycles to execute, returns unsigned(Operand1) * unsigned(Operand2)
                if MCycleOp(0) = '1' then
                  if count /= 0 then
                    shifted_multiplicand := sum & shifted_multiplicand(width - 1 downto 1);
                  end if;
                  Result2 <= shifted_multiplicand(2 * width - 1 downto width);
                  Result1 <= shifted_multiplicand(width - 1 downto 0);
                  srcA <= '0' & shifted_multiplicand(2 * width - 1 downto width);
                  if shifted_multiplicand(0) = '1' then -- add only if b0 = 1
                    srcB <= '0' & shifted_multiplier;
                  else
                    srcB <= (others => '0');
                  end if;
                  cIn <= (others => '0');
                else
                  if count = 0 then
                    srcA <= (others => '0');
                    cIn <= (width downto 1 => '0') & Operand1(width - 1);
                    if Operand1(width - 1) = '1' then
                      srcB <= not ('1' & Operand1);
                    else
                      srcB <= '0' & Operand1;
                    end if;
                  elsif count = 1 then
                    shifted_multiplier := sum(width - 1 downto 0);
                    srcA <= (others => '0');
                    cIn <= (width downto 1 => '0') & Operand2(width - 1);
                    if Operand2(width - 1) = '1' then
                      srcB <= not ('1' & Operand2);
                    else
                      srcB <= '0' & Operand2;
                    end if;
                  elsif count = 2 then
                    shifted_multiplicand := (2 * width - 1 downto width => '0') & sum(width - 1 downto 0);
                    srcA <= '0' & shifted_multiplicand(2 * width - 1 downto width);
                    if shifted_multiplicand(0) = '1' then -- add only if b0 = 1
                      srcB <= '0' & shifted_multiplier;
                    else
                      srcB <= (others => '0');
                    end if;
                    cIn <= (others => '0');
                  elsif count = width + 2 then
                    shifted_multiplicand := sum & shifted_multiplicand(width - 1 downto 1);
                    srcA <= (others => '0');
                    if (Operand1(width - 1) xor Operand2(width - 1)) = '1' then
                      srcB <= not ('1' & shifted_multiplicand(width - 1 downto 0));
                      cIn <= (width downto 1 => '0') & '1';
                    else
                      srcB <= '0' & shifted_multiplicand(width - 1 downto 0);
                      cIn <= (width downto 1 => '0') & '0';
                    end if;
                  elsif count = width + 3 then
                    Result1 <= sum(width - 1 downto 0);
                    srcA <= (others => '0');
                    if (Operand1(width - 1) xor Operand2(width - 1)) = '1' then
                      srcB <= not ('1' & shifted_multiplicand(2 * width - 1 downto width));
                      cIn <= (width downto 1 => '0') & sum(width);
                    else
                      srcB <= '0' & shifted_multiplicand(2 * width - 1 downto width);
                      cIn <= (others => '0');
                    end if;
                  elsif count = width + 4 then
                    Result2 <= sum(width - 1 downto 0);
                  else
                    shifted_multiplicand := sum & shifted_multiplicand(width - 1 downto 1);
                    srcA <= '0' & shifted_multiplicand(2 * width - 1 downto width);
                    if shifted_multiplicand(0) = '1' then -- add only if b0 = 1
                      srcB <= '0' & shifted_multiplier;
                    else
                      srcB <= (others => '0');
                    end if;
                    cIn <= (others => '0');
                  end if;
                end if;
            else -- Divide
                -- MCycleOp(0) = '0' takes 'width + 5' cycles to execute, returns signed(Operand1)/signed(Operand2)
                -- MCycleOp(0) = '1' takes 'width + 1' cycles to execute, returns unsigned(Operand1)/unsigned(Operand2)
                if count /= 0 then
                    if ALUCarryFlag = '1' then -- store subtracted result only if it is positive
                        shifted_dividend := ALUResult(width - 1 downto 0) & shifted_dividend(width - 1 downto 0) & '1';
                    else
                        shifted_dividend := shifted_dividend(2 * width - 1 downto 0) & '0';
                    end if;
                end if;
                Result2 <= shifted_dividend(2 * width downto width + 1);
                Result1 <= shifted_dividend(width - 1 downto 0);
                ALUControl <= "01";  -- Subtract
                ALUSrc1 <= shifted_dividend(2 * width - 1 downto width);
                ALUSrc2 <= divisor;
            end if;
            -- regardless of multiplication or division, check if last cycle is reached
            if (MCycleOp(0) = '0' and count = width + 4) or
               (MCycleOp(0) = '1' and count = width) then     -- If last cycle
                done <= '1';
            end if;
            count := count + 1;
        end if;
    end process;

    state_update_process : process (CLK) -- state updating
    begin
       if (CLK'event and CLK = '1') then
            state <= n_state;
       end if;
    end process;

end Arch_MCycle;
