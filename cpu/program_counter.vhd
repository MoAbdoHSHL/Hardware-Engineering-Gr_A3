
entity program_counter is
    port(
        clk : in  bit;
        rst : in  bit;
        en  : in  bit;
        pc  : out bit_vector(3 downto 0)
    );
end entity;

architecture behavior of program_counter is
    signal count : bit_vector(3 downto 0);
begin

    process(clk, rst)
    begin
        if rst = '1' then
            count <= "0000";

        elsif clk'event and clk = '1' then
            if en = '1' then
                case count is
                    when "0000" => count <= "0001";
                    when "0001" => count <= "0010";
                    when "0010" => count <= "0011";
                    when "0011" => count <= "0100";
                    when "0100" => count <= "0101";
                    when "0101" => count <= "0110";
                    when "0110" => count <= "0111";
                    when "0111" => count <= "1000";
                    when "1000" => count <= "1001";
                    when "1001" => count <= "1010";
                    when "1010" => count <= "1011";
                    when "1011" => count <= "1100";
                    when "1100" => count <= "1101";
                    when "1101" => count <= "1110";
                    when "1110" => count <= "1111";
                    when others => count <= "0000";
                end case;
            end if;
        end if;
    end process;

    pc <= count;

end architecture;