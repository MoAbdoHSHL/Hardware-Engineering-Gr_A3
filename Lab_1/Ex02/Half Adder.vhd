
entity Half_Adder is
    Port (
        A    : in  BIT;
        B    : in  BIT;
        S    : out BIT;
        C    : out BIT
    );
end Half_Adder;

architecture Structural of Half_Adder is
begin
    S <= A XOR B;
    C <= A AND B;
end Structural;