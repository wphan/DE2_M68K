/* STDIO.H for CC680x0 */

#ifndef __STDIO_DEF_
#define __STDIO_DEF_

#include <stdarg.h>

#define NULL       (0L)
#define EOF        (-1)

#define putchar(c) putch(c)
#define getchar()  getche()

extern int _ungetbuf;

int _putch(int);      // used to be int _putch(int) ;
int _getch(void);      // used to be int _getch(void) ;
int _exit(int);
int _kbhit(void);
int kbhit(void);
int putch(int);
int getche(void);
int getch(void);
int ungetch(int);
int puts(char *);
char *gets(char *);
int printf(char *, ...);
int vprintf(char *, va_list);
int sprintf(char *, char *, ...);
int vsprintf(char *, char *, va_list);
void scanflush(void);
int scanf(char *, ...);
int vscanf(char *, va_list);
int sscanf(char *, char *, ...);
int vsscanf(char *, char *, va_list);

#endif