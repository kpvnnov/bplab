*************************************************************
* ERASE subroutine                                         **
*                                                          **
* TMS320F2XX Flash Utilities.                              **
*  Revision: 2.0, 9/10/97                                  **
*  Revision: 2.1,  1/31/98                                 **
*                                                          **
* Filename: sera20.asm                                     **
* Changes20: Re-written to include latest flash algorithms.**
* Changes21: Cleaned up source for release to mass market. **
*            Removed redundant call/ret to XOR_erase       **
*            routine. Changed variable names from B2_ to   **
*            BASE_ since they're not necessarily stored in **
*            B2 RAM. Removed imr modifications. Merged     **
*            inc_erase sub-routine into erase routine.     **
*            Referenced constant ENDADDR for address       **
*            complementing. Added more comments.           **
*                                                          **
*                                                          **
* Called by : c2xx_bex.asm or flash application programs.  **
*                                                          **
* !!CAUTION - INITIALIZE DP BEFORE CALLING THIS ROUTINE!!  **
*                                                          **
* Function  : Erases one or more contiguos segments of     **
*             flash array 0/1 as specified by the          **
*             following variables.                         **
*             SEG_ST = Segment start address.              **
*             SEG_END= Segment end address.                **
*             PROTECT= Sector protect enable.              **
*                                                           *
* The algorithm used is "XOR-VER1" which means that in      *
* addition to the VER1 readmode, an XOR readback is used to *
* gain more margin. During the read portion of the erase to *
* reads are performed for each address; for the first read  *
* all address bits are complemented using a logical XOR with*
* the array end address. The data read during the first read*
* is discarded and the second read is performed on the      *
* actual address. This scheme simulates the worst-case      *
* branching condition for code executing from the flash     *
* array.                                                    *
* The erase pulse-width is 7ms, and a maximum of 1000 pulses*
* are applied to the array.                                 *
*                                                           *
* The following resources are used for temporary storage:   *
*        AR0  - Used for comparisons.                       *
*        AR2  - Used for erase pulse count.                 *
*        AR3  - Used for main banz loop.                    *
*        AR7  - Parameter passsed to DELAY.                 *
*      BASE_0 - Parameter passed to Set_mode.               *
*      BASE_1 - Used for flash address.                     *
*      BASE_2 - Used for flash data.                        *
*      BASE_3 - Used for flash checksum.                    *
*      BASE_4 - Used for segment size.                      *
*      BASE_5 - Flash Erase command.                        *
*      BASE_6 - Flash Erase+EXE command.                    *
*************************************************************
        .include "svar4.h"     ;defines variables for flash0
                                ;or for flash1 array
*
MAX_ER  .set    1000            ;Only allow 1000 erase pulses.
VER1    .set    8               ;VER1 command.
ER_CMND .set    2               ;ERASE COMMAND WORD
ER_EXE  .set    043h            ;ERASE EXEBIN COMMAND WORD
INV_ER  .set    018h            ;INVERSE ERASE COMMAND WORD
FL_WR   .set    6               ;FLASH WRITE COMMAND WORD
FLWR_EX .set    047h            ;FLASH WRITE EXEBIN COMMAND WORD
STOP    .set    0               ;RESET REGISTER COMMAND WORD

        .def    GERS
        .ref    PROTECT, SEG_ST,SEG_END
	.ref	DELAY,REGS,ARRAY
       .sect "fl_ers"
Beginfl_ers	.set $

