entity BCDto7seg_tb is
end BCDto7seg_tb;

architecture Behavioral of BCDto7seg_tb is

    component BCDto7seg
        Port (
            BCD : in  BIT_VECTOR(3 downto 0);
            SEG : out BIT_VECTOR(6 downto 0)
        );
    end component;

    signal BCD : BIT_VECTOR(3 downto 0) := "0000";
    signal SEG : BIT_VECTOR(6 downto 0);

begin
    DUT: BCDto7seg port map(
        BCD => BCD,
        SEG => SEG
    );

    process
    begin
        BCD <= "0000"; wait for 10 ns;
        BCD <= "0001"; wait for 10 ns;
        BCD <= "0010"; wait for 10 ns;
        BCD <= "0011"; wait for 10 ns;
        BCD <= "0100"; wait for 10 ns;
        BCD <= "0101"; wait for 10 ns;
        BCD <= "0110"; wait for 10 ns;
        BCD <= "0111"; wait for 10 ns;
        BCD <= "1000"; wait for 10 ns;
        BCD <= "1001"; wait for 10 ns;
        BCD <= "1010"; wait for 10 ns;
        BCD <= "1111"; wait for 10 ns;
        wait;
    end process;

end Behavioral;
