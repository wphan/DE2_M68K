/* ASSERT.H for CC68K */

#ifndef __ASSERT_DEF_
#define __ASSERT_DEF_

#ifndef NDEBUG
#define assert(expr)\
    if (!(expr)) {\
        printf("\nAssertion failed: %s, file %s, line %d\n", #expr, __FILE__, __LINE__);\
        exit(1);\
    }
#else
#define assert(expr)
#endif

#endif
