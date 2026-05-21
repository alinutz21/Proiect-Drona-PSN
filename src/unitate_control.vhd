library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity unitate_control is
    Port(
        clk: in STD_LOGIC;
        rst: in STD_LOGIC;
        
        start_misiune: in STD_LOGIC;
        resetare_manuala: in STD_LOGIC;
        confirmare_aterizare: in STD_LOGIC;
        cerere_intoarcere: in STD_LOGIC;
        
        tinta_atinsa: in STD_LOGIC;
        baza_atinsa: in STD_LOGIC;
        baterie_scazuta: in STD_LOGIC;
        obstacol_detectat: in STD_LOGIC;
        pierdere_GPS: in STD_LOGIC;
        
        T_Done: in STD_LOGIC;
        
        activare_motoare: out STD_LOGIC;
        activare_navigatie: out STD_LOGIC;
        activare_sarcina_utila: out STD_LOGIC;
        mod_intoarcere: out STD_LOGIC;
        alarma: out STD_LOGIC;
        
        EN_Timer: out STD_LOGIC;
        Reset_Timer: out STD_LOGIC;
        
        Valoare_Max: out integer range 0 to 999;
        
        Stare_Curenta: out STD_LOGIC_VECTOR(3 downto 0)
    );
end unitate_control;

architecture Behavioral of unitate_control is
    
    type state_type is (
        S0_IDLE,
        S1_PRE_CHECK,
        S2_TAKEOFF,
        S3_NAV,
        S4_EXEC,
        S5_RETURN,
        S6_LAND,
        S7_EMERGENCY,
        S8_AVOID
    );
    
    signal stare_curenta_int : state_type;
    signal stare_urmatoare   : state_type;
    
begin
    PROCES_REGISTRU: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then 
                stare_curenta_int <= S0_IDLE;
            else 
                stare_curenta_int <= stare_urmatoare;
            end if;
        end if;
    end process;
    
    Stare_Curenta <= "0000" when stare_curenta_int = S0_IDLE else
                     "0001" when stare_curenta_int = S1_PRE_CHECK else
                     "0010" when stare_curenta_int = S2_TAKEOFF else
                     "0011" when stare_curenta_int = S3_NAV else
                     "0100" when stare_curenta_int = S4_EXEC else
                     "0101" when stare_curenta_int = S5_RETURN else
                     "0110" when stare_curenta_int = S6_LAND else
                     "0111" when stare_curenta_int = S7_EMERGENCY else
                     "1000";
    
    PROCES_TRANZITII: process(stare_curenta_int, start_misiune, resetare_manuala,
                              confirmare_aterizare, cerere_intoarcere,
                              tinta_atinsa, baza_atinsa, baterie_scazuta,
                              obstacol_detectat, pierdere_GPS, T_Done)
    begin
        stare_urmatoare <= stare_curenta_int;
        
        case stare_curenta_int is
            
            when S0_IDLE =>
                if start_misiune = '1' then
                    stare_urmatoare <= S1_PRE_CHECK;
                end if;
            
            when S1_PRE_CHECK =>
                if baterie_scazuta = '1' then
                    stare_urmatoare <= S0_IDLE;
                elsif T_Done = '1' then
                    stare_urmatoare <= S2_TAKEOFF;
                end if;
            
            when S2_TAKEOFF =>
                if baterie_scazuta = '1' or pierdere_GPS = '1' then
                    stare_urmatoare <= S7_EMERGENCY;
                elsif T_Done = '1' then
                    stare_urmatoare <= S3_NAV;
                end if;
            
            when S3_NAV =>
                if pierdere_GPS = '1' then
                    stare_urmatoare <= S7_EMERGENCY;
                elsif baterie_scazuta = '1' or cerere_intoarcere = '1' then
                    stare_urmatoare <= S5_RETURN;
                elsif obstacol_detectat = '1' then
                    stare_urmatoare <= S8_AVOID;
                elsif tinta_atinsa = '1' then
                    stare_urmatoare <= S4_EXEC;
                end if;
            
            when S4_EXEC =>
                if pierdere_GPS = '1' then
                    stare_urmatoare <= S7_EMERGENCY;
                elsif T_Done = '1' or baterie_scazuta = '1' then
                    stare_urmatoare <= S5_RETURN;
                end if;
            
            when S5_RETURN =>
                if baterie_scazuta = '1' or pierdere_GPS = '1' then
                    stare_urmatoare <= S7_EMERGENCY;
                elsif baza_atinsa = '1' then
                    stare_urmatoare <= S6_LAND;
                end if;
            
            when S6_LAND =>
                if confirmare_aterizare = '1' then
                    stare_urmatoare <= S0_IDLE;
                elsif T_Done = '1' and confirmare_aterizare = '0' then
                    stare_urmatoare <= S7_EMERGENCY;
                end if;
            
            when S7_EMERGENCY =>
                if resetare_manuala = '1' then
                    stare_urmatoare <= S0_IDLE;
                end if;
            
            when S8_AVOID =>
                if obstacol_detectat = '0' then
                    stare_urmatoare <= S3_NAV;
                elsif T_Done = '1' and obstacol_detectat = '1' then
                    stare_urmatoare <= S5_RETURN;
                end if;
            
            when others =>
                stare_urmatoare <= S0_IDLE;
                
        end case;
    end process;
    
    
    PROCES_IESIRI: process(stare_curenta_int)
    begin
        activare_motoare <= '0';
        activare_navigatie <= '0';
        activare_sarcina_utila <= '0';
        mod_intoarcere <= '0';
        alarma <= '0';
        EN_Timer <= '0';
        Reset_Timer <= '0';
        Valoare_Max <= 0;
        
        case stare_curenta_int is
            
            when S0_IDLE =>
                Reset_Timer <= '1';  
            
            when S1_PRE_CHECK =>
                EN_Timer <= '1';
                Valoare_Max <= 10;
            
            when S2_TAKEOFF =>
                activare_motoare <= '1';
                EN_Timer <= '1';
                Valoare_Max <= 13; 
            
            when S3_NAV =>
                activare_motoare <= '1';
                activare_navigatie <= '1';
                Reset_Timer <= '1';
            
            when S4_EXEC =>
                activare_motoare <= '1';
                activare_sarcina_utila <= '1';
                EN_Timer <= '1';
                Valoare_Max <= 12;
            
            when S5_RETURN =>
                activare_motoare <= '1';
                activare_navigatie <= '1';
                mod_intoarcere <= '1';
                Reset_Timer <= '1'; 
            
            when S6_LAND =>
                activare_motoare <= '1';
                EN_Timer <= '1';
                Valoare_Max <= 90;
            
            when S7_EMERGENCY =>
                activare_motoare <= '1';
                alarma <= '1';
                Reset_Timer <= '1';  
            
            when S8_AVOID =>
                activare_motoare <= '1';
                EN_Timer <= '1';
                Valoare_Max <= 15;
            
            when others =>
                null;
                
        end case;
    end process;
    
end Behavioral;