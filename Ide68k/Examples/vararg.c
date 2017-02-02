/* VARARG.C - A program to test va_start, va_arg and va_end macro's in stdarg.h */

/* This is a C program to test passing of a variable number of
 * arguments to a function using the ANSI-defined macros va_start,
 * va_list and va_end.
 *
 * Author: Peter J. Fondse (pfondse@hetnet.nl)
*/

#include <stdio.h>
#include <stdarg.h>

void add(char *msg, ...)
{
   int sum = 0;
   int i;
   va_list argp;

   va_start(argp, msg);
   while ((i = va_arg(argp, int)) != 0) sum += i;
   va_end(argp);
   printf(msg, sum);
}

// main

void main(void)
{
    add("The sum of 1, 2, 3 and 4 is %d\n", 1, 2, 3, 4, 0);
}
