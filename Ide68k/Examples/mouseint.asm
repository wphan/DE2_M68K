; MOUSEINT.ASM - Demonstration program for mouse interrupts
;
; Drawpad size 256 x 256 pixels or less (use bytes for x and y)
;
; Release mouse with Shift + left mousebutton
; (ESC does not work, keyboard is assigned to I/O window)

; Author: Peter J. Fondse (pfondse@hetnet.nl)

LF         equ         $0A             ; ASCII code for linefeed
CR         equ         $0D             ; ASCII code for carriage return

mouseX     equ         $E027           ; x position of mouse
mouseY     equ         $E029           ; y position of mouse
mouseflags equ         $E02A           ; mouse event flags
mouseint   equ         $E02B           ; mouse interrupt enable flags and IRQ level

           entry       start           ; entry point of program ($400)

; mouse interrupt vector address
           org         $100
           dc.l        mouseproc

; program starts here
           org         $400
start      move.b      #$A5,mouseint   ; left and right button down, mouse moved, IRQ=2
           move.w      #$2000,SR       ; enable all interrupt levels
           bra         *               ; wait for interrupt

; mouse interrupt procedure
mouseproc  movem.l     D0/A0,-(A7)     ; save all registers used in this procedure
lbutton    btst        #0,mouseflags   ; test if left button is clicked
           beq.s       rbutton
           lea         text1,A0        ; yes, print message
           bsr.s       prtstr
           bra.s       ready
rbutton    btst        #2,mouseflags   ; test if right button is clicked
           beq.s       mousemove
           lea         text2,A0        ; yes, print message
           bsr.s       prtstr
           bra.s       ready
mousemove  clr.l       D0              ; must be mouse moved
           lea         text3,A0
           bsr.s       prtstr
           move.b      mouseX,D0       ; print mouse position
           bsr.s       prtnum
           lea         text4,A0
           bsr.s       prtstr
           move.b      mouseY,D0
           bsr.s       prtnum
           lea         text5,A0
           bsr.s       prtstr
ready      clr.b       mouseflags
           movem.l     (A7)+,D0/A0
           rte

prtnum     trap        #15
           dc.w        5
           rts

prtstr     trap        #15
           dc.w        7
           rts

text1      dc.b        'left button',CR,LF,0
text2      dc.b        'right button',CR,LF,0
text3      dc.b        'mouse: x=',0
text4      dc.b        ' y=',0
text5      dc.b        CR,LF,0
