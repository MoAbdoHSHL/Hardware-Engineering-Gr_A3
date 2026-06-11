entity CR_add_sub is
    port(
        a    : in  bit_vector(3 downto 0);
        b    : in  bit_vector(3 downto 0);
        mode : in  bit;                     -- 0=add, 1=subtract
        s    : out bit_vector(3 downto 0);
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

    -- B after XOR with mode
    signal b_xor : bit_vector(3 downto 0);

begin

    -- XOR each bit of B with mode
    -- mode=0: b_xor = b        (addition)
    -- mode=1: b_xor = NOT b    (subtraction, 2s complement step 1)
    b_xor(0) <= b(0) xor mode;
    b_xor(1) <= b(1) xor mode;
    b_xor(2) <= b(2) xor mode;
    b_xor(3) <= b(3) xor mode;

    -- Instantiate the ripple carry adder
    -- ci = mode: when subtracting ci=1 completes the 2s complement
    U1: ripple_carry_adder
        port map(
            a  => a,
            b  => b_xor,
            ci => mode,
            s  => s,
            co => co
        );

end architecture;
