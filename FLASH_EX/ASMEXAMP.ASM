***************************************************
* Filename: ASMEXAMP.ASM                          *
* Description:                                    *
* This file contains an example of how to erase   *
* and program the TMS320F206 flash from assembly  *
* code using the standard flash algorithm modules.*
* The example erases one of the 'F206 flash       *
* modules, then programs the first three words.   *
* Since the standard flash algorithms are actually*
* used to perform the various flash operations,   *
* they must must be combined with this code at    *
* link time.                                      *
*                                                 *
*  03/20/98     Updated for inclusion in flash    *
*               technical reference.              *
***************************************************
        .title  "**Example of Using 'F2XX Flash Algorithms**"

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
*************************************************************************

        .text
*******************************************************************
** First erase flash1 by invoking the clear and erase algorithms.**
** Note that three parameters must be initialized before calling **
** the algorithms.                                               **
*******************************************************************
        LDP     #PARMS
        SPLK    #0,ERS_COUNT    ;Set erase fail count to 0.
**********Put parameters where they belong.**********
        SPLK    #0ff00h,PROTECT
        SPLK    #04000h,SEG_ST
        SPLK    #07FFFh,SEG_END
***********First clear flash ************
ers_loop:
        CALL    GCLR            ;Clear flash.
        LACL    ERROR           ;Check for CLEAR/ERASE error
        BCND    ers_error,neq   ;If error, then hard fail.
***********Next erase flash ************
        CALL    GERS            ;Erase flash.
        LACL    ERROR           ;Check for CLEAR/ERASE error
        BCND    depletion,neq   ;If error, then try Flash-write.
        B       ers_done        ;Else, no errors erasing.
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
*******************************************************************
** If here then an unrecoverable error has occured during erase. **
** In an actual application, the system takes some action to     **
** indicate that service is required.                            **
*******************************************************************
        B       ers_error       ;Error while erasing.

ers_done:
*******************************************************************
** If here then flash is erased and ready to be reprogrammed.    **
** This is a good place in the example to set a breakpoint so    **
** that erasure can be verified (i.e. all flash bits should be 1)**
*******************************************************************

*******************************************************************
** At this point, an actual application fills a buffer with      **
** the data to be programmed. To simulate this in the example,   **
** three SARAM locations are initialized.                        **
*******************************************************************
        LAR     AR1, #0c00h     ;Using last 3K of SARAM as buffer.
        MAR     *,AR1
        SPLK    #0AAAAh,*+      ;Use dummy data for buffer.
        SPLK    #05555h,*+
        SPLK    #0AAAAh,*

*******************************************************************
** Now that the data to be programmed is ready, the programming  **
** algorithm is invoked. Note that four parameters must be       **
** initialized before calling the algorithm.                     **
*******************************************************************
        LDP     #PARMS
**********Put parameters where they belong.**********
        splk    #0ff00h,PROTECT
        splk    #0c00h,PRG_bufaddr
        splk    #04000h,PRG_paddr
        splk    #3,PRG_length
***********Next program flash ************
        CALL    GPGMJ           ;Program flash from buffer.
        LACL    ERROR           ;Check for program error.
        BCND    prg_error,neq   ;If error then clear ACC.
        B       prg_done        ;Else, No errors programming.

prg_error:
*******************************************************************
** If here then an error has occured during programming. In an   **
** actual application, the system takes some action to indicate  **
** that service is required.                                     **
*******************************************************************
        B       prg_error       ;Error while programming.

prg_done:
*******************************************************************
** If here then flash has been successfully programmed.           *
*******************************************************************
        B       prg_done        ;Done programming.
