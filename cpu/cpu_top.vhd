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

    component result_register is
        port(
            clk : in  bit;
            rst : in  bit;
            en  : in  bit;
            d   : in  bit_vector(7 downto 0);
            q   : out bit_vector(7 downto 0)
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
            tens     : out bit_vector(3 downto 0);
            ones     : out bit_vector(3 downto 0);
            overflow : out bit
        );
    end component;

    signal a_in          : bit_vector(3 downto 0);
    signal b_in          : bit_vector(3 downto 0);
    signal op_in         : bit_vector(1 downto 0);

    signal alu_result    : bit_vector(7 downto 0);
    signal stored_result : bit_vector(7 downto 0);
    signal carry_temp    : bit;

    signal seg_low       : bit_vector(6 downto 0);
    signal seg_high      : bit_vector(6 downto 0);
    
    signal bcd_tens : bit_vector(3 downto 0);
    signal bcd_ones : bit_vector(3 downto 0);
    signal overflow_flag : bit;

    signal display_select : bit := '0';

    -- 100 MHz / 50000 = 2 kHz toggle rate
    -- each digit refreshes around 1 kHz
    signal refresh_counter : integer range 0 to 49999 := 0;

begin

    a_in  <= sw(3 downto 0);
    b_in  <= sw(7 downto 4);
    op_in <= sw(9 downto 8);

    ALU_UNIT : alu
        port map(
            a      => a_in,
            b      => b_in,
            op     => op_in,
            result => alu_result,
            carry  => carry_temp
        );

    RESULT_REG : result_register
        port map(
            clk => clk,
            rst => btn_rst,
            en  => btn_exec,
            d   => alu_result,
            q   => stored_result
        );

    DEC_LOW : seven_segment_decoder
        port map(
            bin => bcd_ones,
            seg => seg_low
        );

    DEC_HIGH : seven_segment_decoder
        port map(
            bin => bcd_tens,
            seg => seg_high
        );
     
    BCD_CONV : binary_to_bcd
        port map(
            bin      => stored_result,
            tens     => bcd_tens,
            ones     => bcd_ones,
            overflow => overflow_flag
        );

    -- proper 7-segment multiplexing clock divider
    process(clk, btn_rst)
    begin
        if btn_rst = '1' then
            refresh_counter <= 0;
            display_select  <= '0';

        elsif clk'event and clk = '1' then
            if refresh_counter = 49999 then
                refresh_counter <= 0;
                display_select  <= not display_select;
            else
                refresh_counter <= refresh_counter + 1;
            end if;
        end if;
    end process;

    -- choose which digit is active
    process(display_select, seg_low, seg_high, overflow_flag)
begin
    if overflow_flag = '1' then
        if display_select = '0' then
            seg <= "0001110"; -- F
            an  <= "11111110";
        else
            seg <= "1000000"; -- O / 0 shape
            an  <= "11111101";
        end if;
    else
        if display_select = '0' then
            seg <= seg_low;
            an  <= "11111110";
        else
            seg <= seg_high;
            an  <= "11111101";
        end if;
    end if;
end process;

    led <= stored_result;

end architecture;