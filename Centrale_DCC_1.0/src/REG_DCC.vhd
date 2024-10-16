----------------------------------------------------------------------------------
-- Company: SORBONNE UNIVERSITE
-- Designed by: S.EL MOUAHID, Spring 2024
--
-- Module Name: REG_DCC - Behavioral
-- Project Name: Centrale DCC
-- Target Devices: Basys 3
-- 
--	Déscription à mettre !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity REG_DCC is
    Port (Clk :         in STD_LOGIC;                        -- Horloge 100 MHz
          Reset :       in STD_LOGIC;                        -- Reset Asynchrone
          Go_Trame :    in STD_LOGIC;                        -- Commande d'utilisation
          Go_Charge :   in STD_LOGIC;                        -- Commande de chargement
          Go_Dec :      in STD_LOGIC;                        -- Commande de décalage
          Trame_DCC :   in STD_LOGIC_VECTOR(50 downto 0);    -- Trame DCC transmise
          Data :        out STD_LOGIC;                       -- Bit de la trame à transmettre
          Fin_Charge :  out STD_LOGIC;                       -- Drapeau de fin de Chargement
          Fin_Dec :     out STD_LOGIC;                       -- Drapeau de fin de décalage
          Fin_Trame :   out STD_LOGIC                        -- Drapeau de fin
          );
end REG_DCC;

architecture Behavioral of REG_DCC is

signal Reg : STD_LOGIC_VECTOR(50 downto 0) := (others => '0');     -- Registre de la trame
signal indice : INTEGER range 0 to 50 := 50;                       -- Indice du bit à transmettre
signal done : STD_LOGIC := '0';                                    -- Drapeau anti-décalage involontaire

begin

    -- Séquenceur
    process(Clk, Reset)
    begin
        if Reset='1' then 
            indice <= 50;
            Reg <= (others => '0');
	    done <= '0';
            Fin_Charge <= '0';
            Fin_Dec <= '0';
        elsif rising_edge(Clk) then
            if (Go_Dec='1') then
                -- Peut-être pas nécessaire
                if (done='0') then
                    indice <= indice - 1;
                    done <= '1';
                end if;
                Fin_Charge <= '0';
                Fin_Dec <= '1';
            elsif (Go_Charge='1') then
                Reg <= Trame_DCC;
                Fin_Charge <= '1';
                Fin_Dec <= '0';
            elsif (Go_Trame='0') then 
                indice <= 50;
                done <= '0';
                Fin_Charge <= '0';
                Fin_Dec <= '0';
            else
		        done <= '0';
                Fin_Charge <= '0';
                Fin_Dec <= '0';
            end if;
        end if;    
    end process;
    
    -- Sorties Registre DCC
    Data <= Reg(indice) and Go_Trame;
    Fin_Trame <= '1' when (indice = 0) else '0';

end Behavioral;