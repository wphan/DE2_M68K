; CSTART.ASM  -  C startup-code for SIM68K
                section CODE
                align

                org $00000000
InitialSP       dc.l $00840000
InitialPC       dc.l start

                org $00000064
Level1IRQ       dc.l Timer4RamISR
Level2IRQ       dc.l Timer3RamISR
Level3IRQ       dc.l Timer2RamISR
Level4IRQ       dc.l Timer1RamISR
Level5IRQ       dc.l Key3PressRamISR
Level6IRQ       dc.l Key2PressRamISR
Level7IRQ       dc.l Key1PressRamISR



                org       $00000400
start:          move.w    #$0000,SR     clear interrupts to enable all
                move.l    #$0083f000,a7    load the user stack pointer

* Copy initialised variables to Ram at startup


                jmp       _main


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