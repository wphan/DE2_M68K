**********************************************************************************************************
* CSTART.ASM  -  C startup-code
*
*          Initialises the system prior to running the users main() program
*
*          1) Sets up the user program stack pointer
*          2) Switches to User mode in the 68000
*          3) Enables All Interrupts 1-7 on 68000
*          4) Copies all initialised C program variables from Rom to Ram prior to running main()
*
**********************************************************************************************************
                section CODE
                align                  Make sure first instruction aligns to an even address e.g. 0 not 1 for 68000

**********************************************************************************************************
* The Following ORG Statement marks the address of the start of the this CStart Program
*
* The debug Monitor and Flash Load and Program routines assume your program lives here
**********************************************************************************************************
                org       $00800000

start:
*                move.w    #$2000,SR             clear interrupts to enable all, move to supervisor mode
*                move.l    #$00870000,a7         load the user stack pointer to an area of Ram above the code but within 512k block

*************************************************************************************
* Copy initialised variables to Ram at startup
************************************************************************************

mainloop        move.l    #-1,__ungetbuf         required for use of scanf() etc in C programs
                clr.l     __allocp               used by malloc() in C
                movea.l   #DataStart,a0          point a0 to the start of the initialised data section held in ROM
                movea.l   #bssEnd,a1             point a1 to the start of the Ram where we copy initialised C program data to at run time
                move.l    #DataLength,d0         figure out how many bytes of C program variables data to copy
                beq       go_main                if no data to copy go straight to program
varinit         move.b    (a0)+,(a1)+            copy the C program initialise variables from rom to ram
                subq.l    #1,d0
                bne       varinit
go_main         jsr       _main
                bra       start

*********************************************************************************************************
* Section for Initialised Data
*********************************************************************************************************
               section   data                  for initialised data
                align
DataStart       equ       *

*********************************************************************************************************
* Data Section for Initialised Data - these will be placed in rom as constants and have to be copied
* to ram as part of the CStart routine in this file
*********************************************************************************************************

                section   bss                   for uninitialised data
                align
DataEnd         equ     *                       this label will equate to the address of the last byte of global variable in it

*********************************************************************************************************
* Section for Uninitialised Data held in ROM as constants
*********************************************************************************************************

                org     $00010000               variables
DataLength      equ     DataEnd-DataStart       length of data needed to copy to Ram on bootup


bss             org       bss


***********************************************************************************************************
__ungetbuf:     ds.w    1       ; ungetbuffer for stdio functions
__allocp:       ds.l    0       ; start of allocation units
__heap:         ds.l    0       ; pointers for malloc functions

*__himem:       ds.l    himem            ; highest memory location + 1
*__stklen:      ds.l    stklen           ; default stack size

*********************************************************************************************************
* Section for Heap
*********************************************************************************************************

                section   heap           area for dynamic memory allocation e.g. malloc() etc
                align
bssEnd          equ *                   end of storage space for unitialised variables
*                                       we have to copy all initialised variable from rom to here at startup
heap   equ       *
           align







