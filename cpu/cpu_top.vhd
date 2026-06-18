entity cpu_top is
    port(
        clk      : in  bit;
        btn_exec : in  bit;
        btn_rst  : in  bit;

        sw       : in  bit_vector(9 downto 0);

        led      : out bit_vector(7 downto 0);
        seg      : out bit_vector(6 downto 0);
        an       : out bit_vector(7 downto 0)
    );
end entity;

architecture structure of cpu_top is

    component alu is
        port(
            a      : in  bit_vector(3 downto 0);
            b      : in  bit_vector(3 downto 0);
            op     : in  bit_vector(1 downto 0);
            result : out bit_vector(7 downto 0);
            carry  : out bit
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

    signal reg_file : register_array := (
        "00000000",
        "00000000",
        "00000000",
        "00000000"
    );

    signal mode_select : bit;

    signal load_value  : bit_vector(7 downto 0);
    signal view_value  : bit_vector(7 downto 0);

    signal src_a_value : bit_vector(7 downto 0);
    signal src_b_value : bit_vector(7 downto 0);

    signal a_in        : bit_vector(3 downto 0);
    signal b_in        : bit_vector(3 downto 0);
    signal op_in       : bit_vector(1 downto 0);

    signal alu_result  : bit_vector(7 downto 0);
    signal carry_temp  : bit;

    signal bcd_hundreds  : bit_vector(3 downto 0);
    signal bcd_tens      : bit_vector(3 downto 0);
    signal bcd_ones      : bit_vector(3 downto 0);
    signal overflow_flag : bit;

    signal seg_ones     : bit_vector(6 downto 0);
    signal seg_tens     : bit_vector(6 downto 0);
    signal seg_hundreds : bit_vector(6 downto 0);

    signal display_select  : bit_vector(1 downto 0) := "00";
    signal refresh_counter : integer range 0 to 49999 := 0;

begin

    mode_select <= sw(8);

    -- LOAD MODE:
    -- SW[3:0] = unsigned input value from 0 to 15
    -- Stored as an 8-bit value.
    load_value <= "0000" & sw(3 downto 0);

    -- EXECUTE MODE:
    -- SW[7:6] selects operation.
    -- 00 = ADD, 01 = SUB, 10 = MUL, 11 = DIV
    op_in <= sw(7 downto 6);

    -- Source register A selected by SW[1:0]
    process(sw, reg_file)
    begin
        case sw(1 downto 0) is
            when "00"   => src_a_value <= reg_file(0);
            when "01"   => src_a_value <= reg_file(1);
            when "10"   => src_a_value <= reg_file(2);
            when others => src_a_value <= reg_file(3);
        end case;
    end process;

    -- Source register B selected by SW[3:2]
    process(sw, reg_file)
    begin
        case sw(3 downto 2) is
            when "00"   => src_b_value <= reg_file(0);
            when "01"   => src_b_value <= reg_file(1);
            when "10"   => src_b_value <= reg_file(2);
            when others => src_b_value <= reg_file(3);
        end case;
    end process;

    -- Current ALU is still 4-bit.
    -- It only uses the lower 4 bits of each selected 8-bit register.
    a_in <= src_a_value(3 downto 0);
    b_in <= src_b_value(3 downto 0);

    ALU_UNIT : alu
        port map(
            a      => a_in,
            b      => b_in,
            op     => op_in,
            result => alu_result,
            carry  => carry_temp
        );

    -- Register write process
    process(clk, btn_rst)
    begin
        if btn_rst = '1' then

            reg_file(0) <= "00000000";
            reg_file(1) <= "00000000";
            reg_file(2) <= "00000000";
            reg_file(3) <= "00000000";

        elsif clk'event and clk = '1' then

            if btn_exec = '1' then

                if mode_select = '0' then

                    -- LOAD MODE:
                    -- SW[5:4] selects which register receives the manual input value.
                    case sw(5 downto 4) is
                        when "00"   => reg_file(0) <= load_value;
                        when "01"   => reg_file(1) <= load_value;
                        when "10"   => reg_file(2) <= load_value;
                        when others => reg_file(3) <= load_value;
                    end case;

                else

                    -- EXECUTE MODE:
                    -- SW[5:4] selects destination register for ALU result.
                    case sw(5 downto 4) is
                        when "00"   => reg_file(0) <= alu_result;
                        when "01"   => reg_file(1) <= alu_result;
                        when "10"   => reg_file(2) <= alu_result;
                        when others => reg_file(3) <= alu_result;
                    end case;

                end if;

            end if;

        end if;
    end process;

    -- Display selected register.
    -- In LOAD mode, SW[5:4] selects the register to view/load.
    -- In EXECUTE mode, SW[5:4] selects the destination register to view.
    process(sw, reg_file)
    begin
        case sw(5 downto 4) is
            when "00"   => view_value <= reg_file(0);
            when "01"   => view_value <= reg_file(1);
            when "10"   => view_value <= reg_file(2);
            when others => view_value <= reg_file(3);
        end case;
    end process;

    BCD_CONV : binary_to_bcd
        port map(
            bin      => view_value,
            hundreds => bcd_hundreds,
            tens     => bcd_tens,
            ones     => bcd_ones,
            overflow => overflow_flag
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

    -- Display refresh.
    -- display_select = 00 -> an[0] ones
    -- display_select = 01 -> an[1] tens
    -- display_select = 10 -> an[2] hundreds
    -- display_select = 11 -> an[3] blank for now
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

    -- Display output.
    -- an[0] = ones
    -- an[1] = tens
    -- an[2] = hundreds
    -- an[3] = blank for now
    process(display_select, seg_ones, seg_tens, seg_hundreds,
            bcd_tens, bcd_hundreds, overflow_flag)
    begin

        if overflow_flag = '1' then

            case display_select is

                when "00" =>
                    seg <= "0001110"; -- F
                    an  <= "11111110"; -- an[0]

                when "01" =>
                    seg <= "1000000"; -- O / 0 shape
                    an  <= "11111101"; -- an[1]

                when others =>
                    seg <= "1111111"; -- blank
                    an  <= "11111111"; -- all off

            end case;

        else

            case display_select is

                when "00" =>
                    -- Ones digit is always shown.
                    seg <= seg_ones;
                    an  <= "11111110"; -- an[0]

                when "01" =>
                    -- Tens digit is blank if hundreds = 0 and tens = 0.
                    if bcd_hundreds = "0000" and bcd_tens = "0000" then
                        seg <= "1111111"; -- blank
                    else
                        seg <= seg_tens;
                    end if;

                    an <= "11111101"; -- an[1]

                when "10" =>
                    -- Hundreds digit is blank if hundreds = 0.
                    if bcd_hundreds = "0000" then
                        seg <= "1111111"; -- blank
                    else
                        seg <= seg_hundreds;
                    end if;

                    an <= "11111011"; -- an[2]

                when others =>
                    -- Fourth digit is blank for now.
                    seg <= "1111111";
                    an  <= "11110111"; -- an[3]

            end case;

        end if;
    end process;

    -- Temporary LED debug mapping:
    -- LEDs directly show switch positions SW0 to SW7.
    -- SW8 is mode but is not shown yet.
    led <= sw(7 downto 0);

end architecture;