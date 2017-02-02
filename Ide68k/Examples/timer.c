// TIMER.C - a program to count seconds since start of 68000 program

// This program can be compiled by loading timer.prj in the "Project|Open
// project" menu.

// Be sure to select option "generate assembly listing" for every file in
// the project, otherwise it cannot be run on the 68000 Visual Simulator.

// To run this program in the 68000 Visual Simulator, you must enable the
// 7-SEGMENT DISPLAY window from the Peripherals menu.

// The display indicates the time in seconds since the 68000 program has
// started. Its main purpose is to show how 68000 I/O devices can be
// programmed from a C-program (using pointers to the device).

// Although this program can be run in Single-step and Auto-step mode,
// Run mode is preferred.

// Author: Peter J. Fondse (pfondse@hetnet.nl)

// Pointers to I/O devices
unsigned short *display = (unsigned short *) 0xE010; // display[0] is leftmost digit etc.
unsigned long *timer = (unsigned long *) 0xE040;     // timer

// bit pattern for 7 segment display 0 - 9
unsigned short bitpat[] = { 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F };

// clear 7 segment display
void clear7seg(void)
{
    int i;

    for (i = 0; i < 3; i++) display[i] = 0;      // clear first 3 digits
    display[3] = bitpat[0];                      // last digit is '0'
}

// write to 7 segment display (recursive)
void write7seg(long n, int i)
{
    if (n > 9) write7seg(n / 10, i - 1);
    display[i] = bitpat[n % 10];
}

void main(void)
{
    long counter = 0;

    clear7seg();
    for (;;) {
        long cntr = *timer / 10;
        if (counter != cntr) {                   // timer has changed
            counter = cntr;
            if (counter == 10000) break;         // stop after 9999 seconds
            write7seg(counter, 3);
        }
    }
}
