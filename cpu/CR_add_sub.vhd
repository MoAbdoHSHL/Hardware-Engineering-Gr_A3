entity CR_add_sub is
    port(
        a    : in  bit_vector(7 downto 0);
        b    : in  bit_vector(7 downto 0);
        mode : in  bit;                     -- 0 = add, 1 = subtract
        s    : out bit_vector(7 downto 0);
        co   : out bit
    );
end entity;

architecture Structure of CR_add_sub is

    component ripple_carry_adder is
        port(
            a  : in  bit_vector(3 downto 0);
            b  : in  bit_vector(3 downto 0);
            ci : in  bit;
            s  : out bit_vector(3 downto 0);
            co : out bit
        );
    end component;

    signal b_xor : bit_vector(7 downto 0);
    signal c_mid : bit;

begin

    b_xor(0) <= b(0) xor mode;
    b_xor(1) <= b(1) xor mode;
    b_xor(2) <= b(2) xor mode;
    b_xor(3) <= b(3) xor mode;
    b_xor(4) <= b(4) xor mode;
    b_xor(5) <= b(5) xor mode;
    b_xor(6) <= b(6) xor mode;
    b_xor(7) <= b(7) xor mode;

    ADD_LOW : ripple_carry_adder
        port map(
            a  => a(3 downto 0),
            b  => b_xor(3 downto 0),
            ci => mode,
            s  => s(3 downto 0),
            co => c_mid
        );

    ADD_HIGH : ripple_carry_adder
        port map(
            a  => a(7 downto 4),
            b  => b_xor(7 downto 4),
            ci => c_mid,
            s  => s(7 downto 4),
            co => co
        );

end architecture;