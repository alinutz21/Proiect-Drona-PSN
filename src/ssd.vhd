library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ssd is
    Port ( clk : in  STD_LOGIC;
           digit0 : in  STD_LOGIC_VECTOR (3 downto 0);
           digit1 : in  STD_LOGIC_VECTOR (3 downto 0);
           digit2 : in  STD_LOGIC_VECTOR (3 downto 0);
           digit3 : in  STD_LOGIC_VECTOR (3 downto 0);
           digit4 : in  STD_LOGIC_VECTOR (3 downto 0);
           digit5 : in  STD_LOGIC_VECTOR (3 downto 0);
           digit6 : in  STD_LOGIC_VECTOR (3 downto 0);
           digit7 : in  STD_LOGIC_VECTOR (3 downto 0);
           dp_in : in  STD_LOGIC_VECTOR (7 downto 0);   
           anod : out  STD_LOGIC_VECTOR (7 downto 0);
           catod : out  STD_LOGIC_VECTOR (6 downto 0);
           dp_out : out STD_LOGIC);
end ssd;

architecture Behavioral of ssd is

    signal numar: std_logic_vector (15 downto 0) := (others => '0');
    signal hex: std_logic_vector (3 downto 0);

begin

process(CLK)
begin
    if(CLK='1' and CLK'EVENT) then
          numar<=numar+1;
    end if;
end process;

process(numar)
begin
    case(numar(15 downto 13)) is
        when "000" => anod<=b"1111_1110";
        when "001" => anod<=b"1111_1101";
        when "010" => anod<=b"1111_1011";
        when "011" => anod<=b"1111_0111";
        when "100" => anod<=b"1110_1111";
        when "101" => anod<=b"1101_1111";
        when "110" => anod<=b"1011_1111";
        when others => anod<=b"0111_1111";
    end case;
end process;

process(numar)
begin
    case(numar(15 downto 13))is
        when "000" => hex<=digit0;
        when "001" => hex<=digit1;
        when "010" => hex<=digit2;
        when "011" => hex<=digit3;
        when "100" => hex<=digit4;
        when "101" => hex<=digit5;
        when "110" => hex<=digit6;
        when others => hex<=digit7;
    end case;
end process;

process(numar, dp_in)
begin
    case(numar(15 downto 13))is
        when "000" => dp_out <= not dp_in(0);
        when "001" => dp_out <= not dp_in(1);
        when "010" => dp_out <= not dp_in(2);
        when "011" => dp_out <= not dp_in(3);
        when "100" => dp_out <= not dp_in(4);
        when "101" => dp_out <= not dp_in(5);
        when "110" => dp_out <= not dp_in(6);
        when others => dp_out <= not dp_in(7);
    end case;
end process;

process(hex)
begin
    case (hex) is
        when "0000" => catod <= "0000001";
        when "0001" => catod <= "1001111"; 
        when "0010" => catod <= "0010010"; 
        when "0011" => catod <= "0000110"; 
        when "0100" => catod <= "1001100";
        when "0101" => catod <= "0100100"; 
        when "0110" => catod <= "0100000"; 
        when "0111" => catod <= "0001111"; 
        when "1000" => catod <= "0000000"; 
        when "1001" => catod <= "0000100"; 
        when others => catod <= "1111111"; 
end case;
end process;

end Behavioral;