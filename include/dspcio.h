/*****************************************************************************/
/*  TRGCIO.H v7.00                                                          */
/*  Copyright (c) 1996-1999 Texas Instruments Incorporated                   */
/*****************************************************************************/

/****************************************************************************/
/*  This file contains OTIS-driven CIO constant definitions                 */
/****************************************************************************/

/*---------------------------------------------------------------------------*/
/* constants for the data transfer functions for the predefined driver       */
/*---------------------------------------------------------------------------*/
#define _DTOPEN    (0xF0)
#define _DTCLOSE   (0xF1)
#define _DTREAD    (0xF2)
#define _DTWRITE   (0xF3)
#define _DTLSEEK   (0xF4)
#define _DTUNLINK  (0xF5)
#define _DTGETENV  (0xF6)
#define _DTRENAME  (0xF7)
#define _DTGETTIME (0xF8)
#define _DTGETCLK  (0xF9)
#define _DTSYNC    (0xFF)

#define CIOBUFSIZ BUFSIZ+32

/*---------------------------------------------------------------------------*/
/* THESE MACROS PACK AND UNPACK SHORTS AND LONGS INTO CHARACTER ARRAYS       */
/*                                                                           */
/* THIS IS DONE BYTE REVERSED TO MAKE THE PC'S JOB EASIER AND SINCE THE      */
/*     DEVICE COULD BE BIG OR LITTLE ENDIAN                                  */
/*---------------------------------------------------------------------------*/
#define LOADSHORT(x,y,z)  { x[(z)]   = (unsigned short) (y); \
                            x[(z)+1] = (unsigned short) (y) >> 8;  }

#define UNLOADSHORT(x,z)   ((short) ( (((long) x[(z)]   << 16) + \
			               ((long) x[(z)+1] << 24)) >> 16))

#define LOADLONG(x,y,z) { x[(z)]   = (unsigned long) (y); \
                          x[(z)+1] = (unsigned long) (y) >> 8; \
                          x[(z)+2] = (unsigned long) (y) >> 16;  \
                          x[(z)+3] = (unsigned long) (y) >> 24;   }

#define UNLOADLONG(x,z) ( (long) x[(z)]           +  \
                         ((long) x[(z)+1] << 8)   +  \
                         ((long) x[(z)+2] << 16)  +  \
			 ((long) x[(z)+3] << 24))

/*---------------------------------------------------------------------------*/
/* THESE MACROS CAN BE USED TO PACK AND UNPACK CHARACTER STREAMS INTO TARGET */
/* WORDS FOR MORE EFFICIENT TRANSFER.                                        */
/*---------------------------------------------------------------------------*/
#define PACKCHAR(val, base, byte) ( ((byte)%2 == 0) ?  \
	 (*((base) + ((byte)/2))  = ((val) & 0xFF)) : \
	 (*((base) + ((byte)/2)) |= ((val) & 0xFF) << (((byte)%2) * 8)) )

#define UNPACKCHAR(base, byte) \
         ( (*((base) + ((byte)/2)) >> (((byte)%2) * 8)) & 0xFF )


