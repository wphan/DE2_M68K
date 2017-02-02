/* STDARG.H for CC68K */

#ifndef __STDARG_DEF_
#define __STDARG_DEF_

#define va_list           char *
#define va_argsize(x)     ((sizeof(x) + sizeof(int) - 1) & ~(sizeof(int) - 1))
#define va_start(ap, arg) ap = (va_list) &(arg) + va_argsize(arg)
#define va_arg(ap, type)  (*(type *)(((ap) += va_argsize(type)) - va_argsize(type)))
#define va_end(ap)        ap = (va_list) 0L

#endif