/********************************************************************/
/* stdarg.h v7.00                                                   */
/* Copyright (c) 1988-1996 Texas Instruments Inc.                   */
/********************************************************************/

#ifndef _STDARG
#define _STDARG

typedef char *va_list;

#define va_start(ap, parmN) (ap = (char *)&parmN)
#define va_end(ap)
#define va_arg(ap, type)  ((ap -= (sizeof(type) > sizeof(int))  \
				?  sizeof(type) : sizeof(int)), \
				 (*(type *)(ap)))

#endif /* ifndef _STDARG */
