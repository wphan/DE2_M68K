* TIMERTEST.ASM - test timer interrupt at vector 16
*
* Three manual interrupts are active, 5 increments the LED's, 6 and 7 give a sound
*
* The timer interrupt is generated at a rate of approx. 10 times per second and increments
* the BAR display (0 to full-scale in +/- 25 seconds)
*
* Select LEDS and BAR from the Peripherals menu, make sure sounds are enabled in WINDOWS
*
* To work, the program MUST be run in RUN-mode (timer is inactive in single- and
* autostep mode

* Author: Peter J. Fondse (pfondse@hetnet.nl)

LEDS       equ     $E003              I/O address of LED display
BAR        equ     $E007              I/O address of BAR display
SOUND      equ     $E031              I/O address of sound generator

* initialize vectors in lower memory

           org     $0
           dc.l    stack              initial SP
           dc.l    start              initial PC

           org     $0040
           dc.l    timerproc          timer interrupt routine

           org     $0074
           dc.l    int5proc           autovector interrupt routines
           dc.l    int6proc
           dc.l    int7proc

* program begins here

           org     $0400
start      move    #$2400,SR          accept IRQ 5, 6 & 7
           bra     *                  wait for interrupt

* Interrupt 5 routine

int5proc   addq.b  #1,LEDS           inc led's
           rte

* Interrupt 6 routine

int6proc   move.b  #0,SOUND           say "ping"
           rte

* Interrupt 7 routine

int7proc   move.b  #1,SOUND           say "pong"
           rte

* Timer interrupt routine

timerproc  addq.b  #1,BAR            incr. bar at 10 (+/- 1) times per sec
           rte

* Stack area

           ds.w    256               stack area, 512 bytes
stack      equ     *
