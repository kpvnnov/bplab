/*************************************************************************/
/* string.h  v7.00                                                       */
/* Copyright (c) 1988-1996 Texas Instruments Inc.                        */
/*************************************************************************/
#ifndef _STRING
#define _STRING

#ifndef NULL
#define NULL 0
#endif

#ifndef _SIZE_T
#define _SIZE_T
typedef unsigned size_t;
#endif

#ifdef _INLINE
#define __INLINE static inline
#else
#define __INLINE
#endif

__INLINE void  *memchr  (const void *_s,        int   _c,  size_t _n);
__INLINE int    memcmp  (const void *_s1, const void *_s2, size_t _n);
__INLINE void  *memcpy  (      void *_s1, const void *_s2, size_t _n);
         void  *memmove (      void *_s1, const void *_s2, size_t _n);
__INLINE void  *memset  (      void *_s,        int   _c,  size_t _n);

__INLINE char  *strcat  (      char *_s1, const char *_s2);
__INLINE char  *strchr  (const char *_s,        int   _c);
__INLINE int    strcmp  (const char *_s1, const char *_s2);
         int    strcoll (const char *_s1, const char *_s2);
__INLINE char  *strcpy  (      char *_s1, const char *_s2);
         size_t strcspn (const char *_s1, const char *_s2);
         char  *strerror(      int   _errno);
__INLINE size_t strlen  (const char *_s1);
         char  *strncat (      char *_s1, const char *_s2, size_t _n);
         int    strncmp (const char *_s1, const char *_s2, size_t _n);
         char  *strncpy (      char *_s1, const char *_s2, size_t _n);
         char  *strpbrk (const char *_s1, const char *_s2);
__INLINE char  *strrchr (const char *_s1,       int   _c);
         size_t strspn  (const char *_s1, const char *_s2);
         char  *strstr  (const char *_s1, const char *_s2);
         char  *strtok  (      char *_s1, const char *_s2);
         size_t strxfrm (      char *_s1, const char *_s2, size_t _n);

#ifdef _INLINE

static inline void *memchr(const void *mem, int ch, size_t length)
{
     register const unsigned char *str = (unsigned char *) mem;
     register       unsigned char  rch = ch;
     register       size_t len         = length;

     while (len-- != 0) 
        if (*str++ == rch) { --str; return((void *) str); }
   
     return (0);
}

static inline int memcmp(const void *mem1, const void *mem2, size_t length)
{
     register char *r1 = (char *) mem1;
     register char *r2 = (char *) mem2;
     register size_t rn = length;

     if (rn == 0) return(0);

     while ((rn-- != 0) && (*r1++ == *r2++));

     return (*--r1 - *--r2);
}

static inline void *memcpy(void *to, const void *from, size_t n)
{
     register char *rto   = (char *) to;
     register char *rfrom = (char *) from;
     register size_t rn;

     for (rn = 0; rn < n; rn++) *rto++ = *rfrom++;
     return (to);
}

static inline void *memset(void *mem, int ch, size_t length)
{
     register char *str = (char *) mem;
     register char  rch = ch;
     register size_t n;

     for (n = 0; n < length; n++) *str++ = rch;
   
     return (mem);
}

static inline char *strcat(char *string1, const char *string2)
{
     register       char *r1 = string1;
     register const char *r2 = string2;

     while (*r1++);                                /* FIND END OF STRING   */
     --r1;
     while (*r1++ = *r2++);                        /* APPEND SECOND STRING */
     return (string1);
}

static inline char *strchr(const char *string, int ch)
{
     register char *str = (char *) string;
     register char  rch = ch;

     do
       if (*str == rch) return str;
     while (*str++);

     return NULL;
}

static inline int strcmp(const char *string1, const char *string2)
{
     register const char *r1 = string1;
     register const char *r2 = string2;

    for(;;)
    {
      if (!*r1) return(0 - *r2);
      if (*r1++ != *r2++)
	return(*--r1 - *--r2);
    }
}

static inline char *strcpy(char *to, const char *from)
{
     register       char *rto   = to;
     register const char *rfrom = from;

     while (*rto++ = *rfrom++);
     return (to);
}

static inline size_t strlen(const char *string)
{
     register const char  *rstr = string;
     register       size_t n    = 0;

     while (*rstr++) ++n;
     return (n);
}

static inline char *strrchr(const char *string, int ch)
{
     register char *str = (char *) string;
     register char  rch = ch;
     register char *result = NULL;

     do
       if (*str == rch) result = str;
     while (*str++);

     return(result);
}

#endif /* _INLINE */

#undef __INLINE

#endif /* _STRING */
