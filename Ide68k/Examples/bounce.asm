; BOUNCE.ASM - moves the cursor across the screen

; This program shows a bouncing ball (actually the cursor) bouncing
; across the screen. Ctrl+Break (= Reset) will terminated the program.
; The main purpose of the program is to demonstrate cursor movement
; functions by means of ANSI escape-codes.

; Author: J.W. Mol / Peter J. Fondse (pfondse@hetnet.nl)

           title    Bouncing Ball

ESC        equ      $1B
DELAY      equ      20000              ; adjust for PC clock frequency

           org      $400

; program starts here

           bsr      clrscr
           moveq    #1,D1               ; x pos
           moveq    #1,D2               ; y pos
           moveq    #1,D3               ; x direction
           moveq    #1,D4               ; y direction
repeat     move.l   #DELAY,D5           ; delay
dloop      subq.l   #1,D5
           bne      dloop
           cmpi.b   #1,D3               ; x dir == 1 ?
           bne.s    lab1
           addq.w   #1,D1               ; incr. x pos
           lea      CUF(PC),A0          ; print cursor right
           bsr      print
           bra.s    lab2
lab1       subq.w   #1,D1               ; decr. x pos
           lea      CUB(PC),A0          ; print cursor left
           bsr      print
lab2       cmpi.b   #1,D4               ; y dir == 1 ?
           bne.s    lab3
           addq.w   #1,D2               ; incr. y pos
           lea      CUD(PC),A0          ; print cursor down
           bsr      print
           bra.s    lab4
lab3       subq.w   #1,D2               ; decr. y pos
           lea      CUU(PC),A0          ; print cursor up
           bsr      print
lab4       cmpi.b   #80,D1              ; x pos == 80 ?
           bne.s    lab5
           moveq    #0,D3               ; x dir = 0
lab5       cmpi.b   #1,D1               ; x pos == 1 ?
           bne.s    lab6
           moveq    #1,D3               ; x dir = 1
lab6       cmpi.b   #25,D2              ; y pos == 25 ?
           bne.s    lab7
           moveq    #0,D4               ; y dir = 0
lab7       cmpi.b   #1,D2               ; y pos == 1 ?
           bne      repeat
           moveq    #1,D4               ; y dir = 1
           bra      repeat

clrscr     lea      ED(PC),A0           ; clear screen
           bsr      print
           rts

print      move.b   (A0)+,D0            ; print routine
           beq.s    done
           bsr      cout                ; character output routine
           bra      print
done       rts

exit       trap     #15                 ; system call routines
           dc.w     0

cout       trap     #15
           dc.w     1
           rts

;ANSI messages for ANSI terminal

ED         dc.b      ESC, '[2J', 0      ; Erase display
CUU        dc.b      ESC, '[1A', 0      ; Cursor up
CUD        dc.b      ESC, '[1B', 0      ; Cursor down
CUF        dc.b      ESC, '[1C', 0      ; Cursor forwards
CUB        dc.b      ESC, '[1D', 0      ; Cusor backwards
