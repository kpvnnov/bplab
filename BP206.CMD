/***************************************************************************/
/*                  Измерение арториального давления        14.03.97 12:22 */
/* $Id: BP206.CMD,v 1.11 2001-10-22 13:38:11 peter Exp $ */
/***************************************************************************/
/* */
/* -m Bp206.map */
/* -o Bp206.out */
flashprg\sclr4.obj
flashprg\sera4.obj
flashprg\sflw4.obj
flashprg\spgm4.obj
flashprg\sutils4.obj
BP206VEC.obj
MEMORY
{
 PAGE 0: VECS:        origin = 00000h, length = 00028h /* таблица векторов */
         SIGNAT:      origin = 00028h, length = 000e8h /* сигнатура */
 	 CODE(RX):    org =    00110h, len    = 04000h  /*Program Memory*/

/*  PAGE 0 : PROG: origin = 0xff00, length = 0x100 */
  PAGE 0 : SPROG: origin = 0x8000, length = 0x500/* 1kx16 for algorithm*/

 PAGE 1: B2(RW):      org = 60h    , len = 20h   /*Data Memory*/
         B00(RW):     org = 200h   , len = 080h
         B01(RW):     org = 280h   , len = 080h
         B10(RW):     org = 300h   , len = 080h
         B11(RW):     org = 380h   , len = 080h


/*         B3(RW):      org = 200h   , len = 080h */
/*	 B31(RW):     org = 280h   , len = 080h */
	 B5(RW):      org = 8000h  , len = 8000h


  PAGE 1 : SDATA: origin = 0xc00, length = 0xc00  /* 3Kx16 up to 0x1800 */
  PAGE 1 : SPROG: origin = 0x800, length = 0x400  /* 1Kx16 up to 0x0c00 */


}
SECTIONS
{
  vectors  :     { } > VECS  	PAGE 0
  signat   :     { } > SIGNAT   PAGE 0

  /* данные секции должны быть в ТАКОМ порядке */
  /* секции предназначены для программирования */
  /* по последовательному порту */
  PrgAlgor  : load > CODE PAGE 0 , run > SPROG PAGE 0
  fl_clr    : load > CODE PAGE 0 , run > SPROG PAGE 0
  fl_ers    : load > CODE PAGE 0 , run > SPROG PAGE 0
  fl_wrt    : load > CODE PAGE 0 , run > SPROG PAGE 0
  fl_prg    : load > CODE PAGE 0 , run > SPROG PAGE 0
  DLY       : load > CODE PAGE 0 , run > SPROG PAGE 0
  REG       : load > CODE PAGE 0 , run > SPROG PAGE 0
  ARY       : load > CODE PAGE 0 , run > SPROG PAGE 0

  .text:   {} > CODE, PAGE 0   /*Program Memory*/

  flash:    	load > B5    	PAGE 1  /*Data Memory*/
  bss2:         load > B00    	PAGE 1  /*Data Memory*/
  bss1:         load > B00    	PAGE 1  /*Data Memory*/
  _Stack:       load > B2      	PAGE 1  /*Data Memory*/
  MNArray:      load > SDATA   	PAGE 1  /*Data Memory*/
  MNArray0:     load > SDATA   	PAGE 1  /*Data Memory*/
  SigArray:     load > SDATA 	PAGE 1  /*Data Memory*/
  StepNum:      load > SDATA 	PAGE 1  /*Data Memory*/
  watch:	load > SDATA 	PAGE 1  /*Data Memory*/
  serial:       load > SDATA 	PAGE 1  /*Data Memory*/
  adcrez:       load > SDATA 	PAGE 1  /*Data Memory*/
  clock:        load > SDATA 	PAGE 1  /*Data Memory*/
  displ:        load > SDATA 	PAGE 1  /*Data Memory*/
  keyb:         load > SDATA 	PAGE 1  /*Data Memory*/
  error:        load > SDATA 	PAGE 1  /*Data Memory*/
  flbuf:        load > SDATA 	PAGE 1  /*Data Memory*/
  bss3:         load > SDATA   	PAGE 1  /*Data Memory*/





}
