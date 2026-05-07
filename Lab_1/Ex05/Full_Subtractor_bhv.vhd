entity Full_Subtractor_bhv is
    Port (
        A    : in  BIT;
        B    : in  BIT;
        Bin  : in  BIT;
        Diff : out BIT;
        Bout : out BIT
    );
end Full_Subtractor_bhv;

architecture Structural of Full_Subtractor_bhv is

    component Half_Subtractor
        Port (
            A    : in  BIT;
            B    : in  BIT;
            Diff : out BIT;
            Bout : out BIT
        );
    end component;

    component OR_gate
        Port (
            A : in  BIT;
            B : in  BIT;
            Y : out BIT
        );
    end component;

    signal HS1_Diff, HS1_Bout : BIT;
    signal HS2_Diff, HS2_Bout : BIT;

begin
    HS1: Half_Subtractor port map(A => A,        B => B,   Diff => HS1_Diff, Bout => HS1_Bout);
    HS2: Half_Subtractor port map(A => HS1_Diff, B => Bin, Diff => HS2_Diff, Bout => HS2_Bout);
    OR1: OR_gate         port map(A => HS1_Bout, B => HS2_Bout, Y => Bout);

    Diff <= HS2_Diff;

end Structural;
