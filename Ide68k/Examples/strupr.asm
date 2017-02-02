* STRUPR.ASM -  Read a string and print it in uppercase
*
* This program asks the user to enter a string which is subsequently
* displayed in upper-case characters. This program makes use of a
* subroutine to convert characters to uppercase; the use of the stack
* to store the return address is clearly visible in the memory window.
*
* Author: Peter J. Fondse (pfondse@hetnet.nl)

LF      equ     $0A
CR      equ     $0D

        org     $400

* program begins here

prog    lea     prompt,A0
        trap    #15
        dc.w    7               print prompt
        lea     buf,A0          A0 points to textbuffer
        trap    #15
        dc.w    8               get a string from terminal
        bsr.s   strupr          convert to uppercase
        lea     buf,A0          A0 to buffer
        trap    #15
        dc.w    7               print string
        lea     newline,A0
        trap    #15
        dc.w    7
        stop    #$2700          stop program execution

strupr  move.b  (A0)+,D0        char in D0
        beq.s   strup1          NULL is ready
        cmp.b   #'a',D0
        blt.s   strupr          if < a, do nothing
        cmp.b   #'z',D0
        bgt.s   strupr          if > z, do nothing
        add.b   #'A'-'a',D0     only lower case, convert
        move.b  D0,-1(A0)       replace
        bra     strupr
strup1  rts                     end TOUPPER

prompt  dc.b    'Type a string...'
newline dc.b    CR,LF,0
buf     ds.b    80

