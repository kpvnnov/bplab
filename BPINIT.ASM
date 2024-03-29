;&D
* $Id: BPINIT.ASM,v 1.25 2001-11-23 15:37:37 peter Exp $
INIT
	SETC 	INTM 		;����� ���뢠���
	LDP  	#4      	;load data memory page pointer
				;���� ����� 0300H-037FH

	SPLK 	#02E06h,TMP
				;02E06H->[TMP]
				;(store parallel long immediate)
				;ARP(15-13),OV,OVM,1,INTM,DP(8-0)
				;       001, 0,  1,1,   1,000000110h
	LST  	#0,TMP      ; load status register #0
	NOP
	NOP
	LDP  	#4      	;load data memory page pointer
				;���� ����� 0300H-037FH
*!!!! �६���� CNF ��⠭�������� � 1, ��饥 �᫮ �뫮 025FC, �⠫� 035FC
	SPLK 	#025FCh,TMP ;025FCH->[TMP]
				;(store parallel long immediate)
				;ARB(15-13),CNF,TC,SXM,C,1,1,1,1,XF,1,1,PM(1-0)
				;       001,  0, 0,  1,0,1,1,1,1, 1,1,1,00
	LST  	#1,TMP	; load status register #1
;��ࠬ���� Interrupt.
        MAR	*,AR2
	LAR  	AR2,#IMR	;load auxiliary reg #IMR -> AR2
	SPLK 	#0027h,*	; 0027H->[AR2==IMR], 0027->IMR(DS@0004h)
*�஡�
*	SPLK 	#0025h,*
				;Interrupt mask register
				;0(15-6),TXRXINT,XINT,RINT,TINT,INT2(INT3),INT1
				;0      ,1      ,0    0    1   ,1         ,1
				;ࠧ�蠥� ���뢠��� ��
				; - ��᫥����⥫쭮�� �ᨭ�஭����
				; - ⠩���
				; - int2 (�����窠)
				; - int1 alarm!
	LAR  	AR2,#IFR        ;load auxiliary reg #IFR -> AR2
				;interrupt flag register
	LACC 	*       	;load accumulator with shift
	SACL 	*       	;pending all interrupts
	SPLK 	#001Fh,TMP 	;0015H->[TMP]
;	SPLK 	#0015h,TMP 	;0015H->[TMP]
				;(store parallel long immediate)
	OUT  	TMP,ICR    	;0015H -> ICR(IS@0FFECh)
				;interrupt control register
				;             1     1     1     1     1
				;0...,MODE_INT1,FINT3,FINT2,MINT3,MINT2
				;�室 HOLD/INT1 �ࠡ��뢠�� �� ᯠ�� ⮫쪮
				;INT2 ࠧ�襭� � pending

*
	SPLK 	#CWSGR,TMP 	;CWSGR->[TMP]
				;(store parallel long immediate)
				;constant Wait State Generator
				;0,0,0,0,ISWS,DSWS,PSUWS,PSLWS
	OUT  	TMP,WSGR   	;#0 -> WSGR(IS@FFFCh)
*
	SPLK 	#1,TMP     	;0001H->[TMP]
				;(store parallel long immediate)
				;at reset this bit configured as a zero for
				;the CLKOUT1 pin to be active. if bit is a 1,
				;pin turned off
	OUT  	TMP,CLK    	;#1 -> CLK(IS@FFE8h)
*
	SPLK 	#6,TMP     	;0004H->[TMP]
				;(store parallel long immediate)
				;bits 1 and 2 configure the
				;SARAM(single-access) mapping either
				;in program memory, data memory
				;or both.at reset these bits are 00
				; DON (bit 2)  	PON (bit 1)
				;  0 		0	- SARAM not mapped
				;                     	  address in
				;			  external memory
				;                         (reset value)
				;  0            1  	- in on-chip program
				;                         memory at 0x8000H
				;  1            0       - in on-chip data
				;                         memory at 0x0800H
				;  1            1       - in on-chip program
				;                         and data memory
	OUT  	TMP,PMST   	;SRAM -> Data memory #1 -> PMST(IS@FFE4h)

