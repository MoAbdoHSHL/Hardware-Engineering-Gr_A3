
entity clk_divider_tb is
end entity;

architecture test of clk_divider_tb is

    signal CLK   : bit := '0';
    signal RESET : bit := '1';
    signal CLK_N : bit;

begin

    uut: entity work.clk_divider
        port map(
            CLK   => CLK,
            RESET => RESET,
            CLK_N => CLK_N
        );

    -- Main clock generator
    clk_process: process
    begin
        while true loop
            CLK <= '0';
            wait for 5 ns;
            CLK <= '1';
            wait for 5 ns;
        end loop;
    end process;

    -- Test process
    stim_process: process
    begin
        RESET <= '1';
        wait for 20 ns;

        RESET <= '0';
        wait for 200 ns;

        wait;
    end process;

end architecture;