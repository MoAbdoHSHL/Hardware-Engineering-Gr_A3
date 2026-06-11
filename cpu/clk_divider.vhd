entity clk_divider is
    port(
        CLK   : in  bit;
        RESET : in  bit;
        CLK_N : out bit
    );
end entity;

architecture behavior of clk_divider is
    signal count : bit_vector(2 downto 0) := "000";
    signal clk_temp : bit := '0';
begin

    process(CLK, RESET)
    begin
        if RESET = '1' then
            count <= "000";
            clk_temp <= '0';

        elsif CLK'event and CLK = '1' then
            case count is
                when "000" => count <= "001";
                when "001" => count <= "010";
                when "010" => count <= "011";
                when "011" =>
                    count <= "000";
                    clk_temp <= not clk_temp;

                when others =>
                    count <= "000";
            end case;
        end if;
    end process;

    CLK_N <= clk_temp;

end architecture;
