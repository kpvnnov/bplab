;&D
*****************************************************************************
*       Subroutine is used for check IDLE mode.
*       If Idle mode is interrupted, then XF pin value is changed
*****************************************************************************
*
IOSR    .set	0FFF6h
SDTR    .set	0FFF0h
SSPS	.set	0CC38h
SSPCR	.set	0FFF1h  ; Sinchronous Serial Port Control Register Adress
TCR  	.set	0FFF8h	; Timer Control Register Adress
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
