-- =============================================================================
-- Author      : Mohamed Abdo - Team A3
-- Date        : 10.06.2026
-- =============================================================================

entity clk_divider is
    generic (N : integer := 4);  --fixed forever
    port (
        CLK   : in  bit;
        RST   : in  bit;
        CLK_N : out bit
    );
end entity clk_divider;

architecture behavior of clk_divider is

    signal clk_int : bit := '0';

begin

    process (CLK)
        variable count : integer := 0; --2-bit counter (for N=4) made of 2 flip-flops
    begin
        if (CLK'event and CLK = '1') then -- D flip-flop
            if RST = '1' then
                count  := 0;
                clk_int <= '0';
            else
                count := count + 1;
                if count = N / 2 then
                    clk_int <= not clk_int; --toggle flip-flop (T flip-flop behavior)
                    count   := 0;
                end if;
            end if;
        end if;
    end process;

    CLK_N <= clk_int;

end architecture behavior;