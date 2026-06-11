entity bcd_adder_tb is
end entity;

architecture test of bcd_adder_tb is

	signal a 	: bit_vector(3 downto 0);
	signal b 	: bit_vector(3 downto 0);
	signal cin 	: bit;
	signal sout 	: bit_vector(3 downto 0);
	signal co_bcd 	: bit;

begin

DUT : entity work.bcd_adder
	port map(
		a => a,
		b => b,
		cin => cin,
		sout => sout,
		co_bcd => co_bcd);

	process 
	begin

        -- 0 + 0 = 0
        a <= "0000";
        b <= "0000";
        cin <= '0';
        wait for 20 ns;

        -- 2 + 3 = 5
        a <= "0010";
        b <= "0011";
        cin <= '0';
        wait for 20 ns;

        -- 5 + 4 = 9
        a <= "0101";
        b <= "0100";
        cin <= '0';
        wait for 20 ns;

        -- 5 + 5 = 10
        -- Expected: sout = 0000, co_bcd = 1
        a <= "0101";
        b <= "0101";
        cin <= '0';
        wait for 20 ns;

        -- 7 + 8 = 15
        -- Expected: sout = 0101, co_bcd = 1
        a <= "0111";
        b <= "1000";
        cin <= '0';
        wait for 20 ns;

        -- 9 + 9 = 18
        -- Expected: sout = 1000, co_bcd = 1
        a <= "1001";
        b <= "1001";
        cin <= '0';
        wait for 20 ns;

        -- 9 + 0 + cin = 10
        -- Expected: sout = 0000, co_bcd = 1
        a <= "1001";
        b <= "0000";
        cin <= '1';
        wait for 20 ns;

        wait;

    end process;

end architecture;
	

