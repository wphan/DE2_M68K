* HELP.ASM - A program to display flashing HELP on a 7 segment display

* To run this program in the 68000 Visual Simulator, you must enable
* the 7-SEGMENT DISPLAY window from the Peripherals menu.

* Although this program can be run in Single-step and Auto-step mode,
* Run mode is preferred.

* When the program runs, flashing HELP is displayed on the 7-segment
* display.

* Author: Peter J. Fondse (pfondse@hetnet.nl)

        org     $400

start   move.b  #%01110110,$E011     H  bit pattern
        move.b  #%01111001,$E013     E
        move.b  #%00111000,$E015     L
        move.b  #%01110011,$E017     P
        bsr     delay                short delay
        clr.b   $E011                clear display
        clr.b   $E013
        clr.b   $E015
        clr.b   $E017
        bsr     delay                short delay
        bra     start                repeat

delay   move.l  #$60000,D0           delay depends on PC clock frequency
loop    subq.l  #1,D0
        bne     loop                 loop 60000 times
        rts
