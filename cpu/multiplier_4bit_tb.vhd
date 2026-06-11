entity multiplier_tb is
end entity;

architecture test of multiplier_tb is

    signal a : bit_vector(3 downto 0);
    signal b : bit_vector(3 downto 0);
    signal p : bit_vector(7 downto 0);

begin

    DUT : entity work.multiplier
        port map(
            a => a,
            b => b,
            p => p
        );

    process
    begin
        -- 0 x 0 = 0
        a <= "0000";
        b <= "0000";
        wait for 10 ns;
        assert p = "00000000"
            report "Failed: 0 x 0"
            severity error;

        -- 3 x 2 = 6
        a <= "0011";
        b <= "0010";
        wait for 10 ns;
        assert p = "00000110"
            report "Failed: 3 x 2"
            severity error;

        -- 3 x 5 = 15
        a <= "0011";
        b <= "0101";
        wait for 10 ns;
        assert p = "00001111"
            report "Failed: 3 x 5"
            severity error;

        -- 7 x 3 = 21
        a <= "0111";
        b <= "0011";
        wait for 10 ns;
        assert p = "00010101"
            report "Failed: 7 x 3"
            severity error;

        -- 15 x 15 = 225
        a <= "1111";
        b <= "1111";
        wait for 10 ns;
        assert p = "11100001"
            report "Failed: 15 x 15"
            severity error;

        report "All multiplier tests passed."
            severity note;

        wait;
    end process;

end architecture;
