library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity drone_mission_top is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        -- Butoane
        start_misiune : in STD_LOGIC;
        resetare_manuala : in STD_LOGIC;
        confirmare_aterizare : in STD_LOGIC;
        cerere_intoarcere : in STD_LOGIC;
        -- Switch
        tinta_atinsa : in STD_LOGIC;
        baza_atinsa : in STD_LOGIC;
        baterie_scazuta : in STD_LOGIC;
        obstacol_detectat : in STD_LOGIC;
        pierdere_GPS : in STD_LOGIC;
        -- LED
        activare_motoare : out STD_LOGIC;
        activare_navigatie : out STD_LOGIC;
        activare_sarcina_utila : out STD_LOGIC;
        mod_intoarcere : out STD_LOGIC;
        alarma : out STD_LOGIC;
        -- SSD
        anod : out STD_LOGIC_VECTOR(7 downto 0);
        catod : out STD_LOGIC_VECTOR(6 downto 0);
        dp : out STD_LOGIC
    );
end drone_mission_top;

architecture Structural of drone_mission_top is

    component freq_divider is
        generic (
            DIVISOR : integer := 100_000_000
        );
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            tick_sec : out STD_LOGIC
        );
    end component;
    
    component MPG is
        Port (
            btn : in STD_LOGIC;
            clk : in STD_LOGIC;
            en : out STD_LOGIC
        );
    end component;
     
    component numarator_timp is
        Port (
                clk: in STD_LOGIC;
                rst: in STD_LOGIC;
                tick_sec: in STD_LOGIC;
                EN_Timer: in STD_LOGIC;
                Reset_Timer: in STD_LOGIC;
                Valoare_Max: in integer range 0 to 999;
                        
                T_Done: out STD_LOGIC;    
                Valoare_Sec: out STD_LOGIC_VECTOR(5 downto 0);
                Valoare_Min: out STD_LOGIC_VECTOR(3 downto 0)            
             );
    end component;
    
    component unitate_control is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            start_misiune : in STD_LOGIC;
            resetare_manuala : in STD_LOGIC;
            confirmare_aterizare : in STD_LOGIC;
            cerere_intoarcere : in STD_LOGIC;
            tinta_atinsa : in STD_LOGIC;
            baza_atinsa : in STD_LOGIC;
            baterie_scazuta : in STD_LOGIC;
            obstacol_detectat : in STD_LOGIC;
            pierdere_GPS : in STD_LOGIC;
            T_Done : in STD_LOGIC;
            activare_motoare : out STD_LOGIC;
            activare_navigatie : out STD_LOGIC;
            activare_sarcina_utila : out STD_LOGIC;
            mod_intoarcere : out STD_LOGIC;
            alarma : out STD_LOGIC;
            EN_Timer : out STD_LOGIC;
            Reset_Timer : out STD_LOGIC;
            Valoare_Max : out integer range 0 to 999;
            Stare_Curenta : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
    
    component bcd_converter is
        Port (
            Valoare_Min : in STD_LOGIC_VECTOR(3 downto 0);
            Valoare_Sec : in STD_LOGIC_VECTOR(5 downto 0);
            Stare_Curenta : in STD_LOGIC_VECTOR(3 downto 0);
            digit0 : out STD_LOGIC_VECTOR(3 downto 0);
            digit1 : out STD_LOGIC_VECTOR(3 downto 0);
            digit2 : out STD_LOGIC_VECTOR(3 downto 0);
            digit3 : out STD_LOGIC_VECTOR(3 downto 0);
            digit4 : out STD_LOGIC_VECTOR(3 downto 0);
            digit5 : out STD_LOGIC_VECTOR(3 downto 0);
            digit6 : out STD_LOGIC_VECTOR(3 downto 0);
            digit7 : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;
    
    component ssd is
        Port (
            clk : in STD_LOGIC;
            digit0 : in STD_LOGIC_VECTOR(3 downto 0);
            digit1 : in STD_LOGIC_VECTOR(3 downto 0);
            digit2 : in STD_LOGIC_VECTOR(3 downto 0);
            digit3 : in STD_LOGIC_VECTOR(3 downto 0);
            digit4 : in STD_LOGIC_VECTOR(3 downto 0);
            digit5 : in STD_LOGIC_VECTOR(3 downto 0);
            digit6 : in STD_LOGIC_VECTOR(3 downto 0);
            digit7 : in STD_LOGIC_VECTOR(3 downto 0);
            dp_in : in STD_LOGIC_VECTOR(7 downto 0);
            anod : out STD_LOGIC_VECTOR(7 downto 0);
            catod : out STD_LOGIC_VECTOR(6 downto 0);
            dp_out : out STD_LOGIC
        );
    end component;
   
    -- semnale din mpg
    signal start_misiune_clean : STD_LOGIC;
    signal resetare_manuala_clean : STD_LOGIC;
    signal confirmare_aterizare_clean : STD_LOGIC;
    signal cerere_intoarcere_clean : STD_LOGIC;
    signal tinta_atinsa_clean : STD_LOGIC;
    signal baza_atinsa_clean : STD_LOGIC;
    signal baterie_scazuta_clean : STD_LOGIC;
    signal obstacol_detectat_clean : STD_LOGIC;
    signal pierdere_GPS_clean : STD_LOGIC;
    
    -- Semnale UE
    signal tick_sec_int : STD_LOGIC;
    signal tick_min_int : STD_LOGIC;
    signal T_Done_int : STD_LOGIC;
    
    -- Semnale de la UC la UE
    signal EN_Timer_int : STD_LOGIC;
    signal Reset_Timer_int : STD_LOGIC;
    signal Valoare_Max_int : integer range 0 to 999;
    
    -- Semnale de la UE la bcd_convertor
    signal Valoare_Sec_int : STD_LOGIC_VECTOR(5 downto 0);
    signal Valoare_Min_int : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Semnal de la UC la bcd_convertor
    signal Stare_Curenta_int : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Semnal alarma
    signal alarma_int : STD_LOGIC;
    signal clipire : STD_LOGIC := '0';
    
    -- Semnale de la bcd_converter la ssd
    signal digit0_int : STD_LOGIC_VECTOR(3 downto 0);
    signal digit1_int : STD_LOGIC_VECTOR(3 downto 0);
    signal digit2_int : STD_LOGIC_VECTOR(3 downto 0);
    signal digit3_int : STD_LOGIC_VECTOR(3 downto 0);
    signal digit4_int : STD_LOGIC_VECTOR(3 downto 0);
    signal digit5_int : STD_LOGIC_VECTOR(3 downto 0);
    signal digit6_int : STD_LOGIC_VECTOR(3 downto 0);
    signal digit7_int : STD_LOGIC_VECTOR(3 downto 0);

begin
    -- MPG intrari
    MPG_start: MPG port map (btn => start_misiune, clk => clk, en => start_misiune_clean);
    MPG_reset_man: MPG port map (btn => resetare_manuala, clk => clk, en => resetare_manuala_clean);
    MPG_confirm: MPG port map (btn => confirmare_aterizare, clk => clk, en => confirmare_aterizare_clean);
    MPG_cerere: MPG port map (btn => cerere_intoarcere, clk => clk, en => cerere_intoarcere_clean);
    MPG_tinta: MPG port map (btn => tinta_atinsa, clk => clk, en => tinta_atinsa_clean);
    MPG_baza: MPG port map (btn => baza_atinsa, clk => clk, en => baza_atinsa_clean);
    MPG_baterie: MPG port map (btn => baterie_scazuta, clk => clk, en => baterie_scazuta_clean);
    MPG_obstacol: MPG port map (btn => obstacol_detectat, clk => clk, en => obstacol_detectat_clean);
    MPG_GPS: MPG port map (btn => pierdere_GPS, clk => clk, en => pierdere_GPS_clean);
    
   
    U1: freq_divider
        generic map (
           DIVISOR => 100_000_000
           --DIVISOR => 5
        )
        port map (
            clk => clk,
            rst => rst,
            tick_sec => tick_sec_int
        );
    
    U2: numarator_timp
        port map (
            clk => clk,
            rst => rst,
            tick_sec => tick_sec_int,
            Reset_Timer => Reset_Timer_int,
            EN_Timer => EN_Timer_int,
            Valoare_Max =>  Valoare_Max_int,
            T_Done => T_Done_int,
            Valoare_Sec => Valoare_Sec_int,
            Valoare_Min => Valoare_Min_int
        );

    U4: unitate_control
        port map (
            clk => clk,
            rst => rst,
            start_misiune => start_misiune_clean,
            resetare_manuala => resetare_manuala_clean,
            confirmare_aterizare => confirmare_aterizare_clean,
            cerere_intoarcere => cerere_intoarcere_clean,
            tinta_atinsa => tinta_atinsa_clean,
            baza_atinsa => baza_atinsa_clean,
            baterie_scazuta => baterie_scazuta_clean,
            obstacol_detectat => obstacol_detectat,
            pierdere_GPS => pierdere_GPS_clean,
            T_Done => T_Done_int,
            activare_motoare => activare_motoare,
            activare_navigatie => activare_navigatie,
            activare_sarcina_utila => activare_sarcina_utila,
            mod_intoarcere => mod_intoarcere,
            alarma => alarma_int,  
            EN_Timer => EN_Timer_int,
            Reset_Timer => Reset_Timer_int,
            Valoare_Max => Valoare_Max_int,
            Stare_Curenta => Stare_Curenta_int
        );
    
    U5: bcd_converter
        port map (
            Valoare_Min => Valoare_Min_int,
            Valoare_Sec => Valoare_Sec_int,
            Stare_Curenta => Stare_Curenta_int,
            digit0 => digit0_int,
            digit1 => digit1_int,
            digit2 => digit2_int,
            digit3 => digit3_int,
            digit4 => digit4_int,
            digit5 => digit5_int,
            digit6 => digit6_int,
            digit7 => digit7_int
        );
    
    U6: ssd
        port map (
            clk => clk,
            digit0 => digit0_int,
            digit1 => digit1_int,
            digit2 => digit2_int,
            digit3 => digit3_int,
            digit4 => digit4_int,
            digit5 => digit5_int,
            digit6 => digit6_int,
            digit7 => digit7_int,
            dp_in => "00000100",   
            anod => anod,
            catod => catod,
            dp_out => dp
        );
    
    PROCES_CLIPIRE: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                clipire <= '0';
            elsif tick_sec_int = '1' then
                clipire <= not clipire;
            end if;
        end if;
    end process;
    
    -- LED alarma
    alarma <= alarma_int and clipire;

end Structural;