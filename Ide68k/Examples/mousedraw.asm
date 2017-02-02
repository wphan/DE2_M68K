; MOUSEDRAW.ASM - drawing with mouse on drawpad
;
; draw line with left button down, move to new position with left button up
; erase drawpad with right button
;
; use large drawpad size 640x480 or 512x512 pixels for best effect
;
; this program uses polling instead of interrupts

; Author: Peter J. Fondse (pfondse@hetnet.nl)

padX       equ         $E020           ; use word for sizes >= 256
padY       equ         $E022
padCmd     equ         $E024           ; use word for extended commands
mouseX     equ         $E026
mouseY     equ         $E028
mouseflags equ         $E02A

           org         $400

start      btst        #0,mouseflags  ; check bit 0 = left button down
           bne.s       left_dwn
           btst        #2,mouseflags  ; check bit 2 = right button down
           bne.s       right_dwn
           bra         start

left_dwn   move.w      mouseX,padX
           move.w      mouseY,padY
           move.w      #$0080,padCmd   ; make this start position of line
           clr.b       mouseflags
loop       btst        #1,mouseflags   ; check bit 1 = left button up
           bne.s       left_up
           btst        #7,mouseflags   ; check bit 7 = mouse move
           beq         loop
draw       move.w      mouseX,padX     ; yes, mouse has moved
           move.w      mouseY,padY
           move.w      #$0071,padCmd   ; draw white line of 1 pixel width
           and.b       #$7F,mouseflags ; clear mouse move flag
           bra         loop
left_up    clr.b       mouseflags
           bra         start

right_dwn  btst        #3,mouseflags   ; check bit 3 = right button up
           beq         right_dwn
           clr.w       padCmd          ; erase pad
           clr.b       mouseflags
           bra         start
