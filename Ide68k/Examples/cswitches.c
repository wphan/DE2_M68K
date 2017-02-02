// CSWITCHES.ASM - Read switches and copy to LEDs

// To run this program in the 68000 Visual Simulator, you must enable the
// SWITCHES and LED's windows from the Peripherals menu.

// Although this program can be run in Single-step and Auto-step mode,
// Run mode is preferred.

// If you click the mouse on one of the switches, the corresponding LED
// will be turned on.

// This C program has the same functionality as Switches.asm

// Author: Peter J. Fondse (pfondse@hetnet.nl)

typedef unsigned char BYTE;

BYTE *switches = (BYTE *) 0xE001;
BYTE *leds = (BYTE *) 0xE003;

void main(void)
{
	for (;;)
		*leds = *switches;
}