;        SPLK 	#0,TMP     	;0000H->[TMP]
				;FLASH1 -> �������
;        OUT  	TMP,FACCES1

*******************************
*   	��ࠬ���� ⠩���.
*******************************
	SPLK 	#CPRD,TMP  	;CPRD->[TMP]
				;�� CLK   Fsampl
				;�� 3,6864���. 200��  PRD=023Fh, TDDR=0Fh
				;�� 3,6864���. 100��  PRD=047Fh, TDDR=0Fh
	OUT  	TMP,PRD    	;CPRD -> PRD(IS@0FFF9h)
				;timer period register
	SPLK 	#CTCR,TMP  	;CTCR->[TMP]
	OUT  	TMP,TCR    	;CTCR -> TCR(IS@0FFF8h)
				;timer-control register
				;0,0,0,0,FREE,SOFT,PSC,TRB,TSS,TDDR

********************************
*	��ࠬ���� SSP.
********************************
	SPLK 	#SSPR,TMP  	;reset SSP
	OUT  	TMP,SSPCR  	;SSPR -> SSPCR(IS@0FFF1h)
				;synchronous serial-port control register
	IN   	TMP,SDTR   	;[TMP] <- SDTR(IS@0FFF0h)
	IN   	TMP,SDTR   	;synchronous serial-port(SSP)transmit and
	IN   	TMP,SDTR   	;receive  register
	IN   	TMP,SDTR

********************************
*	��ࠬ���� ASP.
********************************
	SPLK 	#ASPR,TMP	;reset ASP
	OUT  	TMP,ASPCR  	;ASPSRA -> ASPCR(IS@0FFF5h)
				;asynchronous serial-port
				;control register(ASPCR)
	SPLK 	#ASPSRA,TMP	;Enable receiver A
				;� �ਥ� ᨬ����� �����
	;FREE,SOFT,URST,0,0,0,DIM,TIM,RIM,STB,CAD,SETBRK,CIO3,CIO2,CIO1,CIO0
	;   1,   1,   1,0,0,0,  0,  0,  1,  0,  1,     0,   1,   1,   1,   1
	;0E0AFh
;15 FREE. This bit sets the port to function in emulation or run mode.
;14 SOFT. This bit is enabled when the FREE bit is 0. It determines
;         the emulation mode.
;13 URST  Reset asynchronous serial port bit. URST is used to reset the
;   asynchronous serial port. At reset, URST = 0,=1 The port is enabled.
;9  DIM   Delta interrupt mask.
;8  TIM   Transmit interrupt mask.
;7  RIM   Receive interrupt mask.
;6  STB   Stop bit selector.
;   STB = 0 One stop bit is used in transmission and reception. This is
;           the default value at reset.
;   STB = 1 Two stop bits are used in transmission and reception.
;5  CAD   Calibrate A detect bit. CAD is used to enable and disable
;         automatic baud-rate alignment (auto-baud alignment).
;   CAD = 0 Disables auto-baud alignment.
;   CAD = 1 Enables auto-baud alignment.
;4 SETBRK Set break bit. Selects the output level of TX when the port is
;         not transmitting.
;  SETBRK = 0 The TX output is forced high when the port is not
;         transmitting.
;  SETBRK = 1 The TX output is forced low when the port is not
;         transmitting.
;3-0 CIO3-CIO0  Configuration bit for IO3-IO0. configures I/O pin  as an
;         input or as an output.
; CIOn = 0 IOn is configured as an input.
;         This is the default value at re-set.
; CIOn = 1 IOn is configured as an output.
	OUT  TMP,ASPCR  	;ASPSRA -> ASPCR(IS@0FFF5h)
				;asynchronous serial-port
				;control register(ASPCR)
	SPLK 	#(CIOSR+0FFh),TMP

;CIOSR  06600h
      ;0,ADC,BI,TEMP,THRE,FE,OE,DR,DIO3,DIO2,DIO1,DIO0,IO3,IO2,IO1,IO0
