*************************************************************
** PROGRAM Subroutine                                      **
*                                                          **
* TMS320F2XX Flash Utilities.                              **
*  Revision: 2.0,  9/10/97                                 **
*  Revision: 2.0b, 12/5/97                                 **
*  Revision: 2.1,  1/31/98                                 **
*                                                          **
* Filename: spgm20.asm                                     **
* Changes20: Re-written to include latest flash algorithms.**
* Changes20b: Changed conditional branch on line 185 near  **
*            row-done label from GEQ to GT, to prevent     **
*            skipping of last address on sections that end **
*            with a mult of 32d address (020h,040h,etc.)   **
* Changes21: Cleaned up source for release to mass market. **
*            Replaced the manual 2s-comp in adj_row with   **
*            neg instruction. Removed extra branch at top  **
*            of GPGMJ. Created PRG_BYTE subroutine for use **
*            on both high and low bytes. Changed variable  **
*            names from B2_ to BASE_ since they're not     **
*            necessarily stored in B2 RAM. Added more      **
*            comments.                                     **
*                                                          **
*                                                          **
* Called by : c2xx_bpx.asm or flash application programs.  **
*                                                          **
* !!CAUTION - INITIALIZE DP BEFORE CALLING THIS ROUTINE!!  **
*                                                          **
* Function  : This routine programs all or part of the     **
*             flash as specified by the variables:         **
*              PRG_paddr - Destination start address.       *
*              PRG_length - Source buffer length.           *
*              PRG_bufaddr - Source buffer start address.   *
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
* The following variables are used for temp storage:        *
*        AR0  - Used for comparisons.                       *
*        AR1  - Used for pgm pulse count.                   *
*        AR2  - Used for row banz loop.                     *
*        AR3  - Used for buffer addr index.                 *
*        AR4  - Used for flash address.                     *
*        AR6  - Parameter passed to Delay.                  *
*       SPAD1 - Flash program and STOP commands.            *
*       SPAD2 - Flash program + EXE command.                *
*     FL_ADRS - Used for flash address.                     *
*     FL_DATA - Used for flash data.                        *
*      BASE_0 - Used for row-done flag.                     *
*      BASE_1 - Used for row start address.                 *
*      BASE_2 - Used for row length-1.                      *
*      BASE_3 - Used for buffer/row start addr.             *
*      BASE_4 - Used for destination end addr.              *
*      BASE_5 - Used for byte mask.                        **
*************************************************************

        .include "svar4.h"
*
MAX_PGM .set    150        ;Only allow 150 pulses per row.
VER0    .set    010h       ;VER0 command.
WR_CMND .set    4          ;Write command.
WR_EXE  .set    045h       ;Write EXEBIN command.
STOP    .set    0          ;Reset command.

        .def    GPGMJ
        .ref    PRG_bufaddr,PRG_length,PRG_paddr
        .ref    PROTECT,DELAY,REGS,ARRAY

       .sect "fl_prg"
Beginfl_prg	.set $

************************************************
* GPGMJ: This routine programs all or part of  *
*        the flash as specified by the         *
*        variables:                            *
*   PRG_paddr - Destination start address.     *
*  PRG_length - Source buffer length.          *
* PRG_bufaddr - Buffer start address.          *
*                                              *
* The following variables are used for temp    *
* storage:                                     *
*        AR0  - Used for comparisons.          *
*        AR1  - Used for pgm pulse count.      *
*        AR2  - Used for row banz loop.        *
*        AR3  - Used for buffer addr index.    *
*     FL_ADRS - Used for flash address.        *
*     FL_DATA - Used for flash data.           *
*      BASE_0 - Used for row-done flag.        *
*      BASE_1 - Used for row start address.    *
*      BASE_2 - Used for row length-1.         *
*      BASE_3 - Used for buffer/row start addr.*
*      BASE_4 - Used for destination end addr. *
*      BASE_5 - Used for byte mask.            *
************************************************
GPGMJ:  SPLK    #0,IMR                  ;MASK ALL INTERRUPTS
	SETC	INTM		        ;GLOBALLY MASK ALL INTERRUPTS
        SPLK    #0,ERROR                ;Initialize error flag (no error).
        LACL    PRG_paddr               ;Get destination start address.
        SACL    FL_ADRS                 ;Save as current address.

        ADD     PRG_length              ;Determine destination end addr.
        SUB     #1                      ;
        SACL    BASE_4                  ;Save destination end addr.
        LACL    PRG_paddr               ;Get destination start addr.

        LAR     AR3,PRG_bufaddr         ;Get buffer start address.
