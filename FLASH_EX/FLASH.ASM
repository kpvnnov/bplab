***************************************************
* This file contains two C-callable functions:    *
*         program(), and erase()                  *
* These functions are used for programming and    *
* erasing the on-chip flash EEPROM of the 'F2XX   *
* product family.                                 *
***************************************************
* The functions provide a C-callable, interface to*
* the standard 'F2XX flash algorithms. They can   *
* also be used from assembly code, as long as the *
* C stack calling convention is used. Since the   *
* standard flash algorithms are actually used to  *
* perform the various flash operations, they must *
* must be combined with this code at link time.   *
*                                                 *
* The erase function includes all the operations  *
* (clear+erase+flw) required to prepare the flash *
* for programming. In addition to providing the   *
* C-callable interface, this function is very     *
* useful since it provides a single call to erase *
* the flash memory.                               *
* Since programming the device requires a single  *
* algorithm, the only purpose for the program()   *
* function is to provide a C-callable interface.  *
* The program() function transfers a specified    *
* block of data memory into a specified, erased   *
* flash array.                                    *
*                                                 *
* The parameters for each function are described  *
* in detail below. Note, these functions cannot   *
* reside in the same flash module that they are   *
* meant to modify.                                *
*                                                 *
*  10/29/97     Ruben D. Perez                    *
*               DSP Applications Team             *
*               Texas Instruments, Inc.           *
*  03/20/98     Updated for inclusion in flash    *
*               technical reference.              *
***************************************************
        .title "C-callable Interface to 'F2XX Flash Algorithms**"
;**C-callable functions defined in this file.
        .global _erase, _program

;**Variables included from flash algorithms.
        .include "svar20.h"    ; Variable declarations
        .ref GCLR              ; References clear algo.
        .ref GPGMJ             ; References program algo.
        .ref GERS              ; References erase algo.
        .ref FLWS              ; References Flash-write algo.
;**Parameters used by flash algorithms.
        .def PRG_bufaddr, PRG_paddr
        .def PRG_length, PARMS
        .def SEG_ST,SEG_END,PROTECT

*************************************************************************
VARS:    .usect  "PRG_data",16  ;This is an uninitialized data section  *
                                ;required by the standard flash algos   *
                                ;for temporary variables. Pointers to   *
                                ;this space are hardcoded in SVAR2X.H,  *
                                ;and variables are init'd at run-time.  *
*************************************************************************
PARMS:   .usect  "PRG_parm",10  ;This is an uninitialized data section  *
                                ;which is used for temporary variables, *
                                ;and for passing parameters to the flash*
                                ;algorithms.                            *
*************************************************************************
PROTECT     .set    PARMS       ;Segment enable bits.                   *
*************************************************************************
*****        Parameters needed for Programming algorithm.           *****
*************************************************************************
PRG_bufaddr .set    PARMS+1     ;Address of buffer for program data.    *
PRG_paddr   .set    PARMS+2     ;First flash address to program.        *
PRG_length  .set    PARMS+3     ;Length of block to program.            *
*************************************************************************
*****    Parameters needed for CLEAR, ERASE, and FLW algorithms.    *****
*************************************************************************
SEG_ST      .set    PARMS+4     ;Segment start address.                 *
SEG_END     .set    PARMS+5     ;Segment end address.                   *
*************************************************************************
****                  Other misc variables.                         *****
*************************************************************************
ERS_COUNT   .set    PARMS+6     ;Used for erase fail count.             *
SV_AR1      .set    PARMS+7     ;Used to save AR1.                      *
*************************************************************************

        .sect   "PRG_text"
*********************************************************
* function erase(PROTECT,SEG_ST,SEG_END)                *
* Status is be returned in the accumulator.             *
*       0=Fail,1=Pass                                   *
*********************************************************
* This function performs the clear, and erase operation *
* on the 'F2XX flash. If the erase operation fails, the *
* flash-write operation is used to try to recover from  *
* depletion. If the array recovers, the entire process  *
* (clr+ers+flw) is repeated a maximum of 10 times. The  *
* return value indicates the status. If this function   *
* passes, the flash is ready to be re-programmed. The   *
* operations are performed on the segments of the flash *
* module described by the parameter list:               *
*   1)PROTECT-defines which flash segments to protect.  *
*   2)SEG_ST -start address of segment to be erased.    *
*   3)SEG_END-end address of segment to be erased.      *
* To erase flash0 use erase(0xff00,0x0000,0x3fff).      *
* To erase flash1 use erase(0xff00,0x4000,0x7fff).      *
*********************************************************
* CAUTION: Erasing individual segments is not allowed.  *
*          The PROTECT parameter should always be set to*
*          enable all segments, and SEG_ST and SEG_END  *
*          should be set to the end and start address of*
*          the array to be erased.                      *
*********************************************************
_erase:

ERS_PARAMS .set 3

AR_STACK .set ar1

AR_PROTECT .set ar2
AR_SEG_ST  .set ar3
AR_SEG_END .set ar4

; Begin C Preprocessing
	POPD	*+			; pop return address, push on software stack
	sar	ar0,*+			; save FP
	sar	ar6,*			; save ar6
	sbrk #3

        ; get arguments and place them properly - take them from the
	; software stack and place them into their correct positions

	lar AR_PROTECT,*-			
	lar AR_SEG_ST,*-			
	lar AR_SEG_END,*-			

        adrk #ERS_PARAMS+4 ; ar1 = next empty point on stack (SP)

