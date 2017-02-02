* ADD5.ASM - Add 5 numbers in memory

* This is a program to add 5 numbers at location $2000-$2004 or $20000-$20004
* and store the result in next location ($2005 or $20005)

* NOTE: THIS PROGRAM CONTAINS SEVERAL RUN-TIME ERRORS

* Author: Peter J. Fondse (pfondse@hetnet.nl)

LEDS    equ     $E003

* Programs in user mode cannot be run below address $10000!
        org     $1000           this will generated an exception
*       org     $10000          this is OK

* Program starts here
        lea     stack,A0        Set user stackpointer
        move.l  A0,USP
        move.w  #$0000,SR       switch to user mode
        lea     numbers,A0      A0 points to array of numbers
        clr.b   D0              D0 receives sum
        moveq   #5,D1           D1 is item count
loop    add.b   (A0)+,D0        add term
        subq    #1,D1           decrement item count
        bne     loop
* Peripherals are not directly accessible in user mode
        move.b  D0,LEDS         this will generated a protection exception
        move.b  D0,(A0)         store sum
* A STOP-instruction here will generate a privilege violation error in user mode
        stop    #$2700          this will generated a privilege violation
*       trap    #15             this is OK
*       dc.w    0

* Numbers cannot be stored below address $10000 in user mode
        org     $2000           this will generate a protection exection
*       org     $20000          this is OK

numbers dc.b    1,2,3,4,5       array
result  ds.b    1               location of sum
        ds.w    128             stack (256 bytes)
stack   equ     *
