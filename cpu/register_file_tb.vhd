entity register_file_tb is
end entity;

architecture test of register_file_tb is

    signal clk          : bit := '0';
    signal rst          : bit := '0';
    signal write_enable : bit := '0';

    signal read_addr_a  : bit_vector(1 downto 0);
    signal read_addr_b  : bit_vector(1 downto 0);
    signal write_addr   : bit_vector(1 downto 0);

    signal write_data   : bit_vector(3 downto 0);

    signal data_a       : bit_vector(3 downto 0);
    signal data_b       : bit_vector(3 downto 0);

begin

    DUT : entity work.register_file
        port map(
            clk          => clk,
            rst          => rst,
            write_enable => write_enable,
            read_addr_a  => read_addr_a,
            read_addr_b  => read_addr_b,
            write_addr   => write_addr,
            write_data   => write_data,
            data_a       => data_a,
            data_b       => data_b
        );

    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 5 ns;
            clk <= '1';
            wait for 5 ns;
        end loop;
    end process;

    stim_process : process
    begin
        -- Reset registers
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 10 ns;

        -- Check initial values after reset
        read_addr_a <= "00";
        read_addr_b <= "01";
        wait for 10 ns;
        assert data_a = "0000" and data_b = "0001"
            report "Reset read failed: R0/R1"
            severity error;

        read_addr_a <= "10";
        read_addr_b <= "11";
        wait for 10 ns;
        assert data_a = "0010" and data_b = "0011"
            report "Reset read failed: R2/R3"
            severity error;

        -- Write 1010 into R2
        write_enable <= '1';
        write_addr   <= "10";
        write_data   <= "1010";
        wait for 10 ns;

        write_enable <= '0';

        -- Read R2
        read_addr_a <= "10";
        wait for 10 ns;
        assert data_a = "1010"
            report "Write/read failed: R2"
            severity error;

        -- Write 1111 into R3
        write_enable <= '1';
        write_addr   <= "11";
        write_data   <= "1111";
        wait for 10 ns;

        write_enable <= '0';

        -- Read R3 and R2
        read_addr_a <= "11";
        read_addr_b <= "10";
        wait for 10 ns;
        assert data_a = "1111" and data_b = "1010"
            report "Write/read failed: R3/R2"
            severity error;

        report "All register file tests passed."
            severity note;

        wait;
    end process;

end architecture;