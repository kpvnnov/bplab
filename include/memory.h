/****************************************************************************/
/*  memory.h v7.00                                                          */
/*  Copyright (c) 1988-1996 Texas Instruments Inc.                          */
/****************************************************************************/

/*****************************************************************************/
/*                                                                           */
/*  This file contains the definitions for the functions which implement the */
/*  dynamic memory management routines for DSP C.  The following assumptions */
/*  apply:                                                                   */
/*                                                                           */
/*   1) Packets are allocated a minimum of one word, max 32k words.          */
/*   2) The heap can be reset at any time by calling the function "minit"    */
/*                                                                           */
/*                                                                           */
/*****************************************************************************/
#undef _INLINE				/* DISABLE INLINE EXPANSION          */
#include <stdlib.h>
#include <string.h>

/*****************************************************************************/
/* The memory pool                                                           */
/*****************************************************************************/
extern int _sys_memory[];

/*****************************************************************************/
/* __SYSMEM_SIZE is symbol that the linker defines as the size of the heap.  */
/* Access of that value from 'C' is done by taking the address of this symbol*/
/*****************************************************************************/
extern int _SYSMEM_SIZE;
#define MEMORY_SIZE ((unsigned)&_SYSMEM_SIZE)

/*****************************************************************************/
/* "PACKET" is the template for a data packet.  Packet size contains         */
/* the number of words allocated for the user, excluding the size            */
/* required for management of the packet (16 bits).  Packets are always      */
/* allocated memory in words.  A negative size indicates a free packet.      */
/*****************************************************************************/
typedef struct pack {
                     int packet_size;         /* in words */
                     struct pack  *size_ptr;
                    }
                     PACKET;

/*****************************************************************************/
/* Helper functions                                                          */
/*****************************************************************************/
void _minsert(PACKET *ptr);
void _mremove(PACKET *ptr);
