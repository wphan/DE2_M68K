
; CSTART.ASM  -  C startup-code
                section CODE
                align

                org $00000000          ;start of rom based vector table
InitialSP       dc.l $00880000         ;initial supervisor state stack pointer(stack decrements first before being used
InitialPC       dc.l start             ;address of 1st instruction of program after a reset
BusError        dc.l E_BErro           ;bus error - stop program
AddressError    dc.l E_AErro           ;address error - stop program
IllegalInstr    dc.l E_IInst           ;illegal instruction - stop program
DividebyZero    dc.l E_DZero           ;divide by zero error - stop program
Check           dc.l E_Check           ;Check instruction - stop program
TrapV           dc.l E_Trapv           ;Trapv instruction - stop program
Privilege       dc.l E_Priv            ;privilige violation - stop program
Trace           dc.l E_Trace           ;stop on trace
Line1010emul    dc.l E_1010            ;1010 instructions stop
Line1111emul    dc.l E_1111            ;1111 instructions stop
Unassigned1     dc.l E_Unnas1           ;unassigned vector
Unassigned2     dc.l E_Unnas2           ;unassigned vector
Unassigned3     dc.l E_Unnas3           ;unassigned vector
Uninit_IRQ      dc.l E_UnitI           ;uninitialised interrupt
Unassigned4     dc.l E_Unnas4           ;unassigned vector
Unassigned5     dc.l E_Unnas5           ;unassigned vector
Unassigned6     dc.l E_Unnas6           ;unassigned vector
Unassigned7     dc.l E_Unnas7           ;unassigned vector
Unassigned8     dc.l E_Unnas8           ;unassigned vector
Unassigned9     dc.l E_Unnas9           ;unassigned vector
Unassigned10    dc.l E_Unnas10           ;unassigned vector
Unassigned11    dc.l E_Unnas11           ;unassigned vector
SpuriousIRQ     dc.l E_Spuri           ;stop on spurious irq
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
Trap0           dc.l Trap0RamISR        ; User installed trap handler
Trap1           dc.l Trap1RamISR        ; User installed trap handler
Trap2           dc.l Trap2RamISR        ; User installed trap handler
Trap3           dc.l Trap3RamISR        ; User installed trap handler
Trap4           dc.l Trap4RamISR        ; User installed trap handler
Trap5           dc.l Trap5RamISR        ; User installed trap handler
Trap6           dc.l Trap6RamISR        ; User installed trap handler
Trap7           dc.l Trap7RamISR        ; User installed trap handler
Trap8           dc.l Trap8RamISR        ; User installed trap handler
Trap9           dc.l Trap9RamISR        ; User installed trap handler
Trap10          dc.l Trap10RamISR       ; User installed trap handler
Trap11          dc.l Trap11RamISR       ; User installed trap handler
Trap12          dc.l Trap12RamISR       ; User installed trap handler
Trap13          dc.l Trap13RamISR       ; User installed trap handler
Trap14          dc.l Trap14RamISR       ; User installed trap handler
Trap15          dc.l Trap15RamISR       ; User installed trap handler

*
* Other vectors 64-255 are users vectors for autovectored IO device (not implemented in TG68)
*

                org       $00000400

start:          move.w     #$2700,SR             set interrupts to disable until later

*************************************************************************************
** add some 68000 instruction to read and write to memory, IO etc. This doesn't do anything
** important, it just creates read and write bus cycles to specific addresses which
** help with debugging hardware in Quartus simulations
**************************************************************************************

* graphics
*	move.w	  #$0001,$FF100000	x1
*	move.w	  #$0001,$FF100002	y1
*	move.w	  #$FFFF,$FF100008	colour
*	move.w	  #$ffFF,$FF100010	font reg
*	move.w	  #$ffFF,$FF100012	font reg
*	move.w	  #$ffFF,$FF100014	font reg
*	move.w	  #$ffFF,$FF100016	font reg
*	move.w	  #$ffFF,$FF100018	font reg
*	move.w	  #$ffFF,$FF10001a	font reg
*	move.w	  #$ffFF,$FF10001c	font reg
*	move.w	  #$0005,$FF10000A	command char


                move.b     #$55,$F0000000       write to memory
                move.b     $F0000000,d0         read it back
                move.b     #$55,$01000000       write to the flash (ignored without proper protocol)
                move.b     $01000000,d0         read it back
                move.l     #$11223344,$00860000       write 32 bits, to memory
                move.l     $00860000,d0         read 32 bits back
                move.b     #0,$00400000         write to the output ports
                move.b     #0,$00400002         write to the output ports
                move.b     #0,$00400004         write to the output ports
                move.b     #0,$00400006         write to the output ports
                move.b     #0,$00400008         write to the output ports
                move.b     #0,$00400010         write to the hex display ports
                move.b     #0,$00400012         write to the hex display ports
                move.b     #0,$00400020         write to the LCD
                move.b     #0,$00400022         write to the LCD
                move.b     #0,$00400030         write to the Timer1 Data
                move.b     #0,$00400032         write to the Timer1 Control

                ; program DMA
                move.l     #$00000000,$FF000000     write to DMA From address
                move.l     #$00860000,$FF000004     write to DMA to
                move.l     #$00000010,$FF000008     count = hex 10 (16) words
                move.w     #%000000000010100,$FF00000C             go DMA increment from/to by 2, word trasnfer

*************************************************************************************
* Copy initialised variables to Ram at startup
************************************************************************************

mainloop        jsr       _main
                bra       mainloop

*********************************************************************************************************
* Code to call Ram Based Interrupt handler and other exeception handler code
*********************************************************************************************************
Level1RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VL1IRQ,a0               get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Level2RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VL2IRQ,a0               get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Level3RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VL3IRQ,a0               get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
Level4RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VL4IRQ,a0               get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

* Trace trap Handler

Level5RamISR
*
**         Copy 68000 registers from debug monitor Variables,
*
*
                move.l    #1,_Trace              switch on Trace Mode
                move.b    #$0,$0040000A          turn off a trace exception so we don't when generate a trace when disassembling instruction in the register dump (disassembling causes access to use program)
                move.w    (sp)+,_SR              get at the users status register pointed to by stack pointer and copy
                move.l    (sp)+,_PC              get at the users program counter and copy
*
                move.l    SP,_SSP                copy system stack pointer to debug monitor variable
                move.l    d0,_d0
                move.l    d1,_d1
                move.l    d2,_d2
                move.l    d3,_d3
                move.l    d4,_d4
                move.l    d5,_d5
                move.l    d6,_d6
                move.l    d7,_d7
*
                move.l    a0,_a0
                move.l    a1,_a1
                move.l    a2,_a2
                move.l    a3,_a3
                move.l    a4,_a4
                move.l    a5,_a5
                move.l    a6,_a6
                move.l    usp,a0
                move.l    a0,_USP
*
                move.l    VL5IRQ,a0              get ram based address into a0, trace exception for next instruction will be generated in Menu SPACE command
                jsr       0(a0)                  jump to the subroutine that is the trap handler, using ram based address

** After trace, reload 68000 registers with new values before continuing

                move.l   _d0,d0
                move.l   _d1,d1
                move.l   _d2,d2
                move.l   _d3,d3
                move.l   _d4,d4
                move.l   _d5,d5
                move.l   _d6,d6
                move.l   _d7,d7

                move.l   _USP,a0
                move.l   a0,USP                     load user stack pointer
                move.l   _a0,a0
                move.l   _a1,a1
                move.l   _a2,a2
                move.l   _a3,a3
                move.l   _a4,a4
                move.l   _a5,a5
                move.l   _a6,a6

                move.l   _SSP,sp
                move.l   _PC,-(sp)
                move.w   _SR,-(sp)
                move.b    $00000074,$0	          read trace exception vector after accessing disassembly to reset the trace request causes by disassembling program above
                rte

* address trap handler

Level6RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VL6IRQ,a0               get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Level7RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VL7IRQ,a0               get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the interrupt handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte


********************************************************************************************************
* Ram based Trap handler and other exeception handler code
*********************************************************************************************************

Trap0RamISR     movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap0,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap1RamISR     movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap1,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap2RamISR     movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap2,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap3RamISR     movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap3,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap4RamISR     movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap4,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap5RamISR     movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap5,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap6RamISR     movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap6,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap7RamISR     movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap7,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap8RamISR     movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap8,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap9RamISR     movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap9,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap10RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap10,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap11RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap11,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap12RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap12,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap13RamISR    movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrap13,a0                get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte

Trap14RamISR    ;Break Point Handler
*
**         Copy 68000 registers from debug monitor Variables
*
                move.l    #1,_Trace      switch on Trace Mode
                move.w    (sp)+,_SR       get at the users status register pointed to by stack pointer and copy
                move.l    (sp)+,_PC      get at the users program counter and copy
*
                move.l    d0,_d0
                move.l    d1,_d1
                move.l    d2,_d2
                move.l    d3,_d3
                move.l    d4,_d4
                move.l    d5,_d5
                move.l    d6,_d6
                move.l    d7,_d7
*
                move.l    a0,_a0
                move.l    a1,_a1
                move.l    a2,_a2
                move.l    a3,_a3
                move.l    a4,_a4
                move.l    a5,_a5
                move.l    a6,_a6
                move.l    USP,a0
                move.l    a0,_USP
*
                move.l    VTrap14,a0             get ram based address into a0
                jsr       0(a0)                  jump to the subroutine that is the trap handler, using ram based address

** After breakpoint reload 68000 registers with new values before continuing

*                move.b    #$ff,$0040000A     generate a trace exception for the next instruction
                move.l   _d0,d0
                move.l   _d1,d1
                move.l   _d2,d2
                move.l   _d3,d3
                move.l   _d4,d4
                move.l   _d5,d5
                move.l   _d6,d6
                move.l   _d7,d7

                move.l   _USP,a0
                move.l   a0,USP        load user stack pointer A7
                move.l   _a0,a0
                move.l   _a1,a1
                move.l   _a2,a2
                move.l   _a3,a3
                move.l   _a4,a4
                move.l   _a5,a5
                move.l   _a6,a6

                move.l   _PC,-(sp)
                move.w   _SR,-(sp)
                rte

Trap15RamISR    jmp     _CallDebugMonitor
*                movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
*                move.l    VTrap15,a0                get ram based address into a0
*                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
*                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
*                rte

*********************************************************************************************************
*Default exception handler for everything without a specific handler
*********************************************************************************************************

*
**              Jump here for each unhandled exception
**              If you need to, MAKE SURE YOU SAVE ALL IMPORTANT REGISTERS AND RESTORE THEM BEFORE RETURNING (IF APPROPRIATE)
*

E_BErro         movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VBusError,a0            get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
E_AErro         movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VAddressError,a0        get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
E_IInst         movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VIllegalInstr,a0        get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
E_DZero         movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VDividebyZero,a0        get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
E_Check         movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VCheck,a0               get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
E_Trapv         movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrapV,a0               get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
E_Priv          movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VPrivilege,a0           get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
E_Trace         movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VTrace,a0               get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
E_1010          movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VLine1010emul,a0        get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
E_1111          movem.l   d0-d7/a0-a6,-(SP)       save everything not automatically saved
                move.l    VLine1111emul,a0        get ram based address into a0
                jsr       0(a0)                   jump to the subroutine that is the trap handler, using ram based address
                movem.l   (SP)+,d0-d7/a0-a6       pull eveything off the stack
                rte
E_Unnas1
E_Unnas2
E_Unnas3
E_UnitI
E_Unnas4
E_Unnas5
E_Unnas6
E_Unnas7
E_Unnas8
E_Unnas9
E_Unnas10
E_Unnas11
E_Spuri
_stop            bra _stop                         stop
***************************************************************************************************
* Go() function in debug monitor
***************************************************************************************************
_go
                move.l   _SSP,a7        load system stack pointer (remember we are in supervisor mode when running this so a7 is the System stack pointer)
                move.l   _PC,-(sp)      copy debug monitor PC variable to the stack
                move.w   _SR,-(sp)      copy debug monitor status reg to the stack

                move.b   $00000078,d0  remove any spurious address exception arising after power on
                move.l   _d0,d0
                move.l   _d1,d1
                move.l   _d2,d2
                move.l   _d3,d3
                move.l   _d4,d4
                move.l   _d5,d5
                move.l   _d6,d6
                move.l   _d7,d7

                move.l   _USP,a0
                move.l   a0,USP        load user stack pointer (remember we are in supervisor mode when running this, so a7 is the System stack pointer)
                move.l   _a0,a0
                move.l   _a1,a1
                move.l   _a2,a2
                move.l   _a3,a3
                move.l   _a4,a4
                move.l   _a5,a5
                move.l   _a6,a6
                rte                    load the status reg and PC from the stack and commence running
                                       *used to be rte but this didn't load the status byte


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

                org     $00840000               Ram based vector table must be stored here otherwise InstallException Handler will not work
DataLength      equ     DataEnd-DataStart       length of data needed to copy to Ram on bootup


bss             org       bss

*********************************************************************************************************
* Build a ram based vector table for interrupts so we can install our own Exception Handlers in C code at run time
* install the exception handler using the C function InstallExceptionHandler()
*********************************************************************************************************



VInitialSP       ds.l    1      dummy as we can't really install a handler for this
VInitialPC       ds.l    1      dummy as we can't reallin install a handler for this
VBusError        ds.l    1      storage for address of Bus Error Handler
VAddressError    ds.l    1      storage for address of Address Error Handler
VIllegalInstr    ds.l    1      storage for address of Illegal Instruction handler
VDividebyZero    ds.l    1      storage for address of divide by zero handler
VCheck           ds.l    1      ditto
VTrapV           ds.l    1      ditto
VPrivilege       ds.l    1      ditto
VTrace           ds.l    1
VLine1010emul    ds.l    1
VLine1111emul    ds.l    1
VUnassigned1     ds.l    1
VUnassigned2     ds.l    1
VUnassigned3     ds.l    1
VUninit_IRQ      ds.l    1
VUnassigned4     ds.l    1
VUnassigned5     ds.l    1
VUnassigned6     ds.l    1
VUnassigned7     ds.l    1
VUnassigned8     ds.l    1
VUnassigned9     ds.l    1
VUnassigned10    ds.l    1
VUnassigned11    ds.l    1
VSpuriousIRQ     ds.l    1

* Interrupt handlers Vector 25-31
VL1IRQ           ds.l    1       storage for 4 byte address of IRQ handler in your C program - install the handler using the C function InstallExceptionHandler()
VL2IRQ           ds.l    1       storage for 4 byte address of IRQ handler in your C program - install the handler using the C function InstallExceptionHandler()
VL3IRQ           ds.l    1       storage for 4 byte address of IRQ handler in your C program - install the handler using the C function InstallExceptionHandler()
VL4IRQ           ds.l    1       storage for 4 byte address of IRQ handler in your C program - install the handler using the C function InstallExceptionHandler()
VL5IRQ           ds.l    1       storage for 4 byte address of IRQ handler in your C program - install the handler using the C function InstallExceptionHandler()
VL6IRQ           ds.l    1       storage for 4 byte address of IRQ handler in your C program - install the handler using the C function InstallExceptionHandler()
VL7IRQ           ds.l    1       storage for 4 byte address of IRQ handler in your C program - install the handler using the C function InstallExceptionHandler()

* Trap Handler vectors 32-47
VTrap0           ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap1           ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap2           ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap3           ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap4           ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap5           ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap6           ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap7           ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap8           ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap9           ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap10          ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap11          ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap12          ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap13          ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap14          ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()
VTrap15          ds.l   1        storage for 4 byte address of TRAP handler in your C program - install the handler using the C function InstallExceptionHandler()

* the remaining exceptions are unassigned in the 68000 so no need to allocate storage for them here

***********************************************************************************************************
* Other Variables
***********************************************************************************************************
*__DebugA5       ds.l    1
*__UserA5        ds.l    1

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