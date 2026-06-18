entity binary_to_bcd is
    port(
        bin      : in  bit_vector(7 downto 0);
        hundreds : out bit_vector(3 downto 0);
        tens     : out bit_vector(3 downto 0);
        ones     : out bit_vector(3 downto 0);
        overflow : out bit
    );
end entity;

architecture behavior of binary_to_bcd is
begin

    process(bin)
        variable value : integer;
        variable h     : integer;
        variable t     : integer;
        variable o     : integer;
    begin
        value := 0;

        if bin(0) = '1' then value := value + 1; end if;
        if bin(1) = '1' then value := value + 2; end if;
        if bin(2) = '1' then value := value + 4; end if;
        if bin(3) = '1' then value := value + 8; end if;
        if bin(4) = '1' then value := value + 16; end if;
        if bin(5) = '1' then value := value + 32; end if;
        if bin(6) = '1' then value := value + 64; end if;
        if bin(7) = '1' then value := value + 128; end if;

        -- unsigned 8-bit range is 0 to 255, so it fits in 3 digits
        overflow <= '0';

        h := value / 100;
        t := (value - (h * 100)) / 10;
        o := value - (h * 100) - (t * 10);

        case h is
            when 0 => hundreds <= "0000";
            when 1 => hundreds <= "0001";
            when 2 => hundreds <= "0010";
            when others => hundreds <= "0000";
        end case;

        case t is
            when 0 => tens <= "0000";
            when 1 => tens <= "0001";
            when 2 => tens <= "0010";
            when 3 => tens <= "0011";
            when 4 => tens <= "0100";
            when 5 => tens <= "0101";
            when 6 => tens <= "0110";
            when 7 => tens <= "0111";
            when 8 => tens <= "1000";
            when 9 => tens <= "1001";
            when others => tens <= "0000";
        end case;

        case o is
            when 0 => ones <= "0000";
            when 1 => ones <= "0001";
            when 2 => ones <= "0010";
            when 3 => ones <= "0011";
            when 4 => ones <= "0100";
            when 5 => ones <= "0101";
            when 6 => ones <= "0110";
            when 7 => ones <= "0111";
            when 8 => ones <= "1000";
            when 9 => ones <= "1001";
            when others => ones <= "0000";
        end case;

    end process;

end architecture;