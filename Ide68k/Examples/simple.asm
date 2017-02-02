* SIMPLE.ASM - Simple, custom defined I/O device
*
* This program must be run in the 68000 Visual Simulator and exercises
* the custom I/O device implemented in SIMPLEDEV.DLL
*
* To load the library, select menu Peripherals|Configure peripherals
* and open Simpledev.dll (normally in directory C:\Ide68k\Custom).
*
* Select Peripherals|Custom device to activate the device window.
* Select Switches and LEDS from the Peripherals menu to activate switch
* and LED windows.
*
* Run the program in Single-step or Run mode.
*
* The 68000 is made to run with interrupt levels 5 and 6 enabled.
*
* Input data read from the custom device I/O ports A and B is exclusive
* or'ed and masked with databits from the switch device. The result sent
* to is I/O port C and displayed by the custom device and the LEDs.
*
* Pressing one of the buttons of the custom device marked 5 or 6 generates
* the corresponding interrupt.
*
* Depending on the interrupt, the 68000 generates two different sound
* signals (sounds must be enabled in Windows).
*
* Author: Peter J. Fondse (pfondse@hetnet.nl)

INT5       equ     $0074              level 5 interrupt vector
INT6       equ     $0078              level 6 interrupt vector

SWITCHES   equ     $E001              I/O address of switches
LEDS       equ     $E003              I/O address of LEDS
SOUND      equ     $E031              sound I/O port

INPUT1     equ     $200001            I/O addresses of custom device
INPUT2     equ     $200003
OUTPUT     equ     $200005

           org     $400

* Program starts here

program    move.l  #int5proc,INT5     setup interrupt vectors
           move.l  #int6proc,INT6
           move    #$2400,SR          accept IRQ 5 & 6

* main program loop

loop       move.b  INPUT1,D0          input value 1 from device
           move.b  INPUT2,D1          input value 2
           eor.b   D1,D0              excl. or
           move.b  SWITCHES,D1        read switches
           not.b   D1                 and complement
           and.b   D1,D0              mask bits with switches (1 = masked)
           move.b  D0,OUTPUT          output to device
           move.b  D0,LEDS            and LEDS
           bra     loop               repeat

* Interrupt 5 routine

int5proc   move.b  #0,SOUND           say "ping"
           lea     int5txt,A0
           trap    #15
           dc.w    7
           rte

* Interrupt 6 routine

int6proc   move.b  #1,SOUND           say "pong"
           lea     int6txt,A0
           trap    #15
           dc.w    7
           rte

int5txt    dc.b    'Interrupt 5!',$0D,$0A,$00
int6txt    dc.b    'Interrupt 6!',$0D,$0A,$00
