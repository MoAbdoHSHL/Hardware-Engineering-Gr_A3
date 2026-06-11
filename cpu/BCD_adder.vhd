entity bcd_adder is
port(
    a      : in  bit_vector(3 downto 0);
    b      : in  bit_vector(3 downto 0);
    cin    : in  bit;
    sout   : out bit_vector(3 downto 0);
    co_bcd : out bit
);
end entity;

architecture structure of bcd_adder is

    component ripple_carry_adder is
    port(
        a  : in  bit_vector(3 downto 0);
        b  : in  bit_vector(3 downto 0);
        ci : in  bit;
        s  : out bit_vector(3 downto 0);
        co : out bit
    );
    end component;

    signal c1, c2, correction : bit;
    signal sum_1 : bit_vector(3 downto 0);
    signal add6  : bit_vector(3 downto 0);

begin

    RCA1 : ripple_carry_adder
        port map(
            a  => a,
            b  => b,
            ci => cin,
            s  => sum_1,
            co => c1
        );

    correction <= c1 or 
                  (sum_1(3) and sum_1(2)) or 
                  (sum_1(3) and sum_1(1));

    add6(0) <= '0';
    add6(1) <= correction;
    add6(2) <= correction;
    add6(3) <= '0';

    RCA2 : ripple_carry_adder
        port map(
            a  => add6,
            b  => sum_1,
            ci => '0',
            s  => sout,
            co => c2
        );

    co_bcd <= correction;

end architecture;
