entity CR_add_sub_tb is
end entity;

architecture Structure of CR_add_sub_tb is

    component CR_add_sub is
        port(
            a    : in  bit_vector(3 downto 0);
            b    : in  bit_vector(3 downto 0);
            mode : in  bit;
            s    : out bit_vector(3 downto 0);
            co   : out bit
        );
    end component;

    signal a_tb    : bit_vector(3 downto 0) := "0000";
    signal b_tb    : bit_vector(3 downto 0) := "0000";
    signal mode_tb : bit := '0';
    signal s_tb    : bit_vector(3 downto 0);
    signal co_tb   : bit;

begin

    UUT: CR_add_sub
        port map(
            a    => a_tb,
            b    => b_tb,
            mode => mode_tb,
            s    => s_tb,
            co   => co_tb
        );

    stim_proc: process
    begin

        -- ADDITION TESTS (mode=0)
        -- 0+0 = 0000, co=0
        a_tb <= "0000"; b_tb <= "0000"; mode_tb <= '0'; wait for 20 ns;

        -- 3+1 = 0100, co=0
        a_tb <= "0011"; b_tb <= "0001"; mode_tb <= '0'; wait for 20 ns;

        -- 7+8 = 1111, co=0
        a_tb <= "0111"; b_tb <= "1000"; mode_tb <= '0'; wait for 20 ns;

        -- 15+1 = 0000, co=1 (overflow)
        a_tb <= "1111"; b_tb <= "0001"; mode_tb <= '0'; wait for 20 ns;

        -- 10+5 = 1111, co=0
        a_tb <= "1010"; b_tb <= "0101"; mode_tb <= '0'; wait for 20 ns;

        -- SUBTRACTION TESTS (mode=1)
        -- 5-3 = 0010, co=1
        a_tb <= "0101"; b_tb <= "0011"; mode_tb <= '1'; wait for 20 ns;

        -- 8-1 = 0111, co=1
        a_tb <= "1000"; b_tb <= "0001"; mode_tb <= '1'; wait for 20 ns;

        -- 15-5 = 1010, co=1
        a_tb <= "1111"; b_tb <= "0101"; mode_tb <= '1'; wait for 20 ns;

        -- 0-1 = 1111, co=0 (borrow/underflow)
        a_tb <= "0000"; b_tb <= "0001"; mode_tb <= '1'; wait for 20 ns;

        -- 7-7 = 0000, co=1
        a_tb <= "0111"; b_tb <= "0111"; mode_tb <= '1'; wait for 20 ns;

        wait;
    end process;

end architecture;
