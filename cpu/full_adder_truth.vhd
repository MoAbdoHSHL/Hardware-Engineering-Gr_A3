entity full_adder_truth is
	port( 	a, b, cin : in bit;
		s, cout : out bit);
end entity;

architecture structure of full_adder_truth is
begin

    -- SUM
    s <= '1' when (
            (a='0' and b='0' and cin='1') or
            (a='0' and b='1' and cin='0') or
            (a='1' and b='0' and cin='0') or
            (a='1' and b='1' and cin='1')
         )
         else '0';

    -- CARRY
    cout <= '1' when (
                (a='0' and b='1' and cin='1') or
                (a='1' and b='0' and cin='1') or
                (a='1' and b='1' and cin='0') or
                (a='1' and b='1' and cin='1')
             )
             else '0';

end architecture;
