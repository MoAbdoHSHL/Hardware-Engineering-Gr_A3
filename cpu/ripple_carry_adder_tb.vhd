entity ripple_carry_adder_tb is
end entity;

architecture structure of ripple_carry_adder_tb is

    component ripple_carry_adder is
        port(
            a  : in  bit_vector(3 downto 0);
            b  : in  bit_vector(3 downto 0);
            ci : in  bit;
            s  : out bit_vector(3 downto 0);
            co : out bit
        );
    end component;

    signal a_tb  : bit_vector(3 downto 0) := "0000";
    signal b_tb  : bit_vector(3 downto 0) := "0000";
    signal ci_tb : bit := '0';
    signal s_tb  : bit_vector(3 downto 0);
    signal co_tb : bit;

begin

    UUT: ripple_carry_adder
        port map(
            a  => a_tb,
            b  => b_tb,
            ci => ci_tb,
            s  => s_tb,
            co => co_tb
        );

    stim_proc: process
    begin
        -- Test 1: 0000 + 0000 = 0000, co=0  (0+0=0)
        a_tb <= "0000"; b_tb <= "0000"; ci_tb <= '0'; wait for 20 ns;

        -- Test 2: 0001 + 0001 = 0010, co=0  (1+1=2)
        a_tb <= "0001"; b_tb <= "0001"; ci_tb <= '0'; wait for 20 ns;

        -- Test 3: 0011 + 0001 = 0100, co=0  (3+1=4)
        a_tb <= "0011"; b_tb <= "0001"; ci_tb <= '0'; wait for 20 ns;

        -- Test 4: 0111 + 0001 = 1000, co=0  (7+1=8)
        a_tb <= "0111"; b_tb <= "0001"; ci_tb <= '0'; wait for 20 ns;

        -- Test 5: 1111 + 0001 = 0000, co=1  (15+1=16 overflow!)
        a_tb <= "1111"; b_tb <= "0001"; ci_tb <= '0'; wait for 20 ns;

        -- Test 6: 1010 + 0101 = 1111, co=0  (10+5=15)
        a_tb <= "1010"; b_tb <= "0101"; ci_tb <= '0'; wait for 20 ns;

        -- Test 7: 1111 + 1111 = 1110, co=1  (15+15=30)
        a_tb <= "1111"; b_tb <= "1111"; ci_tb <= '0'; wait for 20 ns;

        -- Test 8: 1111 + 1111 + ci=1 = 1111, co=1  (15+15+1=31)
        a_tb <= "1111"; b_tb <= "1111"; ci_tb <= '1'; wait for 20 ns;

	-- Test 9: 1001 + 1001 + ci=0 = 0010, co=1 (9+9=18)
	a_tb <= "1001"; b_tb <= "1001"; ci_tb <= '0'; wait for 20 ns;

        wait;
    end process;

end architecture;