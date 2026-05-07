entity CR_adder is
    Port (
        A    : in  BIT_VECTOR(3 downto 0);
        B    : in  BIT_VECTOR(3 downto 0);
        Cin  : in  BIT;
        Sum  : out BIT_VECTOR(3 downto 0);
        Cout : out BIT
    );
end CR_adder;

architecture Structural of CR_adder is

    component Full_Adder
        Port (
            A    : in  BIT;
            B    : in  BIT;
            Cin  : in  BIT;
            Sum  : out BIT;
            Cout : out BIT
        );
    end component;

    signal C : BIT_VECTOR(3 downto 0);

begin
    FA0: Full_Adder port map(A => A(0), B => B(0), Cin => Cin,  Sum => Sum(0), Cout => C(0));
    FA1: Full_Adder port map(A => A(1), B => B(1), Cin => C(0), Sum => Sum(1), Cout => C(1));
    FA2: Full_Adder port map(A => A(2), B => B(2), Cin => C(1), Sum => Sum(2), Cout => C(2));
    FA3: Full_Adder port map(A => A(3), B => B(3), Cin => C(2), Sum => Sum(3), Cout => Cout);

end Structural;