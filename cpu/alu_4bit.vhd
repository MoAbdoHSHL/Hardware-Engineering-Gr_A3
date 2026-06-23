entity alu is
    port(
        clk       : in  bit;
        rst       : in  bit;
        start     : in  bit;

        a         : in  bit_vector(7 downto 0);
        b         : in  bit_vector(7 downto 0);
        op        : in  bit_vector(1 downto 0);

        result    : out bit_vector(7 downto 0);
        remainder : out bit_vector(7 downto 0);

        carry     : out bit;
        overflow  : out bit;
        div_zero  : out bit;

        busy      : out bit;
        done      : out bit
    );
end entity;

architecture structure of alu is

    component CR_add_sub is
        port(
            a    : in  bit_vector(7 downto 0);
            b    : in  bit_vector(7 downto 0);
            mode : in  bit;
            s    : out bit_vector(7 downto 0);
            co   : out bit
        );
    end component;

    component multiplier is
        port(
            clk      : in  bit;
            rst      : in  bit;
            start    : in  bit;
            a        : in  bit_vector(7 downto 0);
            b        : in  bit_vector(7 downto 0);
            p        : out bit_vector(7 downto 0);
            overflow : out bit;
            busy     : out bit;
            done     : out bit
        );
    end component;

    component divider is
        port(
            clk           : in  bit;
            rst           : in  bit;
            start         : in  bit;
            a             : in  bit_vector(7 downto 0);
            b             : in  bit_vector(7 downto 0);
            q             : out bit_vector(7 downto 0);
            r             : out bit_vector(7 downto 0);
            div_zero      : out bit;
            display_error : out bit;
            busy          : out bit;
            done          : out bit
        );
    end component;

    signal addsub_result : bit_vector(7 downto 0);
    signal addsub_carry  : bit;

    signal mult_result   : bit_vector(7 downto 0);
    signal mult_overflow : bit;
    signal mult_busy     : bit;
    signal mult_done     : bit;

    signal div_q             : bit_vector(7 downto 0);
    signal div_r             : bit_vector(7 downto 0);
    signal div_zero_sig      : bit;
    signal div_display_error : bit;
    signal div_busy          : bit;
    signal div_done          : bit;

    signal result_reg    : bit_vector(7 downto 0) := "00000000";
    signal remainder_reg : bit_vector(7 downto 0) := "00000000";
    signal carry_reg     : bit := '0';
    signal overflow_reg  : bit := '0';
    signal div_zero_reg  : bit := '0';
    signal done_reg      : bit := '0';

    signal mult_start : bit;
    signal div_start  : bit;

    function signed_add_overflow(a_in : bit_vector(7 downto 0);
                                 b_in : bit_vector(7 downto 0);
                                 s_in : bit_vector(7 downto 0)) return bit is
    begin
        if a_in(7) = b_in(7) and s_in(7) /= a_in(7) then
            return '1';
        else
            return '0';
        end if;
    end function;

    function signed_sub_overflow(a_in : bit_vector(7 downto 0);
                                 b_in : bit_vector(7 downto 0);
                                 s_in : bit_vector(7 downto 0)) return bit is
    begin
        if a_in(7) /= b_in(7) and s_in(7) /= a_in(7) then
            return '1';
        else
            return '0';
        end if;
    end function;

begin

    ADDSUB : CR_add_sub
        port map(
            a    => a,
            b    => b,
            mode => op(0),
            s    => addsub_result,
            co   => addsub_carry
        );

    mult_start <= start when op = "10" else '0';
    div_start  <= start when op = "11" else '0';

    MULT : multiplier
        port map(
            clk      => clk,
            rst      => rst,
            start    => mult_start,
            a        => a,
            b        => b,
            p        => mult_result,
            overflow => mult_overflow,
            busy     => mult_busy,
            done     => mult_done
        );

    DIV_UNIT : divider
        port map(
            clk           => clk,
            rst           => rst,
            start         => div_start,
            a             => a,
            b             => b,
            q             => div_q,
            r             => div_r,
            div_zero      => div_zero_sig,
            display_error => div_display_error,
            busy          => div_busy,
            done          => div_done
        );

    process(clk, rst)
    begin
        if rst = '1' then

            result_reg    <= "00000000";
            remainder_reg <= "00000000";
            carry_reg     <= '0';
            overflow_reg  <= '0';
            div_zero_reg  <= '0';
            done_reg      <= '0';

        elsif clk'event and clk = '1' then

            done_reg <= '0';

            if start = '1' and op = "00" then

                result_reg    <= addsub_result;
                remainder_reg <= "00000000";
                carry_reg     <= addsub_carry;
                overflow_reg  <= signed_add_overflow(a, b, addsub_result);
                div_zero_reg  <= '0';
                done_reg      <= '1';

            elsif start = '1' and op = "01" then

                result_reg    <= addsub_result;
                remainder_reg <= "00000000";
                carry_reg     <= addsub_carry;
                overflow_reg  <= signed_sub_overflow(a, b, addsub_result);
                div_zero_reg  <= '0';
                done_reg      <= '1';

            elsif mult_done = '1' then

                result_reg    <= mult_result;
                remainder_reg <= "00000000";
                carry_reg     <= mult_overflow;
                overflow_reg  <= mult_overflow;
                div_zero_reg  <= '0';
                done_reg      <= '1';

            elsif div_done = '1' then

                result_reg    <= div_q;
                remainder_reg <= div_r;
                carry_reg     <= '0';
                overflow_reg  <= div_display_error;
                div_zero_reg  <= div_zero_sig;
                done_reg      <= '1';

            end if;

        end if;
    end process;

    result    <= result_reg;
    remainder <= remainder_reg;
    carry     <= carry_reg;
    overflow  <= overflow_reg;
    div_zero  <= div_zero_reg;
    done      <= done_reg;
    busy      <= mult_busy or div_busy;

end architecture;