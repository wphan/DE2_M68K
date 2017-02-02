* BSORT.ASM - A simple bubblesort program

* Sorts 5 numbers at location $1000-$1004 in ascending order

* Running this program in Single-step or Auto-step mode clearly shows
* the sorting process in the memory window of the Visual Simulator.

* Register usage
* A0: points into array
* D0: temp. storage
* D1: id.
* D2  swap flag, (1 = swapped)
* D3: index counter

* Author: Peter J. Fondse (pfondse@hz.nl)

N       equ     5               array size

        org     $400

* Program starts here

start   lea     array,A0        A0 points to array
        clr     D2              clear swap flag
        moveq   #N-1,D3         set item count (minus 1)
loop1   move.b  (A0),D0         get 1st number of pair
        move.b  1(A0),D1        get 2nd number
        cmp.b   D0,D1           compare
        bge.s   noswap          if less than, swap
        move.b  D0,1(A0)        replace 2nd with 1st
        move.b  D1,(A0)         replace 1st with 2nd
        moveq   #1,D2           set swap flag
noswap  addq.l  #1,A0           A0 points to next pair
        subq    #1,D3           decrement item count
        bne     loop1           repeat if more pairs
        tst     D2              test swap flag
        bne     start           restart if one or more items swapped
        stop    #$2000          end exec

        org     $1000

array   dc.b    5,4,3,2,1       array, after sorting: 1,2,3,4,5