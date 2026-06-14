entity divider_tb is
end entity;

architecture test of divider_tb is

    signal a : bit_vector(3 downto 0);
    signal b : bit_vector(3 downto 0);
    signal q : bit_vector(3 downto 0);
    signal r : bit_vector(3 downto 0);

begin

    DUT : entity work.divider
        port map(
            a => a,
            b => b,
            q => q
        );

    process
    begin
	-- 9 / 2 = 4 remainder 1
	a <= "1001";
	b <= "0010";
	wait for 10 ns;
	assert q = "0100" and r = "0001"
	    report "Failed: 9 / 2"
	    severity error;

	-- 15 / 3 = 5 remainder 0
	a <= "1111";
	b <= "0011";
	wait for 10 ns;
	assert q = "0101" and r = "0000"
	    report "Failed: 15 / 3"
	    severity error;

	-- 7 / 8 = 0 remainder 7
	a <= "0111";
	b <= "1000";
	wait for 10 ns;
	assert q = "0000" and r = "0111"
	    report "Failed: 7 / 8"
	    severity error;

	-- 15 / 4 = 3 remainder 3
	a <= "1111";
	b <= "0100";
	wait for 10 ns;
	assert q = "0011" and r = "0011"
	    report "Failed: 15 / 4"
	    severity error;

        report "All divider tests passed."
            severity note;

        wait;
    end process;

end architecture;