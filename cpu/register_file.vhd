entity register_file is
    port(
        clk          : in  bit;
        rst          : in  bit;
        write_enable : in  bit;

        read_addr_a  : in  bit_vector(1 downto 0);
        read_addr_b  : in  bit_vector(1 downto 0);
        write_addr   : in  bit_vector(1 downto 0);

        write_data   : in  bit_vector(3 downto 0);

        data_a       : out bit_vector(3 downto 0);
        data_b       : out bit_vector(3 downto 0)
    );
end entity;

architecture behavior of register_file is

    signal r0 : bit_vector(3 downto 0);
    signal r1 : bit_vector(3 downto 0);
    signal r2 : bit_vector(3 downto 0);
    signal r3 : bit_vector(3 downto 0);

begin

    -- WRITE logic: stores data on rising clock edge
    process(clk, rst)
    begin
        if rst = '1' then
            r0 <= "0000";
            r1 <= "0001";
            r2 <= "0010";
            r3 <= "0011";

        elsif clk'event and clk = '1' then
            if write_enable = '1' then
                case write_addr is
                    when "00" =>
                        r0 <= write_data;

                    when "01" =>
                        r1 <= write_data;

                    when "10" =>
                        r2 <= write_data;

                    when "11" =>
                        r3 <= write_data;

                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    -- READ port A
    process(read_addr_a, r0, r1, r2, r3)
    begin
        case read_addr_a is
            when "00" =>
                data_a <= r0;

            when "01" =>
                data_a <= r1;

            when "10" =>
                data_a <= r2;

            when "11" =>
                data_a <= r3;

            when others =>
                data_a <= "0000";
        end case;
    end process;

    -- READ port B
    process(read_addr_b, r0, r1, r2, r3)
    begin
        case read_addr_b is
            when "00" =>
                data_b <= r0;

            when "01" =>
                data_b <= r1;

            when "10" =>
                data_b <= r2;

            when "11" =>
                data_b <= r3;

            when others =>
                data_b <= "0000";
        end case;
    end process;

end architecture;