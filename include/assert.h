/********************************************************************/
/* assert.h v7.00                                                   */
/* Copyright (c) 1992-1996 Texas Instruments Incorporated           */
/********************************************************************/
#ifndef _ASSERT
#define _ASSERT

void _nassert(int), _assert(int, char *);

#define _STR(x)  __STR(x)
#define __STR(x) #x

#if defined(NDEBUG)
#define assert(_ignore) ((void)0)

#elif defined(NASSERT)
#define assert(_expr)	_nassert(_expr)

#else
#define assert(_expr)	((_expr) ? (void)0 :                             \
          ( printf("Assertion failed, (" _STR(_expr) "), file " __FILE__ \
		   ", line " _STR(__LINE__) "\n" ),                      \
	    (void)abort()))
#endif
#endif

