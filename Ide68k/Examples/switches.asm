* SWITCHES.ASM - Read switches and copy to LEDs

* To run this program in the 68000 Visual Simulator, you must enable the
* SWITCHES and LED's windows from the Peripherals menu.

* Although this program can be run in Single-step and Auto-step mode,
* Run mode is preferred.

* If you click the mouse on one of the switches, the corresponding LED
* will be turned on.

* Author: Peter J. Fondse (pfondse@hetnet.nl)

SWITCH  equ     $E001         I/O address of switches
LEDS    equ     $E003         I/O address of LED display

        org     $400

start   move.b  SWITCH,LEDS   read switch state and copy to LED
        bra     start         repeat
