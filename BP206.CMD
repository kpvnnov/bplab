/***************************************************************************/
/*                  Измерение арториального давления        14.03.97 12:22 */
/* $Id: BP206.CMD,v 1.9 2000-12-13 13:43:24 peter Exp $ */
/***************************************************************************/
/* */
-m Bp206.map
-o Bp206.out
/* Bp206.obj */
flashprg\sclr4.obj
flashprg\sera4.obj
flashprg\sflw4.obj
flashprg\spgm4.obj
flashprg\sutils4.obj

MEMORY
{
 PAGE 0: CODE(RX):    org = 0h     , len = 4000h /*Program Memory*/

/*  PAGE 0 : PROG: origin = 0xff00, length = 0x100 */
  PAGE 0 : SPROG: origin = 0x8000, length = 0x400/* 1kx16 for algorithm*/

 PAGE 1: B2(RW):      org = 60h    , len = 20h   /*Data Memory*/
	 B3(RW):      org = 200h   , len = 080h
	 B31(RW):     org = 280h   , len = 080h
/*	 B1(RW):      org = 300h   , len = 080h */
/*	 B11(RW):     org = 380h   , len = 080h */
/*	 B4(RW):      org = 800h   , len = 1000h */
	 B5(RW):      org = 8000h  , len = 8000h
/*	 B6(RW):      org = 1000h  , len = 2000h */


/*  PAGE 1 : VARS: origin = 0x0300, length = 0x10 */
/*  PAGE 1 : DATA: origin = 0x0320, length = 0xd0 */
  PAGE 1 : SDATA: origin = 0xc00, length = 0xc00  /* 3Kx16 up to 0x1800 */
  PAGE 1 : SPROG: origin = 0x800, length = 0x400  /* 1Kx16 up to 0x0c00 */
/*  PAGE 1 : PARMS: origin = 0x310, length = 0x10 */


}
SECTIONS
{
  .text:   {} > CODE, PAGE 0   /*Program Memory*/
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

/*  .data:   {} > TABL, PAGE 0 */
/*  asp	   {} > CODEASP,PAGE 0 program memory Asp routine*/
/*  .bss:    {} > B1    PAGE 1  Data Memory*/
  flash:    	load > B5    	PAGE 1  /*Data Memory*/
  bss2:         load > B3    	PAGE 1  /*Data Memory*/
  bss1:         load > B3    	PAGE 1  /*Data Memory*/
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


/*  PRG_parm  : load > DSPAD1 PAGE 1
  PRG_data  : load > DATA PAGE 1    */
/*  ary_var   : load > 0x300 PAGE 1 */



}
