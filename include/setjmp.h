/****************************************************************************/
/*  setjmp.h v7.00                                                          */
/*  Copyright (c) 1990-1996 Texas Instruments Incorporated                  */
/****************************************************************************/
#ifndef _SETJMP
#define _SETJMP

typedef int jmp_buf[5];

#define setjmp(_x) _setjmp(_x)
void longjmp(jmp_buf _env, int _returnval); 

#endif
