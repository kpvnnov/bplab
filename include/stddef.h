/********************************************************************/
/* stddef.h v7.00                                                   */
/* Copyright (c) 1988-1996 Texas Instruments Inc.                   */
/********************************************************************/
#ifndef _STDDEF
#define _STDDEF

#ifndef NULL
#define NULL 0
#endif

typedef int ptrdiff_t;

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned size_t;
#endif

#ifndef _WCHAR_T
#define _WCHAR_T
typedef char wchar_t;
#endif

#define offsetof(type, ident) ((size_t)(&((type *)0)->ident))

#endif
