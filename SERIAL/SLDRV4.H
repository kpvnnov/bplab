*File name: sldrv1.h                                            *  
*Include file with Flash programming variable declarations      *
*Common to flash control and flash algorithms                   * 
*                                                               *
*                                                               *
*Rev 2.00                                                       *
*Written by: Sam Saba, TI Houston                       9/8/97  *
*****************************************************************
        .mmregs
; Memory variables specific to flash algorithms
***************************************************
BASE    .set    0300h            ; Base address for variables
B2_0    .set    BASE+0           ; can be changed to relocate
B2_1    .set    BASE+1           ; variable space in RAM
B2_2    .set    BASE+2
B2_3    .set    BASE+3
B2_4    .set    BASE+5
B2_5    .set    BASE+6
B2_6    .set    BASE+7
SPAD1   .set    BASE+8           ; Scatch pad registers
SPAD2   .set    BASE+9

FL_ADRS .set    BASE+10         ;FLASH LOAD ADRS
FL_DATA .set    BASE+11         ;FLASH LOAD DATA
FL_CTRL .set    BASE+12         ;FLASH CTRL REG ADRS
FL_BYTE .set    BASE+13         ;BYTE TO BE FLASHED
PGM_MASK .set   BASE+14         ;BITS TO BE FLASHED
ERROR    .set   BASE+15         ;ERROR flag register

*Variables for CLEAR
RPG_CNT .set    BASE+10         ;

*Variables for ERASE
SEG_ST  .set    BASE+11         ;
SEG_END .set    BASE+12         ;

*Array variables  to be used by flash control algorithms
*c2xx_prog or c2xx_sl1 in serial loader
*********************************************************
BASE1   .set    0310h
PRG_bufaddr .set  BASE1+0       ;Address of buffer for program
PRG_bufsize .set  BASE1+1       ;Flash program data buffer size
PRG_devsize .set  BASE1+2       ;Addressable memory on the device 

                                ;Algorithm Array variables
PRG_paddr   .set  BASE1+3       ;First address to program in flash array
PRG_page    .set  BASE1+4       ;Page to program
PRG_length  .set  BASE1+5       ;Length of current block to be programmed
PRG_status  .set  BASE1+6       ;Status of programming functions
Temp        .set  BASE1+7       ;Temp location for verify
PROTECT     .set  BASE1+8       ;Enable all 8 segments of flash0 /1 array
FL_ST       .set  BASE1+9       ;Define Flash array 0/1 start addres
                                ;for CLEAR and ERASE
                                ;0x0000 for flash0
                                ;0x4000 for flash1
FL_END      .set  BASE1+10      ;End of flash array, 0x4000 or 0x8000
FL_LEN      .set  BASE1+11      ;Length of array to be CLEARED
SFLAG       .set  BASE1+12      ;Serial loader control flag                             
HFLAG       .set  BASE1+13      ;Host status flag
BAUD        .set  BASE1+14      ;Temp buffer for uart buad rate
PRG_END     .set  BASE1+15      ;LOAD SEGMENT END PATTERN
PRG_data    .set  8400h         ;start address for flash program buffer 

* Variables for Uart_loader
***************************************************
B2      .set 320h
B2S_0   .set B2+0h              ; Scratch registers
B2S_1   .set B2+1h
B2PA_2  .set B2+2h              ; Program start address
B2PA_3  .set B2+3h              ; Program start address
B2PL_4  .set B2+4h              ; Program Length
B2PD_5  .set B2+5h              ; Program Code/Data
B2D_6   .set B2+6h              ; Variables
B2D_7   .set B2+7h
B2FM_8  .set B2+8h              ; Flag for start Data move - Data_move
B2FH_9  .set B2+9h              ; Flag for Header receive - Header_done
B2FD_a  .set B2+0ah             ; Flag for data move complete - Data_ready
B2FSH   .set B2+0bh             ; High word check sum
B2FSL   .set B2+0ch             ; Low word check sum

*
* On-chip I/O registers
F_ACCESS0 .set    0FFE0h  ;206 access REGISTER 0
F_ACCESS1 .set    0FFE1h  ;206 access register 1
PMST      .set    0FFE4h  ;Defines SARAM in PM/DM and MP/MC bit
* CLKOUT
clk1	.set	0ffe8h
* INTERRUPT CONTROL
icr	.set	0ffech
* SYNC PORT
sdtr	.set    0fff0h
sspcr	.set    0fff1h
* UART
adtr	.set    0fff4h
aspcr   .set    0fff5h
iosr    .set    0fff6h
brd     .set    0fff7h

* TIMER
tcr	.set	0fff8h
prd	.set	0fff9h
tim	.set 	0fffah

* WAIT STATES
wsgr	.set    0fffch
*
* Flash control register
* 15-8    - 7     6  5  4    3    2     1     0
* Seg_bits  Busy  Key   ver0 ver1 Write Erase Exe
* Seg_bits - bits 8 -15 enables eight 2kx16 flash segments.
*            0 - disable, 1 is enable.   
