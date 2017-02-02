; C:\IDE68K\ARRAY\ARRAY.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J.Fondse
; #include <stdio.h>
; short x[10] ;
; void main()
; {
       section   code
       xdef      _main
_main:
       movem.l   D2,-(A7)
; int i ;
; for(i = 0; i < 10; i ++)
       clr.l     D2
main_1:
       cmp.l     #10,D2
       bge.s     main_3
; x[i] = i ;
       move.l    D2,D0
       lsl.l     #1,D0
       lea       _x,A0
       move.w    D2,0(A0,D0.L)
       addq.l    #1,D2
       bra       main_1
main_3:
       movem.l   (A7)+,D2
       rts
; }
       section   bss
       xdef      _x
_x:
       ds.b      20
