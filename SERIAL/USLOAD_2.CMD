/*  Linker command file for serial Loader rev 2.0	      */	
/*  For TMX320F206 DSP devices, Texas Instruments             */
/*  Rev : 2.0                                                 */
/*  Written by : Sam Saba, TI Houston              9/8/97     */

                                             
-o usload_2.out
-m usload_2.map
usload_2.obj
MEMORY
{
  PAGE 0 : PROG: origin = 0x0000, length = 0x00ff
  PAGE 0 : SPROG: origin = 0x8000, length = 0x400/* 1kx16 for algorithm*/

  PAGE 1 : VARS: origin = 0x0300, length = 0x10
  PAGE 1 : DATA: origin = 0x0320, length = 0xd0
  PAGE 1 : SDATA: origin = 0xc00, length = 0xc00 /* 3Kx16 up to 0x1800 */
  PAGE 1 : DSPAD1: origin = 0x310, length = 0x10

}


SECTIONS
{
   .text > 0x0000   PAGE0
}
