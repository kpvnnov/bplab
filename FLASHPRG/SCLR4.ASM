*************************************************************
** CLEAR  Subroutine                                       **
*                                                          **
* TMS320F2XX Flash Utilities.                              **
*  Revision: 2.0,  9/10/97                                 **
*  Revision: 2.1,  1/31/98                                 **
*                                                          **
* Filename: sclr20.asm                                     **
* Changes20: Re-written to include latest flash algorithms.**
* Changes21: Cleaned up source for release to mass market. **
*            Initialize error flag to 0 (no error). Removed**
*            redundant call/ret to clear routine. Changed  **
*            variable names from B2_ to BASE_ since they're**
*            not necessarily stored in B2 RAM. Removed imr **
*            modifications. Created PRG_BYTE subroutine for**
*            use on both high and low bytes. Added more    **
*            comments.                                     **
*                                                          **
*                                                          **
* Called by : c2xx_bcx.asm or flash application programs.  **
*                                                          **
* !!CAUTION - INITIALIZE DP BEFORE CALLING THIS ROUTINE!!  **
*                                                          **
* Function  : Clears one or more contiguous segments of    **
*             flash array 0/1 as specified by the fol      **
*             -lowing variables.                           **
*             SEG_ST = Segment start address.              **
*             SEG_END= Segment end address.                **
*             PROTECT= Sector protect enable.              **
*                                                           *
* The algorithm used is "row-horizontal" which means that   *
* an entire flash row (32 words) are programed in parallel. *
* This method provides better uniformity of programming     *
* levels between adjacent bits then if each address were    *
* programed independently. The algorithm also uses a 3-read *
* check for VER0 margin (i.e. The flash location is read    *
* three times and the first two values are discarded.) This *
* provides low-freq read-back margin on programed bits. For *
* example, if the flash is programmed using a CLKOUT period *
* of 50ns, the flash can be reliably readback over the      *
* CLKOUT period range of 50ns to 150ns (6.67Mhz-20Mhz).     *
* The programming pulse-width is 100us, and a maximum of    *
* 150 pulses are applied per row.                           *
*                                                           *
* The following resources are used for temporary storage:   *
*        AR0  - Used for comparisons.                       *
*        AR2  - Used for pgm pulse count.                   *
*        AR3  - Used for row banz loop.                     *
*        AR7  - Parameter passed to Delay.                  *
*    FL_ADRS  - Used for flash address.                     *
*    FL_DATA  - Used for flash data.                        *
*      FL_ST  - Used for flash start address.               *
*     BASE_0  - Used for row-done flag.                     *
*     BASE_1  - Used for row start address.                 *
*      SPAD1  - Flash commands.                             *
*      SPAD2  - Flash commands.                             *
*                                                          **
*************************************************************
        .include "svar4.h"
*
MAX_PGM .set    150             ;Only allow 150 pulses per row.
VER0    .set    010h            ;VER0 command.
WR_CMND .set    4               ;Write command.
WR_EXE  .set    045h            ;Write EXEBIN command.
STOP    .set    0               ;Reset command.

        .def    GCLR
        .ref    PROTECT,SEG_ST,SEG_END
	.ref	DELAY,REGS,ARRAY

       .sect "fl_clr"
Beginfl_clr	.set $
************************************************
* GCLR:    This routine performs a clear opera *
* -tion on the flash array defined by the FL_ST*
* variable. The segments to be cleared are     *
* defined by the SEG_ST, SEG_END, and PROTECT  *
* variables.                                   *
* The following resources are used for temp    *
* storage:                                     *
*        AR0  - Used for comparisons.          *
*        AR2  - Used for pgm pulse count.      *
*        AR3  - Used for row banz loop.        *
*    FL_ADRS  - Used for flash address.        *
*    FL_DATA  - Used for flash data.           *
*      BASE_0 - Used for row-done flag.        *
*      BASE_1 - Used for row start address.    *
*      BASE_2 - Used for byte mask.            *
************************************************
GCLR:
        SETC    INTM            ;Disable all ints.
        CLRC    SXM             ;Disable sign extension.
        SPLK    #0,ERROR        ;Reset error flag
        LACL    SEG_ST          ;Get segment start address.
        SACL    FL_ADRS         ;Save as current address.
        AND     #04000h         ;Get array start address.
        SACL    FL_ST           ;Save array start address.
        LACL    FL_ADRS         ;Get segment start address.

NEWROW          ;********Begin a new row.*
        SACL    BASE_1          ;Save row start address.
        LAR     AR2,#0          ;Init pulse count to zero.

SAMEROW         ;********Same row, next pulse.*
        SPLK    #1,BASE_0       ;Set row done flag = 1(True).
        LACL    BASE_1          ;Get row start address.
        SACL    FL_ADRS         ;Save as current address.
        LAR     AR3,#31         ;Init row index.

********Repeat the following code 32 times until end of row.*
LOBYTE          ;********First do low-byte.*
        SPLK    #0FFh,BASE_2    ;Get lo-byte mask.
        CALL    PRG_BYTE        ;Check/Program lo-byte
        SPLK    #0FF00h,BASE_2  ;Get hi-byte mask.
        CALL    PRG_BYTE        ;Check/Program hi-byte.

NEXTWORD        ;********Next word in row.
        LACL    FL_ADRS         ;Load address for next word.
        ADD     #1              ;Increment address.
        SACL    FL_ADRS         ;Save as current address.
        MAR     *, AR3          ;Point to row index.
        BANZ    LOBYTE          ;Do next word,and dec AR3.

