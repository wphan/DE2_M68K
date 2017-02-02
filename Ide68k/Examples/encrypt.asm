; ENCRYPT.ASM - Encrypt a string using another string as key

; The user is asked to enter a string to encrypt and another
; string as encryption key. Both the original and the encrypted
; string are shown. When the user enters the encrypted string and
; the same key as used for encryption, the original string is shown.

; This program demonstrates the use of macros

; Author: Peter J. Fondse (pfondse@hetnet.nl)

BS          equ     $08
LF          equ     $0A
CR          equ     $0D

; macro definitions

exit        macro
            trap     #15
            dc.w     0              ; SIM68K function 0: EXIT
            endm

prtchr      macro
            trap     #15
            dc.w     1              ; SIM68K function 1: PRTCHR
            endm

getchr      macro
            trap     #15
            dc.w     2              ; SIM68K function 2: GETCHR
            endm

getstr      macro
            trap     #15
            dc.w     8              ; SIM68K function 8: GETSTR
            endm

prtstr      macro
            trap     #15            ; SIM68K function 7: PRTSTR
            dc.w     7
            endm

puts        macro   string          ; macro for print string
            move.l  A0,-(A7)        ; save A0
            move.l  #string,A0
            prtstr
            move.l  (A7)+,A0        ; restore A0
            endm

gets        macro   prompt,string   ; macro for get string with prompt
            puts    prompt
            move.l  A0,-(A7)        ; save A0
            move.l  #string,A0
            getstr
            move.l  (A7)+,A0        ; restore A0
            endm

encode      macro   in,key,out      ; macro for encrypt
            move.l  #in,A0          ; input string
            move.l  #key,A1         ; key
            move.l  #out,A2         ; output string
            bsr     encrypt
            endm

            org     $400

; program begins here

            gets    prompt1,string_in       ; read string
            gets    prompt2,key             ; read key
            encode  string_in,key,string_out
            puts    prompt3
            puts    string_in      ; show orig. string
            puts    prompt4
            puts    string_out     ; show result
            puts    newline
            exit

; ENCRYPT encrypts a string, address in A0, key addres in A1, output in A2

encrypt     movem.l D0/D1/A0-A3,-(A7)
            move.l  A1,A3          ; save A1
encr1       move.b  (A0)+,D0
            beq     encr3          ; end of string ?
            move.b  (A1)+,D1       ; no
            bne     encr2          ; end of key ?
            move.l  A3,A1          ; yes, reset A1
            move.b  (A1)+,D1       ; get 1st key byte
encr2       and.b   #$1F,D1        ; strip high bits
            eor.b   D1,D0          ; scramble
            cmp.b   #$7F,D0
            bne     encr4          ; byte = 7F (cannot be typed on keyboard)
            eor.b   D1,D0          ; yes, restore orig. char
encr4       move.b  D0,(A2)+       ; output string
            bra     encr1
encr3       clr.b   (A2)           ; terminate with NULL byte
            movem.l (A7)+,D0/D1/A0-A3
            rts

; PROMPT

prompt1    dc.b     CR, LF, 'Enter a string:', CR, LF, 0
prompt2    dc.b     CR, LF, 'Enter a key:', CR, LF, 0
prompt3    dc.b     CR, LF, 'Original string:', CR, LF, 0
prompt4    dc.b     CR, LF, 'Encrypted string:', CR, LF, 0
newline    dc.b     CR, LF, 0

; STRINGS

string_in  ds.b     256            ; 256 chars max.
string_out ds.b     256            ; 256 chars max.

; KEY

key        ds.b     256            ; 256 chars max.
