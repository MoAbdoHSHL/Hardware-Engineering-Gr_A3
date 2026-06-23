entity alu is
    port(
        a         : in  bit_vector(7 downto 0);
        b         : in  bit_vector(7 downto 0);
        op        : in  bit_vector(1 downto 0);

        result    : out bit_vector(7 downto 0);
        remainder : out bit_vector(7 downto 0);

        carry     : out bit;
        overflow  : out bit;
        div_zero  : out bit
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
            a        : in  bit_vector(7 downto 0);
            b        : in  bit_vector(7 downto 0);
            p        : out bit_vector(7 downto 0);
            overflow : out bit
        );
    end component;

    component divider is
        port(
            a             : in  bit_vector(7 downto 0);
            b             : in  bit_vector(7 downto 0);
            q             : out bit_vector(7 downto 0);
            r             : out bit_vector(7 downto 0);
            div_zero      : out bit;
            display_error : out bit
        );
    end component;

    signal addsub_result : bit_vector(7 downto 0);
    signal addsub_carry  : bit;

    signal mult_result   : bit_vector(7 downto 0);
    signal mult_overflow : bit;

    signal div_q             : bit_vector(7 downto 0);
    signal div_r             : bit_vector(7 downto 0);
    signal div_zero_sig      : bit;
    signal div_display_error : bit;

begin

    ADDSUB : CR_add_sub
        port map(
            a    => a,
            b    => b,
            mode => op(0),
            s    => addsub_result,
            co   => addsub_carry
        );

    MULT : multiplier
        port map(
            a        => a,
            b        => b,
            p        => mult_result,
            overflow => mult_overflow
        );

    DIV_UNIT : divider
        port map(
            a             => a,
            b             => b,
            q             => div_q,
            r             => div_r,
            div_zero      => div_zero_sig,
            display_error => div_display_error
        );

    process(op, addsub_result, addsub_carry,
            mult_result, mult_overflow,
            div_q, div_r, div_zero_sig, div_display_error)
    begin

        case op is

            when "00" => -- ADD
                result    <= addsub_result;
                remainder <= "00000000";
                carry     <= addsub_carry;

                -- Unsigned 8-bit ADD overflow happens when carry out = 1.
                overflow  <= addsub_carry;
                div_zero  <= '0';

            when "01" => -- SUB
                result    <= addsub_result;
                remainder <= "00000000";
                carry     <= addsub_carry;

                -- In unsigned subtraction, carry = 0 means borrow/underflow.
                overflow  <= not addsub_carry;
                div_zero  <= '0';

            when "10" => -- MUL
                result    <= mult_result;
                remainder <= "00000000";
                carry     <= '0';

                -- Multiplier sets overflow if product > 255.
                overflow  <= mult_overflow;
                div_zero  <= '0';

            when "11" => -- DIV
                result    <= div_q;       -- quotient
                remainder <= div_r;       -- remainder
                carry     <= '0';

                -- Divider display rule:
                -- quotient must be 0..99 and remainder must be 0..9.
                -- If not, display_error becomes 1 and CPU top can show OF.
                overflow  <= div_display_error;
                div_zero  <= div_zero_sig;

            when others =>
                result    <= "00000000";
                remainder <= "00000000";
                carry     <= '0';
                overflow  <= '0';
                div_zero  <= '0';

        end case;

    end process;

end architecture;