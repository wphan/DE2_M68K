* SWITCHES.ASM - Read switches and copy to LEDs
*
* To run this program in the 68000 Visual Simulator, you must enable the
* SWITCHES and LED's windows from the Peripherals menu.
*
* Although this program can be run in Single-step and Auto-step mode,
* Run mode is preferred.
*
* If you click the mouse on one of the switches, the corresponding LED
* will be turned on.
*
* Its main purpose is to show how user-defined peripherals can be used
* in a 68000 program
*
* Author: Peter J. Fondse (pfondse@hetnet.nl)

SWITCH  equ     $200001         I/O address of switches
LEDS    equ     $200003         I/O address of LED display

        org     $400

start   move.b  SWITCH,D0       read switch positions
        not.b   D0              complement
        move.b  D0,LEDS         and copy to LED display
        bra     start           repeat
