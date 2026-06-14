entity divider is
    port(
        a : in  bit_vector(3 downto 0);
        b : in  bit_vector(3 downto 0);
        q : out bit_vector(3 downto 0);
        r : out bit_vector(3 downto 0)
    );
end entity;

architecture structure of divider is

    component CR_add_sub is
        port(
            a    : in  bit_vector(3 downto 0);
            b    : in  bit_vector(3 downto 0);
            mode : in  bit;
            s    : out bit_vector(3 downto 0);
            co   : out bit
        );
    end component;

    signal r0, r1, r2, r3, r4, r5, r6, r7 : bit_vector(3 downto 0);
    signal r8, r9, r10, r11, r12, r13, r14, r15 : bit_vector(3 downto 0);

    signal c1, c2, c3, c4, c5, c6, c7, c8 : bit;
    signal c9, c10, c11, c12, c13, c14, c15 : bit;

begin

    r0 <= a;

    SUB1  : CR_add_sub port map(r0,  b, '1', r1,  c1);
    SUB2  : CR_add_sub port map(r1,  b, '1', r2,  c2);
    SUB3  : CR_add_sub port map(r2,  b, '1', r3,  c3);
    SUB4  : CR_add_sub port map(r3,  b, '1', r4,  c4);
    SUB5  : CR_add_sub port map(r4,  b, '1', r5,  c5);
    SUB6  : CR_add_sub port map(r5,  b, '1', r6,  c6);
    SUB7  : CR_add_sub port map(r6,  b, '1', r7,  c7);
    SUB8  : CR_add_sub port map(r7,  b, '1', r8,  c8);
    SUB9  : CR_add_sub port map(r8,  b, '1', r9,  c9);
    SUB10 : CR_add_sub port map(r9,  b, '1', r10, c10);
    SUB11 : CR_add_sub port map(r10, b, '1', r11, c11);
    SUB12 : CR_add_sub port map(r11, b, '1', r12, c12);
    SUB13 : CR_add_sub port map(r12, b, '1', r13, c13);
    SUB14 : CR_add_sub port map(r13, b, '1', r14, c14);
    SUB15 : CR_add_sub port map(r14, b, '1', r15, c15);

    process(a, b, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15)
    begin
        if b = "0000" then
    q <= "1111";
    r <= "1111";

	elsif c1 = '0' then
	    q <= "0000";
	    r <= r0;
	
	elsif c2 = '0' then
	    q <= "0001";
	    r <= r1;

	elsif c3 = '0' then
	    q <= "0010";
	    r <= r2;

	elsif c4 = '0' then
	    q <= "0011";
	    r <= r3;

	elsif c5 = '0' then
	    q <= "0100";
	    r <= r4;

	elsif c6 = '0' then
	    q <= "0101";
	    r <= r5;

	elsif c7 = '0' then
	    q <= "0110";
	    r <= r6;

	elsif c8 = '0' then
	    q <= "0111";
	    r <= r7;

	elsif c9 = '0' then
	    q <= "1000";
	    r <= r8;

	elsif c10 = '0' then
	    q <= "1001";
	    r <= r9;
		
	elsif c11 = '0' then
	    q <= "1010";
	    r <= r10;

	elsif c12 = '0' then
	    q <= "1011";
	    r <= r11;

	elsif c13 = '0' then
	    q <= "1100";
	    r <= r12;

	elsif c14 = '0' then
	    q <= "1101";
	    r <= r13;

	elsif c15 = '0' then
	    q <= "1110";
	    r <= r14;

	else
	    q <= "1111";
	    r <= r15;
	end if;
    end process;

end architecture;