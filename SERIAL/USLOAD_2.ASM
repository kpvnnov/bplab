* Program : usload_2.asm                                   *     
* Function: F206 Serial loader Code -Level 1               *
*           Loads code/data either through UART or SSP     *
*           if BIO pin is low at boot/reset time           *
*           Uart starts in autobaud mode, receive          *
*           "a" or "A"as first character.                  *     
*           The cpu will wait indefinitely for first       *
*           character to be "a" or"A". On receipt of "a" or*
*           "A" uart data will be loaded as  valid code.   *
*           Receive data format :                          *
*		     First character       "A" or "a"      *
*           Header : Destination/Load/Run                  *
*                    start address         1 word          *
*                    Program code/length   2 word          *
*                    Program code/data     from 3 word     * 
*           After data load the, interrupts will be        *
*           disabled and PC will jump to the Destination   *
*           /Load/Run address.                             *
*							   *
* Revision  : 1.1					   *
* Written by: Sam Saba/ASP/St,TX            Date: 7/17/97  *                   
	
        .title  " Serial loader"  ; Title
        .copy "finit.h"           ; Variable and register declaration
        .text
         b start
	 b     inpt1	   	; INT1 - These interrupt vector locations
	                	;        are with RET, for safety.
	 b     inpt23           ; INT2/INT3 - The exact interrupt routine address
	                	;             need to be specified here when 
	                   	;             interrupt routines are used
	 b     time		; TINI  Timer interrupt
	 b     codrx       	; RX_Sync interrupt
			   	;
	 b     codtx	   	; TX_SYNC interrupt 
	 b     uart           	; TX/RX Uart port interrupt 
start:  setc CNF                ; Block B0 in PM
        ldp #0h                 ; set DP=0
        setc INTM               ; Disable all interrupts
* UART initialization *	
	splk #0ffffh,ifr	; clear interrupts
        splk #0000h,B2S_0
        out B2S_0, wsgr         ; Set zero wait states
        splk #0006h,B2S_0
        out B2S_0, pmst         ; Set SARAM in DM and PM
*Uart initialization with autobaud enable
        splk #0c0a0h,B2S_0      ; reset the UART by writing 0
	out B2S_0, aspcr	; 1 stop bit, rx interrupt, input i/o
        splk #0e0a0h,B2S_0      ; CDC=1 enable
	out B2S_0,aspcr
	splk #4fffh,B2S_0	; enable ADC bit
        out B2S_0,iosr		; enable auto baud
        splk #20h,imr           ; Enable UART interrupt only
        bcnd sspld,bio          ; If BIO is low use SSP loader
        b uartld
*SSP initialization, if BIO pin = 0 at boot/reset, else UART loader enabled
sspld:  splk #0c00ah,B2S_0      ; Initialize SSP in Burst mode
        out B2S_0,sspcr         ; External Clocks, 16 bit word
        splk #0c03ah, B2S_0     ; Interrupt on 1 word in FIFO
        out B2S_0, sspcr
        splk #8h,imr            ; Enable SSP RX interrupt only
uartld: lacc #0
        lar ar1,#B2             ; Point B2_RAM start address
        mar *,ar1
        rpt #16
        sacl *+                 ; Clear B2 memory 
        lar ar1,#00h            ; Clear pointers
        lar ar2,#00h            ; 
        lar ar3,#00h            
        clrc intm 
wait:   idle                    ; 
        bit B2FM_8,15           ; Wait until Data_move ready flag
        bcnd wait,ntc
        splk #0,B2FM_8
        lacl B2PA_2             ; Load destination address
        tblw B2PD_5             ; Move data to the current destination address
        add #1                  ; Increment destination address+1
        sacl B2PA_2             ; save next destination address
        banz wait,*-
        setc intm               ; Disable interrupts
        lacl B2PA_3             ; Point to Destination/Load/Run address 
        bacc                    ; Branch to Program address
        b wait

