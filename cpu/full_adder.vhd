entity full_adder is
port( 	a, b, ci : in bit;
	s, co : out bit);
end entity;

architecture structure of full_adder is 

	component half_adder is
    		port(	a, b : in  bit;
        		s, co : out bit);
	end component;

	signal s_ha1 : bit;
	signal co_ha1 : bit;
	signal co_ha2 : bit;

begin

	-- first half adder adds a and b
	U1 : half_adder
		port map(	a => a,
				b => b,
				s => s_ha1,
				co => co_ha1);

	-- feccond half adder ads the result of the fitst HA with the carry in
	U2 : half_adder
		port map(	a => s_ha1,
				b => ci,
				s => s,
				co => co_ha2);
	
	-- final carry out if either half adder produces a carry
	co <= co_ha1 or co_ha2;
end architecture;

	
