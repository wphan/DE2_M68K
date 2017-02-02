; KERNEL.ASM - Load and execute a child process

; This program demonstrates how a program loads and starts a child process
; child process runs in user mode with 16 kB allocated
; child terminates with standard TRAP #15 / DC.W 0 call

; Author: Peter J. Fondse (pfondse@hetnet.nl)

LF       equ     $0A           ; some ASCII chars
CR       equ     $0D

tp15vec  equ     $00BC         ; TRAP #15 vector address

         org     $400
; load child module
         lea     child,A0      ; get name of child module = 'div2'
         trap    #15
         dc.w    19            ; load child, entry point in D0
         beq.s   loaderror     ; D0 = 0 on error
         move.l  D0,A1         ; save entrypoint in A1
         lea     startmsg,A0
         trap    #15
         dc.w    7             ; print "start of child" message
; take over TRAP #15 handler
         move.l  tp15vec,tp15  ; save orig. TRAP #15 address in "tp15"
         lea     tp15proc,A0
         move.l  A0,tp15vec    ; replace orig. TRAP #15 address with handler address
; start child module
         move.l  A1,A0         ; get entry point of child
         add.l   #$4000,A0     ; allocate 16 kB for child
         move.l  A0,USP        ; load initial SP for child
         move.l  A1,-(A7)      ; push initial PC for child (= entry point)
         move.w  #$0000,-(A7)  ; push initial SR for child
         rte                   ; Return from exception, this sets PC and SR, loads SP with USP

; TRAP #15 handler - process TRAP #15 call from child (cannot use any register w/o saving first)
tp15proc:
         movem.l D0/A0,-(A7)   ; save D0 & A0
         move.l  10(A7),A0     ; get TRAP #15 return address in child module
         move.w  (A0),D0       ; get code at return address
         bne.s   process       ; if not 0, process trap
         add.l   #14,A7        ; remove saved regs + trap stackframe
         jmp     terminate     ; child has terminated
process: movem.l (A7)+,D0/A0   ; restore D0 & A0
         move.l  tp15,-(A7)    ; push orig. TRAP #15 vector
         rts                   ; jump to orig. handler

; here when child terminates
terminate:
         move.l  tp15,tp15vec  ; restore orig. TRAP #15 vector
         lea     endmsg,A0
         trap    #15           ; print "child terminated" message
         dc.w    7
         stop    #$2000        ; stop parent process

; when child cannot be loaded
loaderror:
         trap    #15
         dc.w    7             ; print modulename first
         lea     errmsg,A0
         trap    #15
         dc.w    7             ; followed by error message
         trap    #15
         dc.w    0             ; exit
         stop    #$2700

child    dc.b    "div2",0      ; Child process to run
startmsg dc.b    "start of child process",CR,LF,0
endmsg   dc.b    CR,LF,"child process terminated",CR,LF,0
errmsg   dc.b     ": error loading module",CR,LF,0
tp15     ds.l    1
