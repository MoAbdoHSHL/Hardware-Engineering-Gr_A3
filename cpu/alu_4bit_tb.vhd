entity alu_tb is
end entity;

architecture test of alu_tb is

    signal a      : bit_vector(3 downto 0);
    signal b      : bit_vector(3 downto 0);
    signal op     : bit_vector(1 downto 0);
    signal result : bit_vector(7 downto 0);
    signal carry  : bit;

begin

    DUT : entity work.alu
        port map(
            a      => a,
            b      => b,
            op     => op,
            result => result,
            carry  => carry
        );

    process
    begin

        -- ADD: 3 + 2 = 5
        a <= "0011";
        b <= "0010";
        op <= "00";
        wait for 10 ns;
        assert result = "00000101"
            report "Failed ADD: 3 + 2"
            severity error;

        -- ADD: 15 + 1 = 16
        a <= "1111";
        b <= "0001";
        op <= "00";
        wait for 10 ns;
        assert result(3 downto 0) = "0000" and carry = '1'
            report "Failed ADD: 15 + 1"
            severity error;

        -- SUB: 5 - 2 = 3
        a <= "0101";
        b <= "0010";
        op <= "01";
        wait for 10 ns;
        assert result = "00000011"
            report "Failed SUB: 5 - 2"
            severity error;

        -- SUB: 2 - 3 = -1 in 4-bit two's complement = 1111
        a <= "0010";
        b <= "0011";
        op <= "01";
        wait for 10 ns;
        assert result(3 downto 0) = "1111"
            report "Failed SUB: 2 - 3"
            severity error;

        -- MUL: 3 x 5 = 15
        a <= "0011";
        b <= "0101";
        op <= "10";
        wait for 10 ns;
        assert result = "00001111"
            report "Failed MUL: 3 x 5"
            severity error;

        -- MUL: 15 x 15 = 225
        a <= "1111";
        b <= "1111";
        op <= "10";
        wait for 10 ns;
        assert result = "11100001"
            report "Failed MUL: 15 x 15"
            severity error;

        -- DIV placeholder
        a <= "1000";
        b <= "0010";
        op <= "11";
        wait for 10 ns;
        assert result = "00000000"
            report "Failed DIV placeholder"
            severity error;

        report "All ALU tests passed."
            severity note;

        wait;
    end process;

end architecture;
