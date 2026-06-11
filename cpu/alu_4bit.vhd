
entity alu is
    port(
        a      : in  bit_vector(3 downto 0);
        b      : in  bit_vector(3 downto 0);
        op     : in  bit_vector(1 downto 0); -- two switches with different input types

        result : out bit_vector(7 downto 0);
        carry  : out bit
    );
end entity;

architecture structure of alu is

    component CR_add_sub is
        port(
            a    : in  bit_vector(3 downto 0);
            b    : in  bit_vector(3 downto 0);
            mode : in  bit;
            s    : out bit_vector(3 downto 0);
            co   : out bit
        );
    end component;

    component multiplier is
        port(
            a : in  bit_vector(3 downto 0);
            b : in  bit_vector(3 downto 0);
            p : out bit_vector(7 downto 0)
        );
    end component;

    signal addsub_result : bit_vector(3 downto 0);
    signal addsub_carry  : bit;

    signal mult_result   : bit_vector(7 downto 0);

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
            a => a,
            b => b,
            p => mult_result
        );

    process(op, addsub_result, mult_result, addsub_carry)
    begin

        case op is

            when "00" =>       -- ADD
                result(3 downto 0) <= addsub_result;
                result(7 downto 4) <= "0000";
                carry <= addsub_carry;

            when "01" =>       -- SUB
                result(3 downto 0) <= addsub_result;
                result(7 downto 4) <= "0000";
                carry <= addsub_carry;

            when "10" =>       -- MULTIPLY
                result <= mult_result;
                carry <= '0';

            when others =>     -- DIV placeholder
                result <= "00000000";
                carry <= '0';

        end case;

    end process;

end architecture;