uart:
	in B2S_0,aspcr
	bit B2S_0,10		; Check CDC =1
	bcnd nrcv,ntc		; If 0 , start receive, autobaud done 
        in B2S_1,iosr           ; load input status from iosr
        bit B2S_1,1             ; check if auto baud bit is set,else return
        bcnd nauto,ntc          ; and wait for Auto baud detect receive
        splk #4000h,B2S_1       ; Auto baud detect done 
        out B2S_1,iosr          ; clear ADC
	splk #0e080h,B2S_1
	out B2S_1, aspcr	; Disable CDC bit/ auto baud
        in B2S_1,adtr           ; Dummy read to discard "a"
        out B2S_1,adtr          ; Echo back "a"
nauto:  in B2S_1,adtr           ; Dummy read to clear uart rx buffer
        b skip                  ; Exit and wait for "a"
nrcv:   in B2S_0,iosr           ; Load input status from iosr
        bit B2S_0,7             ; bit 8 in the data
        bcnd skip,ntc           ; IF DR=0 no echo, return
        mar *,ar1               ; Valid UART data, Point to Word index reg.
        bit B2D_6,15            ; Check if bit0 of word index =1,low byte 
        bcnd lbyte,tc           ; received!
        in B2S_1,adtr           ; No, Hi byte received!
        out B2S_1,adtr          ; Echo receive data
        lacc B2S_1,8            ; Align to upper byte
        sacl B2D_7              ; Save aligned word
        mar *+                  ; Increment Word Index 
        sar ar1,B2D_6           ; Store high_byte flag
        splk #0,B2FM_8          ; Reset Data/word move flag as only hi-byte recd!
        b skip                  ; wait for next byte 
lbyte:  in B2S_0,adtr           ; Receive second byte/low byte
        out B2S_0,adtr          ; Echo received data
        lacc B2S_0,0
        and #0ffh               ; Clear high byte
        or B2D_7                ; Add high byte to the word
        sacl B2PD_5             ; store 16-bit word at ar1
        mar *+                  ; 1+
        sar ar1,B2D_6           ; Save the count 
        bit B2FH_9,15           ; Check Header_done flag
        bcnd smove,tc           ; No, if 2 words received update Data_move flag
        lar ar0,#2
        cmpr 0
        bcnd word2,ntc          
        sacl B2PA_2             ; Store destination/Load/Run address
        sacl B2PA_3             ; Store destination/Load/Run address 
        b skip                  ;
word2:  lar ar0,#4              ; Check if 4 words recvd, update program length
        cmpr 0                  ; Program length register
        bcnd skip,ntc           ; Else exit
        lar ar2,B2PD_5          ; Yes received!,Load PM length in AR2
        sar ar2, B2PL_4         ; Save program length
        splk #1,B2FH_9          ; Set Header_done flag 
        b skip
smove:  mar *,ar2
        splk #1h,B2FM_8         ; Set UART Data_move ready flag
skip:   splk #6600h,B2S_0
        out B2S_0,iosr          ; Clear all Interrupt sources
        splk #0020h, ifr        ; Clear interrupt in ifr!
	clrc intm
	ret
* SSP loader code!
codrx:
        in B2S_0,sdtr           ; Load Scratch register
        out B2S_0,sdtr          ; Echo received data
        mar *,ar3               ; Set Word index register as ar3
        mar *+                  ; Increment word index
        lar ar0,#1              ; If word index =1 save Program start address
        cmpr 0
        bcnd pmad,tc
        lar ar0,#2              ; If index =2 save Program length
        cmpr 0
        bcnd plen,tc
        lacc B2S_0,0            
        sacl B2PD_5,0           ; Store received word 
        splk #1h,B2FM_8         ; Set SSP Data_move ready flag
        b skips,ar2
pmad:   lacc B2S_0,0            ; Store destinations start address at
        sacl B2PA_2             ; B2PA_2 and B2PA_3
        sacl B2PA_3              
        b skips,ar2
plen:   lar ar2,B2S_0           ; Store Program length at B2PL_4
        sar ar2,B2PL_4
skips:  splk #8h,ifr            ; Clear interrupt flag
        clrc intm
        ret
inpt1:	ret
inpt23: ret
time:	ret
codtx:  ret                     
	.end                    ; Assembler module end directive -optional
