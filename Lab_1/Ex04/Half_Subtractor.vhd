entity Half_Subtractor is
    Port (
        A    : in  BIT;
        B    : in  BIT;
        Diff : out BIT;
        Bout : out BIT
    );
end Half_Subtractor;

architecture Structural of Half_Subtractor is
begin
    Diff <= A XOR B;
    Bout <= (NOT A) AND B;
end Structural;