
entity reg_tb is
end entity;

architecture test of reg_tb is

    signal clk : bit := '0';
    signal rst : bit := '0';
    signal en  : bit := '0';

    signal d : bit_vector(7 downto 0);
    signal q : bit_vector(7 downto 0);

begin

    DUT : entity work.result_register
    port map(
        clk => clk,
        rst => rst,
        en  => en,
        d   => d,
        q   => q
    );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;

            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    stim_process : process
    begin

        -- Reset
        rst <= '1';
        wait for 20 ns;

        rst <= '0';

        -- Store first value
        en <= '1';
        d <= "10101010";
        wait for 20 ns;

        -- Store second value
        d <= "11110000";
        wait for 20 ns;

        -- Disable writing
        en <= '0';
        d <= "00000000";
        wait for 20 ns;

        wait;
    end process;

end architecture;