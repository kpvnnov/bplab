/**********************************************************************/
/* Filename: ASMEXAMP.CMD                                             */
/* Description: Linker command file for 'F06 example of on-chip flash */
/*              programming from assembly. This command file links the*/
/*              example to addr 0x8000 of the onchip SARAM, so that   */
/*              the debugger can be used to set breakpoints. Another  */
/*              benefit of linking the example to SARAM is that the   */
/*              code can be modified to operate on either flash       */
/*              module0, or module1, or both.                         */
/*              Notes:                                                */
/*                1 - This example expects the 'F206 SARAM to be      */
/*                    mapped in both data space and program space     */
/*                    (DON=PON=1).                                    */
/*                2 - The object modules for the standard flash algos */
/*                    are expected to be in a subdirectory (ALGOS) of */
/*                    the path of this file.                          */
/**********************************************************************/
/* Rev1.0                                                    3/98 RDP */
/**********************************************************************/

/************************Command Line Options**************************/
-e .text
-o asmexamp.out
-m asmexamp.map

/*****************************Input Files******************************/
asmexamp.obj         /*User assembly code that calls flash algos.     */
algos\spgm20.obj     /*Standard Programming algorithm.                */
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
  .text     :{}  > PSARAM PAGE 0   /* asmexamp.asm */

    /*All these sections are for flash programming.*/
  fl_prg    : {} > PSARAM PAGE 0  /**Programming Algorithm*****/
  fl_clr    : {} > PSARAM PAGE 0  /******Clear Algorithm*******/
  fl_ers    : {} > PSARAM PAGE 0  /******Erase Algorithm*******/
  fl_wrt    : {} > PSARAM PAGE 0  /****Flash-write Algorithm***/
  DLY       : {} > PSARAM PAGE 0  /******Delay Subroutine******/
  REG       : {} > PSARAM PAGE 0  /*******Regs Subroutine******/
  ARY       : {} > PSARAM PAGE 0  /******Array Subroutine******/
  PRG_data  : {} > B1     PAGE 1  /*Reserved in asmexamp.asm **/
                                  /*for flash algo variables.**/   
  PRG_parm  : {} > B1     PAGE 1  /*Reserved in asmexamp.asm **/
                                  /*for param passing to algos*/
    /*End of sections for flash programming.       */

}
