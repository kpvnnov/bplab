*************************************************************
** Delay And Access Mode Subroutines                       **
*                                                          **
* TMS320F2XX Flash Utilities.                              **
*  Revision: 2.0,  9/10/97                                 **
*  Revision: 2.1,  1/31/98                                 **
*                                                          **
* Filename: sutils20.asm                                   **
* Modified for F2xx : Sam Saba                   12/24/96  **
* Changes20: Changed DELAY parameter passing to use AR7    **
*            instead of a RAM location.                    **
* Changes21: Added conditional assembly statements to REGS **
*            and ARRAY subroutines for F206 versus F24X.   **
*                                                          **
*                                                          **
* Called by: These utilites are used by CLEAR,ERASE,       **
*            PROGRAM algorithms written for F2xx devices.  **
* Function : DELAY - Delay loop specified by AR7.          **
*            REGS  - Clears MODE bit of F_ACCESS0/1 to     **
*                    access flash module control registers.**
*            ARRAY - Sets MODE bit of F_ACCESS0/1 to access**
*                    the flash array.                      **
*************************************************************
	.include "svar4.h"
	.def DELAY,REGS,ARRAY
	.def LenDLY,LenREGS,LenARRAY
	.sect	"DLY"
BeginDLY	.set	$
*************************************
*Delays as follows:                 *
*  LAR      AR7,#N        2 Cycles  *
*  CALL     DELAY         4 Cycles  *
*  RPT      #DLOOP  2*(N+1) Cycles  *
*  NOP          DLOOP*(N+1) Cycles  *
*  BANZ   DLY_LP      4*N+2 Cycles  *
*  RET                    4 Cycles  *
*         ------------------------  *
*       = DLOOP(N+1)+6*N+14 Cycles  *
* Set N and DLOOP appropriately to  *
* get desired delay.                *
*************************************

DELAY                           ;AR7 = OUTER LOOP COUNT
DLY_LP  RPT     #DLOOP          ;APPROX 5US DELAY
        NOP
	BANZ	DLY_LP,*-	;LOOP UNTIL DONE
	RET			;RETURN TO CALLING SEQUENCE
LenDLY	.set	$-BeginDLY
        .page
**************************************************
* REGS  - Clears MODE bit of F_ACCESS0/1 to     **
*         access flash module control registers.**
**************************************************
	.sect   "REG"
BeginREGS	.set	$
REGS
        SPLK    #0000h,SPAD2
***********The next instruction is for F240 only,*************
        .if     F24X != 0       ;Assemble for F24X only.
        OUT     SPAD2,F24X_ACCS ;Enable F24X flash reg mode.
                                ;SPAD1 is dummy value.
        .endif

**************************************************************
        .if     F24X = 0        ;Assemble for F206 only.
        LACC    FL_ST
        SUB     #4000h
        BCND    reg1, geq       ;if address>= 4000h,set
                                ;set reg mode for flash1 array
        OUT     SPAD2,F_ACCESS0 ;Change mode of flash0.
        RET
reg1    OUT     SPAD2,F_ACCESS1 ;Change mode of flash1.
        .endif
        RET                     ;RETURN TO CALLING SEQUENCE

LenREGS	.set	$-BeginREGS

        .page
**************************************************
* ARRAY - Sets MODE bit of F_ACCESS0/1 to access**
*         the flash array.                      **
**************************************************
	.sect	"ARY"
BeginARRAY	.set	$
ARRAY
        SPLK    #0001h,SPAD2
***********The next instruction is for F240 only,*************
        .if     F24X != 0       ;Assemble for F24X only.
        IN      SPAD1,F24X_ACCS ;Enable F24X flash array mode.
                                ;SPAD1 is dummy value.
        .endif

**************************************************************
        .if     F24X = 0        ;Assemble for F206 only.
        LACC    FL_ST
        SUB     #4000h
        BCND    ary1, geq       ;if address>= 4000h,set
                                ;set reg mode for flash1 array
        OUT     SPAD2,F_ACCESS0 ;Change mode of flash0.
        RET
ary1    OUT     SPAD2,F_ACCESS1 ;Change mode of flash1.
        .endif
        RET                     ;RETURN TO CALLING SEQUENCE
                     
LenARRAY	.set	$-BeginARRAY
	.end