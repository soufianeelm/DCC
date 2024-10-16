----------------------------------------------------------------------------------
-- Company: SORBONNE UNIVERSITE
-- Designed by: S.EL MOUAHID, Spring 2024
--
-- Module Name: Top_DCC - Behavioral
-- Project Name: Centrale DCC
-- Target Devices: Basys 3
-- 
--	Déscription à mettre !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_DCC is
    Port (Clk : in STD_LOGIC;
          Reset : in STD_LOGIC;
          Trame_DCC : in STD_LOGIC_VECTOR(50 downto 0);
          Final_Data : out STD_LOGIC
           );
end Top_DCC;

architecture Behavioral of Top_DCC is

-- MAE/Compteur Tempo
signal Fin_Tempo, Fin_Charge, Fin_Dec : STD_LOGIC;
signal Fin_Trame, Fin_1, Fin_0 : STD_LOGIC;
signal Data, Go_1, Go_0 : STD_LOGIC;
signal Start_Tempo, Go_Charge, Go_Dec, Go_Trame : STD_LOGIC;

-- DCC_Bit_0/1
signal DCC_0, DCC_1 : STD_LOGIC;

-- Diviseur Horloge
signal Clk1M : STD_LOGIC;

begin
    
    -- MAE
    MAE: entity work.MAE
        port map (
            Clk => Clk,
            Reset => Reset,
            Fin_Tempo => Fin_Tempo,
            Fin_Charge => Fin_Charge,
            Fin_Dec => Fin_Dec,
            Fin_Trame => Fin_Trame,
            Fin_1 => Fin_1,
            Fin_0 => Fin_0,
            Data => Data,
            Go_1 => Go_1,
            Go_0 => Go_0,
            Go_Tempo => Start_Tempo,
            Go_Charge => Go_charge,
            Go_Dec => Go_Dec,
            Go_Trame => Go_Trame
        );
    
    -- Compteur_Tempo
    CT: entity work.COMPTEUR_TEMPO
        port map (
            Clk => Clk,
            Reset => Reset,
            Clk1M => Clk1M,
            Start_Tempo => Start_Tempo,
            Fin_Tempo => Fin_tempo
        );
        
    -- Registre DCC
    RD: entity work.REG_DCC
        port map (
            Clk => Clk,
            Reset => Reset,
            Go_Trame => Go_Trame,
            Go_Charge => Go_Charge,
            Go_Dec => Go_Dec,
            Trame_DCC => Trame_DCC,
            Data => Data,
            Fin_Charge => Fin_Charge,
            Fin_Dec => Fin_Dec,
            Fin_Trame => Fin_Trame
        );
        
    -- DCC_Bit_0
    DB0 : entity work.DCC_Bit_0
        port map (
            Clk => Clk,
            Reset => Reset,
            Clk1M => Clk1M,
            Go_0 => Go_0,
            Fin_0 => Fin_0,
            DCC_0 => DCC_0
        );
    
    -- DCC_Bit_1
    DB1 : entity work.DCC_Bit_1
        port map (
            Clk => Clk,
            Reset => Reset,
            Clk1M => Clk1M,
            Go_1 => Go_1,
            Fin_1 => Fin_1,
            DCC_1 => DCC_1
        );
    
    -- Diviseur Horloge
    DH : entity work.CLK_DIV
        port map (
            Reset => Reset,
            Clk_In => Clk,
            Clk_Out => Clk1M
        );
    
    Final_Data <= DCC_0 or DCC_1;

end Behavioral;
