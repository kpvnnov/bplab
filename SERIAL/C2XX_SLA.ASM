;**************************************************************************
; FILENAME: c2xxprog.asm - Generic name
;           c2xx_slx.asm  
;
; DESCRIPTION:
;   Flash Programmer control module with flash algorithms -CEP
;   to be transfered using flash serial loader, F206sldr.exe
;   Uses the on-chip SARAM for algorithms and flash program data buffer
;
; GLOBALS:
;
;   unsigned * PRG_bufaddr      Address of buffer for flash/program data
;   unsigned   PRG_bufsize      Size of program data buffer
;   unsigned   PRG_devsize      Size of programmable device
;   unsigned * PRG_paddr        First programming address
;   unsigned   PRG_page         Programming page
;   unsigned   PRG_length       Length of programming data
;   unsigned   PRG_status       Status of programming functions
;
; PUBLIC FUNCTIONS:
;   PRG_init                    Initialize system for programming
;   PRG_program                 Program a block
;   PRG_clear                   clear a flash array
;   PRG_erase                   Erase a flash array
;   PRG_verify                  Verify a block
;
; PRIVIATE FUNCTIONS:
;   None
;
; USAGE/LIMITATIONS
;   The global and public function symbol values must be available in the
;   COFF file for the loader to work properly. The functions are not
;   intended to be called by another program.
;
; NOTES:
;   The program needs three memory sections to operate:
;   Actual location of these sections in the memory is defined in the
;   linker command file - *.cmd
;
;       PRG_text    Executable section for this program
;       PRG_parms   Variable section for this program
;       PRG_data    Data buffer used to hold programming data
;
;   The size and location of each section  is user defined.  The
;   loader program will read the value of PRG_bufaddr and PRG_bufsize to
;   determine the location and size of the PRG_data section.
;
;  
;  Serial loader 
;   F206sldr  -      WINDOWS'95 version, requires configuration file to run                         
;  <UART loader)                      
;
;
;   Source : TI Tools group, Houston
;   Version : 2.00
;   Modified for F2xx devices: Sam Saba, TI Houston            9/8/97
; H**************************************************************************

;
; ***************************************************************************
; INCLUDE FILES
; ***************************************************************************
    .mmregs
    .include "sldrv4.h"     ; Variable declarations
    .include "CMDS4.h"
    .ref GPGMJ,GCLR, GERS  ; References Flash algorithms GCLR or GERS or GPGMJ
    .ref uart_ld           ; utility modules, uart loader
; ***************************************************************************
; PUBLIC DECLARATIONS
; ***************************************************************************
        .global PRG_init, PRG_program, PRG_erase, PRG_verify, PRG_stop
        .global PRG_bufaddr, PRG_bufsize, PRG_devsize, PRG_paddr, PRG_page
        .global PRG_length, PRG_status,PARMS,SEG_ST,SEG_END
        .global PROTECT, FL_ST,FL_END,ENDZ
; ***************************************************************************
; PRIVATE DECLARATIONS
; ***************************************************************************
                       
BUFFER_SIZE .set    3000        ;Size of program buffer size
                                ;Can be increased based available
                                ;memory

DEVICE_SIZE .set    0ffffh      ;Size of device to be programmed.
                                ;Default is maximum address range for
                                ;the F2xx
DFL0_ST      .set   0000h       ; Flash0 and Flash1 array address
DFL0_END     .set   3fffh       ; definitions
DFL1_ST      .set   4000h
DFL1_END     .set   7fffh
PARMS        .set   6h

; ***************************************************************************
; Define the PRG_parm section
; Flash program variables to be moved for run time use in the address space
; B1(310-320h). CLEAR,ERASE,PROGRAM algorithms use these variables
; ***************************************************************************
    .sect   "PRG_parm"          ;Actual location in memory defined is
                                ;linker command file
DPRG_bufaddr .word   0c00h      ;Address of program data buffer
DPRG_bufsize .word   BUFFER_SIZE ;Flash program data buffer size
DPRG_devsize .word   DEVICE_SIZE ;Addressable memory size

*                               ;The following parameters will be redefined by
*                               ;F206sldr based on the flashcode.out
                                ;Algorithm Array variables
DPRG_paddr   .word   0           ;First address to program
DPRG_page    .word   0           ;Page to program
DPRG_length  .word   0           ;Length of block to program
DPRG_status  .word   0           ;Status of programming functions
DTemp        .word   0           ;Temp location for verify
DPROTECT     .word   0FF00h      ;Enable all 8 segments
DFL_ST       .word   0000h       ;Define Flash array start addres
                                 ;for CLEAR and ERASE
                                 ;0x0000 for flash0
                                 ;0x4000 for flash1
