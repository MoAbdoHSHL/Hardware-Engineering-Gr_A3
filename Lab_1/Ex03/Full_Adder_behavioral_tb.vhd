entity Full_Adder_bhv_tb is
end Full_Adder_bhv_tb;

architecture Behavioral of Full_Adder_bhv_tb is

    component Full_Adder_bhv
        Port (
            A    : in  BIT;
            B    : in  BIT;
            Cin  : in  BIT;
            Sum  : out BIT;
            Cout : out BIT
        );
    end component;

    signal A, B, Cin : BIT := '0';
    signal Sum, Cout : BIT;

begin
    DUT: Full_Adder_bhv port map(
        A    => A,
        B    => B,
        Cin  => Cin,
        Sum  => Sum,
        Cout => Cout
    );

    process
    begin
        A <= '0'; B <= '0'; Cin <= '0'; wait for 10 ns;
        A <= '0'; B <= '0'; Cin <= '1'; wait for 10 ns;
        A <= '0'; B <= '1'; Cin <= '0'; wait for 10 ns;
        A <= '0'; B <= '1'; Cin <= '1'; wait for 10 ns;
        A <= '1'; B <= '0'; Cin <= '0'; wait for 10 ns;
        A <= '1'; B <= '0'; Cin <= '1'; wait for 10 ns;
        A <= '1'; B <= '1'; Cin <= '0'; wait for 10 ns;
        A <= '1'; B <= '1'; Cin <= '1'; wait for 10 ns;
        wait;
    end process;

end Behavioral;