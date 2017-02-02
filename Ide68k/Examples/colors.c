// COLORS.C - A C-program for testing ANSI escape-sequences

// This is a C program to demonstrate ANSI Escape sequences for color
// setting. The program runs forever and can only be terminated by
// resetting the simulator (Ctrl+Break).

// Author: Peter J. Fondse (pfondse@hetnet.nl)

#include <stdio.h>

void main(void)
{
   int i, j;
   long k;

   for (;;) {
       for (i = 40; i < 48; i++) {
           printf("\033[%dm", i);             // Set background color
           printf("\033[2J");                 // Erase screen
           for (j = 30; j < 38; j++) {
               printf("\033[%dm", j);         // Set text color
               printf("Colors");
               printf("\033[2B");             // cursor 2 pos. down
               for (k = 0; k < 90000; k++);   // delay, depends on PC frequency
           }
       }
   }
}
