library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity regs_tb is
end entity regs_tb;

architecture teste of regs_tb is

    constant WSIZE : natural := 32;
    constant CLK_PERIOD : time := 10 ns;

    signal clk  : std_logic := '0';
    signal wren : std_logic := '0';

    signal rs1 : std_logic_vector(4 downto 0) := (others => '0');
    signal rs2 : std_logic_vector(4 downto 0) := (others => '0');
    signal rd  : std_logic_vector(4 downto 0) := (others => '0');

    signal data : std_logic_vector(WSIZE-1 downto 0) :=
        (others => '0');

    signal ro1 : std_logic_vector(WSIZE-1 downto 0);
    signal ro2 : std_logic_vector(WSIZE-1 downto 0);

    signal etapa : integer := 0;
    signal simulacao_ativa : boolean := true;

begin

    -- Instancia o banco de registradores
    DUT: entity work.regs
        generic map (
            WSIZE => WSIZE
        )
        port map (
            clk  => clk,
            wren => wren,
            rs1  => rs1,
            rs2  => rs2,
            rd   => rd,
            data => data,
            ro1  => ro1,
            ro2  => ro2
        );

    -- Gerador de clock
    clock_process: process
    begin
        while simulacao_ativa loop
            clk <= '0';
            wait for CLK_PERIOD / 2;

            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;

        wait;
    end process;

    -- Processo de testes
    stimulus: process

        variable valor_esperado :
            std_logic_vector(WSIZE-1 downto 0);

    begin

        -------------------------------------------------
        -- TESTE 1: REGISTRADOR ZERO
        -------------------------------------------------

        etapa <= 1;

        rs1 <= "00000";
        rs2 <= "00000";

        wait for 2 ns;

        assert ro1 = x"00000000"
            report "ERRO: x0 diferente de zero em ro1"
            severity error;

        assert ro2 = x"00000000"
            report "ERRO: x0 diferente de zero em ro2"
            severity error;

        -------------------------------------------------
        -- TESTE 2: PREENCHIMENTO DOS REGISTRADORES
        -------------------------------------------------

        etapa <= 2;

        wren <= '1';

        for i in 1 to 31 loop

            -- Cada registrador recebe i * 10
            rd <= std_logic_vector(to_unsigned(i, 5));

            data <= std_logic_vector(
                to_unsigned(i * 10, WSIZE)
            );

            -- Aguarda a proxima borda de subida
            wait until rising_edge(clk);
            wait for 1 ns;

        end loop;

        wren <= '0';

        -------------------------------------------------
        -- TESTE 3: LEITURA PELA PORTA 1
        -------------------------------------------------

        etapa <= 3;

        for i in 1 to 31 loop

            rs1 <= std_logic_vector(to_unsigned(i, 5));

            valor_esperado := std_logic_vector(
                to_unsigned(i * 10, WSIZE)
            );

            wait for 10 ns;

            assert ro1 = valor_esperado
                report "ERRO: leitura incorreta em ro1"
                severity error;

        end loop;

        -------------------------------------------------
        -- TESTE 4: LEITURA PELA PORTA 2
        -------------------------------------------------

        etapa <= 4;

        for i in 1 to 31 loop

            rs2 <= std_logic_vector(to_unsigned(i, 5));

            valor_esperado := std_logic_vector(
                to_unsigned(i * 10, WSIZE)
            );

            wait for 10 ns;

            assert ro2 = valor_esperado
                report "ERRO: leitura incorreta em ro2"
                severity error;

        end loop;

        -------------------------------------------------
        -- TESTE 5: ESCRITA NO REGISTRADOR ZERO
        -------------------------------------------------

        etapa <= 5;

        rd <= "00000";
        data <= x"FFFFFFFF";
        wren <= '1';

        rs1 <= "00000";
        rs2 <= "00000";

        wait until rising_edge(clk);
        wait for 1 ns;

        assert ro1 = x"00000000"
            report "ERRO: x0 foi alterado em ro1"
            severity error;

        assert ro2 = x"00000000"
            report "ERRO: x0 foi alterado em ro2"
            severity error;

        wren <= '0';

        -------------------------------------------------
        -- TESTE 6: ESCRITA DESABILITADA
        -------------------------------------------------

        etapa <= 6;

        rd <= "00101";  -- x5
        data <= x"AAAAAAAA";
        wren <= '0';

        rs1 <= "00101";
        rs2 <= "00101";

        wait until rising_edge(clk);
        wait for 1 ns;

        -- x5 deve continuar com 50
        assert ro1 = x"00000032"
            report "ERRO: escrita ocorreu com wren=0"
            severity error;

        assert ro2 = x"00000032"
            report "ERRO: ro2 alterado com wren=0"
            severity error;

        -------------------------------------------------
        -- TESTE 7: SOBRESCRITA DO REGISTRADOR X5
        -------------------------------------------------

        etapa <= 7;

        rd <= "00101";
        data <= x"12345678";
        wren <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        assert ro1 = x"12345678"
            report "ERRO: sobrescrita de x5 em ro1"
            severity error;

        assert ro2 = x"12345678"
            report "ERRO: sobrescrita de x5 em ro2"
            severity error;

        wren <= '0';

        -------------------------------------------------
        -- TESTE 8: LEITURA SIMULTANEA
        -------------------------------------------------

        etapa <= 8;

        rs1 <= "00101";  -- x5
        rs2 <= "01010";  -- x10

        wait for 10 ns;

        assert ro1 = x"12345678"
            report "ERRO: leitura simultanea ro1"
            severity error;

        assert ro2 = x"00000064"
            report "ERRO: leitura simultanea ro2"
            severity error;

        -------------------------------------------------
        -- FIM DA SIMULACAO
        -------------------------------------------------

        etapa <= 9;

        report "TODOS OS TESTES CONCLUIDOS!"
            severity note;

        simulacao_ativa <= false;

        wait;

    end process;

end architecture teste;