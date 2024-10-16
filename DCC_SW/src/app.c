#include "xil_io.h"
#include "Centrale_DCC.h"
#include "xgpio.h"
#include "xparameters.h"

#define CENTER 1
#define UP     2
#define LEFT   4
#define RIGHT  8
#define DOWN   16

#define maxSpeed  32     // STOP - STOP(I) - E-STOP - E-STOP(I) - step 1 - ... - step 28
#define maxAdress 16     // de l'adresse 1 à l'adresse 16
#define maxFct    21     // de la fonction f0 à la fonction f20

// convertisseur indice entier into son affichage sur 7 segments
unsigned int num[10] = {64, 121, 36, 48, 25, 18, 2, 120, 0, 16};

// tempo de clignement de l'affichage
unsigned int clign = 0;

// Temporisateur de Bouton
unsigned int tempo = 0;

// Les Deux Parties de la Trame à Envoyer
unsigned int Trame_1 = 0;
unsigned int Trame_2 = 0;

// L'état Interne du Système
unsigned int menu = 1;
unsigned int storedAdress = 0;
unsigned int storedSpeed = 0;
unsigned int storedFct = 0;
unsigned int storedActive[maxFct];
unsigned int storedDirection = 1;
unsigned int fct = 1;

// L'état Affiché du Système
unsigned int displayedAdress = 0;
unsigned int displayedSpeed = 0;
unsigned int displayedFct = 0;
unsigned int displayedActive[maxFct];
unsigned int displayedDirection = 1;

// GPIO
XGpio buttons_screen;

// utile pour améliorer luminosité de l'affichage
void temporize() {
	unsigned int tempo = 0;
	while (tempo < 20) {
		tempo++;
	}
	tempo = 0;
}

// test de pression + debouncer
unsigned int press(unsigned int button) {
	if (XGpio_DiscreteRead(&buttons_screen, 1) & button && !tempo) {
		tempo = 100000;
		return 1;
	}
	else if (tempo) {
		tempo -= 1;
	}
	return 0;
}

