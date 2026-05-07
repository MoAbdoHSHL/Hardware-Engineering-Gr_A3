entity Full_Adder_bhv is
    Port (
        A    : in  BIT;
        B    : in  BIT;
        Cin  : in  BIT;
        Sum  : out BIT;
        Cout : out BIT
    );
end Full_Adder_bhv;

architecture Behavioral of Full_Adder_bhv is
begin
    Sum  <= A XOR B XOR Cin;
    Cout <= (A AND B) OR (B AND Cin) OR (A AND Cin);
end Behavioral;