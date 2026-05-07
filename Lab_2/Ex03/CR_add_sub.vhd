entity CR_add_sub is
    Port (
        A      : in  BIT_VECTOR(3 downto 0);
        B      : in  BIT_VECTOR(3 downto 0);
        Mode   : in  BIT;
        Result : out BIT_VECTOR(3 downto 0);
        Cout   : out BIT
    );
end CR_add_sub;

architecture Structural of CR_add_sub is

    component CR_adder
        Port (
            A    : in  BIT_VECTOR(3 downto 0);
            B    : in  BIT_VECTOR(3 downto 0);
            Cin  : in  BIT;
            Sum  : out BIT_VECTOR(3 downto 0);
            Cout : out BIT
        );
    end component;

    component XOR_gate
        Port (
            A : in  BIT;
            B : in  BIT;
            Y : out BIT
        );
    end component;

    signal B_modified : BIT_VECTOR(3 downto 0);

begin
    XOR0: XOR_gate port map(A => B(0), B => Mode, Y => B_modified(0));
    XOR1: XOR_gate port map(A => B(1), B => Mode, Y => B_modified(1));
    XOR2: XOR_gate port map(A => B(2), B => Mode, Y => B_modified(2));
    XOR3: XOR_gate port map(A => B(3), B => Mode, Y => B_modified(3));

    ADDER: CR_adder port map(
        A    => A,
        B    => B_modified,
        Cin  => Mode,
        Sum  => Result,
        Cout => Cout
    );

end Structural;
