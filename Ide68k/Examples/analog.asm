; ANALOG.ASM - Read slidebar and copy to bar graph display and LEDs

; To run this program in the 68000 Visual Simulator, you must enable the
; SLIDER, LED's and BARGRAPH windows from the Peripherals menu.

; Although this program can be run in Single-step and Auto-step mode,
; Run mode is preferred.

; If you click the mouse on the slider button and keep the mousebutton
; down, you can move the slider control up and down. The BARGRAPH will
; display the slider position in analog form. The LED display indicates
; the slider position in binary (0 - 255).

; Author: Peter J. Fondse (pfondse@hetnet.nl)

LEDS    equ     $E003       ; I/O address of LED display
SLIDER  equ     $E005       ; I/O address of slider
BAR     equ     $E007       ; I/O address of bar display

        org     $400

start   move.b  SLIDER,D0   ; read track bar position
        move.b  D0,LEDS     ; write to LED display
        move.b  D0,BAR      ; write to BAR display
        bra     start       ; repeat
