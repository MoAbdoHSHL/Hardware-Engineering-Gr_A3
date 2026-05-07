entity Half_Subtractor_tb is
end Half_Subtractor_tb;

architecture Structural of Half_Subtractor_tb is

    component Half_Subtractor
        Port (
            A    : in  BIT;
            B    : in  BIT;
            Diff : out BIT;
            Bout : out BIT
        );
    end component;

    signal A, B  : BIT := '0';
    signal Diff  : BIT;
    signal Bout  : BIT;

begin
    DUT: Half_Subtractor port map(
        A    => A,
        B    => B,
        Diff => Diff,
        Bout => Bout
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
