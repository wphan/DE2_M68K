; DRAWSHAPES.ASM - test shape drawing functions for DRAWPAD peripheral device
;
; Demonstration program for text, line- and shape drawing on the IDE68K drawpad
; it also demonstrates the use of macros
;
; Use drawpad size of 350x200 pixels or larger

; Author: Peter J. Fondse (pfondse@hetnet.nl)

; drawpad addresses:
X        equ        $E020        ; X coordinate word
Y        equ        $E022        ; Y coordinate word
CTRL     equ        $E024        ; control word

; colors:
BLACK    equ        0
BLUE     equ        1
GREEN    equ        2
RED      equ        4
CYAN     equ        GREEN+BLUE
MAGENTA  equ        RED+BLUE
YELLOW   equ        RED+GREEN
WHITE    equ        RED+GREEN+BLUE
TRANSP   equ        8

         include    drawpad.inc

         org        $400

         backgrnd   BLUE
         txtout     30,50,txt1,YELLOW,3
         line       30,80,320,80,GREEN,2
         rect       50,100,100,150,YELLOW,CYAN,2
         rndrect    150,100,200,150,TRANSP,RED,3
         ellipse    250,100,300,150,WHITE,RED,8
         txtout     150,170,txt2,WHITE,1
         stop       #$2700

txt1     dc.b       'This is DrawPad version 2',0
txt2     dc.b       'End of program',0