DFL_END      .word   0000h       ;0x4000, for flash0,0x8000, for flash1
DFL_LEN      .word   4000h       ;Length of array to be CLEARED
                                 ;or ERASED
DSFLAG       .word   0h          ;Serial loader Program control flag
DHFLAG       .word   0h          ;host status flag, defined here or by host
DBAUD        .word   1h          ;Buad value to updated from BRD register
DPRG_END     .word   0ABCDh      ;LOAD SEGMENT END PATTERN

    .sect   "ary_var"            ; Initialize buffer to 0x0000 for program
ENDZ:       .word   0201h         ; end indentification

; ***************************************************************************
; Define the PRG_text section
; ***************************************************************************
    .sect   "PRG_text"          ; Control and algorithm module

; F**************************************************************************
; Name: PRG_init
; F**************************************************************************
 
PRG_init:   ldp #PARMS                  ; Defines data page
	    splk    #0,PRG_status
            splk    #0,ERROR            ; Reset Error flag
            splk #6h,B2_0               ; set SARAM in PM/DM
            out B2_0,PMST
            in BAUD,brd                 ; update buad rate of host
            clrc xf                     ; Toggle XF - test only
            call var_init               ; initialize flash variable space
            call var_mov                ; move flash variables
            call ht_req_H2
            call  flash_cmd             ; Process flash command
            lacl  #H_done               ; hand_shake
            call  uart_xmit             ; program_done to Host
            lacl #0001h                 ; Send Fl_status_word
            call uart_xmit
            b     hw_sign               ; branch h/w flag once program is done
            b     PRG_stop

*Flash function command detect stage.
flash_cmd:                              ; Transfer control based on SFLAG
            bit  SFLAG,#FX_ARY0         ; Check if the flash functions are
            bcnd fl_ary1,ntc            ; for Flash 0  or Flash1 array.
            bit SFLAG,#FX_CLR           ; Check for clear function
            cc    do_f0_clr,tc          
            bit SFLAG,#FX_ERS           ; Check for erase function
            cc    do_f0_ers,tc
            bit SFLAG,#FX_FN11          ; Skip Clear/erase for flash1
            bcnd fl_prog,tc

fl_ary1:    bit SFLAG,#FX_ARY1          ; Check if flash1 is selected
            bcnd no_fl1,ntc		; else return
                                        ; Flash 1 array functions
            bit SFLAG,#FX_CLR           ; Check for clear function
            cc    do_f1_clr,tc          
            bit SFLAG,#FX_ERS           ; Check for erase function
            cc    do_f1_ers,tc
fl_prog:    bit SFLAG,#FX_PGM           ; check for program function
            cc    do_f0_pgm,tc
no_fl1      ret

do_f0_clr   call var_init
            call fl0_ary_init           ; Do flash0 init,clear           
            call PRG_clear
            ret
do_f0_ers
            call var_init               ; Do flash0 init,erase
            call fl0_ary_init
            call PRG_erase
            ret

do_f0_pgm                               ; Do flash0 init,program  
nxt0_blk    call prg_blk
            call PRG_program            ; Proceed to program current block
            bit   HFLAG,8               ; If more program code to follow,fetch
            bcnd  nxt0_blk,tc           ; again                
            ret

do_f1_clr
            call var_init    
            call fl1_ary_init           ; Do flash1 init,clear
            call PRG_clear
            ret
do_f1_ers
            call var_init
            call fl1_ary_init           ; Do flash1 init,erase
            call PRG_erase
            ret

prg_blk:
            lacl  #H_coffc_req          ; hand_shake_H3
            call uart_xmit              ; send COFFC request to Host
                                        ; hand_shake_H3
            call uart_recv              ; receive SFLAG, and check end
            sacl HFLAG                  ; COFFC block or more block to come from host
            call uart_ld                ; load COFFC block from host
            bit B2FD_a,15               ; check if uart_ld is fine,
                                        ; using data_ready flag,else error
            bcnd  perror,tc             ; Bit 15=1, checksum error!
            call move_fl_var            ; Update flash variables in 310-320h
            ret
perror:             
            lacl #H_com_err             ; Error! hand_shake_H4
            call uart_xmit              ;
	    splk #2h,ERROR		; Communication error code 2
            b PRG_stop                  ; Error exit!


*F2xx - Host uart functions

uart_xmit:
            sacl SPAD1                  ; save in scratch pad
            out SPAD1, adtr             ; xmit host command
            ret

