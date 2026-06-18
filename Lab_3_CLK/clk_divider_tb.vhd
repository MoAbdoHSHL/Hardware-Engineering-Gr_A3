-- =============================================================================
-- Author      : Mohamed Abdo - Team A3
-- Date        : 10.06.2026
-- =============================================================================

entity clk_divider_tb is
end entity clk_divider_tb;

architecture sim of clk_divider_tb is

    constant CLK_PERIOD : time    := 10 ns;
    constant N_VAL      : integer := 4;

    signal clk_tb   : bit := '0';
    signal rst_tb   : bit := '1';
    signal clk_n_tb : bit;

begin

    DUT : entity work.clk_divider
        generic map (N => N_VAL)
        port map (
            CLK   => clk_tb,
            RST   => rst_tb,
            CLK_N => clk_n_tb
        );

    clk_gen : process
    begin
        clk_tb <= '0';
        wait for CLK_PERIOD / 2;
        clk_tb <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    stimulus : process
    begin
        rst_tb <= '1';
        wait for 5 * CLK_PERIOD;

        rst_tb <= '0';
        wait for 10 * N_VAL * CLK_PERIOD;

        rst_tb <= '1';
        wait for 3 * CLK_PERIOD;

        rst_tb <= '0';
        wait for 10 * N_VAL * CLK_PERIOD;

        wait;
    end process;

end architecture sim;