entity multiplier is
    port(
        a : in  bit_vector(3 downto 0);
        b : in  bit_vector(3 downto 0);
        p : out bit_vector(7 downto 0)
    );
end entity;

architecture structure of multiplier is

    component ripple_carry_adder is
        port(
            a  : in  bit_vector(3 downto 0);
            b  : in  bit_vector(3 downto 0);
            ci : in  bit;
            s  : out bit_vector(3 downto 0);
            co : out bit
        );
    end component;

    signal pp0, pp1, pp2, pp3 : bit_vector(7 downto 0);

    signal sum01  : bit_vector(7 downto 0);
    signal sum012 : bit_vector(7 downto 0);

    signal c01_low, c01_high     : bit;
    signal c012_low, c012_high   : bit;
    signal cfinal_low, cfinal_hi : bit;

begin

    -- Partial product 0: A * b(0), shifted by 0
    pp0(0) <= a(0) and b(0);
    pp0(1) <= a(1) and b(0);
    pp0(2) <= a(2) and b(0);
    pp0(3) <= a(3) and b(0);
    pp0(4) <= '0';
    pp0(5) <= '0';
    pp0(6) <= '0';
    pp0(7) <= '0';

    -- Partial product 1: A * b(1), shifted left by 1
    pp1(0) <= '0';
    pp1(1) <= a(0) and b(1);
    pp1(2) <= a(1) and b(1);
    pp1(3) <= a(2) and b(1);
    pp1(4) <= a(3) and b(1);
    pp1(5) <= '0';
    pp1(6) <= '0';
    pp1(7) <= '0';

    -- Partial product 2: A * b(2), shifted left by 2
    pp2(0) <= '0';
    pp2(1) <= '0';
    pp2(2) <= a(0) and b(2);
    pp2(3) <= a(1) and b(2);
    pp2(4) <= a(2) and b(2);
    pp2(5) <= a(3) and b(2);
    pp2(6) <= '0';
    pp2(7) <= '0';

    -- Partial product 3: A * b(3), shifted left by 3
    pp3(0) <= '0';
    pp3(1) <= '0';
    pp3(2) <= '0';
    pp3(3) <= a(0) and b(3);
    pp3(4) <= a(1) and b(3);
    pp3(5) <= a(2) and b(3);
    pp3(6) <= a(3) and b(3);
    pp3(7) <= '0';

    -- sum01 = pp0 + pp1
    ADD01_LOW : ripple_carry_adder
        port map(pp0(3 downto 0), pp1(3 downto 0), '0', sum01(3 downto 0), c01_low);

    ADD01_HIGH : ripple_carry_adder
        port map(pp0(7 downto 4), pp1(7 downto 4), c01_low, sum01(7 downto 4), c01_high);

    -- sum012 = sum01 + pp2
    ADD012_LOW : ripple_carry_adder
        port map(sum01(3 downto 0), pp2(3 downto 0), '0', sum012(3 downto 0), c012_low);

    ADD012_HIGH : ripple_carry_adder
        port map(sum01(7 downto 4), pp2(7 downto 4), c012_low, sum012(7 downto 4), c012_high);

    -- p = sum012 + pp3
    ADDF_LOW : ripple_carry_adder
        port map(sum012(3 downto 0), pp3(3 downto 0), '0', p(3 downto 0), cfinal_low);

    ADDF_HIGH : ripple_carry_adder
        port map(sum012(7 downto 4), pp3(7 downto 4), cfinal_low, p(7 downto 4), cfinal_hi);

end architecture;
