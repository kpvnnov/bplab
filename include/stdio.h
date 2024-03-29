/*****************************************************************************/
/* STDIO.H v7.00                                                            */
/* Copyright (c) 1993-1999 Texas Instruments Incorporated                    */
/*****************************************************************************/
#ifndef _STDIO 
#define _STDIO

/****************************************************************************/
/* TYPES THAT ANSI REQUIRES TO BE DEFINED                                   */
/****************************************************************************/
#ifndef _SIZE_T                                                    
#define _SIZE_T                                                    
typedef unsigned size_t;                                           
#endif

typedef struct {
         int fd;                    /* File descriptor */
         unsigned char* buf;        /* Pointer to start of buffer */
         unsigned char* pos;        /* Position in buffer */
         unsigned char* bufend;     /* Pointer to end of buffer */
         unsigned char* buff_stop;  /* Pointer to last read char in buffer */
         unsigned int   flags;      /* File status flags (see below) */
         int index;                 /* Location in ftable */
} FILE;

#ifndef _FPOS_T
#define _FPOS_T

#ifdef _TMS320C6x
typedef int fpos_t;
#else
typedef long fpos_t;
#endif

#endif

/****************************************************************************/
/* MACROS THAT DEFINE AND USE FILE STATUS FLAGS                             */
/****************************************************************************/
#define _IOFBF       0x0001
#define _IOLBF       0x0002
#define _IONBF       0x0004
#define _BUFFALOC    0x0008
#define _MODER       0x0010
#define _MODEW       0x0020
#define _MODERW      0x0040
#define _MODEA       0x0080
#define _MODEBIN     0x0100
#define _STATEOF     0x0200
#define _STATERR     0x0400
#define _UNGETC      0x0800
#define _TMPFILE     0x1000

#define _SET(_fp, _b)      (((_fp)->flags) |= (_b))
#define _UNSET(_fp, _b)    (((_fp)->flags) &= ~(_b))
#define _STCHK(_fp, _b)    (((_fp)->flags) & (_b))
#define _BUFFMODE(_fp)     (((_fp)->flags) & (_IOFBF | _IOLBF | _IONBF))
#define _ACCMODE(_fp)      (((_fp)->flags) & (_MODER | _MODEW))

/****************************************************************************/
/* MACROS THAT ANSI REQUIRES TO BE DEFINED                                  */
/****************************************************************************/
#define BUFSIZ          256 
#define FOPEN_MAX       12
#define FILENAME_MAX    256  
#define TMP_MAX         65535

#define SEEK_SET  (0x0000)
#define SEEK_CUR  (0x0001)
#define SEEK_END  (0x0002)

#ifndef NULL
#define NULL (void *) 0
#endif

#ifndef EOF
#define EOF    (-1)
#endif

#define stdin     (&_ftable[0])      
#define stdout    (&_ftable[1])
#define stderr    (&_ftable[2])

#define L_tmpnam  (sizeof(P_tmpdir) + 15)

/******** END OF ANSI MACROS ************************************************/

#define P_tmpdir        ""                   /* Path for temp files         */

/****************************************************************************/
/* DEVICE AND STREAM RELATED DATA STRUCTURES AND MACROS                     */
/****************************************************************************/
/*- If you modify these values, be sure to also modify the ftable[] to     -*/
/*- correctly initialize the entries.  This is necessary since we do no    -*/
/*- clear bss by default!                                                  -*/
/****************************************************************************/
#define _NFILE          20                   /* Max number of files open    */
#define _NSTREAM        20                   /* Size of stream table        */
#define _NDEVICE        3                    /* Size of device table        */

#define _SSA      (0x0000)             /* Single Stream allowed       */
#define _BUSY     (0x0001)             /* Device busy                 */
#define _MSA      (0x0002)             /* Multiple Streams Allowed    */

#define stdevice        (&_device[0])        /* Default device (host)       */

typedef struct {                             
   char  name[9];
   unsigned short flags;
   int    (*OPEN) ();
   int    (*CLOSE) ();
   int    (*READ) ();
   int    (*WRITE) ();
   fpos_t (*LSEEK) ();
   int    (*UNLINK) ();
   int    (*RENAME) ();
} _DEVICE;

extern FILE _ftable[_NFILE];
extern char _tmpnams[_NFILE][L_tmpnam];

/****************************************************************************/
/*   FUNCTION DEFINITIONS  - ANSI                                           */
/****************************************************************************/
/****************************************************************************/
/* OPERATIONS ON FILES                                                      */
/****************************************************************************/
       int     remove(const char *_file);
