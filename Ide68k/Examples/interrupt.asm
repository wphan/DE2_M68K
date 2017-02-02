* INTERRUPT.ASM - Interrupt processing

* This program exercises the interrupt handling built into the 68000
* Visual Simulator. The 68000 is made run to with interrupt levels 5 to 7 enabled.
* Pressing one of the marked I5, I6 or I7 generates the corresponding interrupt.

* Depending on the interrupt, the 68000 generates two different sound
* signals (sounds must be enabled in Windows).

* You can use the interrupt timer if you select INTERRRUPT TIMER from
* the Peripherals menu and set interrupt level and interval time of the
* timer.

* Running the program in Run mode is preferred unless you select
* very long interval times.

* Author: Peter J. Fondse (pfondse@hetnet.nl)


INT5       equ     $0074              level 5 autovector
INT6       equ     $0078              level 6 autovector
INT7       equ     $007C              level 7 autovector
LEDS       equ     $E003              I/O address of LED display
SOUND      equ     $E031              I/O address of sound generator

           org     $400

* Program starts here

           move.l  #int5proc,INT5     set interrupt vectors
           move.l  #int6proc,INT6
           move.l  #int7proc,INT7
           clr.b   LEDS               turn LEDs off
           move    #$2400,SR          accept IRQ 5 - 7
           bra     *                  wait for interrupt

* Interrupt 5 routine

int5proc   addq.b  #1,LEDS            inc led's
           rte

* Interrupt 6 routine

int6proc   move.b  #0,SOUND           say "ping"
           rte

* Interrupt 7 routine

int7proc   move.b  #1,SOUND           say "pong"
           rte
