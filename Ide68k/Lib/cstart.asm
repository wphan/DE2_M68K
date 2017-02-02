; CSTART.ASM  -  C startup-code for SIM68K
                section CODE
                align

                org $00000000
InitialSP       dc.l $00820000
InitialPC       dc.l start

                org $00000064
Level1IRQ       dc.l Timer4RamISR
Level2IRQ       dc.l Timer3RamISR
Level3IRQ       dc.l Timer2RamISR
Level4IRQ       dc.l Timer1RamISR
Level5IRQ       dc.l Key2PressRamISR
Level6IRQ       dc.l Key1PressRamISR
Level7IRQ       dc.l $0

                org       $00000400
start:

                move.w    #$0000,SR             clear interrupts to enable all
                move.l    #$00810000,a7         load the user stack pointer


* Copy initialised variables to Ram at startup

mainloop        movea.l   #DataStart,a0          point a0 to the start of the initialised data section held in ROM
                movea.l   #bssEnd,a1             point a1 to the start of the Ram where we copy initialised data to at run time
                movea.l   #bssEnd,a5             used to relocatable pointer
                move.l    #DataLength,d0         get how many bytes to copy
varinit         move.b    (a0)+,(a1)+
                subq.l    #1,d0
                bne       varinit
                jsr       _main
                bra       mainloop
Timer4RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    L1IRQ,a0                get ram based address into a0
                jsr       0(a0)                    jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Timer3RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    L2IRQ,a0                get ram based address into a0
                jsr       0(a0)                    jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Timer2RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    L3IRQ,a0                get ram based address into a0
                jsr       0(a0)                    jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Timer1RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    L4IRQ,a0                get ram based address into a0
                jsr       0(a0)                    jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Key2PressRamISR movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    L5IRQ,a0                get ram based address into a0
                jsr       0(a0)                    jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Key1PressRamISR movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    L6IRQ,a0                get ram based address into a0
                jsr       0(a0)                    jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

                section   data           for initialised data
                align
DataStart       equ       *


                section   bss            for uninitialised data
                align
DataEnd         equ     *                this label will have the address of the last byte of global variable in it

DataLength      equ     DataEnd-DataStart       length of data needed to copy to Ram on bootup


bss             equ       $00800000
                org       bss
* Build a ram based vector table for interrupts so we can install our own ISRs in C code at run time


                org     $00800000
L1IRQ           ds.l    1       storage for 4 byte address of Timer 4 ISR
L2IRQ           ds.l    1       storage for 4 byte address of Timer 3 ISR
L3IRQ           ds.l    1       storage for 4 byte address of Timer 2 ISR
L4IRQ           ds.l    1       storage for 4 byte address of Timer 1 ISR
L5IRQ           ds.l    1       storage for 4 byte address of Key3 ISR
L6IRQ           ds.l    1       storage for 4 byte address of Key2 ISR
L7IRQ           ds.l    1       storage for 4 byte address of Key1 ISR

                section   heap           area for dynamic memory allocation e.g. malloc() etc
                align
bssEnd          equ *                   end of storage space for unitialised variables
*                                       we have to copy all initialised variable from rom to here at startup
heap   equ       *