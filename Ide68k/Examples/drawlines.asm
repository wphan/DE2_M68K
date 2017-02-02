* DRAWLINES.ASM - write random lines on drawpad.

* To run this program in the 68000 Visual Simulator, you must enable
* the DRAW PAD window from the Peripherals menu.

* When the program runs, the 68000 draws a pattern of random lines
* on the drawing pad using randomly selected colors. After 100 lines
* drawn, the program waits for a few seconds, then erases the display
* with a randomly selected background color and starts drawing lines
* again.

* Author: Peter J. Fondse (pfondse@hetnet.nl)

* I/O addresses for drawpad

X          equ     $E021        X coordinate
Y          equ     $E023        Y coordinate
PAD        equ     $E025        control byte

DELAY      equ     100000       delay, depends on PC frequency

MAXLINES   equ     100          100 lines drawn on pad

* program begins here

           org     $400

start      move.w  #MAXLINES,D3
next       move.b  Xpos,D0      randomize X
           bsr     rand
           move.b  D0,Xpos
           move.b  Ypos,D0      randomize Y
           bsr     rand
           move.b  D0,Ypos
           move.b  Color,D0     randomize color
           bsr     rand
           move.b  D0,Color
           move.b  Xpos,X       write x coordinate
           move.b  Ypos,Y       write y coordinate
           move.b  Color,D0
           and.b   #$70,D0      isolate color from random value
           or.b    #8,D0        add line width
           move.b  D0,PAD       control byte to draw pad
           move.l  #DELAY,D0    delay loop 1
loop1      subq.l  #1,D0
           bne     loop1
           subq.w  #1,D3        100 lines drawn?
           bne     next         if not, draw next
           move.l  #20*DELAY,D0 delay loop 2
loop2      subq.l  #1,D0
           bne     loop2
           move.b  Color,D0     if yes
           and.b   #$70,D0
           move.b  D0,PAD       erase drawpad with current color
           bra     start

* randomize byte in D0.b by using shift reg. with exor feedback

rand       move.b  D0,D1        PRBS with feedback from 2, 3, 4 & 8
           lsr.b   #1,D1
           move.b  D1,D2
           lsr.b   #1,D1        |8|7|6|5|4|3|2|1| <-
           eor.b   D1,D2         |       | | |      | excl. or
           lsr.b   #1,D1         ->->->->->->->->->-
           eor.b   D1,D2
           lsr.b   #4,D1
           eor.b   D1,D2
           and.b   $1,D2
           lsl.b   #1,D0
           or.b    D2,D0
           rts

* variables

Xpos       dc.b    37           start x position
Ypos       dc.b    217          start y position
Color      dc.b    233          start of color


