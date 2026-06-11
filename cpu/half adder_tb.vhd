entity tb_half_adder is
end entity;

architecture Behavioral of tb_half_adder is

    signal a_tb  : bit := '0';
    signal b_tb  : bit := '0';
    signal s_tb  : bit;
    signal co_tb : bit;

	component half_adder is
        port(
            a, b  : in  bit;
            s, co : out bit
        );
    	end component; 

begin

    UUT: half_adder
        port map(
            a  => a_tb,
            b  => b_tb,
            s  => s_tb,
            co => co_tb
        );

    stim_proc: process
    begin
        -- a=0, b=0 ? s=0, co=0
        a_tb <= '0'; b_tb <= '0'; wait for 20 ns;

        -- a=0, b=1 ? s=1, co=0
        a_tb <= '0'; b_tb <= '1'; wait for 20 ns;

        -- a=1, b=0 ? s=1, co=0
        a_tb <= '1'; b_tb <= '0'; wait for 20 ns;

        -- a=1, b=1 ? s=0, co=1
        a_tb <= '1'; b_tb <= '1'; wait for 20 ns;

        wait;
    end process;

end Behavioral;
