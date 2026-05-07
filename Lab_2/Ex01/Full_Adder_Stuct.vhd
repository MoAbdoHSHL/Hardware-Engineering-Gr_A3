entity Full_Adder is
    Port (
        A    : in  BIT;
        B    : in  BIT;
        Cin  : in  BIT;
        Sum  : out BIT;
        Cout : out BIT
    );
end Full_Adder;

architecture Structural of Full_Adder is

    component Half_Adder
        Port (
            A : in  BIT;
            B : in  BIT;
            S : out BIT;
            C : out BIT
        );
    end component;

    component OR_gate
        Port (
            A : in  BIT;
            B : in  BIT;
            Y : out BIT
        );
    end component;

    signal HA1_S, HA1_C : BIT;
    signal HA2_S, HA2_C : BIT;

begin
    HA1: Half_Adder port map(A => A,     B => B,   S => HA1_S, C => HA1_C);
    HA2: Half_Adder port map(A => HA1_S, B => Cin, S => HA2_S, C => HA2_C);
    OR1: OR_gate    port map(A => HA1_C, B => HA2_C, Y => Cout);

    Sum <= HA2_S;

end Structural;
