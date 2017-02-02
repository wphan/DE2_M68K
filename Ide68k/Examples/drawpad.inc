*  DRAWPAD.INC - a set of useful macro's for the new drawpad
*
*  included by DRAWTEST.ASM
*
* Author: Peter J. Fondse (pfondse@hz.nl)

backgrnd macro      color
         move.w     #color<<4,CTRL
         endm

moveto   macro      xp,yp
         move.w     #xp,X
         move.w     #yp,Y
         move.w     #$0080,CTRL
         endm

line     macro      left,top,right,bottom,color,width
         moveto     left,top
         move.w     #right,X
         move.w     #bottom,Y
         move.w     #$0000|(color<<4)|width,CTRL
         endm

ellipse  macro      left,top,right,bottom,color,border,width
         moveto     left,top
         move.w     #right,X
         move.w     #bottom,Y
         move.w     #$1000|(color<<8)|(border<<4)|width,CTRL
         endm

rect     macro      left,top,right,bottom,color,border,width
         moveto     left,top
         move.w     #right,X
         move.w     #bottom,Y
         move.w     #$2000|(color<<8)|(border<<4)|width,CTRL
         endm

rndrect  macro      left,top,right,bottom,color,border,width
         moveto     left,top
         move.w     #right,X
         move.w     #bottom,Y
         move.w     #$3000|(color<<8)|(border<<4)|width,CTRL
         endm

prtchr   macro      color,size
         asl.w      #8,D0
         or.w       #$8000|(color<<4)|size,D0
         move.w     D0,CTRL
         endm

txtout   macro      x,y,text,color,size
         local      loop,finish
         moveto     x,y
         lea        text,A0
loop     move.b     (A0)+,D0
         beq.s      finish
         prtchr     color,size
         bra        loop
finish   equ        *
         endm
