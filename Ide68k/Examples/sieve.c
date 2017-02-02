/* SIEVE.C - Sieve of Erastothenes to find prime numbers */

/* This is a C language version of Eratosthenes' sieve to find prime
 * numbers. Its main purpose is to check the execution speed of the
 * simulator versus a real 68000 microcomputer board. As is turned
 * out, the simulator runs about ten times faster than the real 68000
 * at 10 MHz.(On a 2.8 GHz Pentium PC).
 *
 * Author: Peter J. Fondse (pfondse@hetnet.nl)
*/

#include <stdio.h>

#define MAX    10000
#define LOOPS  10
#define TRUE   1
#define FALSE  0

char prime[MAX];

void main(void)
{
    int i, j, k, n = 1;

    for (k = 0; k < LOOPS; k++) {
        for (i = 0; i < MAX; i++) prime[i] = TRUE;
        for (n = 1, i = 2; i < MAX; i++) {
            if (prime[i]) {
                for (j = 2 * i; j < MAX; j += i) prime[j] = FALSE;
                n++;
           }
        }
    }
    printf("%d primes between 1 and %d\n", n, MAX);
}
