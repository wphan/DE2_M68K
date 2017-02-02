; HELLO68K.ASM - print "Hello IDE68K!" on the screen

; This is the first program to run on IDE68K

; Author: Peter J. Fondse (pfondse@hetnet.nl)

LF       equ     $0A           ; ASCII definitions for Linefeed and
CR       equ     $0D           ; Carriage Return

         org     $400          ; start of program (>= $400)

         lea     text,A0       ; get address of text string in A0
         trap    #15
         dc.w    7             ; call system function 7 (print string)
         trap    #15
         dc.w    0             ; call system function 0 (exit program)

; string to print, string ends with NULL
text     dc.b    'Hello IDE68K!',CR,LF,0