int main() {
	XGpio_Initialize(&buttons_screen, XPAR_BUTTONS_SCREEN_DEVICE_ID);

	// boutons
	XGpio_SetDataDirection(&buttons_screen, 1, 0x1F);
	// display
	XGpio_SetDataDirection(&buttons_screen, 2, 0);

	while (1) {

		// affichage du menu sur le display
		XGpio_DiscreteWrite(&buttons_screen, 2, 1792 + num[menu]);
		temporize();

		switch (menu) {

			// menu des fonctions
			case 2 :

				// reset menu 1 et 0
				if (!fct) {
					// menu 1
					if (displayedAdress != storedAdress) {
						displayedAdress = storedAdress;
					}
					// menu 0
					if (displayedSpeed != storedSpeed) {
						displayedSpeed = storedSpeed;
					}
					if (displayedDirection != storedDirection) {
						displayedDirection = storedDirection;
					}
				}

				// pression sur droite pour changer de menu
				menu = menu - press(RIGHT);

				// pression sur haut ou bas pour défiler les fonctions
				if (press(UP)) {
					displayedActive[displayedFct] = storedActive[displayedFct];
					displayedFct = (displayedFct + 1) % maxFct;
				}
				else if (press(DOWN)) {
					displayedActive[displayedFct] = storedActive[displayedFct];
					displayedFct = displayedFct - ((displayedFct > 0) ? 1 : (-maxFct + 1));
				}
				else if (press(LEFT)) {
					displayedActive[displayedFct] = !displayedActive[displayedFct];
				}

				// affichage de la fonction sur le display
				XGpio_DiscreteWrite(&buttons_screen, 2, 2816 + num[displayedActive[displayedFct]]);
				temporize();
				if (displayedFct > 9) {
					XGpio_DiscreteWrite(&buttons_screen, 2, 3456 + num[displayedFct/10]);
					temporize();
				}
				XGpio_DiscreteWrite(&buttons_screen, 2, 3584 + num[displayedFct%10]);
				temporize();

				// marquage du passage par le menu 2
				fct = 1;
				break;

			// menu adresse du train
			case 1 :

				// pression sur gauche/droite pour changer de menu
				menu = menu + press(LEFT) - press(RIGHT);

				// pression sur haut ou bas pour défiler les adresses
				displayedAdress = (displayedAdress + press(UP) - ((displayedAdress > 0) ? 1 : (-maxAdress + 1)) * press(DOWN)) % maxAdress;

				// affichage de l'adresse sur le display
				if ((displayedAdress + 1) > 9) {
					XGpio_DiscreteWrite(&buttons_screen, 2, 3456 + num[(displayedAdress+1)/10]);
					temporize();
				}
				XGpio_DiscreteWrite(&buttons_screen, 2, 3584 + num[(displayedAdress+1)%10]);
				temporize();
				break;

			// menu vitesse et direction
			case 0 :

				// reset menu 2 et 1
				if (fct) {
					// menu 2
					if (displayedActive != storedActive[displayedFct]) {
						displayedActive[displayedFct] = storedActive[displayedFct];
					}
					if (displayedFct != storedFct) {
						displayedFct = storedFct;
					}
					// menu 1
					if (displayedAdress != storedAdress) {
						displayedAdress = storedAdress;
					}
				}

				// pression sur gauche pour changer de menu
				menu = menu + press(LEFT);

				// pression sur haut ou bas pour défiler la vitesse
				displayedSpeed = (displayedSpeed + press(UP) - ((displayedSpeed > 0) ? 1 : (-maxSpeed + 1)) * press(DOWN)) % maxSpeed;

				// pression sur droite pour changer de direction
				if (press(RIGHT)) {
					displayedDirection = !displayedDirection;
				}

				// affichage de la vitesse et de la direction sur le display
				XGpio_DiscreteWrite(&buttons_screen, 2, 2816 + num[displayedDirection]);
				temporize();
				switch (displayedSpeed) {

					// Stop
					case 0 :
						XGpio_DiscreteWrite(&buttons_screen, 2, 3712 + num[5]);
						temporize();
						break;

					// Stop (I)
					case 1 :
						if (clign > 20000) {
							XGpio_DiscreteWrite(&buttons_screen, 2, 3712 + num[5]);
							temporize();
						} else if (!clign) {
							clign = 40000;
						}
						clign--;
						break;

					// E-Stop
					case 2 :
						XGpio_DiscreteWrite(&buttons_screen, 2, 3712 + num[5]);
						temporize();
						XGpio_DiscreteWrite(&buttons_screen, 2, 3462);
						temporize();
						break;

					// E-Stop (I)
					case 3 :
						if (clign > 20000) {
							XGpio_DiscreteWrite(&buttons_screen, 2, 3712 + num[5]);
							temporize();
							XGpio_DiscreteWrite(&buttons_screen, 2, 3462);
							temporize();
						} else if (!clign) {
							clign = 40000;
						}
						clign--;
						break;

					default :
						if (displayedSpeed > 12) {
							XGpio_DiscreteWrite(&buttons_screen, 2, 3456 + num[(displayedSpeed - 3)/10]);
							temporize();
						}
						XGpio_DiscreteWrite(&buttons_screen, 2, 3584 + num[(displayedSpeed - 3)%10]);
						temporize();
						break;
				}

				// indicateur du passage par le menu 0
				fct = 0;
				break;
		}

		// préparation de la trame
		// trame fonction
		if (fct) {

			// Si commande à 2 octets
			if (displayedFct > 12) {

				// Champ commande 1 + adresse
				Trame_1 = 0xFFFC0000 + (displayedAdress + 1) * 512 + 222;

				// Champ commande 2
				Trame_2 = displayedActive[20] * 131072 + displayedActive[19] * 65536 + displayedActive[18] * 32768 + displayedActive[17] * 16384 + displayedActive[16] * 8192 + displayedActive[15] * 4096 + displayedActive[14] * 2048 + displayedActive[13] * 1024;

				// Champ contrôle + bit final
				Trame_2 += (((displayedAdress + 1) ^ 222) ^ (Trame_2 / 1024)) * 2 + 1;
			}

			// Si commande à 1 octet
			else {

				// Champ adresse
				Trame_1 = 0xFFFFFE00 + (displayedAdress + 1);

				// Champ commande
				Trame_2 = 131072; // 2^17
				if (displayedFct < 5) {

					// F0 à F4
					Trame_2 += displayedActive[0] * 16384 + displayedActive[4] * 8192 + displayedActive[3] * 4096 + displayedActive[2] * 2048 + displayedActive[1] * 1024;
				} else {
					Trame_2 += 32768;
					if (displayedFct < 9) {

						// F5 à F8
						Trame_2 += 16384 + displayedActive[8] * 8192 + displayedActive[7] * 4096 + displayedActive[6] * 2048 + displayedActive[5] * 1024 ;
					} else {

						// F9 à F12
						Trame_2 += displayedActive[12] * 8192 + displayedActive[11] * 4096 + displayedActive[10] * 2048 + displayedActive[9] * 1024;
					}
				}

				// Champ contrôle + bit final
				Trame_2 += ((Trame_2 / 1024) ^ (displayedAdress + 1)) * 2 + 1;
			}
		// trame vitesse
		} else {

			// Champ adresse
			Trame_1 = 0xFFFFFE00 + (displayedAdress + 1);
			int speed = (displayedSpeed/2 + 16*(displayedSpeed%2));

			// Champ commande
			Trame_2 = 65536 + 32768 * displayedDirection + speed * 1024;

			// Champ contrôle + bit final
			Trame_2 += ((Trame_2 / 1024) ^ (displayedAdress + 1)) * 2 + 1;
		}

		// pression du bouton centrale pour envoyer la trame préparée
		if (press(CENTER)) {

			// maj du système interne
			storedDirection = displayedDirection;
			storedSpeed = displayedSpeed;
			storedAdress = displayedAdress;
			storedFct = displayedFct;
			storedActive[storedFct] = displayedActive[displayedFct];

			// envoie de la trame vers la centrale DCC
			CENTRALE_DCC_mWriteReg(XPAR_CENTRALE_DCC_0_S00_AXI_BASEADDR, CENTRALE_DCC_S00_AXI_SLV_REG0_OFFSET, Trame_1);
			CENTRALE_DCC_mWriteReg(XPAR_CENTRALE_DCC_0_S00_AXI_BASEADDR, CENTRALE_DCC_S00_AXI_SLV_REG1_OFFSET, Trame_2);
		}
	}

	return 0;
}
