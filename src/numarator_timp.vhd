library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity numarator_timp is
    Port( 
        clk:in STD_LOGIC;
        rst: in STD_LOGIC;
        tick_sec: in STD_LOGIC;
        EN_Timer: in STD_LOGIC;
        Reset_Timer:in STD_LOGIC;
        Valoare_Max:in integer range 0 to 999;
        T_Done: out STD_LOGIC;
        Valoare_Sec: out STD_LOGIC_VECTOR(5 downto 0);
        Valoare_Min: out STD_LOGIC_VECTOR(3 downto 0)
    );
end numarator_timp;

architecture Behavioral of numarator_timp is
    signal secunde: integer range 0  to 999 := 0;
    signal EN_Timer_prev: STD_LOGIC := '0';
    signal Valoare_Max_prev : integer range 0 to 999 := 0;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            T_Done <= '0'; 
            
            if rst = '1' then
                secunde <= 0;
                EN_Timer_prev <= '0';
                Valoare_Max_prev <= 0;
            else
                EN_Timer_prev <= EN_Timer;
                Valoare_Max_prev <= Valoare_Max;
                
                -- 30s -> 60s
                if (EN_Timer = '1' and EN_Timer_prev = '0') or 
                   (EN_Timer = '1' and Valoare_Max /= Valoare_Max_prev) then
                    secunde <= Valoare_Max;
                    
                elsif Reset_Timer ='1' then
                    secunde <= 0;
                    
                elsif EN_Timer = '1' and tick_sec = '1' then
                    if secunde > 0 then
                        secunde <= secunde - 1;
                        
                        if secunde = 1 then
                            T_Done <= '1';
                        end if;
                    end if; 
                end if;   
            end if;
        end if;
    end process;

    Valoare_Min <= std_logic_vector(to_unsigned(secunde / 60, 4));
    Valoare_Sec <= std_logic_vector(to_unsigned(secunde mod 60, 6));

end Behavioral;