********Reached end of row. Check if row done. *
        BIT     BASE_0,15       ;Get row_done flag.
        BCND    ROW_DONE,TC     ;If 1 then row is done.
        MAR     *,AR2           ;Else, row is not done, so
        MAR     *+              ;inc row pulse count.
        LAR     AR0,#MAX_PGM    ;Check if passed allowable max.
        CMPR    2               ;If AR2>MAX_PGM then
        BCND    EXIT,TC         ;fail, don't continue.
        B       SAMEROW         ;else, go to beginning
                                ;of same row.

********If row done then check if Array done. *
ROW_DONE                        ;Check if end of array.
        SUB     SEG_END         ;Subtract segment end address.
        BCND    DONE, GEQ       ;If >0 then done.

********Else, goto next row. *
        LACL    FL_ADRS         ;Get current address.
        B       NEWROW          ;Start new row.

********If here then done.
DONE    CALL    ARRAY           ;Access flash in array mode.
        RET

********If here then unit failed to program. *
EXIT    SPLK    #1,ERROR        ;Update error flag.
        B       DONE            ;Get outa here.

	.page
************************************************************
* THIS SECTION PROGRAMS THE VALUE STORED IN FL_DATA INTO   *
* THE FLASH ADDRESS DEFINED BY FL_ADRS.                    *
*							   *
* The following resources are used for temporary storage:  *
*        AR7  - Parameter passed to Delay.                 *
*        SPAD1 - Flash program and STOP commands.          *
*        SPAD2 - Flash program + EXE command.              *
************************************************************
EXE_PGM                                                   ;*
	CALL	ARRAY		;ACCESS ARRAY		   *
* LOAD WADRS AND WDATA					  **
        LACL    FL_ADRS         ;ACC => PROGRAM ADRS       *
        TBLW    FL_DATA         ;LOAD WADRS AND WDATA      *
	CALL	REGS		;ACCESS FLASH REGS	   *
* SET-UP WRITE COMMAND WORDS				  **
        LACL    PROTECT         ;GET SEGMENT PROTECT MASK **
        OR      #WR_CMND        ;OR IN WRITE COMMAND      **
        SACL    SPAD1           ;SPAD1 = WRITE COMMAND    **
        OR      #WR_EXE         ;OR IN EXEBIN COMMAND     **
        SACL    SPAD2           ;SPAD2 = WRITE EXE COMMAND**
*							   *
        LACL    FL_ST           ;ACC => 0 (FLASH0)         *
* ACTIVATE WRITE BIT					  **
        TBLW    SPAD1           ;EXECUTE COMMAND          **
        LAR     AR7,#D10        ;SET DELAY                **
	CALL	DELAY,*,AR7	;WAIT			  **
* SET EXEBIN BIT					 ***
        TBLW    SPAD2           ;EXECUTE COMMAND         ***
        LAR     AR7,#D100       ;SET DELAY               ***
	CALL	DELAY,*,AR7	;WAIT			 ***
* STOP WRITE OPERATION					   *
        SPLK    #0,SPAD1        ;SHUTDONW WRITE OPERATION  *
        TBLW    SPAD1           ;EXECUTE COMMAND           *
        LAR     AR7,#D10        ;SET DELAY                 *
	CALL	DELAY,*,AR7	;WAIT			   *
*							   *
        RET                     ;RETURN TO CALLING SEQUENCE*
************************************************************
	.page
************************************************************
* ACTIVATE VER0 ON FLASH READS                             *
* LOADS FLASH WORD AT ADDR FL_ADRS TO FL_DATA.             *
* Uses SPAD1 for temporary storage of flash comands.       *
************************************************************
SET_RD_VER0                                               ;*
        CALL    REGS            ;ACCESS FLASH REGISTERS    *
        LACL    FL_ST           ;ACC => FLASH              *
        SPLK    #VER0,SPAD1     ;ACTIVATE VER0             *
        TBLW    SPAD1           ;EXECUTE COMMAND           *
        LAR     AR7,#D10        ;SET DELAY                 *
        CALL    DELAY,*,AR7     ;WAIT                      *
        CALL    ARRAY           ;ACCESS FLASH ARRAY        *
        LACL    FL_ADRS         ;POINT TO ADRS             *
        TBLR    FL_DATA         ;GET FLASH WORD 1x read    *
        TBLR    FL_DATA         ; 2x read                  *
        TBLR    FL_DATA         ; 3x read                  *
        CALL    REGS            ;ACCESS FLASH REGISTERS    *
        LACL    FL_ST           ;ACC => FLASH              *
        SPLK    #STOP,SPAD1     ;DEACTIVATE VER0           *
        TBLW    SPAD1           ;EXECUTE COMMAND           *
        LAR     AR7,#D10        ;SET DELAY                 *
        CALL    DELAY,*,AR7     ;WAIT                      *
        CALL    ARRAY           ;ACCESS FLASH ARRAY        *
        RET                     ;RETURN TO CALLING SEQUENCE*
************************************************************

************************************************
* PRG_BYTE: Programs hi or lo byte depending on*
*           byte mask (BASE_2).                *
************************************************
PRG_BYTE:
        CALL    SET_RD_VER0     ;Read word at VER0 level.
        LACL    BASE_2          ;Get lo/hi byte mask.
        AND     FL_DATA         ;Xor with read-back value.
        BCND    PB_DONE,EQ      ;If zero then done.
        XOR     #0FFFFh         ;else, mask off good bits.
        SACL    FL_DATA         ;New data.
        CALL    EXE_PGM         ;PGM Pulse.
        SPLK    #0,BASE_0       ;Set row done flag = 0(False).
PB_DONE RET
************************************************
Lenfl_clr	.set $-Beginfl_clr
	.def	Lenfl_clr
	.end