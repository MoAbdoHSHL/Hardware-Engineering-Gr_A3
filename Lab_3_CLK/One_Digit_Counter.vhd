entity One_Digit_Counter is
    port (
        CLK100MHZ : in  bit;
        sw        : in  bit_vector(1 downto 0);
        seg       : out bit_vector(6 downto 0);
        an        : out bit_vector(7 downto 0);
        dp        : out bit
    );
end entity One_Digit_Counter;

architecture behavior of One_Digit_Counter is

    signal clk_1hz : bit;
    signal count   : integer := 0;

begin

    DIV : entity work.clk_divider
        generic map (N => 100000000)
        port map (
            CLK   => CLK100MHZ,
            RST   => sw(1),
            CLK_N => clk_1hz
        );

    process (clk_1hz)
    begin
        if (clk_1hz'event and clk_1hz = '1') then
            if sw(1) = '1' then
                count <= 0;
            elsif sw(0) = '1' then
                if count = 9 then
                    count <= 0;
                else
                    count <= count + 1;
                end if;
            end if;
        end if;
    end process;

    process (count)
    begin
        case count is
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

    an <= "11111110";
    dp <= '1';

end architecture behavior;