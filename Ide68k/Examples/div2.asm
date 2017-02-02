* DIV2.ASM - Get two numbers and divide

* This program asks the user to enter two decimal numbers and displays
* the quotient. Numbers are entered and the result is displayed in the
* I/O window which is automatically activated.
* May trigger the zero-divide exception (if B = 0)

* This program is also loaded and run by kernel.asm (in user mode)

* Author: Peter J. Fondse (pfondse@hetnet.nl)

* system call function codes

EXIT    equ     0
PRTNUM  equ     5
GETNUM  equ     6
PRTSTR  equ     7

        org     $10000          >= 10000 (for user mode)

* program begins here

        lea     prompt1,A0      ask for 1st number (A)
        trap    #15
        dc.w    PRTSTR          print "A ="
        trap    #15
        dc.w    GETNUM          get number
        move.l  D0,D1           store in D1
        lea     prompt2,A0      ask for 2nd number (B)
        trap    #15
        dc.w    PRTSTR          print "B ="
        trap    #15
        dc.w    GETNUM          get number
        exg     D0,D1
        divs    D1,D0           divide A by B
        and.l   #$FFFF,D0       zero remainder
        lea     prompt3,A0      print quotient ( A / B)
        trap    #15
        dc.w    PRTSTR          print "A / B ="
        trap    #15
        dc.w    PRTNUM          print result
        trap    #15
        dc.w    EXIT            end of program

prompt1 dc.b    'A = ',0
prompt2 dc.b    'B = ',0
prompt3 dc.b    'A / B = ',0
