* Program : Pload_20.asm                                   *     
* Function: F2xx Serial loader module by polling DR-bit    *
*                                                          *
*           Receive data format :                          *
*           Header :                                       *     
*                    start address         1 word          *
*                    Program code/length   2 word          *
*                    Program code/data     from 3 word     *
*           Incoming code is loaded in 0x8400 PM           *
*           After data load the PC will jump to the        *
*           Destination/Load/Run address.                  * 
* Written by: Sam Saba/ASP/St,TX            Date: 4/17/97  *                   
        .def uart_ld
        .title  " Serial loader"  ; Title
        .copy "sldrv4.h"         ; Variable and register declaration
        .sect "uartld"
uart_ld:
*Uart initialization for polled receive

        call B2_init            ; The B2 is now pointing to B1

pwait:
        in B2S_0,iosr           ; Load input status from iosr
        bit B2S_0,7             ; bit 8 in the data
        bcnd pwait,ntc          ; IF DR=0 no echo, return
        call pnrcv              ;
        bit B2FM_8,15           ; Wait until Data_move ready flag
        bcnd pwait,ntc
        lacl B2PA_2             ; Load destination address
        tblw B2PD_5             ; Move data to the current destination address
        add #1                  ; Increment destination address+1
        sacl B2PA_2             ; save next destination address
        lacc B2FSH,16           ; Check sum calculations
        adds B2FSL              ; Check sum= Checksum+byte
        addc B2S_1
        addc B2S_0
        sach B2FSH
        sacl B2FSL
        banz pwait,*-
ck_sum:
        in B2D_7,iosr           ; Load input status from iosr !!!!
        bit B2D_7,7             ; bit 8 in the data
        bcnd ck_sum,ntc         ; IF DR=0 no echo, return
        in   B2PD_5,adtr
        and  #00ffh             ; Check if LSB byte of chksum= chksum char
        sub  B2PD_5             ; sent from host, else error        
        bcnd errc,neq
        ret
errc:   splk #1,B2FD_a          ; Update Data_error flag
        ret

pnrcv:
        mar *,ar1               ; Valid UART data, Point to Word index reg.
        bit B2D_6,15            ; Check if bit0 of word index =1,low byte 
        bcnd plbyte,tc          ; received!
        in B2S_1,adtr           ; No, Hi byte received!
*        out B2S_1,adtr          ; Echo receive data
        lacc B2S_1,8            ; Align to upper byte
        sacl B2D_7              ; Save aligned word
        mar *+                  ; Increment Word Index 
        sar ar1,B2D_6           ; Store high_byte flag
        splk #0,B2FM_8          ; Reset Data/word move flag as only hi-byte recd!
        b pskip                 ; wait for next byte 
plbyte:
        in B2S_0,adtr           ; Receive second byte/low byte
*        out B2S_0,adtr          ; Echo received data
        lacc B2S_0,0
        and #0ffh               ; Clear high byte
        or B2D_7                ; Add high byte to the word
        sacl B2PD_5             ; store 16-bit word at ar1
        mar *+                  ; 1+
        sar ar1,B2D_6           ; Save the count 
        bit B2FH_9,15           ; Check Header_done flag
        bcnd psmove,tc          ; No, if 2 words received update Data_move flag
        lar ar0,#2
        cmpr 0
        bcnd pword2,ntc          
        sacl B2PA_3             ; Store COFF segment address
        lacc #PRG_data          ; load data buffer address
        sacl B2PA_2             ; Save data buffer address 
        b pskip                 ;
pword2:
        lar ar0,#4              ; Check if 4 words recvd, update program length
        cmpr 0                  ; Program length register
        bcnd pskip,ntc          ; Else exit
        lar ar2,B2PD_5          ; Yes received!,Load PM length in AR2
        sar ar2, B2PL_4         ; Save program length
        splk #1,B2FH_9          ; Set Header_done flag 
        b pskip
psmove:
        mar *,ar2
        splk #1h,B2FM_8         ; Set UART Data_move ready flag
pskip:
        splk #0020h, ifr        ; Clear interrupt in ifr!
	ret

B2_init:
        lacc #0
        lar ar1,#B2            ; Point B2_RAM start address
        mar *,ar1
        rpt #16
        sacl *+                 ; Clear B2 memory 
        lar ar1,#00h            ; Clear pointers
        lar ar2,#00h            ; 
        ret

        .end                    ; Assembler module end directive -optional
