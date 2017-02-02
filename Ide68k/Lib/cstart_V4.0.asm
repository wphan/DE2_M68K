; CSTART.ASM  -  C startup-code for SIM68K
                section CODE
                align

                org $00000000          ;start of rom based vector table
InitialSP       dc.l $00840000         ;initial supervisor state stack pointer
InitialPC       dc.l start             ;address of 1st instruction of program after a reset
BusError        dc.l stop              ;bus error - stop program
AddressError    dc.l stop              ;address error - stop program
IllegalInstr    dc.l stop              ;illegal instruction - stop program
DividebyZero    dc.l stop              ;divide by zero error - stop program
Check           dc.l stop              ;Check instruction - stop program
TrapV           dc.l stop              ;Trapv instruction - stop program
Privilege       dc.l stop              ;privilige violation - stop program
Trace           dc.l stop              ;stop on trace
Line1010emul    dc.l stop              ;1010 instructions stop
Line1111emul    dc.l stop              ;1111 instructions stop
Unassigned1     dc.l stop              ;unassigned vector
Unassigned2     dc.l stop              ;unassigned vector
Unassigned3     dc.l stop              ;unassigned vector
Uninit_IRQ      dc.l stop              ;uninitialised interrupt
Unassigned4     dc.l stop              ;unassigned vector
Unassigned5     dc.l stop              ;unassigned vector
Unassigned6     dc.l stop              ;unassigned vector
Unassigned7     dc.l stop              ;unassigned vector
Unassigned8     dc.l stop              ;unassigned vector
Unassigned9     dc.l stop              ;unassigned vector
Unassigned10    dc.l stop              ;unassigned vector
Unassigned11    dc.l stop              ;unassigned vector
SpuriousIRQ     dc.l stop              ;stop on spurious irq
*
*
Level1IRQ       dc.l Level1RamISR
Level2IRQ       dc.l Level2RamISR
Level3IRQ       dc.l Level3RamISR
Level4IRQ       dc.l Level4RamISR
Level5IRQ       dc.l Level5RamISR
Level6IRQ       dc.l Level6RamISR
Level7IRQ       dc.l Level7RamISR
*
*
Trap0           dc.l stop           ; stop on Trap until trap handler implemented
Trap1           dc.l stop           ; stop on Trap until trap handler implemented
Trap2           dc.l stop           ; stop on Trap until trap handler implemented
Trap3           dc.l stop           ; stop on Trap until trap handler implemented
Trap4           dc.l stop           ; stop on Trap until trap handler implemented
Trap5           dc.l stop           ; stop on Trap until trap handler implemented
Trap6           dc.l stop           ; stop on Trap until trap handler implemented
Trap7           dc.l stop           ; stop on Trap until trap handler implemented
Trap8           dc.l stop           ; stop on Trap until trap handler implemented
Trap9           dc.l stop           ; stop on Trap until trap handler implemented
Trap10          dc.l stop           ; stop on Trap until trap handler implemented
Trap11          dc.l stop           ; stop on Trap until trap handler implemented
Trap12          dc.l stop           ; stop on Trap until trap handler implemented
Trap13          dc.l stop           ; stop on Trap until trap handler implemented
Trap14          dc.l stop           ; stop on Trap until trap handler implemented
Trap15          dc.l stop           ; stop on Trap until trap handler implemented

* Other vectors are reserved so feel free to add here
*

                org       $00000400

start:
                move.w    #$0000,SR             clear interrupts to enable all, move to user mode
                move.l    #$00820000,a7         load the user stack pointer

* 68000 instruction for easy waveform simulation in quartus. This helps with debugging hardware
*
*                move.b     #0,$004000044    program baud rate generator
*                move.b     #%01011101,$00400040     divide by 16 clock, set rts high, 8 bits plus odd parity, transmitter interrupt disabled
*                move.b     $00400040,d0     read status register
*                move.b     #$51,$400042     write ascii char to acia transmit register
*
                move.b    #$FF,$00800000
                move.b    #$FF,$00800001
                move.b    $00800000,d0
                move.b    $00800000,d1
* end of simulation instructions

*************************************************************************************
* Copy initialised variables to Ram at startup
************************************************************************************

mainloop        movea.l   #DataStart,a0          point a0 to the start of the initialised data section held in ROM
                movea.l   #bssEnd,a1             point a1 to the start of the Ram where we copy initialised data to at run time
                movea.l   #bssEnd,a5             used as a relocatable pointer (required by C compiler so never change a5)
                move.l    #DataLength,d0         get how many bytes to copy
                beq       varinitialised
varinit         move.b    (a0)+,(a1)+
                subq.l    #1,d0
                bne       varinit

varinitialised  jsr       _main
                bra       mainloop
Level1RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    L1IRQ,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Level2RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    L2IRQ,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Level3RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    L3IRQ,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Level4RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    L4IRQ,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Level5RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    L5IRQ,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Level6RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    L6IRQ,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Level7RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    L7IRQ,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

stop            bra *                               loop here

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
L4IRQ           ds.l    1       storage for 4 byte address of Key 2 ISR
L5IRQ           ds.l    1       storage for 4 byte address of Key 1 ISR
L6IRQ           ds.l    1       storage for 4 byte address of Timer 1 ISR
L7IRQ           ds.l    1       storage for 4 byte address <NOT USED>

__ungetbuf:
          dc.w    1                ; ungetbuffer for stdio functions
__allocp:
          dc.l    0                ; start of allocation units
__heap:
          dc.l    0                ; pointers for malloc functions
*__himem:
*          dc.l    himem            ; highest memory location + 1
*__stklen:
*          dc.l    stklen           ; default stack size

                section   heap           area for dynamic memory allocation e.g. malloc() etc
                align
bssEnd          equ *                   end of storage space for unitialised variables
*                                       we have to copy all initialised variable from rom to here at startup
heap   equ       *
           align