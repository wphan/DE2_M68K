/* CTYPE.H for CC68x0 */

#ifndef __CTYPE_DEF_
#define __CTYPE_DEF_

#define ISUNDEF  0x00
#define ISLOWER  0x01
#define ISUPPER  0x02
#define ISDIGIT  0x04
#define ISXDIGIT 0x08
#define ISSPACE  0x10
#define ISPUNCT  0x20
#define ISCTRL   0x40
#define ISPRINT  0x80

extern unsigned char _ctype[];

#define islower(x)  (_ctype[(x) + 1] & (char) ISLOWER)
#define isupper(x)  (_ctype[(x) + 1] & (char) ISUPPER)
#define isdigit(x)  (_ctype[(x) + 1] & (char) ISDIGIT)
#define isxdigit(x) (_ctype[(x) + 1] & (char) ISXDIGIT)
#define isspace(x)  (_ctype[(x) + 1] & (char) ISSPACE)
#define ispunct(x)  (_ctype[(x) + 1] & (char) ISPUNCT)
#define iscntrl(x)  (_ctype[(x) + 1] & (char) ISCTRL)
#define isprint(x)  (_ctype[(x) + 1] & (char) ISPRINT)
#define isalpha(x)  (_ctype[(x) + 1] & (char) (ISLOWER | ISUPPER))
#define isalnum(x)  (_ctype[(x) + 1] & (char) (ISLOWER | ISUPPER | ISDIGIT))
#define isgraph(x)  (_ctype[(x) + 1] & (char) (ISLOWER | ISUPPER | ISDIGIT | ISPUNCT))
#define isascii(x)  (((x) & (char) ISPRINT) == 0)

#define toascii(x)  ((x) & 0x7F)
#define _tolower(x) ((x) | 0x20)
#define _toupper(x) ((x) & 0x5F)

int toupper(int);
int tolower(int);

#endif
