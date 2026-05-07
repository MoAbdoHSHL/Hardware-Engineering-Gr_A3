entity Full_Subtractor_bhv_tb is
end Full_Subtractor_bhv_tb;

architecture Structural of Full_Subtractor_bhv_tb is

    component Full_Subtractor_bhv
        Port (
            A    : in  BIT;
            B    : in  BIT;
            Bin  : in  BIT;
            Diff : out BIT;
            Bout : out BIT
        );
    end component;

    signal A, B, Bin  : BIT := '0';
    signal Diff, Bout : BIT;

begin
    DUT: Full_Subtractor_bhv port map(
        A    => A,
        B    => B,
        Bin  => Bin,
        Diff => Diff,
        Bout => Bout
    );

    process
    begin
        A <= '0'; B <= '0'; Bin <= '0'; wait for 10 ns;
        A <= '0'; B <= '0'; Bin <= '1'; wait for 10 ns;
        A <= '0'; B <= '1'; Bin <= '0'; wait for 10 ns;
        A <= '0'; B <= '1'; Bin <= '1'; wait for 10 ns;
        A <= '1'; B <= '0'; Bin <= '0'; wait for 10 ns;
        A <= '1'; B <= '0'; Bin <= '1'; wait for 10 ns;
        A <= '1'; B <= '1'; Bin <= '0'; wait for 10 ns;
        A <= '1'; B <= '1'; Bin <= '1'; wait for 10 ns;
        wait;
    end process;

end Structural;
