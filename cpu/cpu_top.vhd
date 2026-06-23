entity cpu_top is
    port(
        clk      : in  bit;
        btn_exec : in  bit;
        btn_rst  : in  bit;

        sw       : in  bit_vector(9 downto 0);

        led      : out bit_vector(7 downto 0);
        seg      : out bit_vector(6 downto 0);
        dp       : out bit;
        an       : out bit_vector(7 downto 0)
    );
end entity;

architecture structure of cpu_top is

    component alu is
        port(
            clk       : in  bit;
            rst       : in  bit;
            start     : in  bit;

            a         : in  bit_vector(7 downto 0);
            b         : in  bit_vector(7 downto 0);
            op        : in  bit_vector(1 downto 0);

            result    : out bit_vector(7 downto 0);
            remainder : out bit_vector(7 downto 0);

            carry     : out bit;
            overflow  : out bit;
            div_zero  : out bit;

            busy      : out bit;
            done      : out bit
        );
    end component;

    component seven_segment_decoder is
        port(
            bin : in  bit_vector(3 downto 0);
            seg : out bit_vector(6 downto 0)
        );
    end component;

    component binary_to_bcd is
        port(
            bin      : in  bit_vector(7 downto 0);
            hundreds : out bit_vector(3 downto 0);
            tens     : out bit_vector(3 downto 0);
            ones     : out bit_vector(3 downto 0);
            overflow : out bit
        );
    end component;

    type register_array is array (0 to 3) of bit_vector(7 downto 0);
    type cpu_state_type is (CPU_IDLE, CPU_WAIT_ALU);

    signal cpu_state : cpu_state_type := CPU_IDLE;

    signal reg_file : register_array := (
        "00000000",
        "00000000",
        "00000000",
        "00000000"
    );

    signal mode_select : bit;

    signal load_positive : bit_vector(7 downto 0);
    signal load_value    : bit_vector(7 downto 0);

    signal view_value  : bit_vector(7 downto 0);
    signal src_a_value : bit_vector(7 downto 0);
    signal src_b_value : bit_vector(7 downto 0);

    signal alu_a_reg  : bit_vector(7 downto 0) := "00000000";
    signal alu_b_reg  : bit_vector(7 downto 0) := "00000000";
    signal alu_op_reg : bit_vector(1 downto 0) := "00";

    signal op_in : bit_vector(1 downto 0);

    signal alu_start     : bit := '0';
    signal alu_result    : bit_vector(7 downto 0);
    signal alu_remainder : bit_vector(7 downto 0);
    signal carry_temp    : bit;
    signal overflow_temp : bit;
    signal div_zero_temp : bit;
    signal alu_busy      : bit;
    signal alu_done      : bit;

    signal pending_dest : bit_vector(1 downto 0) := "00";

    signal stored_op      : bit_vector(1 downto 0) := "00";
    signal last_dest      : bit_vector(1 downto 0) := "00";
    signal last_remainder : bit_vector(7 downto 0) := "00000000";
    signal last_overflow  : bit := '0';
    signal last_div_zero  : bit := '0';

    signal display_value    : bit_vector(7 downto 0);
    signal display_negative : bit;

    signal rem_display_value : bit_vector(7 downto 0);
    signal rem_negative      : bit;

    signal bcd_hundreds : bit_vector(3 downto 0);
    signal bcd_tens     : bit_vector(3 downto 0);
    signal bcd_ones     : bit_vector(3 downto 0);
    signal bcd_overflow : bit;

    signal rem_hundreds : bit_vector(3 downto 0);
    signal rem_tens     : bit_vector(3 downto 0);
    signal rem_ones     : bit_vector(3 downto 0);
    signal rem_overflow : bit;

    signal seg_ones     : bit_vector(6 downto 0);
    signal seg_tens     : bit_vector(6 downto 0);
    signal seg_hundreds : bit_vector(6 downto 0);

    signal seg_rem_ones : bit_vector(6 downto 0);

    signal display_select  : bit_vector(1 downto 0) := "00";
    signal refresh_counter : integer range 0 to 49999 := 0;

    signal btn_prev : bit := '0';

    signal display_error    : bit;
    signal div_display_mode : bit;

    constant SEG_BLANK : bit_vector(6 downto 0) := "1111111";
    constant SEG_MINUS : bit_vector(6 downto 0) := "0111111";
    constant SEG_O     : bit_vector(6 downto 0) := "1000000";
    constant SEG_F     : bit_vector(6 downto 0) := "0001110";

    function add8_ci(x  : bit_vector(7 downto 0);
                     y  : bit_vector(7 downto 0);
                     ci : bit) return bit_vector is
        variable result : bit_vector(7 downto 0);
        variable c      : bit;
    begin
        c := ci;

        for i in 0 to 7 loop
            result(i) := x(i) xor y(i) xor c;
            c := (x(i) and y(i)) or (x(i) and c) or (y(i) and c);
        end loop;

        return result;
    end function;

    function twos_comp8(x : bit_vector(7 downto 0)) return bit_vector is
        variable inv : bit_vector(7 downto 0);
    begin
        for i in 0 to 7 loop
            inv(i) := not x(i);
        end loop;

        return add8_ci(inv, "00000001", '0');
    end function;