extern int     rename(const char *_old, const char *_new);
extern FILE   *tmpfile(void);
extern char   *tmpnam(char *_s);

/****************************************************************************/
/* FILE ACCESS FUNCTIONS                                                    */
/****************************************************************************/
extern int    fclose(FILE *_fp); 
extern FILE   *fopen(const char *_fname, const char *_mode);
extern FILE   *freopen(const char *_fname, const char *_mode,
               register FILE *_fp);
extern void    setbuf(register FILE *_fp, char *_buf);
extern int     setvbuf(register FILE *_fp, register char *_buf, 
                       register int _type,  register size_t _size); 
extern int     fflush(register FILE *_fp); 

/****************************************************************************/
/* FORMATTED INPUT/OUTPUT FUNCTIONS                                         */
/****************************************************************************/
extern int     fprintf(FILE *_fp, const char *_format, ...);
extern int     fscanf(FILE *_fp, const char *_fmt, ...);
extern int     printf(const char *_format, ...);
extern int     scanf(const char *_fmt, ...);
extern int     sprintf(char *_string, const char *_format, ...);
extern int     sscanf(const char *_str, const char *_fmt, ...);
extern int     vfprintf(FILE *_fp, const char *_format, char *_ap);
extern int     vprintf(const char *_format, char *_ap);
extern int     vsprintf(char *_string, const char *_format, char *_ap);

/****************************************************************************/
/* CHARACTER INPUT/OUTPUT FUNCTIONS                                         */
/****************************************************************************/
extern int     fgetc(register FILE *_fp);
extern char   *fgets(char *_ptr, register int _size, register FILE *_fp);
extern int     fputc(int _c, register FILE *_fp);
extern int     fputs(const char *_ptr, register FILE *_fp);
extern int     getc(FILE *_p);
       int     getchar(void);
extern char   *gets(char *_ptr); 
extern int     putc(int _x, FILE *_fp);
       int     putchar(int _x);
extern int     puts(const char *_ptr); 
extern int     ungetc(int _c, register FILE *_fp);

/****************************************************************************/
/* DIRECT INPUT/OUTPUT FUNCTIONS                                            */
/****************************************************************************/
extern size_t    fread(void *_ptr, size_t _size, size_t _count, FILE *_fp);
extern size_t    fwrite(const void *_ptr, size_t _size, size_t _count,
                        register FILE *_fp); 

/****************************************************************************/
/* FILE POSITIONING FUNCTIONS                                               */
/****************************************************************************/
extern int       fgetpos(FILE *_fp, fpos_t *_pos);
extern int       fseek(register FILE *_fp, long _offset, int _ptrname);
extern int       fsetpos(FILE *_fp, const fpos_t *_pos);
extern long  ftell(FILE *_fp);
extern void  rewind(register FILE *_fp); 

/****************************************************************************/
/* ERROR-HANDLING FUNCTIONS                                                 */
/****************************************************************************/
       void      clearerr(FILE *_fp);
extern int       feof(FILE *_fp);
       int       ferror(FILE *_fp);
extern void      perror(const char *_s);
                

#define _getchar()      getc(stdin)
#define _putchar(_x)    putc((_x), stdout)
#define _clearerr(_fp)   ((void) ((_fp)->flags &= ~(_STATERR | _STATEOF)))

#define _ferror(_x)     ((_x)->flags & _STATERR)

#define _remove(_fl)    (unlink((_fl)))

/******* END OF ANSI FUNCTIONS  *********************************************/


/****************************************************************************/
/* GETENV IS SUPPOSED TO BE IN STDLIB.H IN THE RTS.LIB, BUT BECAUSE STDIO.H */
/* IS THE ONLY HEADER FILE THAT USES ROUTINES TO INTERFACE WITH THE HOST    */
/* OPERATING SYSTEM, GETENV WAS PLACED HERE.                                */
/****************************************************************************/
char            *getenv(const char *_string);

/****************************************************************************/
/* LOW LEVEL FUNCTION PROTOTYPES                                            */
/****************************************************************************/
extern int       add_device(char           *name,
                            unsigned        flags,
                  int            (*dopen)(),
                  int            (*dclose)(),
                  int            (*dread)(),
                  int            (*dwrite)(),
                  fpos_t         (*dlseek)(),
                  int            (*dunlink)(),
                  int            (*drename)());
#endif
