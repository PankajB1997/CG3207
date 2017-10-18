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
    signal topBit1 : std_logic;
    signal topBit2 : std_logic;
    signal sumTopBits : std_logic;
    signal sum : std_logic_vector(width downto 0);
    signal diff : std_logic_vector(width downto 0);
    signal srcA : std_logic_vector(width downto 0);
    signal srcB : std_logic_vector(width downto 0);
    signal doAddition : std_logic;
    signal opResult : std_logic_vector(width downto 0);
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

    sumTopBits <= topBit1 xor topBit2 xor ALUCarryFlag;
    sum <= srcA + srcB;
    diff <= srcA - srcB;
    opResult <= sum when doAddition = '1' else diff;

    computing_process : process (CLK) -- process which does the actual computation
        variable count : std_logic_vector(7 downto 0) := (others => '0'); -- assuming no computation takes more than 256 cycles.
        variable multiplicand : std_logic_vector(width - 1 downto 0) := (others => '0');
        variable shifted_multiplier : std_logic_vector(2 * width - 1 downto 0) := (others => '0');
        variable booth_shifted_multiplier : std_logic_vector(2 * width downto 0) := (others => '0');
        variable shifted_out_bit : std_logic := '0';
        variable shifted_dividend : std_logic_vector(2 * width downto 0) := (others => '0');
        variable divisor : std_logic_vector(width - 1 downto 0) := (others => '0');
    begin
        if (CLK'event and CLK = '1') then
            -- n_state = COMPUTING and state = IDLE implies we are just transitioning into COMPUTING
            if RESET = '1' or (n_state = COMPUTING and state = IDLE) then
                count := (others => '0');
                multiplicand := Operand1;
                shifted_multiplier := (2 * width - 1 downto width => '0') & Operand2;
                booth_shifted_multiplier := (2 * width downto width => '0') & Operand2;
                shifted_out_bit := '0';
                shifted_dividend := (2 * width downto width + 1 => '0') & Operand1 & '0';
                divisor := Operand2;
            end if;

            done <= '0';
            if MCycleOp(1) = '0' then -- Multiply
                -- MCycleOp(0) = '0' takes 'width + 5' cycles to execute, returns signed(Operand1) * signed(Operand2)
                -- MCycleOp(0) = '1' takes 'width + 1' cycles to execute, returns unsigned(Operand1) * unsigned(Operand2)
                if MCycleOp(0) = '1' then -- Unsigned multiplication
                    if count /= 0 then
                        shifted_multiplier := ALUCarryFlag & ALUResult & shifted_multiplier(width - 1 downto 1);
                    end if;
                    Result2 <= shifted_multiplier(2 * width - 1 downto width);
                    Result1 <= shifted_multiplier(width - 1 downto 0);

                    ALUControl <= "00";
                    ALUSrc1 <= shifted_multiplier(2 * width - 1 downto width);
                    if shifted_multiplier(0) = '1' then -- add only if b0 = 1
                        ALUSrc2 <= multiplicand;
                    else
                        ALUSrc2 <= (others => '0');
                    end if;
                else
                    if count /= 0 then
                        booth_shifted_multiplier := opResult & booth_shifted_multiplier(width - 1 downto 0);
                        shifted_out_bit := booth_shifted_multiplier(0);
                        booth_shifted_multiplier := booth_shifted_multiplier(2 * width) & booth_shifted_multiplier(2 * width downto 1);
                    end if;
                    
                    
                    if ((not booth_shifted_multiplier(0)) and shifted_out_bit) = '1' then
                        -- Add
                        srcA <= booth_shifted_multiplier(2 * width downto width);
                        srcB <= Operand1(width - 1) & Operand1;
                        doAddition <= '1';
                    elsif (booth_shifted_multiplier(0) and (not shifted_out_bit)) = '1' then
                        -- Subtract
                        srcA <= booth_shifted_multiplier(2 * width downto width);
                        srcB <= Operand1(width - 1) & Operand1;
                        doAddition <= '0';
                    else
                        srcA <= booth_shifted_multiplier(2 * width downto width);
                        srcB <= (others => '0');
                        doAddition <= '1';
                    end if;

                    Result2 <= booth_shifted_multiplier(2 * width - 1 downto width);
                    Result1 <= booth_shifted_multiplier(width - 1 downto 0);
                end if;

            else -- Divide
                -- MCycleOp(0) = '0' takes 'width + 5' cycles to execute, returns signed(Operand1)/signed(Operand2)
                -- MCycleOp(0) = '1' takes 'width + 1' cycles to execute, returns unsigned(Operand1)/unsigned(Operand2)
                if MCycleOp(0) = '1' then -- Unsigned Division
                    if count /= 0 then
                        -- ALUCarryFlag is complement of Borrow
                        if ALUCarryFlag = '1' then
                            -- store subtracted result only if it is positive
                            shifted_dividend := ALUResult & shifted_dividend(width - 1 downto 0) & '1';
                        else
                            shifted_dividend := shifted_dividend(2 * width - 1 downto 0) & '0';
                        end if;
                    end if;

                    Result2 <= shifted_dividend(2 * width downto width + 1);
                    Result1 <= shifted_dividend(width - 1 downto 0);
                    ALUSrc1 <= shifted_dividend(2 * width - 1 downto width);
                    ALUSrc2 <= divisor;
                    ALUControl <= "01";
                else -- Signed Division
                    if count = 0 then
                        -- negate the dividend if it is negative
                        ALUSrc1 <= (width - 1 downto 0 => '0');
                        ALUSrc2 <= Operand1;
                        if Operand1(width - 1) = '1' then
                            ALUControl <= "01";
                        else
                            ALUControl <= "00";
                        end if;
                    elsif count = 1 then
                        -- store negated dividend from previous step and negate the divisor if it is negative
                        shifted_dividend := (2 * width downto width + 1 => '0') & ALUResult & '0';

                        ALUSrc1 <= (width - 1 downto 0 => '0');
                        ALUSrc2 <= Operand2;
                        if Operand2(width - 1) = '1' then
                            ALUControl <= "01";
                        else
                            ALUControl <= "00";
                        end if;
                    elsif count = 2 then
                        -- store negated divisor from previous step and start division process
                        divisor := ALUResult;

                        ALUSrc1 <= shifted_dividend(2 * width - 1 downto width);
                        ALUSrc2 <= divisor;
                        ALUControl <= "01";
                    elsif count = width + 2 then
                        -- modify shifted dividend based on ALUResult and ALUCarryFlag and negate the quotient if it is negative
                        if ALUCarryFlag = '1' then
                            shifted_dividend := ALUResult & shifted_dividend(width - 1 downto 0) & '1';
                        else
                            shifted_dividend := shifted_dividend(2 * width - 1 downto 0) & '0';
                        end if;

                        ALUSrc1 <= (width - 1 downto 0 => '0');
                        -- if quotient will be negative, negate the current value, else keep it unchanged
                        if (Operand1(width - 1) xor Operand2(width - 1)) = '1' then
                            ALUSrc2 <= shifted_dividend(2 * width downto width + 1);
                            ALUControl <= "01";
                        else
                            ALUSrc2 <= shifted_dividend(2 * width downto width + 1);
                            ALUControl <= "00";
                        end if;
                    elsif count = width + 3 then
                        -- store modified/unmodified quotient from previous step in Result2 and negate the remainder if it is negative
                        Result2 <= ALUResult;

                        ALUSrc1 <= (width - 1 downto 0 => '0');
                        -- if remainder will be negative, negate the current value, else keep it unchanged
                        if (Operand1(width - 1) xor Operand2(width - 1)) = '1' then
                            ALUSrc2 <= shifted_dividend(width - 1 downto 0);
                            ALUControl <= "01";
                        else
                            ALUSrc2 <= shifted_dividend(width - 1 downto 0);
                            ALUControl <= "00";
                        end if;
                    elsif count = width + 4 then
                        -- store modified/unmodified remainder from previous step in Result1
                        Result1 <= ALUResult;
                    else -- perform division
                        if ALUCarryFlag = '1' then -- store subtracted result only if it is positive
                            shifted_dividend := ALUResult & shifted_dividend(width - 1 downto 0) & '1';
                        else
                            shifted_dividend := shifted_dividend(2 * width - 1 downto 0) & '0';
                        end if;

                        ALUSrc1 <= shifted_dividend(2 * width - 1 downto width);
                        ALUSrc2 <= divisor;
                        ALUControl <= "01";
                    end if;
                end if;
            end if;

            -- regardless of multiplication or division, check if last cycle is reached
            if (McycleOp(1) = '0' and MCycleOp(0) = '0' and count = width) or
               (McycleOp(1) = '1' and MCycleOp(0) = '0' and count = width + 4) or
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
