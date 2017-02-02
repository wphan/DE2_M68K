/* MALLOC.H for CC68K */

#ifndef __MALLOC_DEF_
#define __MALLOC_DEF_

typedef struct header {
    unsigned size;
    struct header *next;
} HEADER;

extern char *_heap;
extern char *_stack;
extern HEADER *_allocp;

void *sbrk(unsigned int);
void *calloc(unsigned int, unsigned int);
void *malloc(unsigned int);
void *realloc(char *, unsigned int);
void free(char *);
unsigned long coreleft(void);

#endif