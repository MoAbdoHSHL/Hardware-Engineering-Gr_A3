entity CR_add_sub_tb is
end CR_add_sub_tb;

architecture Structural of CR_add_sub_tb is

    component CR_add_sub
        Port (
            A      : in  BIT_VECTOR(3 downto 0);
            B      : in  BIT_VECTOR(3 downto 0);
            Mode   : in  BIT;
            Result : out BIT_VECTOR(3 downto 0);
            Cout   : out BIT
        );
    end component;

    signal A, B  : BIT_VECTOR(3 downto 0) := "0000";
    signal Mode  : BIT := '0';
    signal Result: BIT_VECTOR(3 downto 0);
    signal Cout  : BIT;

begin
    DUT: CR_add_sub port map(
        A      => A,
        B      => B,
        Mode   => Mode,
        Result => Result,
        Cout   => Cout
    );

    process
    begin
        Mode <= '0'; A <= "0000"; B <= "0000"; wait for 10 ns;
        Mode <= '0'; A <= "0011"; B <= "0101"; wait for 10 ns;
        Mode <= '0'; A <= "0111"; B <= "0111"; wait for 10 ns;
        Mode <= '0'; A <= "1111"; B <= "0001"; wait for 10 ns;
        Mode <= '1'; A <= "0101"; B <= "0011"; wait for 10 ns;
        Mode <= '1'; A <= "1111"; B <= "0001"; wait for 10 ns;
        Mode <= '1'; A <= "0011"; B <= "0101"; wait for 10 ns;
        Mode <= '1'; A <= "0000"; B <= "0000"; wait for 10 ns;
        wait;
    end process;

end Structural;
