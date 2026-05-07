entity CR_adder_tb is
end CR_adder_tb;

architecture Structural of CR_adder_tb is

    component CR_adder
        Port (
            A    : in  BIT_VECTOR(3 downto 0);
            B    : in  BIT_VECTOR(3 downto 0);
            Cin  : in  BIT;
            Sum  : out BIT_VECTOR(3 downto 0);
            Cout : out BIT
        );
    end component;

    signal A, B : BIT_VECTOR(3 downto 0) := "0000";
    signal Cin  : BIT := '0';
    signal Sum  : BIT_VECTOR(3 downto 0);
    signal Cout : BIT;

begin
    DUT: CR_adder port map(
        A    => A,
        B    => B,
        Cin  => Cin,
        Sum  => Sum,
        Cout => Cout
    );

    process
    begin
        A <= "0000"; B <= "0000"; Cin <= '0'; wait for 10 ns;
        A <= "0001"; B <= "0001"; Cin <= '0'; wait for 10 ns;
        A <= "0011"; B <= "0101"; Cin <= '0'; wait for 10 ns;
        A <= "0111"; B <= "1000"; Cin <= '0'; wait for 10 ns;
        A <= "1111"; B <= "0001"; Cin <= '0'; wait for 10 ns;
        A <= "1111"; B <= "1111"; Cin <= '0'; wait for 10 ns;
        A <= "1111"; B <= "1111"; Cin <= '1'; wait for 10 ns;
        A <= "1010"; B <= "0101"; Cin <= '1'; wait for 10 ns;
        wait;
    end process;

end Structural;
