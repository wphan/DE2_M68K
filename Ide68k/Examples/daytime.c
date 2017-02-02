// DAYTIME.C - a program to display the time of day

// This program can be compiled by loading daytime.prj in the "Project|Open
// project" menu.

// Be sure to select option "generate assembly listing" for every file in
// the project, otherwise it cannot be run on the 68000 Visual Simulator.

// Its main purpose is to show how 68000 I/O devices can be programmed from
// a C-program (using an array of 7 segment displays)

// To run this program in the 68000 Visual Simulator, you must enable the
// 7-SEGMENT DISPLAY window from the Peripherals menu.

// Although this program can be run in Single-step and Auto-step mode,
// Run mode is preferred.

// Author: Peter J. Fondse (pfondse@hetnet.nl)

#define secs_minute     60
#define secs_hour      (60 * secs_minute)
#define secs_day       (24 * secs_hour)

// time zone difference from UTC, east = +, west = -
#define TZ  +2

// Pointer to I/O device
short *display = (short *) 0xE010; // display[0] is leftmost digit etc.

// bit pattern for 7 segment display 0 - 9
short bitpat[] = { 0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F };

// pseudo assembly function
unsigned long gettime(void)
{
	_trap(15);
	_word(9);
	return _D0;
}

void main(void)
{
    unsigned long time;
    int hrs, min, secs;

    for (;;) {
        time = gettime() + TZ * secs_hour;   // get UTC time and add timezone offset
        time %= secs_day;                    // time = seconds since midnight
        hrs = time / secs_hour;
        time %= secs_hour;                   // time = seconds since hour
        min = time / secs_minute;
        secs = time % secs_minute;
        // display time on 7 seg display array
        display[0] = bitpat[hrs / 10];
        display[1] = bitpat[hrs % 10] | (secs << 7);
        display[2] = bitpat[min / 10];
        display[3] = bitpat[min % 10];
    }
}
