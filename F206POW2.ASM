*****************************************************************************
*       Subroutine is used for check IDLE mode.
*       If Idle mode is interrupted, then XF pin value is changed
*****************************************************************************
*
IMR		.set	00004h
IFR		.set	00006h
F_ACCESS0 	.set	0FFE0h
F_ACCESS1 	.set	0FFE1h
SSPCR		.set	0FFF1h  ; Sinchronous Serial Port Control Register Adress
TCR  		.set	0FFF8h	; Timer Control Register Adress
	.bss	Temp,1  ; Temporrary memory Adress
	.bss	DIOSR,1
*
        .text
*
        B    Init      		; 0h   RS
        B    ChanceInterrupt    ; 2h   HOLD/INT1
        B    ChanceInterrupt    ; 4h   INT2/INT3
        B    ChanceInterrupt    ; 6h   TINT
        B    ChanceInterrupt    ; 8h   RINT
        B    ChanceInterrupt    ; Ah   XINT
        B    ChanceInterrupt    ; Ch   TXRXINT
        B    ChanceInterrupt    ; Eh   Reserved
        B    ChanceInterrupt    ; 10h  User-Defined
        B    ChanceInterrupt    ; 12h  User-Defined
        B    ChanceInterrupt    ; 14h  User-Defined
        B    ChanceInterrupt    ; 16h  User-Defined
        B    ChanceInterrupt    ; 18h  User-Defined
        B    ChanceInterrupt    ; 1Ah  User-Defined
        B    ChanceInterrupt    ; 1Ch  User-Defined
        B    ChanceInterrupt    ; 1Eh  User-Defined
        B    ChanceInterrupt    ; 20h  User-Defined
        B    ChanceInterrupt    ; 22h  TRAP
        B    ChanceInterrupt    ; 24h  NMI
        B    ChanceInterrupt   	; 26h  Reserved
*
Init:   SETC	INTM            ; All maskable interrupts disabled
*
	LDP	#4
*
	SPLK	#0010h,Temp	; Stoped Timer
	OUT	Temp,TCR
*
	SPLK	#0,Temp		; Stoped Sinchronous Serial Port
	OUT	Temp,SSPCR
*
	MAR	*,AR2
	LAR	AR2,#IMR
	SPLK	#003Fh,*
	LAR	AR2,#IFR
	LACC	*
	SACL	*
*
	SPLK	#0000h,Temp	; Stoped Flasf_1
	OUT	Temp,F_ACCESS1
*
        CLRC	INTM            ; All maskable interrupts disabled
	LACC	#0

ChanceInterrupt:                ; If Idle mode is interrupted,then
				; XF pin value is changed
	XOR	#0001h
	BCND	XF_1,NEQ

	CLRC	XF
        CLRC	INTM            ; All maskable interrupts disabled
	IDLE
	B	ChanceInterrupt

XF_1    SETC	XF
        CLRC	INTM            ; All maskable interrupts disabled
	IDLE
	B	ChanceInterrupt

	.end
