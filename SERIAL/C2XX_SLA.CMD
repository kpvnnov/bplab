/*  Linker command file to specify c2xxprog sections          */
/*  and define PRG2xxw declarations                           */
/*  Locates program section in SARAM & uses part of SARAM as  */
/*  data buffer for Flash 0 array programming                 */
/*  Rev : 2.00                                                */
/*  Modified by : Sam Saba, TI Houston               9/8/96   */                                             
-e PRG_init
-o COFFA.out
-m COFFA.map
c2xx_sla.obj
spgm4.obj
sclr4.obj 
sera4.obj 
sutils4.obj
pload_4.obj
MEMORY
{
  PAGE 0 : PROG: origin = 0xff00, length = 0x100
  PAGE 0 : SPROG: origin = 0x8000, length = 0x1000/* 1kx16 for algorithm*/
 
  PAGE 1 : VARS: origin = 0x0300, length = 0x10
  PAGE 1 : DATA: origin = 0x0320, length = 0xd0
  PAGE 1 : SDATA: origin = 0xc00, length = 0xc00 /* 3Kx16 up to 0x1800 */
  PAGE 1 : DSPAD1: origin = 0x310, length = 0x10

}


SECTIONS
{
boot_sec
{
  *(PRG_text)
  *(fl_prg)
  *(fl_clr)
  *(fl_ers)   
  *(DLY)       
  *(REG)       
  *(ARY)
  *(uartld)
  *(PRG_parm)
  *(ary_var)

} load SPROG PAGE 0

}
