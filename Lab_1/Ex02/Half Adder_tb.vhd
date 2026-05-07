entity Half_Adder_tb is
end Half_Adder_tb;

architecture Structural of Half_Adder_tb is

    component Half_Adder
        Port (
            A : in  BIT;
            B : in  BIT;
            S : out BIT;
            C : out BIT
        );
    end component;

    signal A, B : BIT := '0';
    signal S, C : BIT;

begin
    DUT: Half_Adder port map(
        A => A,
        B => B,
        S => S,
        C => C
    );

    process
    begin
        A <= '0'; B <= '0'; wait for 10 ns;
        A <= '0'; B <= '1'; wait for 10 ns;
        A <= '1'; B <= '0'; wait for 10 ns;
        A <= '1'; B <= '1'; wait for 10 ns;
        wait;
    end process;

end Structural;