library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bcd_converter is
    Port(
        Valoare_Min: in STD_LOGIC_VECTOR(3 downto 0);
        Valoare_Sec: in STD_LOGIC_VECTOR(5 downto 0);
        Stare_Curenta: in STD_LOGIC_VECTOR(3 downto 0);
        
        digit0 : out STD_LOGIC_VECTOR(3 downto 0);
        digit1 : out STD_LOGIC_VECTOR(3 downto 0);
        digit2 : out STD_LOGIC_VECTOR(3 downto 0);
        digit3 : out STD_LOGIC_VECTOR(3 downto 0);
        digit4 : out STD_LOGIC_VECTOR(3 downto 0);
        digit5 : out STD_LOGIC_VECTOR(3 downto 0);
        digit6 : out STD_LOGIC_VECTOR(3 downto 0);
        digit7 : out STD_LOGIC_VECTOR(3 downto 0)
    );
end bcd_converter;

architecture Behavioral of bcd_converter is
    signal sec_int : integer range 0 to 63;
    signal min_int : integer range 0 to 15;
begin
    sec_int <= to_integer(unsigned(Valoare_Sec));
    min_int <= to_integer(unsigned(Valoare_Min));
    
    digit0 <= std_logic_vector(to_unsigned(sec_int mod 10,4));
    digit1 <= std_logic_vector(to_unsigned(sec_int / 10, 4));
    digit2 <= std_logic_vector(to_unsigned(min_int mod 10, 4));
    digit3 <= std_logic_vector(to_unsigned(min_int / 10, 4));
    digit4 <= "0000";
    digit5 <= "0000";
    digit6 <= "0000";
    digit7 <= Stare_Curenta;

end Behavioral;
