library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity regs is
    generic (
        WSIZE : natural := 32
    );
    port (
        clk  : in std_logic;
        wren : in std_logic;

        rs1  : in std_logic_vector(4 downto 0);
        rs2  : in std_logic_vector(4 downto 0);
        rd   : in std_logic_vector(4 downto 0);

        data : in std_logic_vector(WSIZE-1 downto 0);

        ro1  : out std_logic_vector(WSIZE-1 downto 0);
        ro2  : out std_logic_vector(WSIZE-1 downto 0)
    );
end entity regs;

architecture comportamento of regs is

    -- Banco de 32 registradores
    type banco_registradores is array (0 to 31)
        of std_logic_vector(WSIZE-1 downto 0);

    signal registradores : banco_registradores :=
        (others => (others => '0'));

begin

    -- Escrita sincrona na borda de subida
    process(clk)
    begin
        if rising_edge(clk) then
            if wren = '1' then

                -- x0 nunca pode ser alterado
                if unsigned(rd) /= 0 then
                    registradores(to_integer(unsigned(rd))) <= data;
                end if;

            end if;
        end if;
    end process;

    -- Leitura assincrona pela porta 1
    ro1 <= (others => '0') when unsigned(rs1) = 0
           else registradores(to_integer(unsigned(rs1)));

    -- Leitura assincrona pela porta 2
    ro2 <= (others => '0') when unsigned(rs2) = 0
           else registradores(to_integer(unsigned(rs2)));

end architecture comportamento;