********Begin a new row.*
NEWROW
        SACL    BASE_1                  ;Save row start address.
        SAR     AR3,BASE_3              ;Save buffer/row start address.
        LAR     AR1,#0                  ;Init pulse count to zero.
        SPLK    #31,BASE_2              ;Init row length-1 to 31.
        AND     #001Fh                  ;Is start addr on row boundary?
        CC      ADJ_ROW,NEQ             ;If not then adjust row length.
        LACL    BASE_1                  ;Get row start address.
        OR      #001Fh                  ;Get row end address.
        SUB     BASE_4                  ;Is end address on row boundary?
        CC      ADJ_ROW,GT              ;If not then adjust row length.

********Same row, next pulse.*
SAMEROW
        SPLK    #1,BASE_0               ;Set row done flag = 1(True).
        LACL    BASE_1                  ;Get row start address.
        SACL    FL_ADRS                 ;Save as current address.
        LAR     AR3,BASE_3              ;Get buffer/row start addr. 
        LAR     AR2,BASE_2              ;Init row index.

********Repeat the following code 32 times or until end of row.*
LOBYTE          ;********First do low-byte.*
        CALL    SET_MODULE,AR4          ;Determine which flash module.
        SPLK    #0FFh,BASE_5            ;Set lo-byte mask.
        CALL    PRG_BYTE                ;Check/Program lo-byte.
        SPLK    #0FF00h,BASE_5          ;Set hi-byte mask.
        CALL    PRG_BYTE                ;Check/Program hi-byte.

NEXTWORD        ;********Next word in row.
        LACL    FL_ADRS                 ;Load address for next word.
        ADD     #1                      ;Increment address.
        SACL    FL_ADRS                 ;Save as current address.
        MAR     *, AR3                  ;ARP -> buffer addr index.
        MAR     *+,AR2                  ;Inc, and ARP -> row index.
        BANZ    LOBYTE                  ;Do next word,and dec AR2.

********Reached end of row. Check if row done. *
        BIT     BASE_0,15               ;Get row_done flag.
        BCND    ROW_DONE,TC             ;If 1 then row is done.
        MAR     *,AR1                   ;Else, row is not done, so
        MAR     *+                      ;inc row pulse count.
        LAR     AR0,#MAX_PGM            ;Check if passed allowable max.
        CMPR    2                       ;If AR1>MAX_PGM then
        BCND    EXIT,TC                 ;fail, don't continue.
        B       SAMEROW                 ;else, go to beginning
                                        ;of same row.

********If row done then check if Array done. *
ROW_DONE
        LACL    FL_ADRS                 ;Check if end of array.
        SUB     BASE_4                  ;Subtract end addr.
        BCND    DONE, GT                ;If >0 then done.

********Else, goto next row. *
        LACL    FL_ADRS
        B       NEWROW                  ;Start new row.

********If here, then done.
DONE
        CALL    ARRAY                   ;Access flash in array mode.
        RET			        ;Return to calling program.

********If here then unit failed to program. *
EXIT    SPLK    #1,ERROR                ;Update error flag (error).
        B       DONE                    ;Get outa here.
************************************************
        .page
 
************************************************
* ADJ_ROW: This routine is used to adjust the  *
* row length, if the start or end address of   *
* code being programed does not fall on a row  *
* boundary. The row length is passed in the    *
* BASE_2 variable, and the adjustment value to *
* be subtracted is passed in the accumulator.  *
************************************************
ADJ_ROW
        NEG                     ;Take twos complement.
        ADD     BASE_2          ;Add row length.
        SACL    BASE_2          ;Save new row length.
        RET

************************************************
* SET_MODULE: This routine is used to point to *
* the appropriate flash array control register.*
* This is only important for 'F2XX devices with*
* multiple flash modules like the 320F206. The *
* variable FL_ST is returned with the correct  *
* register address.                            *
* The following resources are used temporarily:*
*        AR0  - Used for comparisons.          *
*        AR4  - Used for flash address.        *
************************************************
SET_MODULE
        LAR     AR4,FL_ADRS     ;AR4 = current address.
        SPLK    #0,FL_ST        ;FL_ST  = FLASH0 CTRL REGS
        LAR     AR0,#4000H      ;AR0 = compare value.
        CMPR    1               ;If AR4 < AR0 then
                                ;FL_ADRS < 4000H; SET TC
        BCND    FL0,TC          ;Address is in FL0.
