* $Id: BPINIT.ASM,v 1.22 2001-10-17 15:50:50 peter Exp $
INIT
	SETC 	INTM 		;запрет прерываний
	LDP  	#4      	;load data memory page pointer
				;блок памяти 0300H-037FH

	SPLK 	#02E06h,TMP
				;02E06H->[TMP]
				;(store parallel long immediate)
				;ARP(15-13),OV,OVM,1,INTM,DP(8-0)
				;       001, 0,  1,1,   1,000000110h
	LST  	#0,TMP      ; load status register #0
	NOP
	NOP
	LDP  	#4      	;load data memory page pointer
				;блок памяти 0300H-037FH
*!!!! временно CNF устанавливаем в 1, общее число было 025FC, стало 035FC
	SPLK 	#025FCh,TMP ;025FCH->[TMP]
				;(store parallel long immediate)
				;ARB(15-13),CNF,TC,SXM,C,1,1,1,1,XF,1,1,PM(1-0)
				;       001,  0, 0,  1,0,1,1,1,1, 1,1,1,00
	LST  	#1,TMP	; load status register #1
;Параметры Interrupt.
        MAR	*,AR2
	LAR  	AR2,#IMR	;load auxiliary reg #IMR -> AR2
	SPLK 	#0027h,*	; 0027H->[AR2==IMR], 0027->IMR(DS@0004h)
*проба
*	SPLK 	#0025h,*
				;Interrupt mask register
				;0(15-6),TXRXINT,XINT,RINT,TINT,INT2(INT3),INT1
				;0      ,1      ,0    0    1   ,1         ,1
				;разрешаем прерывания от
				; - последовательного асинхронного
				; - таймера
				; - int2 (кнопочка)
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
				;вход HOLD/INT1 срабатывает по спаду только
				;INT2 разрешено и pending

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
				;FLASH1 -> запретить
;        OUT  	TMP,FACCES1

*******************************
*   	Параметры таймера.
*******************************
	SPLK 	#CPRD,TMP  	;CPRD->[TMP]
				;При CLK   Fsampl
				;При 3,6864мГц. 200Гц  PRD=023Fh, TDDR=0Fh
				;При 3,6864мГц. 100Гц  PRD=047Fh, TDDR=0Fh
	OUT  	TMP,PRD    	;CPRD -> PRD(IS@0FFF9h)
				;timer period register
	SPLK 	#CTCR,TMP  	;CTCR->[TMP]
	OUT  	TMP,TCR    	;CTCR -> TCR(IS@0FFF8h)
				;timer-control register
				;0,0,0,0,FREE,SOFT,PSC,TRB,TSS,TDDR

********************************
*	Параметры SSP.
********************************
	SPLK 	#SSPR,TMP  	;reset SSP
	OUT  	TMP,SSPCR  	;SSPR -> SSPCR(IS@0FFF1h)
				;synchronous serial-port control register
	IN   	TMP,SDTR   	;[TMP] <- SDTR(IS@0FFF0h)
	IN   	TMP,SDTR   	;synchronous serial-port(SSP)transmit and
	IN   	TMP,SDTR   	;receive  register
	IN   	TMP,SDTR

********************************
*	Параметры ASP.
********************************
	SPLK 	#ASPR,TMP	;reset ASP
	OUT  	TMP,ASPCR  	;ASPSRA -> ASPCR(IS@0FFF5h)
				;asynchronous serial-port
				;control register(ASPCR)
	SPLK 	#ASPSRA,TMP	;Enable receiver A
				;и прием символов вообще
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
	OUT  	TMP,BRD    	;При CLK   Fuart
				;При 3,6864мГц. 9,6kdit/c  BRD=000Ch
				;При 3,6864мГц. 19,2kdit/c BRD=0006h
				;При 3,6864мГц. 38,4kdit/c BRD=0003h
				;При 3,6864мГц. 57,6kdit/c BRD=0002h
 .endif