************************************************
* GERS:  This routine performs an erase to     *
* xorver1 level. The Seg to erase is defined by*
* the vars SEG_ST and SEG_END. The following   *
* resources are used for temporary storage:    *
*        AR0  - Used for comparisons.          *
*        AR2  - Used for erase pulse count.    *
*        AR3  - Used for main banz loop.       *
*      BASE_0 - Parameter passed to Set_mode.  *
*      BASE_1 - Used for flash address.        *
*      BASE_2 - Used for flash data.           *
*      BASE_3 - Used for flash checksum.       *
*      BASE_4 - Used for segment size.         *
************************************************
GERS:
************************************************************
* Code initialization section				   *
* Initialize test loop counters:			   *
*   AR2 is the number of ERASE pulses.                     *
************************************************************
        SETC    INTM            ;Disable all maskable ints.
        SETC    SXM             ;Enable sign extension.                     
        CLRC    OVM             ;Disable overflow mode.
        LACL    SEG_ST          ;Get segment start address.
        AND     #04000h         ;Get array start address.
        SACL    FL_ST           ;Save array start address.
        OR      #ENDADDR        ;Get array end address.
        SACL    FL_END          ;Save array end address.
        SPLK    #0,ERROR        ;Reset error flag
        LAR     AR2,#0          ;Set erase count to 0.
        SPLK    #STOP, BASE_0   ;Stop command.
        CALL    SET_MODE        ;Disable any flash cmds.

XOR_ERASE
**** Compute checksum for flash, using address complementing.****
        LACC    SEG_END
        SUB     SEG_ST
        SACL    BASE_4          ;Segment length-1.
        LAR     AR3,BASE_4      ;load n-1 to loop n times.
        ADD     #1
        SACL    BASE_4          ;Segment length.
        SPLK    #VER1,BASE_0    ;VER1 command.
        CALL    SET_MODE        ;Set VER1 mode.
        MAR     *,AR3
        BLDD    #SEG_ST,BASE_1  ;Segment start address.
        SPLK    #0,BASE_3       ;Clear checksum.
RD1_LOOP                        ;For I = SEG_ST to SEG_END.
        LACC    BASE_1          ;ACC => CURRENT ADDR.
        XOR     FL_END          ;XOR addr with flash end addr.
        TBLR    BASE_2          ;Dummy Read.
        LACC    BASE_1          ;Get actual addr again.
        TBLR    BASE_2          ;True Read.
        ADD     #1              ;Increment flash addr.
        SACL    BASE_1          ;Store for next read.
        LACC    BASE_3          ;Get old check sum.
        ADD     BASE_2          ;ACC=>ACC+FL_DATA.
        SACL    BASE_3          ;Save new check sum.
        BANZ    RD1_LOOP,*-
        ADD     BASE_4          ;Should make ACC=0 for erased array.
        BCND    XOR_ERFIN,EQ    ;If BASE_3=0 finished.
                
***** If not erased, apply an erase pulse.
        CALL    ERASE_A         ;Else, pulse it again.
        MAR     *,AR2           ;ARP->AR2(Erase pulse count)
        MAR     *+              ;Increment Erase count.
        LAR     AR0,#MAX_ER
        CMPR    2               ;If AR2>MAX_ER then
        BCND    EXIT,TC         ;fail, don't continue erasing.
        B       XOR_ERASE       ;Else, check again.

***** If here, then erase passed, now check for depletion.
XOR_ERFIN
        SPLK    #STOP, BASE_0   ;Stop command.
        CALL    SET_MODE        ;Disable any flash cmds.
        CALL    INV_ERASE       ;Check for depletion.
DONE    RET                     ;Return to calling code.

***** If here, then an error has occured.
EXIT    SPLK    #1,ERROR        ;Update error flag
        SPLK    #STOP, BASE_0   ;Stop command.
        CALL    SET_MODE        ;Disable any flash cmds.
        B       DONE            ;Get outa here.
************************************************************
        .page


*************************************************
* SET_MODE: This routine sets the flash in the  *
* mode specified by the contents of BASE_0. This*
* can be used for VER0,VER1,INVERASE, or STOP.  *
*        AR7  - Parameter passsed to DELAY.     *
*************************************************
SET_MODE
        CALL    REGS            ;ACCESS FLASH REGS    
        LACL    FL_ST           ;ACC => SEG_CTR.
        TBLW    BASE_0          ;Activate MODE.
        LAR     AR7,#D10        ;SET DELAY                
        CALL    DELAY,*,AR7     ;WAIT                     *
        CALL    ARRAY           ;ACCESS FLASH ARRAY       *
	RET

