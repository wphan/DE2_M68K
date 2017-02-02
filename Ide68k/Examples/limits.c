/* LIMITS.C - show maximum and minimum values of types defined in CC68K */

/* This program can be compiled by loading limits.prj in the
 * "Project|Open project" menu. Its main purpose is to test limits.h
 * and displays the maximimum values of char's, short's, int's and
 * long's both signed and unsigned.
 *
 * Author: Peter J. Fondse (pfondse@hetnet.nl)
*/

#include <stdio.h>
#include <limits.h>

void main(void)
{
   /* signed types */
   printf("signed char  = %d ... %d\n", SCHAR_MIN, SCHAR_MAX);
   printf("signed short = %d ... %d\n", SHRT_MIN, SHRT_MAX);
   printf("signed int   = %d ... %d\n", INT_MIN, INT_MAX);
   printf("signed long  = %ld ... %ld\n\n", LONG_MIN, LONG_MAX);
   /* unsigned types */
   printf("unsigned char  = 0 ... %u\n", UCHAR_MAX);
   printf("unsigned short = 0 ... %u\n", USHRT_MAX);
   printf("unsigned int   = 0 ... %u\n", UINT_MAX);
   printf("unsigned long  = 0 ... %lu\n", ULONG_MAX);
}