********************************
*	ZERO TO ALL DATE
********************************
	LACC 	#0
	LAR  	AR2,#060h
	RPT  	#01Fh
	SACL 	*+,AR2         	;0060h-007Fh
	LAR  	AR2,#200h
	SPLK 	#01FFh,TMP
	RPT  	TMP
	SACL 	*+,AR2         	;0200h-03FFh
	LAR  	AR2,#800h
	SPLK 	#0FFFh,TMP
	RPT  	TMP
	SACL	*+,AR2         	;0800h-17FFh

********************************
*	первоначальная установка переменных
*	обнуляющие строчки заремлены(и так все занулено)
********************************
	LAR	AR2,#iCNTDISP

*	SPLK 	#CNSTDISP,CNTDISP      ;частота обновления дисплея (счетчик)
*	SPLK 	#CNSTREFDISP,CNTDISP+1 ;частота refresh дисплея (счетчик)
	SPLK 	#CNSTDISP,*+		;частота обновления дисплея (счетчик)
	SPLK 	#CNSTREFDISP,*		;частота refresh дисплея (счетчик)

	LAR	AR2,#iCNTCLK

*	SPLK 	#CNSTCLK,CNTCLK        ;чтобы период таймера = 1сек.
	SPLK 	#CNSTCLK,*		;чтобы период таймера = 1сек.

;        SPLK 	#0,CNTKEYB             ;задержка разрешения прерывания от кнопки
;        SPLK 	#0,FLAGKEYB            ;очистка флага нажатия кнопки
;        SPLK 	#0,Flags               ;очистка флагов процессов
;        SPLK 	#0,CNTERROR            ;счетчик вывода ошибки обнуляем
;        SPLK 	#0,ERRORS              ;никаких ошибок пока небыло
;        SPLK 	#0,MODEPR              ;пока ничего не делаем
	SPLK 	#0FFh,_rDIOSR		;запоминаем состояние IOSR
	mOffPeriph                      ;выключаем всю периферию
	mDim_pressure_supply_up_init    ;подготовка переменных для Pressure_diminition


*
;      FirstMeasFlag = TRUE;

	SPLK	#B0_5mm,SistolPressureAmplitude
	LACC	MeasurementFlags,0
	OR	#(1<<FIRST_MEAS_FLAG)
	SACL  	MeasurementFlags,0

*
	SPLK 	#0020h,_DPA0	;сохраняем данные порта в памяти,
					;для последующего вывода в порт
;данные порта
;   5432109876543210
;   !!!!!!!!!!!!!!!+ - BUZZER
;   !!!!!!!!!!!!!!+  - STR
;   !!!!!!!!!!!!!+   - PUMP
;   !!!!!!!!!!!!+    - VALV1 с резистором
;   !!!!!!!!!!!+     - VALV2
;   !!!!!!!!!!+      - CEF
;   ++++++++++       - A15-A24

	OUT  	_DPA0,PA0 		;пока работа с флеш не выбрана
*

	SPLK 	#0000h,_MDSPL       ;вывод времени на дисплей

	LAR  	AR1,#0800h

 .if VersionFerrum=1		;без дешифратора

 .elseif VersionFerrum=2        ;с дешифратором
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
* при включении питания устанавливаем время
* и если необходимо, то включаем мониторирование
****************

* для последовательной флеш минимум 20 ms для "стабилизации"
 .if TypeFlash=1		;последовательная
	SPLK 	#7FFFh,TMP
	RPT  	TMP		;задержка для A/D conversion
	NOP                     ;(N+2)*1542.5347(2)
 .elseif TypeFlash=0        ;параллельная
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
* проверяем как работает AVR 
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


;//сбрасываем еще раз флаги
	SPLK 	#001Fh,TMP 	;0015H->[TMP]
;	SPLK 	#0015h,TMP 	;0015H->[TMP]
				;(store parallel long immediate)
	OUT  	TMP,ICR    	;0015H -> ICR(IS@0FFECh)
				;interrupt control register
				;             1     1     1     1     1
				;0...,MODE_INT1,FINT3,FINT2,MINT3,MINT2
				;вход HOLD/INT1 срабатывает по спаду только
				;INT2 разрешено и pending

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

	CLRC 	INTM 		;разрешение прерываний
