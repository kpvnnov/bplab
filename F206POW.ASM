*****************************************************************************
*       Subroutine is used for check IDLE mode.
*       If Idle mode is interrupted, then XF pin value is changed
*****************************************************************************
*
IMR		.set	00004h
IFR		.set	00006h
F_ACCESS0 	.set	0FFE0h
F_ACCESS1 	.set	0FFE1h
IOSR    	.set	0FFF6h
SDTR    	.set	0FFF0h
SSPS		.set	0CC3Ah
ASPS		.set	0C00Fh
SSPCR		.set	0FFF1h  ; Sinchronous Serial Port Control Register Adress
ASPCR		.set	0FFF5h  ; Sinchronous Serial Port Control Register Adress
CLKCR           .set    0FFE8h
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
	SPLK	#0000h,Temp	; Stoped Flasf_1
	OUT	Temp,F_ACCESS1
*
*	SPLK	#0001h,Temp	; Stoped Flasf_1
*	OUT	Temp,CLKCR
*
	SETC 	XF

	SPLK	#0000Ah,Temp	; Stoped Sinchronous Serial Port
	OUT	Temp,SSPCR

	SPLK 	#SSPS,Temp    ;SSP start
	OUT  	Temp,SSPCR    ;Synchronous Serial Port Control Register

	SPLK 	#ASPS,Temp    ;SSP start
	OUT  	Temp,ASPCR    ;Asynchronous Serial Port Control Register

	SPLK 	#000Fh,DIOSR  ;устанавливаем
	OUT  	DIOSR,IOSR      ;записываем в IO status register

	SPLK 	#0EC00h,Temp  ;software power down
	OUT  	Temp,SDTR     ;7.седьмое слово для передачи

	; mImp_ssp              ;подгоняем SSP к началу передачи MSB
	CLRC 	XF
	SETC 	XF
	; mImp_ssp
	CLRC 	XF
	SETC 	XF
	; mImp_ssp
	CLRC 	XF
	SETC 	XF

	LACC 	DIOSR
	AND  	#0008h  	;сбрасываем в ноль IO0(#CS0),IO2(#C+5VA)
	SACL 	DIOSR
	OUT  	DIOSR,IOSR      ;записываем в IO status register

	CALL 	CLKXF           ;1-передаем первое слово
	NOP
	NOP
	NOP
*
	LACC 	DIOSR
	OR   	#0Fh  		;устанавливаем в 1 IO1(#CS1)
	SACL 	DIOSR
	OUT  	DIOSR,IOSR      ;записываем в IO status register

	IN   	Temp,SDTR     ;команда лишнего чтения
	IN   	Temp,SDTR     ;команда лишнего чтения
	IN   	Temp,SDTR     ;команда лишнего чтения
	IN   	Temp,SDTR     ;команда лишнего чтения

	SPLK	#0000Ah,Temp	; Stoped Sinchronous Serial Port
	OUT	Temp,SSPCR
*
	SPLK	#0010h,Temp	; Stoped Timer
	OUT	Temp,TCR
*
	MAR	*,AR2
	LAR	AR2,#IMR
	SPLK	#003Fh,*
	LAR	AR2,#IFR
	LACC	*
	SACL	*
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

* выдача тактовой частоты для SSP

CLKXF:
       ;	mImp_ssp   ;1
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;2
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;3
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;4
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;5
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;6
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;7
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;8
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;9
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;10
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;11
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;12
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;13
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;14
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;15
	CLRC 	XF
	SETC 	XF
       ;	mImp_ssp   ;16
	CLRC 	XF
	SETC 	XF
	RET

	.end
