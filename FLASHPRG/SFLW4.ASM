*************************************************************
** FLASH-WRITE subroutine                                  **
*                                                          **
* TMS320F2XX Flash Utilities.                              **
*  Revision: 2.0,  9/10/97                                 **
*  Revision: 2.1,  1/31/98                                 **
*                                                          **
* Filename: sflw20.asm                                     **
* Changes20: Added to the flash utilities for re-covery of **
*            over-erased units.                            **
* Changes21: Increased the maximum number of pulses from   **
*            3000 to 10000, to allow recovery of units that**
*            have been severely over-erased because        **
*            operator error. Changed variable names from   **
*            B2_ to BASE_. Removed extra branch at top of  **
*            FLWS. Remove imr modification. Replaced calls **
*            to CLR_CMND subroutine with SET_MODE.         **
*                                                          **
*                                                          **
* Called by : c2xx_bfx.asm or flash application programs.  **
*                                                          **
* !!CAUTION - INITIALIZE DP BEFORE CALLING THIS ROUTINE!!  **
*                                                          **
* Function  : Performs Flash Writes on flash array 0/1 as  **
*             specified by the following vars:             **
*             SEG_ST  = Array segment start address.       **
*             PROTECT= Sector protect enable.              **
*                                                           *
* The flash-write pulse-width used is 14ms, and a maximum   *
* of 10000 pulses are applied until the device passes the   *
* depletion test.                                           *
*                                                           *
* The following resources are used for temp storage:        *
*        AR0  - Used for comparison.                        *
*        AR1  - Flash-Write Pulse Count.                    *
*        AR2  - Used for main BANZ loop.                    *
*        AR6  - Parameter passed to DELAY.                  *
*      BASE_0 - Parameter passed to SET_MODE.               *
*      BASE_1 - Used for flash address.                     *
*      BASE_2 - Used for flash data.                        *
*      BASE_3 - Used for EXE + flw cmd.                     *
*************************************************************
        .include "svar4.h" ;defines variables for flash0
                           ;or for flash1 array
*
MAX_FLW .set   10000       ;Only allow 10000 flw pulses.
INV_ER  .set    018h       ;INVERSE ERASE COMMAND WORD
FLWR    .set    6          ;FLASH WRITE COMMAND WORD
FLWR_EX .set    047h       ;FLASH WRITE EXEBIN COMMAND WORD
STOP    .set    0          ;RESET REGISTER COMMAND WORD

        .def    FLWS
        .ref    PROTECT, SEG_ST,SEG_END
	.ref	DELAY,REGS,ARRAY

       .sect "fl_wrt"
Beginfl_wrt	.set $
************************************************
* FLWS: This routine is used to check for bits *
* in depletion mode. If any are found, flash-  *
* write is used to recover.                    *
*        AR1  - Flashwrite pulse count.        *
*        AR2  - Used for main banz loop.       *
*      BASE_0 - Parameter passed to Set_mode.  *
*      BASE_1 - Used for flash address.        *
*      BASE_2 - Used for flash data.           *
************************************************

FLWS:
************************************************************
* Code initialization section				   *
* Initialize test loop counters:			   *
*   AR1 is the number of flash-write pulses.               *
************************************************************
        SETC    INTM            ;Disable maskable ints.
        LACL    SEG_ST          ;Get segment start address.
        AND     #04000h         ;Get array start address.
        SACL    FL_ST           ;Save array start address.
        SPLK    #0,ERROR        ;Reset error flag.
        LAR     AR1,#0          ;Set FLW count to 0.
        SPLK    #STOP,BASE_0    ;Flash STOP command.
        CALL    SET_MODE        ;Disable any flash commands.

INV_ERASE
        SPLK    #INV_ER,BASE_0
        CALL    SET_MODE        ;Set inverse-erase mode.
        BLDD    #FL_ST,BASE_1   ;Array start address.
        LAR     AR2,#31         ;Loop count.
        MAR     *,AR2
NEXT_IVERS
        LACL    BASE_1          ;Get address.
        TBLR    BASE_2          ;Dummy read.
        TBLR    BASE_2          ;Dummy read.
        TBLR    BASE_2          ;Read data.
        ADD     #1              ;Increment address.
        SACL    BASE_1          ;Save address.
        ZAC
        ADD     BASE_2          ;Add data.
        BCND    FL_WRITE, NEQ   ;If ACC<>0, then flwrite.

*Else continue, until until done with row.
        BANZ    NEXT_IVERS      ;Loop 32 times.
        SPLK    #STOP,BASE_0    ;Flash STOP command.
        CALL    SET_MODE        ;Disable flash commands.
                                ;If here then test passed.
DONE    RET                     ;Return to calling code.

* If here, then an error has occured.
EXIT    SPLK    #1,ERROR        ;Update error flag
        SPLK    #STOP,BASE_0    ;Flash STOP command.
        CALL    SET_MODE        ;Disable flash commands.
        CALL    ARRAY           ;ACCESS FLASH ARRAY
        B       DONE            ;Get outa here.

        .page

************************************************
* FL_WRITE: This routine performs a fl_write on*
* the flash until a maximum is reached. The    *
* array is defined by the variable FL_ST       *
* and the segment(s) is defined by the PROTECT *
* mask. The following resources are used for   *
* temporary storage:                           *
*         AR0 - Used for comparison.           *
*         AR1 - Used for pulse count (Global). *
*         AR6 - Parameter passed to DELAY.     *
*      BASE_0 - Parameter passed to SET_MODE.  *
*      BASE_2 - Used for flw cmd.              *
*      BASE_3 - Used for EXE + flw cmd.        *
************************************************
FL_WRITE
        SPLK    #STOP,BASE_0    ;Flash STOP command.
        CALL    SET_MODE        ;Disable flash commands.
        LACL    PROTECT         ;Get sector_prot mask.
        OR      #FLWR           ;Or in fl_write cmd.
        SACL    BASE_2          ;BASE_2 = fl_write cmd.
        OR      #FLWR_EX        ;Or in EXE + fl_write cmd.
        SACL    BASE_3          ;BASE_3 = EXE + fl_write cmd.

*Set the flash-write command.
        CALL    REGS            ;Access flash regs.
        LACC    FL_ST           ;ACC => SEG_CTL.
        TBLW    BASE_2          ;Initiate fl_write.
        LAR     AR6,#D10        ;Set delay.
        CALL    DELAY,*,AR6     ;Wait,10US flw stabilization time.

*Set the EXE bit (start flash-write pulse).
        TBLW    BASE_3          ;Start flw pulse.
        LAR     AR6,#D7K        ;Set delay to 7ms.
        CALL    DELAY,*,AR6     ;WAIT,7ms.
        LAR     AR6,#D7K        ;Set delay to 7ms.
        CALL    DELAY,*,AR6     ;WAIT,7ms.
*A 14mS flash write pulse has been applied.

        SPLK    #STOP,BASE_0    ;Flash STOP command.
        CALL    SET_MODE        ;Disable flash commands.
        MAR     *,AR1
        MAR     *+              ;Increment flw count.
        LAR     AR0,#MAX_FLW
        CMPR    2               ;If AR1>MAX_FLW then
        BCND    EXIT,TC         ;Fail, don't continue recovery.
        B       INV_ERASE       ;Else, perform iverase again.

*************************************************
* SET_MODE: This routine sets the flash in the  *
* mode specified by the contents of BASE_0. This*
* can be used for VER0,VER1,INVERASE,or STOP.   *
*************************************************
SET_MODE
        CALL    REGS            ;ACCESS FLASH REGS    
        LACL    FL_ST           ;ACC => SEG_CTR.
        TBLW    BASE_0          ;Activate MODE.
        LAR     AR6,#D10        ;SET DELAY                
        CALL    DELAY,*,AR6     ;WAIT                     
        CALL    ARRAY           ;ACCESS FLASH ARRAY       
	RET
*************************************************
Lenfl_wrt	.set $-Beginfl_wrt
	.def	Lenfl_wrt
	.end