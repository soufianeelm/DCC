----------------------------------------------------------------------------------
-- Company: SORBONNE UNIVERSITE
-- Designed by: S.EL MOUAHID, Spring 2024
--
-- Module Name: MAE - Behavioral
-- Project Name: Centrale DCC
-- Target Devices: Basys 3
-- 
--	Machine à état de la Centrale DCC, positionne Go_Trame et Go_Charge à 1, puis 
--  attend le passage à 1 de Fin_Charge pour remettre Go_Charge à 0
--
--  Ensuite si Data est positionné à 0 alors la MAE positionne Go_0 à 1 puis attend 
--  le passage à 1 de Fin_0 pour remettre Go_0 à 0
--  si Data est positionné à 1 alors la MAE positionne Go_1 à 1, puis attend le 
--  passage à 1 de Fin_1 pour remettre Go_1 à 0
--  
--  Par la suite, la MAE positionne Go_Dec à 1, puis attend le passage à 1 de 
--  Fin_Dec pour remettre Go_Dec à 0 et reprendre le processus décrit précédemment
-- 
--  Lorsque Fin_Trame passe à 1, la MAE remet Go_Trame à 0 et positionne Go_Tempo 
--  à 1, puis attend le passage de Fin_Tempo à 1 pour remettre Go_Tempo à 0 et 
--  reprendre du début
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MAE is
    Port (Clk         : in STD_LOGIC;       -- Horloge 100 MHz
          Reset       : in STD_LOGIC;       -- Reset Asynchrone
          Fin_Tempo   : in STD_LOGIC;       -- Drapeau de Fin de Temporisation
          Fin_Charge  : in STD_LOGIC;       -- Drapeau de Fin de Chargement 
          Fin_Dec     : in STD_LOGIC;       -- Drapeau de Fin de Décalage
          Fin_Trame   : in STD_LOGIC;       -- Drapeau de Fin de la Trame
          Fin_1       : in STD_LOGIC;       -- Drapeau de Fin de Transmission du 1
          Fin_0       : in STD_LOGIC;       -- Drapeau de Fin de Transmission du 0
          Data        : in STD_LOGIC;       -- Data à Transmettre
          Go_1        : out STD_LOGIC;      -- Lance la Transmission d'un 1
          Go_0        : out STD_LOGIC;      -- Lance la Transmission d'un 0
          Go_Tempo    : out STD_LOGIC;      -- Lance Compteur de Temporisation
          Go_Charge   : out STD_LOGIC;      -- Lance le Chargement dans Registre DCC
          Go_Dec      : out STD_LOGIC;      -- Lance le Décalage dans Registre DCC
          Go_Trame    : out STD_LOGIC       -- Lance la Transmission de la Data Depuis Registre DCC
          );
end MAE;

architecture Behavioral of MAE is

signal Q : STD_LOGIC_VECTOR(2 downto 0) := "000"; -- Etat Séquenceur

begin
    
    -- Séquenceur
    process(Clk, Reset)
    begin
        -- Reset Asynchrone
        if Reset='1' then
            Q <= "000";
        elsif rising_edge(Clk) then
            Q(2) <= (Q(2) and not Fin_Tempo and not Fin_0) or (Fin_1 and Fin_Trame) or (Fin_Dec and not Data);
            Q(1) <= (Q(1) and not Fin_Tempo and not Fin_Dec) or (Fin_1 or Fin_0);
            Q(0) <= (Q(0) and not Fin_Tempo) or Fin_Charge;
        end if;
    end process;
    
    -- Sorties Séquenceur
    Go_1 <= not Q(2) and not Q(1) and Q(0); 
    Go_0 <= Q(2) and not Q(1) and Q(0); 
    Go_Tempo <= Q(2) and Q(1) and Q(0); 
    Go_Charge <= not Q(2) and not Q(1) and not Q(0);
    Go_Dec <= not Q(2) and Q(1) and Q(0);
    Go_Trame <= not (Q(2) and Q(1) and Q(0));

end Behavioral;
