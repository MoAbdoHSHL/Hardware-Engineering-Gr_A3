entity multiplier is
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
end entity;

architecture behavior of multiplier is

    type state_type is (IDLE, CALC, DONE_STATE);
    signal state : state_type := IDLE;

    signal a_mag        : bit_vector(7 downto 0) := "00000000";
    signal b_mag        : bit_vector(7 downto 0) := "00000000";
    signal acc          : bit_vector(7 downto 0) := "00000000";
    signal multiplicand : bit_vector(7 downto 0) := "00000000";
    signal multiplier_r : bit_vector(7 downto 0) := "00000000";

    signal product_sign : bit := '0';
    signal overflow_reg : bit := '0';
    signal count        : integer range 0 to 8 := 0;

    function add8_result(x : bit_vector(7 downto 0);
                         y : bit_vector(7 downto 0)) return bit_vector is
        variable result : bit_vector(7 downto 0);
        variable c      : bit;
    begin
        c := '0';

        for i in 0 to 7 loop
            result(i) := x(i) xor y(i) xor c;
            c := (x(i) and y(i)) or (x(i) and c) or (y(i) and c);
        end loop;

        return result;
    end function;

    function add8_carry(x : bit_vector(7 downto 0);
                        y : bit_vector(7 downto 0)) return bit is
        variable c     : bit;
        variable dummy : bit;
    begin
        c := '0';

        for i in 0 to 7 loop
            dummy := x(i) xor y(i) xor c;
            c := (x(i) and y(i)) or (x(i) and c) or (y(i) and c);
        end loop;

        return c;
    end function;

    function twos_comp8(x : bit_vector(7 downto 0)) return bit_vector is
        variable inv : bit_vector(7 downto 0);
    begin
        for i in 0 to 7 loop
            inv(i) := not x(i);
        end loop;

        return add8_result(inv, "00000001");
    end function;

    function abs8(x : bit_vector(7 downto 0)) return bit_vector is
    begin
        if x(7) = '1' then
            return twos_comp8(x);
        else
            return x;
        end if;
    end function;

    function shl8(x : bit_vector(7 downto 0)) return bit_vector is
        variable result : bit_vector(7 downto 0);
    begin
        result(7 downto 1) := x(6 downto 0);
        result(0) := '0';
        return result;
    end function;

    function shr8(x : bit_vector(7 downto 0)) return bit_vector is
        variable result : bit_vector(7 downto 0);
    begin
        result(6 downto 0) := x(7 downto 1);
        result(7) := '0';
        return result;
    end function;

    function remaining_multiplier_bits(x : bit_vector(7 downto 0)) return bit is
    begin
        if x(7 downto 1) = "0000000" then
            return '0';
        else
            return '1';
        end if;
    end function;

    function greater_than_128(x : bit_vector(7 downto 0)) return bit is
    begin
        if x(7) = '1' and x /= "10000000" then
            return '1';
        else
            return '0';
        end if;
    end function;

begin

    process(clk, rst)
        variable temp_sum   : bit_vector(7 downto 0);
        variable temp_carry : bit;
        variable final_mag  : bit_vector(7 downto 0);
        variable final_of   : bit;
    begin
        if rst = '1' then

            state        <= IDLE;
            a_mag        <= "00000000";
            b_mag        <= "00000000";
            acc          <= "00000000";
            multiplicand <= "00000000";
            multiplier_r <= "00000000";
            product_sign <= '0';
            overflow_reg <= '0';
            count        <= 0;

            p        <= "00000000";
            overflow <= '0';
            busy     <= '0';
            done     <= '0';

        elsif clk'event and clk = '1' then

            done <= '0';

            case state is

                when IDLE =>

                    busy <= '0';

                    if start = '1' then
                        a_mag <= abs8(a);
                        b_mag <= abs8(b);

                        acc          <= "00000000";
                        multiplicand <= abs8(a);
                        multiplier_r <= abs8(b);

                        product_sign <= a(7) xor b(7);
                        overflow_reg <= '0';
                        count        <= 0;

                        busy  <= '1';
                        state <= CALC;
                    end if;

                when CALC =>

                    busy <= '1';

                    temp_sum   := acc;
                    temp_carry := '0';

                    if multiplier_r(0) = '1' then
                        temp_sum   := add8_result(acc, multiplicand);
                        temp_carry := add8_carry(acc, multiplicand);

                        if temp_carry = '1' then
                            overflow_reg <= '1';
                        end if;
                    end if;

                    acc <= temp_sum;

                    if multiplicand(7) = '1' and remaining_multiplier_bits(multiplier_r) = '1' then
                        overflow_reg <= '1';
                    end if;

                    multiplicand <= shl8(multiplicand);
                    multiplier_r <= shr8(multiplier_r);

                    if count = 7 then
                        state <= DONE_STATE;
                    else
                        count <= count + 1;
                    end if;

                when DONE_STATE =>

                    busy <= '0';
                    done <= '1';

                    final_mag := acc;
                    final_of  := overflow_reg;

                    -- Signed range check:
                    -- positive result must be <= +127
                    -- negative result may be as large as magnitude 128, because -128 is valid.
                    if product_sign = '0' then
                        if final_mag(7) = '1' then
                            final_of := '1';
                        end if;

                        p <= final_mag;

                    else
                        if greater_than_128(final_mag) = '1' then
                            final_of := '1';
                        end if;

                        p <= twos_comp8(final_mag);
                    end if;

                    overflow <= final_of;

                    state <= IDLE;

            end case;

        end if;
    end process;

end architecture;