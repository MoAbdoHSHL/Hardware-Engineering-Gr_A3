entity result_register is
    port(
        clk : in  bit;
        rst : in  bit;
        en  : in  bit;
        d   : in  bit_vector(7 downto 0);
        q   : out bit_vector(7 downto 0)
    );
end entity;

architecture behavior of result_register is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            q <= "00000000";
        elsif clk'event and clk = '1' then
            if en = '1' then
                q <= d;
            end if;
        end if;
    end process;
end architecture;