*                               ;Else address is in FL1.
        SPLK    #04000h,FL_ST   ;FL_ST = FLASH1 CTRL REGS
FL0     RET
        
************************************************************
	.page
************************************************************
* THIS SECTION PROGRAMS THE VALUE STORED IN FL_DATA INTO   *
* THE FLASH ADDRESS DEFINED BY FL_ADRS.                    *
*							   *
* The following resources are used for temporary storage:  *
*        AR6  - Parameter passed to Delay.                 *
*       SPAD1 - Flash program and STOP commands.           *
*       SPAD2 - Flash program + EXE command.               *
************************************************************
EXE_PGM 			;			   *
*							   *
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
        LACL    FL_ST           ;ACC =>  (FLASH)           *
*							   *
* ACTIVATE WRITE BIT					  **
        TBLW    SPAD1           ;EXECUTE COMMAND          **
        LAR     AR6,#D10        ;SET DELAY                **
	CALL	DELAY,*,AR6	;WAIT			  **
* SET EXEBIN BIT					 ***
        TBLW    SPAD2           ;EXECUTE COMMAND         ***
        LAR     AR6,#D100       ;SET DELAY               ***
	CALL	DELAY,*,AR6	;WAIT			 ***
* STOP WRITE OPERATION					   *
        SPLK    #0,SPAD1        ;SHUTDOWN WRITE OPERATION  *
        TBLW    SPAD1           ;EXECUTE COMMAND           *
        TBLW    SPAD1           ;EXECUTE COMMAND           *
        LAR     AR6,#D10        ;SET DELAY                 *
	CALL	DELAY,*,AR6	;WAIT			   *
*							   *
	RET		;RETURN TO CALLING SEQUENCE	   *
************************************************************
	.page

***********************************************************
* ACTIVATE VER0 ON FLASH READS				  *
* LOADS FLASH WORD AT ADDR FL_ADRS TO FL_DATA.            *
* Uses SPAD1 for temporary storage of flash comands.      *
***********************************************************
SET_RD_VER0                     ;                         *
	CALL	REGS		;ACCESS FLASH REGISTERS   *
        LACL    FL_ST           ;ACC => FLASH             *
        SPLK    #VER0,SPAD1     ;ACTIVATE VER0            *
        TBLW    SPAD1           ;EXECUTE COMMAND          *
        LAR     AR6,#D10        ;SET DELAY                *
	CALL	DELAY,*,AR6	;WAIT			  *
	CALL	ARRAY		;ACCESS FLASH ARRAY	  *
        LACL    FL_ADRS         ;POINT TO ADRS            *
        TBLR    FL_DATA         ;GET FLASH WORD 1x read   *
        TBLR    FL_DATA         ; 2x read                 *
        TBLR    FL_DATA         ; 3x read                 *
	CALL	REGS		;ACCESS FLASH REGISTERS   *
        LACL    FL_ST           ;ACC => FLASH             *
        SPLK    #STOP,SPAD1     ;DEACTIVATE VER0          *
        TBLW    SPAD1           ;EXECUTE COMMAND          *
        LAR     AR6,#D10        ;SET DELAY                *
	CALL	DELAY,*,AR6	;WAIT			  *
	CALL	ARRAY		;ACCESS FLASH ARRAY	  *
        RET             ;RETURN TO CALLING SEQUENCE       *
***********************************************************
        .page

************************************************
* PRG_BYTE: Programs hi or lo byte depending on*
*           byte mask (BASE_5).                *
************************************************
PRG_BYTE:
        CALL    SET_RD_VER0             ;Read word at VER0 level.
        MAR     *,AR3                   ;ARP -> buffer addr index.
        LACL    *                       ;Get word to program.
        XOR     FL_DATA                 ;Xor with read-back value.
        AND     BASE_5                  ;Mask off hi/lo byte.
        BCND    PB_END,EQ               ;If zero then done.
        XOR     #0FFFFh                 ;else, mask off good bits.
        SACL    FL_DATA                 ;New data.
        CALL    EXE_PGM                 ;PGM Pulse.
        SPLK    #0,BASE_0               ;Set row done flag = 0(False).
PB_END  RET
************************************************
Lenfl_prg	.set $-Beginfl_prg
	.def	Lenfl_prg
	.end