uart_recv:                              ; Uart receive by polling for
            in B2_0,iosr                ; SFLAG updates from host
            bit B2_0, 7                 ; Check if DR bit is set
            bcnd uart_recv,ntc
            in B2_1,iosr
            out B2_1,iosr               ; disable all error conditions
            in B2_0,adtr                ; if any
*            out B2_0,adtr              ; Echo back to host
            lacl B2_0
            ret


*Uart initialization for polled receive
uart_init:
            splk #0c000h,B2S_0      ; reset the UART by writing 0
            out B2S_0, aspcr        ; 1 stop bit, no interrupt, input i/o
            splk #0e000h,B2S_0      ; CDC=0 disable
            out B2S_0, aspcr
            out BAUD,brd            ; update baud rate register
            ret

* SFLAG request from Host 
ht_req_H2   lacl #H_sflag_req           ; hand_shake_H2
            call uart_xmit              ; send code length as ack. to host
                                        ; hand_shake_H2
            call  uart_recv             ; Get new SFLAG from host
            sacl  SPAD1                 ; update high byte of SFLAG register
            lacc  SPAD1,8
            sacl  SFLAG
            call  uart_recv             ; Get new SFLAG from host
            sacl  SPAD1                 ; Update low_byte of SFLAG register
            lacc  SFLAG
            or    SPAD1
            sacl  SFLAG
            ret
*Flash array variable initializations

var_init:   mar *,ar7                   ; Clear variable space DM@300
            lar ar7,#300h
            lacc #0
            rpt #15
            sacl *+
            lar  ar7,#0310h
            ret

var_mov:    rpt #13
            blpd #DPRG_bufaddr,*+       ; Copy program variable to DM@310
            ret

fl0_ary_init:                           ; Initialize flash variables
            lacc #DFL0_ST               ; with Flash 0 address
            sacl SEG_ST
            lacc #DFL0_END
            sacl SEG_END
            ret

fl1_ary_init:
            lacc #DFL1_ST               ; Initialize Flash1 variables
            sacl SEG_ST
            lacc #DFL1_END
            sacl SEG_END
            ret


move_fl_var:
            lacc B2PA_3                 ; update PRG_paddr with
            sacl PRG_paddr              ; current flash start address
            lacc B2PL_4                 ; update PRG_length with
            add  #1                     ; adjust length to progamming
                                        ; algorithm
            sacl PRG_length             ; current length flash code
            ret                         ; to be programmed

hw_sign:    splk #0ffffh, SPAD1
            setc xf                     ; Indicate program finish by h/w
            rpt  SPAD1                  ; logic - xf toggle - forever!
            nop                         ; optional
            clrc xf                     
            b hw_sign

;
; F**************************************************************************
; Name: PRG_program
;   The assumption is that the programmable device is in program space.
; F**************************************************************************
 
PRG_program:
*                ret                         ; Ret used for Test mode   
                
                ldp #PARMS                  ;Point to data page
                call  GPGMJ
                bit ERROR,15
                bcnd  err3,tc
                splk    #0,PRG_status       ;update algorithm status
                ret
err3:           splk    #1,PRG_status       ;Error in Program stage
                lacl #H_alg_err              ; Error! hand_shake_F4
                call uart_xmit              ;
                splk #5h,ERROR              ; Update Program error code #4    
                b PRG_stop                  ; Error exit!
;
; F**************************************************************************
; Name: PRG_clear
; F**************************************************************************
 
PRG_clear:
*                ret                         ; Ret used for Test mode 
                ldp #PARMS
                call GCLR                   ; Call CLEAR algorithm
                bit ERROR,15
                bcnd err1,tc
                splk    #0,PRG_status
                ret
err1:           splk    #1,PRG_status       ;Error
                lacl #H_alg_err              ; Error! hand_shake_F4
                call uart_xmit              ;
                splk #3h,ERROR              ; Update CLEAR error code #2
                b PRG_stop                  ; Error exit!


; F**************************************************************************
; Name: PRG_erase
; F**************************************************************************
 
PRG_erase:
*                ret                         ; Ret used for Test mode 
                ldp #PARMS
                call GERS                   ; Call ERASE algorithm
                bit ERROR,15
                bcnd err2,tc
                splk    #0,PRG_status
                ret
err2:           splk    #1,PRG_status       ;Error
                lacl #H_alg_err              ; Error! hand_shake_F4
                call uart_xmit              ;
                splk #4h,ERROR              ; Update ERASE error code #3
                b PRG_stop                  ; Error exit!
;
; F**************************************************************************
; Name: PRG_stop
; F**************************************************************************
PRG_stop:

        nop
        lacl ERROR 
        call uart_xmit
        .word   0BE90h                  ;SWI instruction
        nop
        b $
                .end



