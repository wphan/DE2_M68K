/* STDLIB.H for CC680x0 */

#ifndef __STDLIB_DEF_
#define __STDLIB_DEF_

#define max(a,b) (((a) > (b)) ? (a) : (b))
#define min(a,b) (((a) < (b)) ? (a) : (b))
#define abs(a)   (((a) < 0) ? -(a) : (a))

char *ltoa(long, char *, int);
char *ultoa(unsigned long, char *, int);
char *itoa(int, char *, int);
int atoi(char *);
long atol(char *);
long strtol(char *, char **, int);
double strtod(char *, char **);
void exit(int);

#endif