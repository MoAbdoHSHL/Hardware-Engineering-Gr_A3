entity program_counter_tb is
end entity;

architecture test of program_counter_tb is

    signal clk : bit := '0';
    signal rst : bit := '0';
    signal en  : bit := '0';
    signal pc  : bit_vector(3 downto 0);

begin

    DUT : entity work.program_counter
        port map(
            clk => clk,
            rst => rst,
            en  => en,
            pc  => pc
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
        -- Reset PC
        rst <= '1';
        en  <= '0';
        wait for 20 ns;

        rst <= '0';
        wait for 10 ns;

        assert pc = "0000"
            report "PC reset failed"
            severity error;

        -- Enable counting
        en <= '1';

        wait for 10 ns;
        assert pc = "0001"
            report "PC failed at 1"
            severity error;

        wait for 10 ns;
        assert pc = "0010"
            report "PC failed at 2"
            severity error;

        wait for 10 ns;
        assert pc = "0011"
            report "PC failed at 3"
            severity error;

        wait for 10 ns;
        assert pc = "0100"
            report "PC failed at 4"
            severity error;

        -- Disable counting, PC should hold
        en <= '0';
        wait for 20 ns;

        assert pc = "0100"
            report "PC did not hold when enable was 0"
            severity error;

        report "All program counter tests passed."
            severity note;

        wait;
    end process;

end architecture;