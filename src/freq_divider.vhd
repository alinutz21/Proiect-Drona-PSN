library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity freq_divider is
    generic(
        DIVISOR: integer := 100_000_000
    );
    Port( 
        clk: in STD_LOGIC;
        rst: in STD_LOGIC;
        tick_sec: out STD_LOGIC
    );
end freq_divider;

architecture Behavioral of freq_divider is
    signal count: integer range 0 to DIVISOR - 1;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                count <= 0;
                tick_sec <= '0';
            elsif count = DIVISOR - 1 then
                count <= 0;
                tick_sec <= '1';
            else
                count <= count + 1;
                tick_sec <= '0';
            end if;
        end if;
    end process;

end Behavioral;
