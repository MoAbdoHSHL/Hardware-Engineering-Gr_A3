entity BCD_adder_tb is
end BCD_adder_tb;

architecture Structural of BCD_adder_tb is

    component BCD_adder
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
    DUT: BCD_adder port map(
        A    => A,
        B    => B,
        Cin  => Cin,
        Sum  => Sum,
        Cout => Cout
    );

    process
    begin
        A <= "0000"; B <= "0000"; Cin <= '0'; wait for 10 ns;
        A <= "0001"; B <= "0010"; Cin <= '0'; wait for 10 ns;
        A <= "0100"; B <= "0101"; Cin <= '0'; wait for 10 ns;
        A <= "0101"; B <= "0101"; Cin <= '0'; wait for 10 ns;
        A <= "1001"; B <= "0001"; Cin <= '0'; wait for 10 ns;
        A <= "1001"; B <= "1001"; Cin <= '0'; wait for 10 ns;
        A <= "0111"; B <= "0110"; Cin <= '0'; wait for 10 ns;
        A <= "1001"; B <= "1001"; Cin <= '1'; wait for 10 ns;
        wait;
    end process;

end Structural;
