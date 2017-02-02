/* STRING.H for CC680x0*/

#ifndef __STRING_DEF_
#define __STRING_DEF_

void *memset(void *, int, int);
void *memcpy(void *, void *, int);
char *strcat(char *, char *);
char *strchr(char *, int);
int strcmp(char *, char *);
char *strcpy(char *, char *);
int strcspn(char *, char *);
int strlen(char *);
char *strupr(char *);
char *strlwr(char *);
char *strncat(char *, char *);
int strncmp(char *, char *, int);
char *strncpy(char *, char *, int);
char *strpbrk(char *, char *);
char *strrchr(char *, int);
int strspn(char *, char *);
char *strtok(char *, char *);

#endif