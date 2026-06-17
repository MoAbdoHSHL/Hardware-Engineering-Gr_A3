entity Two_Digit_Counter is
    port (
        CLK100MHZ : in  bit;
        sw        : in  bit_vector(1 downto 0);
        seg       : out bit_vector(6 downto 0);
        an        : out bit_vector(7 downto 0);
        dp        : out bit
    );
end entity Two_Digit_Counter;

architecture behavior of Two_Digit_Counter is

    signal clk_1hz  : bit;
    signal clk_mux  : bit;
    signal cnt_u    : integer := 0;
    signal cnt_t    : integer := 0;
    signal mux_sel  : bit := '0';

begin

    DIV1 : entity work.clk_divider
        generic map (N => 100000000)
        port map (
            CLK   => CLK100MHZ,
            RST   => sw(1),
            CLK_N => clk_1hz
        );

    DIV2 : entity work.clk_divider
        generic map (N => 1000)
        port map (
            CLK   => CLK100MHZ,
            RST   => sw(1),
            CLK_N => clk_mux
        );

    process (clk_1hz)
    begin
        if (clk_1hz'event and clk_1hz = '1') then
            if sw(1) = '1' then
                cnt_u <= 0;
                cnt_t <= 0;
            elsif sw(0) = '1' then
                if cnt_u = 9 then
                    cnt_u <= 0;
                    if cnt_t = 9 then
                        cnt_t <= 0;
                    else
                        cnt_t <= cnt_t + 1;
                    end if;
                else
                    cnt_u <= cnt_u + 1;
                end if;
            end if;
        end if;
    end process;

    process (clk_mux)
    begin
        if (clk_mux'event and clk_mux = '1') then
            mux_sel <= not mux_sel;
        end if;
    end process;

    process (mux_sel, cnt_u, cnt_t)
        variable dig : integer := 0;
    begin
        if mux_sel = '0' then
            dig := cnt_u;
            an  <= "11111110";
        else
            dig := cnt_t;
            an  <= "11111101";
        end if;

        case dig is
            when 0 => seg <= "1000000";
            when 1 => seg <= "1111001";
            when 2 => seg <= "0100100";
            when 3 => seg <= "0110000";
            when 4 => seg <= "0011001";
            when 5 => seg <= "0010010";
            when 6 => seg <= "0000010";
            when 7 => seg <= "1111000";
            when 8 => seg <= "0000000";
            when 9 => seg <= "0010000";
            when others => seg <= "1111111";
        end case;
    end process;

    dp <= '1';

end architecture behavior;