begin

    mode_select <= sw(8);

    -- LOAD MODE:
    -- SW7 = sign: 0 positive, 1 negative
    -- SW3..0 = magnitude
    load_positive <= "0000" & sw(3 downto 0);

    load_value <= load_positive when sw(7) = '0' else
                  twos_comp8(load_positive);

    -- EXECUTE MODE:
    -- SW7..6 = operation
    -- 00 ADD, 01 SUB, 10 MUL, 11 DIV
    op_in <= sw(7 downto 6);

    process(sw, reg_file)
    begin
        case sw(1 downto 0) is
            when "00"   => src_a_value <= reg_file(0);
            when "01"   => src_a_value <= reg_file(1);
            when "10"   => src_a_value <= reg_file(2);
            when others => src_a_value <= reg_file(3);
        end case;
    end process;

    process(sw, reg_file)
    begin
        case sw(3 downto 2) is
            when "00"   => src_b_value <= reg_file(0);
            when "01"   => src_b_value <= reg_file(1);
            when "10"   => src_b_value <= reg_file(2);
            when others => src_b_value <= reg_file(3);
        end case;
    end process;

    ALU_UNIT : alu
        port map(
            clk       => clk,
            rst       => btn_rst,
            start     => alu_start,

            a         => alu_a_reg,
            b         => alu_b_reg,
            op        => alu_op_reg,

            result    => alu_result,
            remainder => alu_remainder,

            carry     => carry_temp,
            overflow  => overflow_temp,
            div_zero  => div_zero_temp,

            busy      => alu_busy,
            done      => alu_done
        );

    process(clk, btn_rst)
    begin
        if btn_rst = '1' then

            reg_file(0) <= "00000000";
            reg_file(1) <= "00000000";
            reg_file(2) <= "00000000";
            reg_file(3) <= "00000000";

            alu_a_reg  <= "00000000";
            alu_b_reg  <= "00000000";
            alu_op_reg <= "00";

            alu_start    <= '0';
            pending_dest <= "00";
            cpu_state    <= CPU_IDLE;
            btn_prev     <= '0';

            stored_op      <= "00";
            last_dest      <= "00";
            last_remainder <= "00000000";
            last_overflow  <= '0';
            last_div_zero  <= '0';

        elsif clk'event and clk = '1' then

            alu_start <= '0';

            case cpu_state is

                when CPU_IDLE =>

                    if btn_exec = '1' and btn_prev = '0' then

                        if mode_select = '0' then

                            case sw(5 downto 4) is
                                when "00"   => reg_file(0) <= load_value;
                                when "01"   => reg_file(1) <= load_value;
                                when "10"   => reg_file(2) <= load_value;
                                when others => reg_file(3) <= load_value;
                            end case;

                            stored_op      <= "00";
                            last_remainder <= "00000000";
                            last_overflow  <= '0';
                            last_div_zero  <= '0';
                            last_dest      <= sw(5 downto 4);

                        else

                            alu_a_reg    <= src_a_value;
                            alu_b_reg    <= src_b_value;
                            alu_op_reg   <= op_in;
                            pending_dest <= sw(5 downto 4);

                            alu_start <= '1';
                            cpu_state <= CPU_WAIT_ALU;

                        end if;

                    end if;

                when CPU_WAIT_ALU =>

                    if alu_done = '1' then

                        case pending_dest is
                            when "00"   => reg_file(0) <= alu_result;
                            when "01"   => reg_file(1) <= alu_result;
                            when "10"   => reg_file(2) <= alu_result;
                            when others => reg_file(3) <= alu_result;
                        end case;

                        stored_op      <= alu_op_reg;
                        last_dest      <= pending_dest;
                        last_remainder <= alu_remainder;
                        last_overflow  <= overflow_temp;
                        last_div_zero  <= div_zero_temp;

                        cpu_state <= CPU_IDLE;

                    end if;

            end case;

            btn_prev <= btn_exec;

        end if;
    end process;

    process(sw, reg_file)
    begin
        case sw(5 downto 4) is
            when "00"   => view_value <= reg_file(0);
            when "01"   => view_value <= reg_file(1);
            when "10"   => view_value <= reg_file(2);
            when others => view_value <= reg_file(3);
        end case;
    end process;

    -- Always signed display.
    display_negative <= '1' when view_value(7) = '1' else '0';

    display_value <= twos_comp8(view_value) when display_negative = '1' else
                     view_value;

    rem_negative <= '1' when last_remainder(7) = '1' else '0';

    rem_display_value <= twos_comp8(last_remainder) when rem_negative = '1' else
                         last_remainder;

    BCD_NORMAL : binary_to_bcd
        port map(
            bin      => display_value,
            hundreds => bcd_hundreds,
            tens     => bcd_tens,
            ones     => bcd_ones,
            overflow => bcd_overflow
        );

    BCD_REM : binary_to_bcd
        port map(
            bin      => rem_display_value,
            hundreds => rem_hundreds,
            tens     => rem_tens,
            ones     => rem_ones,
            overflow => rem_overflow
        );

    DEC_ONES : seven_segment_decoder
        port map(
            bin => bcd_ones,
            seg => seg_ones
        );

    DEC_TENS : seven_segment_decoder
        port map(
            bin => bcd_tens,
            seg => seg_tens
        );

    DEC_HUNDREDS : seven_segment_decoder
        port map(
            bin => bcd_hundreds,
            seg => seg_hundreds
        );

    DEC_REM_ONES : seven_segment_decoder
        port map(
            bin => rem_ones,
            seg => seg_rem_ones
        );

    div_display_mode <= '1' when mode_select = '1' and stored_op = "11" and sw(5 downto 4) = last_dest else
                        '0';

    display_error <= '1' when mode_select = '1' and sw(5 downto 4) = last_dest and
                              (last_overflow = '1' or last_div_zero = '1') else
                     '0';

    process(clk, btn_rst)
    begin
        if btn_rst = '1' then
            refresh_counter <= 0;
            display_select  <= "00";

        elsif clk'event and clk = '1' then
            if refresh_counter = 49999 then
                refresh_counter <= 0;

                case display_select is
                    when "00"   => display_select <= "01";
                    when "01"   => display_select <= "10";
                    when "10"   => display_select <= "11";
                    when others => display_select <= "00";
                end case;
            else
                refresh_counter <= refresh_counter + 1;
            end if;
        end if;
    end process;

    process(display_select, display_error, div_display_mode,
            seg_ones, seg_tens, seg_hundreds,
            bcd_tens, bcd_hundreds,
            display_negative,
            seg_rem_ones)
    begin

        -- Decimal point is active-low.
        dp <= '1';

        if display_error = '1' then

            -- Display OF
            case display_select is
                when "00" =>
                    seg <= SEG_F;
                    an  <= "11111110";
                    dp  <= '1';

                when "01" =>
                    seg <= SEG_O;
                    an  <= "11111101";
                    dp  <= '1';

                when others =>
                    seg <= SEG_BLANK;
                    an  <= "11111111";
                    dp  <= '1';
            end case;

        elsif div_display_mode = '1' then

            -- Division display:
            -- Positive examples:
            --   1.8
            --   12.3
            --
            -- Negative examples:
            --   -1.8
            --   -12.3
            --
            -- an[0] = remainder ones
            -- an[1] = quotient ones with decimal point
            -- an[2] = quotient tens OR minus for one-digit negative quotient
            -- an[3] = minus for two-digit negative quotient

            case display_select is

                when "00" =>
                    -- Remainder digit
                    seg <= seg_rem_ones;
                    an  <= "11111110";
                    dp  <= '1';

                when "01" =>
                    -- Quotient ones digit with decimal point ON
                    seg <= seg_ones;
                    an  <= "11111101";
                    dp  <= '0';

                when "10" =>
                    -- Quotient tens, or minus for -1.0 to -9.9
                    if bcd_tens = "0000" then
                        if display_negative = '1' then
                            seg <= SEG_MINUS;
                        else
                            seg <= SEG_BLANK;
                        end if;
                    else
                        seg <= seg_tens;
                    end if;

                    an <= "11111011";
                    dp <= '1';

                when others =>
                    -- Minus for -10.0 to -99.9
                    if display_negative = '1' and bcd_tens /= "0000" then
                        seg <= SEG_MINUS;
                    else
                        seg <= SEG_BLANK;
                    end if;

                    an <= "11110111";
                    dp <= '1';

            end case;

        else

            -- Normal signed display:
            -- +2    ->    2
            -- -2    ->   -2
            -- -15   ->  -15
            -- -128  -> -128
            --
            -- an[0] = ones
            -- an[1] = tens OR minus for -1 to -9
            -- an[2] = hundreds OR minus for -10 to -99
            -- an[3] = minus for -100 to -128

            case display_select is

                when "00" =>
                    -- Ones digit
                    seg <= seg_ones;
                    an  <= "11111110";
                    dp  <= '1';

                when "01" =>
                    -- Tens digit, or minus sign for -1 to -9
                    if bcd_hundreds = "0000" and bcd_tens = "0000" then
                        if display_negative = '1' then
                            seg <= SEG_MINUS;
                        else
                            seg <= SEG_BLANK;
                        end if;
                    else
                        seg <= seg_tens;
                    end if;

                    an <= "11111101";
                    dp <= '1';

                when "10" =>
                    -- Hundreds digit, or minus sign for -10 to -99
                    if bcd_hundreds = "0000" then
                        if display_negative = '1' and bcd_tens /= "0000" then
                            seg <= SEG_MINUS;
                        else
                            seg <= SEG_BLANK;
                        end if;
                    else
                        seg <= seg_hundreds;
                    end if;

                    an <= "11111011";
                    dp <= '1';

                when others =>
                    -- Minus sign for -100 to -128
                    if display_negative = '1' and bcd_hundreds /= "0000" then
                        seg <= SEG_MINUS;
                    else
                        seg <= SEG_BLANK;
                    end if;

                    an <= "11110111";
                    dp <= '1';

            end case;

        end if;
    end process;

    -- LEDs show switches for debugging.
    led <= sw(7 downto 0);

end architecture;