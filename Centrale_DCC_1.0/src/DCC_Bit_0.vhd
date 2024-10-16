----------------------------------------------------------------------------------
-- Company: SORBONNE UNIVERSITE
-- Designed by: S.EL MOUAHID, Spring 2024
--
-- Module Name: DCC_Bit_0 - Behavioral
-- Project Name: Centrale DCC
-- Target Devices: Basys 3
-- 
--	G�n�rateur du signal du bit 0 de la Centrale DCC
--
--		Apr�s d�tection du passage � 1 de la commande Go_0,
--		le module positionne � 0 la sortie DCC_0, compte 100 us,
--      positionne � 1 la sortie DCC_0, recompte 100 us, repositionne 
--      � 0 la sortie DCC_0, et enfin, positionne � 1 la sortie Fin_0
--
--		Pour �tre d�tect�e, la commande Go_0 doit �tre mise � 1
--		pendant au moins 1 p�riode de l'horloge 100 MHz
--
--		Quand Fin_0 passe � 1, la sortie reste dans cet �tat tant que 
--		Go_0 est � 1. 
--		D�s la d�tection du retour � 0 de Go_0,
--		Fin_0 repasse � 0.
--		
--		De cette mani�re, la dur�e de minimale l'impulsion � 1 de 
--		Fin_0 sera d'un cycle de l'horloge 100 MHz.
--		Cela est a priori suffisant pour sa bonne d�tection
--		par la MAE de la Centrale DCC.
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DCC_Bit_0 is
    Port ( Clk 			: in STD_LOGIC;		-- Horloge 100 MHz
           Reset        : in STD_LOGIC;     -- Reset Asynchrone
           Clk1M 		: in STD_LOGIC;		-- Horloge 1 MHz
           Go_0         : in STD_LOGIC;     -- Commande qui active la g�n�ration du bit
           Fin_0        : out STD_LOGIC;    -- Drapeau de fin de la transmission
           DCC_0        : out STD_LOGIC     -- Signal de sortie DCC
		);
end DCC_Bit_0;

architecture Behavioral of DCC_Bit_0 is

signal Q: std_logic_vector(1 downto 0) := "00"; -- Etat DCC
signal Raz_CPt, Inc_Cpt: std_logic := '0'; -- Commandes Compteur
signal Fin_Cpt, Mid_Cpt: std_logic := '0'; -- Drapeaux de Milieu et de Fin de Comptage

-- Compteur de Temporisation
signal Cpt: INTEGER range 0 to 300 := 0; -- Compteur (1 = 1 �s)

begin
    
    -- DCC
    process(Clk,Reset)
    begin
        if Reset='1' then 
            Q <= "00";
        elsif rising_edge(Clk) then
            Q(1) <= (not Q(1) and Q(0) and Mid_Cpt) or (Q(1) and Go_0);
            Q(0) <= (not Q(1) and not Q(0) and Go_0 and not Fin_Cpt) or (not Q(1) and Q(0) and not Mid_Cpt) or (Q(1) and not Q(0) and Fin_Cpt) or (Q(1) and Q(0) and Go_0);
        end if;
    end process;
    
    -- Sorties DCC
    Raz_Cpt <= Q(1) xnor Q(0);
    Inc_Cpt <= Q(1) xor Q(0);
    Fin_0 <= Q(1) and Q(0);
    DCC_0 <= Q(1) and not Q(0);

    -- Compteur de temporisation
    process(Clk1M, Reset)
    begin
        if Reset='1' then 
            Cpt <= 0;
        elsif rising_edge(Clk1M) then
            if Raz_Cpt = '1' then Cpt <= 0;
            elsif Inc_Cpt = '1' then Cpt <= Cpt + 1;
            end if;
        end if;
    end process;
    
    Mid_Cpt <= '1' when (Cpt = 100) else '0';
    Fin_Cpt <= '1' when (Cpt = 200) else '0';

end Behavioral;