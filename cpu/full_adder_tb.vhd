entity full_adder_tb is
end entity;

architecture structural of full_adder_tb is

component full_adder is 
port(	a, b, ci : in bit;
	s, co : out bit);
end component;

	signal a_tb, b_tb, ci_tb : bit := '0';
	signal s_tb, co_tb : bit;

begin
UUT: full_adder
	port map(	
	    a  => a_tb,
            b  => b_tb,
            ci => ci_tb,
            s  => s_tb,
            co => co_tb
        );

    stim_proc: process
    begin
        -- ci = 0 cases
        a_tb <= '0'; b_tb <= '0'; ci_tb <= '0'; wait for 20 ns; -- 0+0+0 = 0, co=0
        a_tb <= '0'; b_tb <= '1'; ci_tb <= '0'; wait for 20 ns; -- 0+1+0 = 1, co=0
        a_tb <= '1'; b_tb <= '0'; ci_tb <= '0'; wait for 20 ns; -- 1+0+0 = 1, co=0
        a_tb <= '1'; b_tb <= '1'; ci_tb <= '0'; wait for 20 ns; -- 1+1+0 = 0, co=1

        -- ci = 1 cases
        a_tb <= '0'; b_tb <= '0'; ci_tb <= '1'; wait for 20 ns; -- 0+0+1 = 1, co=0
        a_tb <= '0'; b_tb <= '1'; ci_tb <= '1'; wait for 20 ns; -- 0+1+1 = 0, co=1
        a_tb <= '1'; b_tb <= '0'; ci_tb <= '1'; wait for 20 ns; -- 1+0+1 = 0, co=1
        a_tb <= '1'; b_tb <= '1'; ci_tb <= '1'; wait for 20 ns; -- 1+1+1 = 1, co=1

        wait;
    end process;

end architecture;
