; C:\M68KV6.0 - DE2 - 640BY480 - FOR 465 STUDENTS\PROGRAMS\DEBUGMONITORCODE\FLASHROUTINES.C - Compiled by CC68K  Version 5.00 (c) 1991-2005  Peter J.Fondse
; #include "DebugMonitor.h"
; /* erase chip by writing to address with data*/
; void EraseFlashChip(void)
; {
       section   code
       xdef      _EraseFlashChip
_EraseFlashChip:
       rts
; }
; void FlashReset(void)
; {
       xdef      _FlashReset
_FlashReset:
       rts
; }
; /* erase sector by writing to address with data*/
; void FlashSectorErase(int SectorAddress)
; {
       xdef      _FlashSectorErase
_FlashSectorErase:
       link      A6,#0
       unlk      A6
       rts
; }
; /* program chip by writing to address with data*/
; void FlashProgram(unsigned int AddressOffset, int ByteData)		// write a byte to the specified address (assumed it has been erased first)
; {
       xdef      _FlashProgram
_FlashProgram:
       link      A6,#0
       unlk      A6
       rts
; }
; /* program chip to read a byte */
; unsigned char FlashRead(unsigned int AddressOffset)		// read a byte from the specified address (assumed it has been erased first)
; {
       xdef      _FlashRead
_FlashRead:
       link      A6,#0
; return 0 ; 	// dummy return to it will compile before you have written your code
       clr.b     D0
       unlk      A6
       rts
; }
