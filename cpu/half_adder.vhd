entity half_adder is
    port(
        a, b : in  bit;
        s, co : out bit
    );
end entity;

architecture Structure of half_adder is
begin
    s  <= a xor b;
    co <= a and b;
end architecture;
