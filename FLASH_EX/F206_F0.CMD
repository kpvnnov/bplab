/**********************************************************************/
/* Filename: F206_F0.CMD                                              */
/* Description: Linker command file for 'F06 example of on-chip flash */
/*              programming from C-code. This command file links the  */
/*              example to addr 0x0 of the onchip flash, so that it   */
/*              can be programmed into module0. That is, the COFF file*/
/*              produced when <F206_F0.CMD> is linked, can be program */
/*              med (using the XDS510) into the 'F206 flash module0.  */
/*              This provides a permanent, "standalone" example of    */
/*              on-chip flash re-programming.                         */
/*              Notes:                                                */
/*                1 - This example expects the 'F206 SARAM to be      */
/*                    mapped in data space (DON=1).                   */
/*                2 - The object modules for the standard flash algos */
/*                    are expected to be in a subdirectory (ALGOS) of */
/*                    the path of this file.                          */
/**********************************************************************/
/* Rev1.0                                                   10/97 RDP */
/**********************************************************************/


/************************Command Line Options**************************/
-c                   /*Use Rom init model.                            */
-heap 0x0            /*No heap needed for this example.               */
-stack 0x96          /*150 word stack is enough for this example.     */
-x                   /*Force re-reading of libraries.                 */
-l c:\dsptools\rts2xx.lib
-o sample_f.out
-m sample_f.map

/*****************************Input Files******************************/
sample.obj           /*User C-code with calls to erase() and program()*/
flash.obj            /*C-callable interface to standard algorithms.   */
algos\spgm20.obj     /*Standard Programming algorithms.               */
algos\sclr20.obj     /*Standard Clear algorithm.                      */
algos\sera20.obj     /*Standard Erase algorithm.                      */
algos\sflw20.obj     /*Standard Flash-write algorithm.                */
algos\sutils20.obj   /*Subroutines used by standard algorithms.       */

/*****************************Memory Map*******************************/
MEMORY
{
PAGE 0: /* PM - Program memory  */

  FLASH0: origin = 0x0000, length = 0x3fff
  FLASH1: origin = 0x4000, length = 0x3fff
  PSARAM: origin = 0x8000, length = 0x400  /*Use 1K of SARAM for PROGRAM*/
  B0:     origin = 0xff00, length = 0x1ff

PAGE 1: /* DM - Data memory    */

  BLK_B2: origin = 0x60,   length = 0x20   /* BLOCK B2  */
  DSARAM: origin = 0xc00 , length = 0xC00  /* Use 3K of SARAM for data DON=1 */
  EX1_DM: origin = 0x4000, length = 0x4000 /* External data RAM */
  B1:     origin = 0x300,  length = 0x1ff  /* B1 Ram (Used for algo vars )*/
}

/*************************Section Allocation***************************/
SECTIONS
{
  .text     :{}  > FLASH0 PAGE 0   /* sample.c */

    /*All these sections are for flash programming.*/
  PRG_text  : {} > FLASH0 PAGE 0  /**erase() and program()*****/
                                  /*****from flash.asm file****/
  fl_prg    : {} > FLASH0 PAGE 0  /**Programming Algorithm*****/
  fl_clr    : {} > FLASH0 PAGE 0  /******Clear Algorithm*******/
  fl_ers    : {} > FLASH0 PAGE 0  /******Erase Algorithm*******/
  fl_wrt    : {} > FLASH0 PAGE 0  /****Flash-write Algorithm***/
  DLY       : {} > FLASH0 PAGE 0  /******Delay Subroutine******/
  REG       : {} > FLASH0 PAGE 0  /*******Regs Subroutine******/
  ARY       : {} > FLASH0 PAGE 0  /******Array Subroutine******/
  PRG_data  : {} > B1     PAGE 1  /*Reserved in flash.asm for**/
                                  /***flash algo variables.****/   
  PRG_parm  : {} > B1     PAGE 1  /*Reserved in flash.asm for**/
                                  /*parameter passing to algos*/
    /*End of sections for flash programming.       */

  .bss      :{}  > B1 PAGE 1
  .cinit    :{}  > B1 PAGE 1
  .const    :{}  > B1 PAGE 1
  .data     :{}  > B1 PAGE 1
  .stack    :{}  > B1 PAGE 1      /*C-stack.                  */


}