; End C Preprocessing

        LDP     #PARMS
        SAR     AR1,SV_AR1      ;Save AR1.
        SPLK    #0,ERS_COUNT    ;Set erase fail count to 0.
        SPLK    #0,ERROR        ;Set algo error flag to 0 (no errors).
**********Put parameters where they belong.**********
        SAR AR_PROTECT,PROTECT
        SAR AR_SEG_ST,SEG_ST
        SAR AR_SEG_END,SEG_END
***********Next Setup to clear flash ************
ers_loop:
        CALL    GCLR            ;Clear flash.
        LACL    ERROR           ;Check for CLEAR/ERASE error
        BCND    ers_error,neq   ;If error, then hard fail.
***********Next Setup to erase flash ************
        CALL    GERS            ;Erase flash.
        LACL    ERROR           ;Check for CLEAR/ERASE error
        BCND    depletion,neq   ;If error, try Flash-write.
        LACL    #1              ;Else, no errors erasing.
        B       ers_done        ;Restore registers and return.
depletion:
        LACL    ERS_COUNT       ;Get erase fail count.
        ADD     #1              ;Increment fail count.
        SACL    ERS_COUNT       ;Save new count.
        SUB     #10             ;CHECK for max of 10.
        BCND    ers_error,GT    ;If ers_cout>10 then hard fail.
        CALL    FLWS            ;Else, try to recover from depletion.
        LACL    ERROR           ;Check for FLASH-WRITE error.
        BCND    ers_error,neq   ;If couldn't recover, then hard fail.
        B       ers_loop        ;Else, Try erase again.

ers_error:
        LACL    #0              ;Error while erasing.
ers_done:
        LAR     AR1,SV_AR1      ;Restore AR1.
        CLRC    OVM             ;Disable overflow.
********************************************
; Begin C Post Processing
	mar *,ar1
	sbrk #1
	lar	ar6,*-			; save FP
	lar	ar0,*-			; save ar6
        pshd    *                       ; pop return address, push on software stack
; End C Post Processing	
	ret
*****************END of _erase************************


*********************************************************
* function  program(PROTECT,PRG_bufaddr,PRG_paddr,      *
*                   PRG_length)                         *
* Status will be returned in the accumulator.           *
*       0=Fail,1=Pass                                   *
*********************************************************
* This function performs the program operation on the   *
* 'F2XX flash. The values to be programmed will be read *
* from a buffer in data memory. The function can program*
* one to n words of flash in a single call; restricted  *
* only by the data buffer size. If the function passes, *
* the flash was programmed correctly. The function is   *
* controlled by the folowing parameter list:            *
*   1)PROTECT     -flash segments to protect.           *
*   2)PRG_bufaddr -Start address of program buffer in   *
*                  data memory.                         *
*   3)PRG_paddr   -Start address of flash locations to  *
*                  be programmed.                       *
*   4)PRG_length  -Number of words to be programmed.    *
*                                                       *
* To prgram 20 words of flash1 starting at address      *
* 0x4020, from a buffer at 0x0800@data use this:        *
*       program(0xff00,0x0800,0x4020,20).               *
*********************************************************
_program:

PRG_PARAMS .set 4

AR_STACK .set ar1

;**Parameters to be pop'd from s/w stack.
AR_PROTECT      .set ar2
AR_bufaddr      .set ar3
AR_paddr        .set ar4
AR_length       .set ar5


; Begin C Preprocessing
	POPD	*+			; pop return address, push on software stack
	sar	ar0,*+			; save FP
	sar	ar6,*			; save ar6
	sbrk #3

	; Local variables (and parameters) will be set up as follows:
	;
        ; get arguments and place them properly - take them from the
	; software stack and place them into their correct positions

	lar AR_PROTECT,*-
        lar AR_bufaddr,*-                 
        lar AR_paddr,*-                
        lar AR_length,*-                

        adrk #PRG_PARAMS+4 ; ar1 = next empty point on stack (SP)

; End C Preprocessing

        LDP     #PARMS
        SAR     AR1,SV_AR1      ;Save AR1.
        SPLK    #0,ERROR        ;Set algo error flag to 0 (no errors).
**********Put parameters where they belong.**********
        SAR AR_PROTECT,PROTECT
        SAR AR_bufaddr,PRG_bufaddr
        SAR AR_paddr,PRG_paddr
        SAR AR_length,PRG_length
***********Next program flash ************
        CALL    GPGMJ           ;Program flash from buffer.
        LACL    ERROR           ;Check for program error.
        BCND    prg_error,neq   ;If error then clear ACC.
        LACL    #1              ;Else, No errors programming.
        B       prg_done

prg_error:
        LACL    #0              ;Error while programming.
prg_done:
        LAR     AR1,SV_AR1      ;Restore AR1.
        CLRC    OVM             ;Disable overflow.
********************************************
; Begin C Post Processing
	mar *,ar1
	sbrk #1
	lar	ar6,*-			; save FP
	lar	ar0,*-			; save ar6
        pshd    *                       ; pop return address, push on software stack
; End C Post Processing	
	ret
*****************END of _program************************
