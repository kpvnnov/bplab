/*****************************************************************************/
/* ERRNO.H    v7.00                                                         */
/* Copyright (c) 1996-1999 Texas Instruments Incorporated                    */
/*****************************************************************************/

#ifndef _ERRNO
#define _ERRNO

#ifdef __cplusplus
//----------------------------------------------------------------------------
// <cerrno> IS RECOMMENDED OVER <errno.h>.  <errno.h> IS PROVIDED FOR 
// COMPATIBILITY WITH C AND THIS USAGE IS DEPRECATED IN C++
//----------------------------------------------------------------------------
#include <cerrno>
using std::errno;

#else /* !__cplusplus */

extern int errno;

#define EDOM   1
#define ERANGE 2
#define ENOENT 3
#define EFPOS  5

#endif

#endif
