/***************************************************************************/
/*                  Измерение арториального давления        14.03.97 12:22 */
/* $Id: BP_MODUL.CMD,v 1.2 2000-12-13 13:43:27 peter Exp $ */
/***************************************************************************/
/* */
bp_modul.obj
/* -m bp_modul.map */
-o bp_modul.out

MEMORY
{
 PAGE 0: CODE(RX):    org = 0h     , len = 2000h /*Program Memory*/
/*	 CODEASP(RX): org = 4000h  , len = 400h */
/*         TABL(R):     org = 2000h  , len = 1000h */
/*         B0(RW):      org = 0ff00h , len = 100h  */

 PAGE 1: B2(RW):      org = 60h    , len = 20h   /*Data Memory*/
         B0(RW):      org = 200h   , len = 100h
	 B1(RW):      org = 300h   , len = 100h
         B3(RW):      org = 1000h  , len = 2000h
         B4(RW):      org = 8000h  , len = 8000h
}
SECTIONS
{
  .text:           {} > CODE, PAGE 0   /*Program Memory*/
/*  .data:           {} > TABL, PAGE 0 */
  .bss:            {} > B0    PAGE 1  /*Data Memory*/
  SigArray:        {} > B3    PAGE 1  /*Data Memory*/
  MNArray:         {} > B1    PAGE 1  /*Data Memory*/
/*  flash:           {} > B5    PAGE 1  /*Data Memory*/
}
