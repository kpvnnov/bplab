* Include file with I/O register declarations *
* For usload_2.asm Serial loader Level 1 only *
*                                             *
* Written by Sam Saba,TI Houston      4/17/97 *
	.mmregs
* On-chip register equates
*Flash control registers
f_access0 .set 0ffe0h
f_access1 .set 0ffe1h
pmst    .set  0ffe4h
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

* Variables
B2      .set 60h
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

