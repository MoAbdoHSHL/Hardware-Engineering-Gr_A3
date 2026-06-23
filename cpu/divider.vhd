entity divider is
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
end entity;

architecture behavior of divider is

    type state_type is (IDLE, CALC, DONE_STATE);
    signal state : state_type := IDLE;

    signal remainder_r : bit_vector(7 downto 0) := "00000000";
    signal divisor_r   : bit_vector(7 downto 0) := "00000000";
    signal quotient_r  : bit_vector(7 downto 0) := "00000000";

    signal q_sign : bit := '0';
    signal r_sign : bit := '0';

    function add8_ci(x  : bit_vector(7 downto 0);
                     y  : bit_vector(7 downto 0);
                     ci : bit) return bit_vector is
        variable result : bit_vector(7 downto 0);
        variable c      : bit;
    begin
        c := ci;

        for i in 0 to 7 loop
            result(i) := x(i) xor y(i) xor c;
            c := (x(i) and y(i)) or (x(i) and c) or (y(i) and c);
        end loop;

        return result;
    end function;

    function twos_comp8(x : bit_vector(7 downto 0)) return bit_vector is
        variable inv : bit_vector(7 downto 0);
    begin
        for i in 0 to 7 loop
            inv(i) := not x(i);
        end loop;

        return add8_ci(inv, "00000001", '0');
    end function;

    function abs8(x : bit_vector(7 downto 0)) return bit_vector is
    begin
        if x(7) = '1' then
            return twos_comp8(x);
        else
            return x;
        end if;
    end function;

    function ge8(x : bit_vector(7 downto 0);
                 y : bit_vector(7 downto 0)) return boolean is
    begin
        for i in 7 downto 0 loop
            if x(i) = '1' and y(i) = '0' then
                return true;
            elsif x(i) = '0' and y(i) = '1' then
                return false;
            end if;
        end loop;

        return true;
    end function;

    function gt8(x : bit_vector(7 downto 0);
                 y : bit_vector(7 downto 0)) return boolean is
    begin
        if ge8(x, y) and x /= y then
            return true;
        else
            return false;
        end if;
    end function;

    function sub8(x : bit_vector(7 downto 0);
                  y : bit_vector(7 downto 0)) return bit_vector is
        variable y_inv : bit_vector(7 downto 0);
    begin
        for i in 0 to 7 loop
            y_inv(i) := not y(i);
        end loop;

        return add8_ci(x, y_inv, '1');
    end function;

    function inc8(x : bit_vector(7 downto 0)) return bit_vector is
    begin
        return add8_ci(x, "00000001", '0');
    end function;

begin

    process(clk, rst)
        variable q_signed : bit_vector(7 downto 0);
        variable r_signed : bit_vector(7 downto 0);
        variable err      : bit;
    begin
        if rst = '1' then

            state       <= IDLE;
            remainder_r <= "00000000";
            divisor_r   <= "00000000";
            quotient_r  <= "00000000";
            q_sign      <= '0';
            r_sign      <= '0';

            q <= "00000000";
            r <= "00000000";

            div_zero      <= '0';
            display_error <= '0';
            busy          <= '0';
            done          <= '0';

        elsif clk'event and clk = '1' then

            done <= '0';

            case state is

                when IDLE =>

                    busy <= '0';

                    if start = '1' then

                        if b = "00000000" then

                            q <= "00000000";
                            r <= "00000000";

                            div_zero      <= '1';
                            display_error <= '1';
                            busy          <= '0';
                            done          <= '1';
                            state         <= IDLE;

                        else

                            remainder_r <= abs8(a);
                            divisor_r   <= abs8(b);
                            quotient_r  <= "00000000";

                            q_sign <= a(7) xor b(7);
                            r_sign <= a(7);

                            div_zero      <= '0';
                            display_error <= '0';
                            busy          <= '1';
                            state         <= CALC;

                        end if;

                    end if;

                when CALC =>

                    busy <= '1';

                    if ge8(remainder_r, divisor_r) then
                        remainder_r <= sub8(remainder_r, divisor_r);
                        quotient_r  <= inc8(quotient_r);
                    else
                        state <= DONE_STATE;
                    end if;

                when DONE_STATE =>

                    busy <= '0';
                    done <= '1';

                    if q_sign = '1' then
                        q_signed := twos_comp8(quotient_r);
                    else
                        q_signed := quotient_r;
                    end if;

                    if r_sign = '1' and remainder_r /= "00000000" then
                        r_signed := twos_comp8(remainder_r);
                    else
                        r_signed := remainder_r;
                    end if;

                    q <= q_signed;
                    r <= r_signed;

                    err := '0';

                    -- Signed quotient overflow:
                    -- Positive quotient cannot have magnitude > 127.
                    -- Negative quotient cannot have magnitude > 128.
                    if q_sign = '0' and quotient_r(7) = '1' then
                        err := '1';
                    elsif q_sign = '1' and gt8(quotient_r, "10000000") then
                        err := '1';
                    end if;

                    -- Display rule using decimal point:
                    -- quotient magnitude must be 0..99
                    -- remainder magnitude must be 0..9
                    if gt8(quotient_r, "01100011") then -- > 99
                        err := '1';
                    elsif gt8(remainder_r, "00001001") then -- > 9
                        err := '1';
                    end if;

                    display_error <= err;

                    state <= IDLE;

            end case;

        end if;
    end process;

end architecture;