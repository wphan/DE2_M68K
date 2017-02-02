* QUIZ.ASM - Test your knowledge of binary to decimal conversion

* To run this pro gram in the 68000 Visual Simulator, you must enable
* the LED's window from the Peripherals menu.

* Although this program can be run in Single-step and Auto-step mode,
* Run mode is preferred.

* The user is asked to type the decimal value of the binary number in
* the LED display in the I/O window.
* If the value is correct, the program responds with "Very good" and
* presents a new random binary number.
* If not correct, the 68000 says "What is this" and presents the same
* binary number again.

* The binary number is choosen at random intervals from the low byte
* of the system timer which increments at approx. 10 times per second

* Author: Peter J. Fondse (pfondse@hetnet.nl)

LEDS    equ     $E003           I/O address of LED array
SOUND   equ     $E031           I/O address of sound device
TIMER   equ     $E043           I/O address of system timer (Low byte)

        org     $400

        lea     prompt,A0       write opening prompt
        trap    #15
        dc.w    7
new     move.b  TIMER,LEDS      write random value to LED's
        add.b   #123,LEDS       add 123 to avoid starting with 0
again   lea     quest,A0
        trap    #15
        dc.w    7               write '?'
        trap    #15
        dc.w    6               get decimal value from I/O window
        cmp.b   LEDS,D0         compare LED indication with typed value
        beq.s   ok
        move.l  #what,SOUND+1   say 'What is this' if not correct
        move.b  #5,SOUND
        bra     again           keep value in LED's, ask again
ok      move.l  #good,SOUND+1   say 'Very good' if OK
        move.b  #5,SOUND
        bra     new             new number

prompt  dc.b    'What is the decimal value in the LED display',$0A,$0D,0
quest   dc.b    '? ',0
what    dc.b    'question.wav',0
good    dc.b    'correct.wav',0
