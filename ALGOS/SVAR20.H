*************************************************************
** Variable declaration file                               **
*                                                          **
* TMS320F2XX Flash Utilities.                              **
*  Revision: 2.0,  9/10/97                                 **
*  Revision: 2.1,  1/31/98                                 **
*                                                          **
* Filename: svar20.asm                                     **
* Modified for F2xx: Sam Saba                      7/07/97 **
* Changes20: Removed some unused variables. Added FL_ST and**
*            FL_END. Tweaked DLOOP constants. Added more   **
*            comments.                                     **
* Changes21: Added conditional assembly variable F24X, to  **
*            distinguish between F24X and F206 devices.    **
*            This is required because of RAM constraints on**
*            F24X. Changed variable names from B2_ to BASE_**
*            since they're actually relocatable.           **
*                                                          **
*                                                          **
*Note:                                                      *
*DLOOP is a delay loop variable used in flash algorithms.   *
*This is a function of CLKOUT1. If the F206 device runs at  *
*any CLKOUT1 speed other than 20MHz, DLOOP value should be  *
*re-defined as per the equation, explained below. Use of    *
*current DLOOP for flash programming at speeds other than   *
*20Mhz is not recommended!.                                 *        
*************************************************************
*
        .mmregs
BASE    .set    0300h           ;Base address for variables
                                ;can be changed to relocate
                                ;variable space in RAM.
BASE_0  .set    BASE+0          ;Scratch pad registers.
BASE_1  .set    BASE+1          ; 
BASE_2  .set    BASE+2          ;
BASE_3  .set    BASE+3          ;
BASE_4  .set    BASE+4          ;
BASE_5  .set    BASE+5          ;
BASE_6  .set    BASE+6          ;
SPAD1   .set    BASE+7          ;
SPAD2   .set    BASE+8          ;

FL_ADRS .set    BASE+10         ;Flash load address.
FL_DATA .set    BASE+11         ;Flash load data.
ERROR   .set    BASE+15         ;Error flag register.

*Variables for ERASE and CLEAR
RPG_CNT .set    BASE+12         ;Program pulse count.
FL_ST   .set    BASE+13         ;Flash start addr/Seg Cntrl Reg.
FL_END  .set    BASE+14         ;Flash end address.

*
*CONSTANTS
*
**************************************************
*Conditional assembly variable for F24X vs F206. *
*If F24X = 1, then assemble for F24X, otherwise  *
*assemble for F206.                              *
**************************************************
F24X    .set    0               ;Assemble for F206
;F24X    .set    1               ;Assemble for F240
;F24X    .set    2               ;Assemble for F241/3

**************************************************
* Array size-1, used to complement addresses in  *
* erase algorithm.                               *
**************************************************
        .if F24X = 2
ENDADDR .set    01FFFh          ;F241/3 have 8K array.
        .else
ENDADDR .set    03FFFh          ;All others have 16K.
        .endif
**************************************************
* Delay variables for CLEAR,ERASE and PROGRAM    *
**************************************************
D5      .set    0               ;5us delay
D10     .set    1               ;10us delay
D100    .set    19              ;100us delay
D5K     .set    999             ;5ms delay
D7K     .set    1399            ;7ms delay

***********************************************************
*DLOOP constant proportional to CLKOUT1                   *
*Calculate DLOOP in decimal using the following equation: *
* DLOOP=FLOOR{(5us/tCLKOUT1)-6};                          *
*Examples                                                 *
*a. @15Mhz,  DLOOP= 69;                                   *
*b. @9.8304Mhz,  DLOOP= 43;                               *
*c. @16.384Mhz,  DLOOP= 75;                               *
***********************************************************

DLOOP   .set      7              ;5us delay loop @ 2.016MIPs
;DLOOP   .set    14              ;5us delay loop @ 4.032MIPs
;DLOOP   .set    19              ;5us delay loop @ 5MIPs
;DLOOP   .set    44              ;5us delay loop @ 10MIPs
;DLOOP   .set    75              ;5us delay loop @ 16.384MIPs
;DLOOP   .set    94              ;5us delay loop @ 20MIPs


*************************
* On-chip I/O registers *
*************************
F_ACCESS0 .set    0FFE0h  ;F206 ACCESS CNTRL REGISTER 0.
F_ACCESS1 .set    0FFE1h  ;F206 ACCESS CNTRL REGISTER 1.
PMST      .set    0FFE4h  ;Defines SARAM in PM/DM and MP/MC bit.
F24X_ACCS .set    0FF0Fh  ;F240 ACCESS CNTRL REGISTER.

;-------------------------------------------
;Register Declarations for F240 Peripherals |
;-------------------------------------------
;Watch-Dog(WD) / Real Time Int(RTI) / Phase Lock Loop(PLL) Registers
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
RTI_CNTR	.set	07021h		;RTI Counter reg
WD_CNTR 	.set	07023h		;WD Counter reg
WD_KEY		.set	07025h		;WD Key reg
RTI_CNTL	.set	07027h		;RTI Control reg
WD_CNTL 	.set	07029h		;WD Control reg
PLL_CNTL1	.set	0702Bh		;PLL control reg 1
PLL_CNTL2	.set	0702Dh		;PLL control reg 2

