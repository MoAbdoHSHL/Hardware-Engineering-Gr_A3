entity BCD_adder is
    Port (
        A    : in  BIT_VECTOR(3 downto 0);
        B    : in  BIT_VECTOR(3 downto 0);
        Cin  : in  BIT;
        Sum  : out BIT_VECTOR(3 downto 0);
        Cout : out BIT
    );
end BCD_adder;

architecture Structural of BCD_adder is

    component CR_adder
        Port (
            A    : in  BIT_VECTOR(3 downto 0);
            B    : in  BIT_VECTOR(3 downto 0);
            Cin  : in  BIT;
            Sum  : out BIT_VECTOR(3 downto 0);
            Cout : out BIT
        );
    end component;

    signal First_Sum  : BIT_VECTOR(3 downto 0);
    signal First_Cout : BIT;
    signal Correction : BIT;
    signal Final_Sum  : BIT_VECTOR(3 downto 0);
    signal Final_Cout : BIT;

begin
    ADDER1: CR_adder port map(
        A    => A,
        B    => B,
        Cin  => Cin,
        Sum  => First_Sum,
        Cout => First_Cout
    );

    Correction <= First_Cout OR
                  (First_Sum(3) AND First_Sum(2)) OR
                  (First_Sum(3) AND First_Sum(1));

    ADDER2: CR_adder port map(
        A    => First_Sum,
        B    => "0110",
        Cin  => '0',
        Sum  => Final_Sum,
        Cout => Final_Cout
    );

    Sum  <= Final_Sum  when Correction = '1' else First_Sum;
    Cout <= Correction;

end Structural;