************************************************
* INV_ERASE: This routine is used to check for *
* depletion in the flash array.                *
*        AR3  - Used for main banz loop.       *
*      BASE_0 - Parameter passed to Set_mode.  *
*      BASE_1 - Used for flash address.        *
*      BASE_2 - Used for flash data.           *
************************************************
INV_ERASE
        SPLK    #INV_ER,BASE_0
        CALL    SET_MODE        ;Set inverse-erase mode.
        BLDD    #FL_ST,BASE_1   ;Array start address.
        LAR     AR3,#31         ;Loop count.
        MAR     *,AR3
NEXT_IVERS
        LACL    BASE_1          ;Get address.
        TBLR    BASE_2          ;Dummy read.
        TBLR    BASE_2          ;Read data.
        ADD     #1              ;Increment address.
        SACL    BASE_1          ;Save address.
        ZAC
        ADD     BASE_2          ;Add data.
        BCND    EXIT, NEQ       ;If ACC<>0, then fail.
*Else continue, until until done with row.
        BANZ    NEXT_IVERS      ;Loop 32 times.
        SPLK    #STOP,BASE_0    ;Stop command.
        CALL    SET_MODE        ;Disable any flash cmds.
        RET                     ;If here then test passed.
        .page


************************************************************
* ERASE_A: This sub-routine applies one erase pulse to the *
* flash array.                                             *
*							   *
* The following resources are used for temporary storage:  *
*       BASE_0 - Flash STOP command, and FFFF for WDATA.   *
*       BASE_5 - Flash erase command.                      *
*       BASE_6 - Flash erase + EXE command.                *
************************************************************
ERASE_A
* SETUP FLASH ERASE COMMANDS FOR PROTECT MASK.            **
        LACL    PROTECT         ;GET SEGMENT PROTECT MASK **
        OR      #ER_CMND        ;OR IN ERASE COMMAND      **
        SACL    BASE_5          ;BASE_5 = ERASE COMMAND   **
        OR      #ER_EXE         ;OR IN EXEBIN COMMAND     **
        SACL    BASE_6          ;BASE_6 = ERASE EXE COMMND**
*							   *
* MUST LOAD WDATA WITH FFFF.                              **
        SPLK    #0FFFFh,BASE_0  ;WDATA VALUE FOR ERASE    **
        LACC    FL_ST           ;ACC => FLASH             **
        TBLW    BASE_0          ;SET WDATA = FFFF          *
*							   *
* THIS SECTION ACTIVATES THE WRITE COMMAND.               **
        SPLK    #STOP,BASE_0    ;Stop command.            **
        CALL    SET_MODE        ;Disable any flash cmds.  **
	CALL	REGS		;ACCESS FLASH REGS	  **
        LACC    FL_ST           ;ACC => FLASH             **
        TBLW    BASE_5          ;ACTIVATE ERASE           **
        LAR     AR7,#D10        ;SET DELAY                **
	CALL	DELAY,*,AR7	;WAIT			  **
*							   *
* THIS SECTION ACTIVATES THE EXEBIN COMMAND.              **
        TBLW    BASE_6          ;START ERASURE            **
        LAR     AR7,#D7K        ;SET DELAY to 7ms         **
	CALL	DELAY,*,AR7	;WAIT			  **
        SPLK    #STOP,BASE_0    ;STOP COMMAND             **
        CALL    SET_MODE        ;STOP ERASE               **
        RET                     ;RETURN TO CALLING CODE   **
************************************************************
Lenfl_ers	.set $-Beginfl_ers
	.def	Lenfl_ers
	.end