*      0  1   1   0    0   1  1  0   1    1    1    1   1   1   1   1
	OUT  	TMP,IOSR   	; I/O status register
				;IOSR is used for detecting current levels
				;and (changes when inputs) on pins IO0-IO3
				;and status of UART
 .if Reset_BRD=1
	SPLK 	#CBRDR,TMP  	;baud rate generator
	OUT  	TMP,BRD    	;�� CLK   Fuart
				;�� 3,6864���. 9,6kdit/c  BRD=000Ch
				;�� 3,6864���. 19,2kdit/c BRD=0006h
				;�� 3,6864���. 38,4kdit/c BRD=0003h
				;�� 3,6864���. 57,6kdit/c BRD=0002h
 .endif

********************************
*	ZERO TO ALL DATE
********************************
	LACC 	#0
	LAR  	AR2,#060h
	RPT  	#01Fh
	SACL 	*+,0,AR2         	;0060h-007Fh
	LAR  	AR2,#200h
	SPLK 	#01FFh,TMP
	RPT  	TMP
	SACL 	*+,0,AR2         	;0200h-03FFh
	LAR  	AR2,#800h
	SPLK 	#0FFFh,TMP
	RPT  	TMP
	SACL	*+,0,AR2         	;0800h-17FFh

********************************
*	��ࢮ��砫쭠� ��⠭���� ��६�����
*	������騥 ���窨 ��६����(� ⠪ �� ���㫥��)
********************************
	LAR	AR2,#iCNTDISP

*	SPLK 	#CNSTDISP,CNTDISP      ;���� ���������� ��ᯫ�� (���稪)
*	SPLK 	#CNSTREFDISP,CNTDISP+1 ;���� refresh ��ᯫ�� (���稪)
	SPLK 	#CNSTDISP,*+		;���� ���������� ��ᯫ�� (���稪)
	SPLK 	#CNSTREFDISP,*		;���� refresh ��ᯫ�� (���稪)

	LAR	AR2,#iCNTCLK

*	SPLK 	#CNSTCLK,CNTCLK        ;�⮡� ��ਮ� ⠩��� = 1ᥪ.
	SPLK 	#CNSTCLK,*		;�⮡� ��ਮ� ⠩��� = 1ᥪ.

;        SPLK 	#0,CNTKEYB             ;����প� ࠧ�襭�� ���뢠��� �� ������
;        SPLK 	#0,FLAGKEYB            ;���⪠ 䫠�� ������ ������
;        SPLK 	#0,Flags               ;���⪠ 䫠��� ����ᮢ
;        SPLK 	#0,CNTERROR            ;���稪 �뢮�� �訡�� ����塞
;        SPLK 	#0,ERRORS              ;������� �訡�� ���� ���뫮
;        SPLK 	#0,MODEPR              ;���� ��祣� �� ������
	SPLK 	#0FFh,_rDIOSR		;���������� ���ﭨ� IOSR
 .if DebugStop=1
        SPLK	#PRESS_20,_Pclose
	SPLK	#TEN_SECOND,_TempPeriod
        SPLK	#MAX_DURATION*4,_AveragePeriod
        SPLK	#MAX_DURATION*4,_AveragePeriodEvaluation
 .endif
	mOffPeriph                      ;�몫�砥� ��� ������
	mDim_pressure_supply_up_init    ;�����⮢�� ��६����� ��� Pressure_diminition


*
;      FirstMeasFlag = TRUE;

	SPLK	#B0_5mm*2,_SistolPressureAmplitude
	LACC	_MeasurementFlags,0
	OR	#(1<<FIRST_MEAS_FLAG)
	SACL  	_MeasurementFlags,0

*
	SPLK 	#0020h,_DPA0	;��࠭塞 ����� ���� � �����,
					;��� ��᫥���饣� �뢮�� � ����
;����� ����
;   5432109876543210
;   !!!!!!!!!!!!!!!+ - BUZZER
;   !!!!!!!!!!!!!!+  - STR
;   !!!!!!!!!!!!!+   - PUMP
;   !!!!!!!!!!!!+    - VALV1 � १���஬
;   !!!!!!!!!!!+     - VALV2
;   !!!!!!!!!!+      - CEF
;   ++++++++++       - A15-A24

	OUT  	_DPA0,PA0 		;���� ࠡ�� � 䫥� �� ��࠭�
*

	SPLK 	#0000h,_MDSPL       ;�뢮� �६��� �� ��ᯫ��

	LAR  	AR1,#0800h

 .if VersionFerrum=1		;��� �������

 .elseif VersionFerrum=2        ;� ������஬
	CALL	InitFifoAndCache
        MAR	*,AR2
	LAR	AR2,#PageCache
	SPLK	#0FFFFh,*
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
;	mADCPowerDown		;software power down ADC
	.global	_adc_power_down
	call	_adc_power_down,*,AR1
 .if WARNINGLDP=1
	LDP	#4
 .endif

****************
* �� ����祭�� ��⠭�� ��⠭�������� �६�
* � �᫨ ����室���, � ����砥� ������஢����
****************

* ��� ��᫥����⥫쭮� 䫥� ������ 20 ms ��� "�⠡�����樨"
 .if TypeFlash=1		;��᫥����⥫쭠�
	SPLK 	#7FFFh,TMP
	RPT  	TMP		;����প� ��� A/D conversion
	NOP                     ;(N+2)*1542.5347(2)
 .elseif TypeFlash=0        ;��ࠫ���쭠�
* gh
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif


	SPLK	#0,_FLADR
	SPLK	#0,_FLADR+1
	CALL	FLREAD


	CALL	InitScheduler

	mCheckBabyLevel

 .if AVRProcessor=1
        mSendBabyModeToAVR
 .endif

	.global _load_avr_state
        .global _load_avr_time
* �஢��塞 ��� ࠡ�⠥� AVR 
        MAR	* ,AR1
	LALK	AVRProg
	SACL	*+
	CALL	_load_avr_state
	MAR	*-
        BCND	load_avr_state_ok,NEQ
        LDPK    _DispErrMeas
	SPLK	#rAVR_SPI_BAD,_DispErrMeas
load_avr_state_ok:
        LALK	AVRProg
	SACL	*+
	CALL	_load_avr_time
	MAR	*-
        BCND	load_avr_time_ok,NEQ
        LDPK    _DispErrMeas
	SPLK	#rAVR_SPI_BAD,_DispErrMeas
load_avr_time_ok:

 .if WARNINGLDP=1
	LDP	#4
 .endif


;//���뢠�� �� ࠧ 䫠��
	SPLK 	#001Fh,TMP 	;0015H->[TMP]
;	SPLK 	#0015h,TMP 	;0015H->[TMP]
				;(store parallel long immediate)
	OUT  	TMP,ICR    	;0015H -> ICR(IS@0FFECh)
				;interrupt control register
				;             1     1     1     1     1
				;0...,MODE_INT1,FINT3,FINT2,MINT3,MINT2
				;�室 HOLD/INT1 �ࠡ��뢠�� �� ᯠ�� ⮫쪮
				;INT2 ࠧ�襭� � pending

	SPLK 	#0FFFFh,TMP
	RPT  	TMP
	NOP

	RPT  	TMP
	NOP

	MAR	*,AR2

	LAR  	AR2,#IFR        ;load auxiliary reg #IFR -> AR2
				;interrupt flag register
	LACC 	*       	;load accumulator with shift
	NOP
	NOP
	NOP

	SACL 	*       	;pending all interrupts

 .if NewFerrum=1

	MAR	*,AR2
	LAR	AR2,#AVRProg+6
	SPLK	#1600,*


 .endif

 .if Sertificarion=1

	SPLK	#rSertification,_DispErrMeas
 .endif

	CLRC 	INTM 		;ࠧ�襭�� ���뢠���
