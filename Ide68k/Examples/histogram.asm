; HISTOGRAM.ASM - print histogram of characters in string

; This program lets the user enter a string and then prints a
; histogram of the number of times a character appears in the string.

; Author: Peter J. Fondse (pfondse@hetnet.nl)

BS        equ     $08
LF        equ     $0A
CR        equ     $0D

          org     $400

start     move.l  #prompt,A0
          bsr     prtstr         ; ask for a string
          move.l  #buffer,A0
          bsr     getstr         ; read string
          move.l  #buffer,A0
          bsr     strupr         ; convert to upper case
          bsr     newline
          move.b  #'A',D1        ; first char in D1
lab41     move.l  #buffer,A0
          bsr     count          ; count chars
          tst.l   D2             ; test counter
          beq     lab42
          bsr     histgrm        ; if <> 0, draw histogram line
lab42     addq.l  #1,D1          ; next char
          cmp.b   #'Z',D1
          ble     lab41          ; again if char <= Z
          bsr     exit
          bra     start          ; restart

; STRUPR converts string to upper case, address of string in A0

strupr    move.l  D0,-(A7)       ; save D0
strup1    move.b  (A0),D0        ; char in D0
          beq.s   strup2         ; if NULL, ready
          bsr.s   toupper        ; convert
          move.b  D0,(A0)+       ; restore in buffer and increment A0
          bra.s   strup1         ; again
strup2    move.l  (A7)+,D0       ; restore D0
          rts                    ; end of STRUPR

; TOUPPER converts lower case in D0 to upper case

toupper   cmp.b   #'a',D0
          blt.s   toupp1         ; if < a, do nothing
          cmp.b   #'z',D0
          bgt.s   toupp1         ; if > z, do nothing
          add.b   #'A'-'a',D0    ; only lower case, convert
toupp1    rts                    ; end TOUPPER

; COUNT counts occurences of char in D1 in string, result in D2

count     clr.l   D2             ; reset D2
count1    move.b  (A0)+,D0       ; char in D0
          beq.s   count2         ; NULL is ready
          cmp.b   D0,D1          ; if not, compare
          bne     count1         ; not equal, get next char
          addq.l  #1,D2          ; equal, increment count
          bra     count1         ; next char
count2    rts                    ; end of COUNT

; HISTGM prints char in D1, followed by space and *'s according to nr. in D2

histgrm   move.b  D1,D0
          bsr     prtchr         ; print char A - Z
          move.b  #' ',D0
          bsr     prtchr         ; print space
histg1    move.b  #'*',D0
          bsr     prtchr         ; print *
          subq.l  #1,D2
          bne     histg1
          bsr     newline
          rts                    ; end HISTGRM

; GETSTR reads string, address in A0

getstr    movem.l A0/D0,-(A7)    ; save A0&D0
gets1     bsr     getchr         ; get char
          cmp.b   #BS,D0
          beq.s   gets2          ; Backspace ?
          cmp.b   #CR,D0
          beq.s   gets3          ; CR ?
          move.b  D0,(A0)+       ; no, char to buffer
          bra.s   gets1          ; next char
gets2     cmp.l   (A7),A0        ; BS, A0 == string address ?
          beq.s   gets1          ; yes, do nothing
          subq.l  #1,A0          ; else delete char
          move.b  #' ',D0
          bsr     prtchr         ; print space
          move.b  #BS,D0
          bsr     prtchr         ; print backspace
          bra     gets1          ; next char
gets3     clr.b   (A0)           ; insert NULL at end of string
          movem.l (A7)+,A0/D0    ; restore A0&D0
          rts                    ; end of GETSTR

; PRTSTR prints a string, address in A0

prtstr   move.l   A0,-(A7)       ; save A0
prts1    move.b   (A0)+,D0       ; char in D0
         beq.s    prts2          ; NULL is ready
         bsr      prtchr         ; print
         bra      prts1          ; next char
prts2    move.l   (A7)+,A0       ; restore A0
         rts                     ; end of PRTSTR

; NEWLINE print CR/LF

newline  move.l  D0,-(A7)        ; save D0
         move.b  #CR,D0
         bsr     prtchr          ; print CR
         move.b  #LF,D0
         bsr     prtchr          ; print LF
         move.l  (A7)+,D0        ; restore D0
         rts                     ; end of NEWLINE

; GETCHR reads char into D0

getchr   trap     #15
         dc.w     2              ; SIM68K function 2
         rts

; PRTCHR prints char in D0

prtchr   trap     #15
         dc.w     1              ; SIM68K function 1
         rts

; EXIT end of program

exit     trap     #15
         dc.w     0              ; SIM68K function 0
         rts                     ;

; PROMPT

prompt   dc.b     'Please enter a string',CR,LF,0

; BUFFER

buffer   ds.b     256            ; 256 chars max.
