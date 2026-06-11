entity ripple_carry_adder is
port( 	a  : in  bit_vector(3 downto 0);  -- 4 bit input A
        b  : in  bit_vector(3 downto 0);  -- 4 bit input B
        ci : in  bit;                      -- carry in
        s  : out bit_vector(3 downto 0);  -- 4 bit sum output
        co : out bit                       -- carry out
    );
end entity;

architecture structure of ripple_carry_adder is
	
component full_adder is
port(	a, b, ci : in bit;
	s, co : out bit);
end component;

	signal c : bit_vector(2 downto 0);  
begin
	FA0: full_adder
        port map(
            a  => a(0),
            b  => b(0),
            ci => ci,
            s  => s(0),
            co => c(0)      
        );

    FA1: full_adder
        port map(
            a  => a(1),
            b  => b(1),
            ci => c(0),    
            s  => s(1),
            co => c(1)      
        );

    FA2: full_adder
        port map(
            a  => a(2),
            b  => b(2),
            ci => c(1),     
            s  => s(2),
            co => c(2)     
        );

    FA3: full_adder
        port map(
            a  => a(3),
            b  => b(3),
            ci => c(2),     
            s  => s(3),
            co => co
        );

end architecture;
