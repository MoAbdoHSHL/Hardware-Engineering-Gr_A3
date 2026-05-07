entity BCDto7seg is
    Port (
        BCD : in  BIT_VECTOR(3 downto 0);
        SEG : out BIT_VECTOR(6 downto 0)
    );
end BCDto7seg;

architecture Behavioral of BCDto7seg is
begin
    process(BCD)
    begin
        case BCD is
            when "0000" => SEG <= "1111110";
            when "0001" => SEG <= "0110000";
            when "0010" => SEG <= "1101101";
            when "0011" => SEG <= "1111001";
            when "0100" => SEG <= "0110011";
            when "0101" => SEG <= "1011011";
            when "0110" => SEG <= "1011111";
            when "0111" => SEG <= "1110000";
            when "1000" => SEG <= "1111111";
            when "1001" => SEG <= "1111011";
            when others => SEG <= "0000000";
        end case;
    end process;
end Behavioral;
