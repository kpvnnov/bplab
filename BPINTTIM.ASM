****************************************************************************
*       Таймер частоты дискретизации - 200Гц.
* $Id: BPINTTIM.ASM,v 1.18 2001-03-26 15:02:27 zykov Exp $
****************************************************************************

INTTIM
	mPush_stack		;сохранение вычислительных
				;регистров в стеке

	LDP  	#4
	MAR  	*,AR1      	;modify auxiliary register
				;данная команда из подмножества LARP 1
				;т.е. при дальнейшей записи индексом AR1
	LAR  	AR1,#IFR   	;загружаем указатель на Interrupt
				;Flag Register
	SPLK 	#04h,*     	;Time Interrupt pending


	MAR	*,AR1
	LAR	AR1,#AVRProg+6
	LACC	*
	SUB	#1
	SACL	*
	BCND	NoPowerDown,GT
	SPLK	#1600,*
	LAR	AR1,#AVRProg
	SPLK	#1,*+
	SPLK	#1101h,*		;SystemState
;	CALL	SendCommandAVR
NoPowerDown
*** отладка
*	MAR	*,AR1
*	LAR	AR1,#AVRProg
*	SPLK	#1,*+
*	SPLK	#0000h,*		;SystemState
*	CALL	SendCommandAVR

****

	BIT 	Jobs,8
	BCND 	NoAdc,NTC
	CALL 	ADCPRO
;	if (((MeasurementFlags )&( 1<<DIM_PRESSURE_FLAG )) == ( 1<<DIM_PRESSURE_FLAG ));
;          { Pressure_diminition_2(); }
	BIT	MeasurementFlags,15-DIM_PRESSURE_FLAG
	BCND 	NoAdc,NTC
	CALL	Pressure_diminition_2
NoAdc:
	BIT 	Jobs,15-BeepLittle_Flag     	;пищать
	BCND 	NoBeep,NTC
	mBeepEnd
 .if AVRProcessor=1
	MAR	*,AR1
	LAR	AR1,#AVRProg
	SPLK	#1,*+
	SPLK	#0BB01h,*		;SetBuzzer
	CALL	SendCommandAVR
 .else
	SPLK 	#10,CNTBEEP
 .endif

NoBeep

**************************
* длинный писк
**************************
	BIT  	Jobs,15-BeepLong_Flag
	BCND 	NootLongBeeping,NTC
 .if AVRProcessor=1
	mBeepLongEnd
	MAR	*,AR1
	LAR	AR1,#AVRProg
	SPLK	#1,*+
	SPLK	#0BB07h,*		;SetBuzzer
	CALL	SendCommandAVR
 .endif
NootLongBeeping
* окончание блока длинного писка
************************************

	LACC 	CNTBEEP
	BCND	NoCountBeep,EQ
	SUB  	#1
	SACL 	CNTBEEP
	mBeeper_xor		;инвертируем значение бита бипера
NoCountBeep

*отладка
*	LACC	DelayTransmit
*	BCND	NoStartTransmit,EQ
*	SUB	#1
*	SACL	DelayTransmit
*	BCND	NoStartTransmit,NEQ

*	SPLK 	#00h,WhatDoingReceve
*	SPLK 	#ASPST,TMP
;0E10F
;FREE,SOFT,URST,0,0,0,DIM,TIM,RIM,STB,CAD,SETBRK,CIO3,CIO2,CIO1,CIO0
;   1,   1,   1,0,0,0,  0,  1,  0,  0,  0,     0,   1,   1,   1,   1
;пишем в CAD "0",разрешаем прерывания передачи
*	OUT  	TMP,ASPCR 	;Параметры ASP. Enable transmit

*NoStartTransmit
* конец отладки
********************************
* 	слежка за работой
*	асинхронного последовательного порта (ASP)
* если долго в "отстое", то переводим
* в режим "автопилота"
********************************
	BIT 	Jobs,13     	;последовательный порт работает ?
	BCND 	PortNotJob,NTC 	;нет, не работает. проверять не будем
	MAR  	*,AR1      	;modify auxiliary register
	LAR	AR1,#iCNTASP
*	LACC 	CNTASP,0
	LACC 	*,0
	SUB  	#1         	;Декрементация счетчика
*	SACL 	CNTASP,0
	SACL 	*,0
	BCND 	PortNotJob,NEQ 	;пока еще не достигли нуля
	SPLK 	#0h,MDSPL  	;выводим на экран время
	LACC 	Jobs,0
	AND  	#0FFFBh
	SACL 	Jobs     	;порт на "автопилоте" ;)
********************************
* выводим порт на "автоприем"
********************************
* 24.06.00
	IN   	TMP,ADTR   	;если что-то есть во входном буфере - читаем

	SPLK 	#ASPSRA,TMP	;Enable receiver A и прием символов вообще
	OUT  	TMP,ASPCR  	;ASPSRA -> ASPCR(IS@0FFF5h)
				;asynchronous serial-port
				;control register(ASPCR)
	LACC 	rDIOSR
	AND  	#0FFH
	OR   	#CIOSR
	SACL 	TMP
;        SPLK 	#CIOSR,TMP
;CIOSR  06600h
      ;0,ADC,BI,TEMP,THRE,FE,OE,DR,DIO3,DIO2,DIO1,DIO0,IO3,IO2,IO1,IO0
*      0  1   1   0    0   1  1  0   1    1    1    1   1   1   1   1
	OUT  	TMP,IOSR   	;I/O status register
				;IOSR is used for detecting current
				;levels and (changes when inputs) on
				;pins IO0-IO3 and status of UART
* 24.06.00
	IN   	TMP,ADTR   	;если что-то есть во входном буфере - читаем

 .if Reset_BRD=1
	SPLK 	#CBRDR,TMP  	;baud rate generator
	OUT  	TMP,BRD    	;При CLK   Fuart
				;При 3,6864мГц. 9,6kdit/c  BRD=000Ch
				;При 3,6864мГц. 19,2kdit/c BRD=0006h
				;При 3,6864мГц. 38,4kdit/c BRD=0003h
				;При 3,6864мГц. 57,6kdit/c BRD=0002h
 .endif
PortNotJob
* конец блока слежения за последовательным портом (ASP)
********************************

;=========================bpmode

	BIT     Jobs,15			;процесс измерения идет?
	BCND    NetIzmereniya,NTC


*	BIT     Jobs,7			;пишем во флеш ?
*	BCND	NetIzmereniya1,NTC
*	CALL	MakeValue
*NetIzmereniya1

	BIT     Jobs,5			;motor on?
	BCND	NotPumping,NTC

	LACC	Motor+2
	SUB	#1
	SACL	Motor+2

	LACC	Motor
	AND	#01Fh		;не больше 31 ступеньки
	ADD	#Motor_Table
	TBLR 	TMP

	LACC	Motor+2
	BCND	motor_mode_1_1,GT
	LACC	TMP
motor_mode_1_1
	SACL    Motor+2
	SUB	#2
	BCND	motor_mode_on,LEQ
	mMotor_off_f
	B	CheckNextRegim
Motor_Table
	.word	3	;0	2/4	= 50  %
	.word	2       ;1      2/2     = 40  %
	.word	6       ;2	3/6	= 50  %
	.word	7       ;3	3/7	= 42.9%
	.word	8       ;4	3/8     = 37.5%
	.word	9       ;5	3/9  	= 33.3%
	.word	10      ;6	3/10 	= 30  %
	.word	11      ;7	3/7
	.word	12      ;8	3/7
	.word	13      ;9	3/7
	.word	14      ;10	3/7
	.word	15      ;11	3/7
	.word	16      ;12	3/7
	.word	17      ;13	3/7
	.word	18      ;14	3/7
	.word	19      ;15	3/7
	.word	20      ;16	3/7
	.word	21      ;17	3/7
	.word	22      ;18	3/7
	.word	23      ;19	3/7
	.word	24      ;20	3/7
	.word	25      ;11	3/7
	.word	26      ;22	3/7
	.word	27      ;23	3/7
	.word	28      ;24	3/7
	.word	29      ;25	3/7
	.word	30      ;26	3/7
	.word	31      ;27	3/7
	.word	32      ;28	3/7
	.word	33      ;29	3/7
	.word	34      ;30	3/7
	.word	35      ;31	3/35 	=8.5%

motor_mode_on
	mMotor_on_f

CheckNextRegim
	LACC    Motor
	BCND	NotPumping,LEQ
	LACC	Motor+1
	BCND	ToNextRegim,LEQ
	SUB	#1
	SACL	Motor+1
	B	NotPumping
ToNextRegim
	LACC	Motor
	SUB	#1
	SACL	Motor
	SPLK	#33,Motor+1
NotPumping


	LAR	AR1,#iCNTCLK
	MAR	*,AR1

*	BIT  	CNTCLK,15  		;каждое второе прерывание
	BIT  	*,15  		;каждое второе прерывание
	BCND 	CallValueProcessing,TC

	CALL	Main

	B 	NetIzmereniya
CallValueProcessing

 .if Emulator=1
	LACC	massiv
	ADD  	#Izmerenie,0
	TBLR 	TMP
	LACC	massiv
	ADD	#1
	SACL	massiv
	LACC	TMP
	MAR     *,AR1
	LAR     AR1,#Signal
	LAR     AR0,SampleNumber
	MAR     *0+,AR1
	SACL    *,0
	CALL	ADC_value_processing
 .else
	SETC	SXM
	LACC	OUTF
	SUB	Preset0
	MAR     *,AR1
	LAR     AR1,#Signal
	LAR     AR0,SampleNumber
	MAR     *0+,AR1
	SACL    *,0
	CALL	ADC_value_processing
	BIT     Jobs,7			;пишем во флеш ?
	BCND	NetIzmereniya,NTC
	CALL	MakeValue
 .endif
NetIzmereniya



;=========================bpmode

********************************
* слежка за прерыванием, возникающем
* при нажатии на кнопку
* в этом прерывании (INTKEY) они маскируются
* а через некоторое время их надо разрешить (размаскировать)
**
* слежка за прерыванием, возникающем
* при снижении питания
* в этом прерывании (INTU) они маскируются
* а через некоторое время их надо разрешить (размаскировать)
********************************

	MAR  	*,AR1      	;modify auxiliary register
				;данная команда из подмножества LARP 1
				;т.е. при дальнейшей записи индексом AR1
	LAR	AR1,#iCNTKEYB
	LACC 	*,0
	BCND 	NoEnable,EQ
	SUB  	#1         	;Декрементация счетчика разрешения
				;прерывания от кнопки
	SACL 	*,0

	BCND 	NoEnable,NEQ
	LAR  	AR1,#IMR   	;загружаем указатель на Interrupt Mask Register
	LACC 	*          	;load accumulator with shift
	OR   	#02h       	;устанавливаем маску INT2
				;(разрешаем эти прерывания)
	SACL 	*          	;store mask interrupts
	IN	TMP,ICR
	LACC	TMP
	AND  	#0FFF7h    	;чтобы не затронуть pending FINT3,
				;его бит обнуляем
	SACL	TMP
	OUT	TMP,ICR

	LAR  	AR1,#IFR   	;загружаем указатель на Interrupt Flag Register
	SPLK 	#02h,*     	;pending INT2
				;pending flag interrupts
NoEnable
	LAR	AR1,#iCNTKEYB+1
	LACC 	*,0
	BCND 	NoEnable1,EQ
	SUB  	#1         	;Декрементация счетчика разрешения
				;прерывания от кнопки
	SACL 	*,0
	BCND 	NoEnable1,NEQ
	LAR  	AR1,#IMR   	;загружаем указатель на Interrupt Mask Register
	LACC 	*          	;load accumulator with shift
	OR   	#01h       	;устанавливаем маску INT1
				;(разрешаем эти прерывания)
	SACL 	*          	;store mask interrupts
	LAR  	AR1,#IFR	;загружаем указатель на Interrupt Flag Register
	MAR  	*,AR1      	;modify auxiliary register
				;данная команда из подмножества LARP 1
				;т.е. при дальнейшей записи индексом AR1
	SPLK 	#01h,*     	;pending INT1
NoEnable1
* конец блока слежки за прерыванием кнопки
********************************


********************************
* работа с часами
*
	LAR	AR1,#iCNTCLK
	MAR	*,AR1

*	LACC 	CNTCLK,0      	;Таймер часов
	LACC 	*,0      	;Таймер часов
	SUB  	#1		;Декрементация програмного таймера
*	SACL 	CNTCLK,0
	SACL 	*,0
	BCND 	ENDTIME,GEQ     ;Если таймер < 0, то загрузка таймера

*	SPLK 	#CNSTCLK,CNTCLK ;чтобы период таймера = 1сек.
	SPLK 	#CNSTCLK,* 	;чтобы период таймера = 1сек.


*********************
* sheduler
**
*****************************
* декрементация всяких переменных
* (чаще с проверкой доходит ли до нуля)
 .newblock
	MAR  	*,AR1
*******
	LAR  	AR1,#CounterToBegin
	LACC	*
	BCND	$1,EQ
	SUB	#1
	SACL	*
$1
********
	LAR  	AR1,#CounterFastToBegin
	LACC	*
	BCND	$2,EQ
	SUB	#1
	SACL	*
$2
********
	LAR  	AR1,#ProtectInterval
	LACC	*
	BCND	$3,EQ
	SUB	#1
	SACL	*
$3
************************
* следим, когда последний раз меряли давление
	LAR  	AR1,#LastMeas
	LACC	*
	BCND	EnsShpion3min,EQ
	SUB	#1
	SACL	*
EnsShpion3min

 .newblock




	BIT     Jobs,6			;sheduler on?
	BCND	EndSheduler,NTC
	BIT     Jobs,15			;процесс измерения идет?
	BCND    EndSheduler,TC         ;да идет
	MAR  	*,AR1
	LAR  	AR1,#CounterToBegin

	LACC	*,0		;единицы секунд
	BCND    SCHEnd,NEQ

	LAR  	AR1,#ProtectInterval	;защитный интервал?
	LACC	*
	BCND	SCHEnd,NEQ

;	BeepLong
	Beep

	CALL    KEY10_1
*	LACC    PressureCode		;устанавливваем уровень накачки
*	SACL	PressureTop
	B	EndSheduler
SCHEnd

*	SUB	#6
*	BCND	EndSheduler,GEQ
*	Beep

EndSheduler
************************


**отладка
	LACC MDSPL
	SUB #3 ; если на экране вывод давления
	BCND NoPress1Chanal,NEQ
	SendToDAC
*	BeepLong
NoPress1Chanal
**
**отладка
;        LACC MDSPL
;        BCND ItIsNoTime,NEQ
;        LACC Jobs
;        OR   #02h     ;кончаем баловаться
;        SACL Jobs
;ItIsNoTime
***
;        LACC Jobs
;        AND   #0FFFDh     ;кончаем баловаться
;        SACL Jobs
	MAR  	*,AR1      	;modify auxiliary register
				;данная команда из подмножества LARP 1
				;т.е. при дальнейшей записи индексом AR1
	LAR  	AR1,#WATCH

 .if ShowBeginTime=1

	BIT     Jobs,6			;sheduler on?
	BCND	NotfingBlank,NTC
	LACC	MDSPL
	BCND	ItIsTime,EQ
	SUB	#13
	BCND    NotfingBlank,NEQ
ItIsTime
	LACC	*
	AND	#07h
	BCND	OnnWaiting,EQ
	LACC	*
	AND	#03h
	BCND	NotfingBlank,NEQ
	SPLK	#0,MDSPL
	B	NotfingBlank
OnnWaiting
	SPLK	#13,MDSPL

NotfingBlank

 .elseif ShowBeginTime=0
 .else
   .emsg _ERROR __ MISSING PARAMETER_
 .endif

*----------------
	LACC 	*,0
	ADD  	#1
	SACL 	*,0
	SUB  	#10
	BCND 	CLK001,LT	;Если счетчик секунд !=60,то
	SPLK 	#0,*+ 		;переход к концу обработки часов
*
	LACC 	*,0
	ADD  	#1
	SACL 	*,0
	SUB  	#6
	BCND 	CLK001,LT 	;Если счетчик секунд !=60,то
	SPLK 	#0,*+        ;переход к концу обработки часов
*
	CALL	Add1minutetoWatch
CLK001
 .if Sertificarion=1
* если сертификационная версия, то заодно увеличиваем время
* тестовых часов
	LAR  	AR1,#TestTime
	LACC 	*,0
	ADD  	#1
	SACL 	*,0
	SUB  	#10
	BCND 	CLKSERT001,LT	;Если счетчик  !=10,то
	SPLK 	#0,*+
*
	LACC 	*,0
	ADD  	#1
	SACL 	*,0
	SUB  	#6
	BCND 	CLKSERT001,LT 	;Если счетчик секунд !=60,то
	SPLK 	#0,*+
*
	LACC 	*,0          ;а если =60, то инкрементация минут
	ADD  	#1              ;единиц минут
	SACL 	*,0
	SUB  	#10
	BCND 	CLKSERT001,LT 	;
	SPLK 	#0,*+
*
	LACC 	*,0		;десятков минут
	ADD  	#1
	SACL 	*,0
	SUB  	#6
	BCND 	CLKSERT001,LT 	;
	SPLK 	#0,*+
CLKSERT001


 .endif ;Sertificarion

************************
 .if Sertificarion=1
* если сертификационная версия, то проверяем, необходимо ли включать
* режим хода тестовых
	MAR	*,AR6
	LAR	AR6,#TestTime+4
	LACC	*
	BCND	NoTestTime,EQ
	SUB	#1
	BCND	BeginTestTime,EQ
	SUB	#6		;пять секунды задержка включения тестового режима
	BCND	WaitThreeSecond,LEQ
	SUB	#1
	BCND	WaitEndOfTestTimeReg,EQ
;непонятный тестовый режим
	SPLK	#0,*
	B	NoTestTime
BeginTestTime
	Beep
	B	WaitThreeSecond_1
WaitThreeSecond
	BCND	WaitThreeSecond_1,NEQ
	Beep
WaitThreeSecond_1
	LACC	*
	ADD	#1
	SACL	*
	LAR	AR6,#TestTime
	LACC	#0
	SACL	*+
	SACL	*+
	SACL	*+
	SACL	*+
	SPLK	#1,MDSPL	;вывод времени на дисплей с секундами
	B	NoTestTime
WaitEndOfTestTimeReg
	LAR	AR6,#TestTime+3
	LACC	*-
	SUB	#1
	BCND    NoTestTime,NEQ
	LACC	*-
	SUB	#5
	BCND	NoTestTime,NEQ
	LACC	*-
	BCND	NoTestTime,NEQ
	LACC	*-
	BCND	NoTestTime,NEQ
	Beep
	LAR	AR6,#TestTime+4
	SPLK	#0,*
	B	NoTestTime

NoTestTime
 .endif 	;Sertificarion


ENDTIME

	LACC	CountResult
	BCND	NotDisplayed,EQ
	SUB  	#1
	SACL    CountResult
	BCND	NotDisplayed,NEQ
	LACC	MDSPL
	SUB	#iSYSTOL_PRESSURE
	BCND	NotDisplayed,LT
	SUB	#iDIASTOL_PRESSURE-iSYSTOL_PRESSURE
	BCND	NotDisplayed,GT
	BCND	NotLastDisplayed,NEQ
*	SPLK	#0,MDSPL
	SPLK	#iSYSTOL_PRESSURE,MDSPL
	mWait_Display_Meas
	LACC    CountResult+1
	BCND	OffResult,EQ
	SUB     #1
	SACL	CountResult+1
	B	NotDisplayed
OffResult
	SPLK 	#0h,MDSPL
	B	NotDisplayed
NotLastDisplayed
	LACC	MDSPL
	ADD	#1
	SACL	MDSPL
	mWait_Display_Meas
NotDisplayed
*не очень критичные (по началу времени относительно прерывания таймера)
*процедурки
	MAR	*,AR6
	LAR	AR6,#iCNTERROR
*	LACC CNTERROR,0
	LACC *,0
	BCND COUNTERR,NEQ 	;счетчик не равен нулю?
	;счетчик равен нулю - проверяем флаги ошибок
	LACC 	DispErrMeas,0
	BCND ENDCOUNTERR,EQ ;если ошибок нет,
			    ;то страшных надписей не выводим
	ADD	#ERRORS_TABLE
	TBLR 	TMP
	LACC	TMP,8
	SACH	ZERROR
	BeepLong
	MAR	*,AR6
	LAR	AR6,#iCNTERROR
*	SPLK 	#CNTERRDISPL,CNTERROR
	SPLK 	#CNTERRDISPL,*
	SPLK 	#5h,MDSPL
	SPLK	#0,DispErrMeas
	B    ENDCOUNTERR
COUNTERR     ;да, мы еще считаем вывод ошибки
	SUB  	#1
*	SACL CNTERROR,0
	SACL 	*,0

	BCND ERRNOZERO,NEQ ;счетчик еще не стал равен нулю?
	;счетчик ошибки стал равен нулю - переводим вывод на часы
	LACC 	MDSPL
	SUB	#5
	BCND	ENDCOUNTERR,NEQ
	SPLK 	#0h,MDSPL
ERRNOZERO
ENDCOUNTERR


************************
* вывод на экран (дисплей)
************************
	MAR  	*,AR1      	;modify auxiliary register
				;данная команда из подмножества LARP 1
				;т.е. при дальнейшей записи индексом AR1

 .if DisableDisplay=1
	BIT 	Jobs,13     	;последовательный порт работает ?
	BCND 	ENDDISPLAY,TC 	;работает. печатать не будем
 .elseif DisableDisplay=0
* gh
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif


	LAR	AR1,#iCNTDISP

*	LACC 	CNTDISP,0
	LACC 	*,0
	SUB  	#1
*	SACL 	CNTDISP,0
	SACL 	*,0
	BCND 	ENDDISPLAY,GT
*	SPLK 	#CNSTDISP,CNTDISP     ;частота обновления дисплея (счетчик)
	SPLK 	#CNSTDISP,*		;частота обновления дисплея (счетчик)	LACC 	MDSPL,1		;Подготовка символов дисплея

	LACC 	MDSPL,1
	ADD  	#MDSPLV,0
	CALA
	CALL 	MODIFSB

	LACC 	MDSPL,0
	SUB  	#2
	BCND 	ENDPOINTSEC,GEQ ;выводим "не" часы?

	LAR	AR1,#iCNTCLK
	LAR	AR6,#iDISPL
	MAR	*,AR1

*	LACC	CNTCLK,1
	LACC	*,1,AR6
	SUB	#CNSTCLK

*	BIT  	CLK0,15    	;выводим секундную точку
*	BCND 	ENDPOINTSEC,TC

	BCND 	ENDPOINTSEC,GEQ
	LACC 	#080h,0
*	XOR  	DISPL
*	SACL 	DISPL
	XOR  	*
	SACL 	*+

 .if ShowSecondPoint=1
	BIT     Jobs,6			;меряем
	BCND	ENDPOINTSEC,NTC
	LACC 	#080h,0
	XOR  	*
	SACL 	*
 .endif

ENDPOINTSEC

*******************************
*смена полярности для LCD
*******************************
	MAR  	*,AR1      	;modify auxiliary register
				;данная команда из подмножества LARP 1
				;т.е. при дальнейшей записи индексом AR1
	LAR	AR1,#iCNTDISP+1
*	LACC 	CNTDISP+1,0  	;уменьшаем счетчик рефреша
	LACC 	*,0  	;уменьшаем счетчик рефреша
	SUB  	#1
*	SACL 	CNTDISP+1,0
	SACL 	*,0
	BCND 	ENDREFRESH,NEQ  ;refresh пока не делаем (ACC!=0)
	LAR	AR6,#iDISPL

*	SPLK 	#CNSTREFDISP,CNTDISP+1
				;частота refresh дисплея (счетчик)
	SPLK 	#CNSTREFDISP,*,AR6
				;частота refresh дисплея (счетчик)
*	LACC 	DISPL          	;производим refresh
	LACC 	*          	;производим refresh
	CMPL
*	SACL 	DISPL
	SACL 	*+
*	LACC 	DISPL+1
	LACC 	*
	CMPL
*	SACL 	DISPL+1
	SACL    *
ENDREFRESH

	CALL 	DISPLAY    	;вывод ячеек памяти индикатора на дисплей
				;восстановление счетчика
ENDDISPLAY
* конец блока вывода на дисплей
************************

	mPop_stack		;восстановление вычислительных регистров
				;из стека
	CLRC 	INTM   		;разрешение прерываний при выходе из
				;прерывания
	RET

*********
* преобразование времени минуты, десятки минут в секунды
* AR6 - указатель на две ячейки, содержащие минуты и десятки минут
* ACC - результат
*  ==1 ошибка интервала
*********

Hour2BIN
	;([AR6+1]*10   +[AR6])*60
	;([AR6+1]*(8+2)+[AR6])*60
	MAR	*,AR6
	LACC	*+
	SUB	#9
	BCND	ErrorMinute,GT	;количество единиц минут >9
	LACC	*
	SUB	#9
	BCND	ErrorMinute,GT	;количество десяток минут >9
	LACC 	*,3
	ADD	*-,1		;ACC=[AR6+1]*(8+2)
	ADD	*               ;ACC=([AR6+1]*(8+2)+[AR6])
	SACL	TMP

	SPM	#0
	LT      TMP
	MPY     #60
	PAC
	RET

ErrorMinute
	LACC	#1
	RET

*********
* записывает текущее время в формате сек, мин(BCD), час по указателю AR6
* use ACC,AR5
*********
SaveTimeOfBeginMeas
	MAR  	*,AR5      	;modify auxiliary register
	LAR  	AR5,#WATCH+1

	LACC 	*,3
	ADD  	*-,1
	ADD  	*+,AR6       	;посчитали количество секунд
	SACL    *+,AR5          ;записали в [AR6]

	MAR	*+,AR5
	LACC 	*+	     	;единицы минут
	ADD  	*+,4,AR6		;десятки минут
	SACL    *+,AR5          ;записали в [AR6]

	LACC 	*+		;единицы часов
	ADD  	*+,4,AR6	;десятки часов
	SACL    *+,AR5	        ;записали в [AR6]

	LACC 	*+,AR6		;номер суток
	SACL 	*+		;номер суток записали в [AR6]



	RET

*******************
* проверяет время на валидность
* время по указателю AR6
* формат единицы минут, десятки минут, единицы часов, десятки часов
* ACC=0 все OK

CheckTime
	MAR	*,AR6
	LACC	*+
	SUB	#9
	BCND	ErrorCheck,GT	;количество единиц минут >9
	LACC	*+
	SUB	#5
	BCND	ErrorCheck,GT	;количество десяток минут >5
	LACC	*
	SUB	#9
	BCND	ErrorCheck,GT	;количество единиц минут >9
	LACC	*+
	SUB	#3
	BCND	CheckHour,GT	;количество единиц минут >3
				;десятки минут должны быть 0-1

	LACC	*
	SUB	#2		;в противном случае может быть 0-2
	BCND	ErrorCheck,GT	;количество единиц минут >1
	LACC	#0
	RET

CheckHour
	LACC	*
	SUB	#1
	BCND	ErrorCheck,GT	;количество единиц минут >1
	LACC	#0
ErrorCheck
	RET
***************
* устанавливает системное время на время инициализации
* use ar1,ar2
**************
SetWatchToInit
	MAR     *,AR7
	POPD	*-
	SAR     AR2,*-

	SPLK	#0,FLADR+1
;по данному адресу находится Время инициализации
*    4 байта - Минуты - единицы, десятки
*              Часы   - единицы, десятки,
*              В двоичном коде
	SPLK	#0200h+TimeInitSh,FLADR

	LAR	AR2,#WATCH+2
	;устанавливаем время (смещение + TimeInitSh)
	CALL	FLREAD
	MAR	*,AR2
	AND	#0Fh
	SACL	*+,AR1		;начинаем с единиц минут

	CALL	FLREAD
	MAR	*,AR2
	AND	#0Fh
	SACL	*+,AR1		;десятки минут

	CALL	FLREAD
	MAR	*,AR2
	AND	#0Fh
	SACL	*+,AR1          ;единицы часов

	CALL	FLREAD
	MAR	*,AR2
	AND	#0Fh
	SACL	*+,AR2          ;десятки часов

	SPLK	#0,*		;номер суток


	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR2,*+
	PSHD	*
	RET
*************
* устанавливаем системное время на время в tmp
* (находится запись в формате измерения)
*************
SetWatchRecordTime
	MAR     *,AR7
	POPD	*-

	MAR	*,AR1
	LAR	AR1,#WATCH+2
	LACC	TMP+1
	AND	#0Fh
	SACL	*+		;единицы минут
;//проверяем запись на валидность
	SUB	#9
	BCND	ClearSetRecordTime,GT

	LACC	TMP+1,12
	AND	#00F0H,12
	SACH	*		;десятки минут
;//проверяем запись на валидность
	LACC	*+
	SUB	#5
	BCND	ClearSetRecordTime,GT

	LACC	TMP+2
	AND	#0Fh
	SACL	*		;единицы часов
;//проверяем запись на валидность
	LACC	*+
	SUB	#9
	BCND	ClearSetRecordTime,GT

	LACC	TMP+2,12
	AND	#00F0H,12
	SACH	*		;десятки часов
;//проверяем запись на валидность
	LACC	*
	SUB	#9
	BCND	ClearSetRecordTime,GT
;//теперь надо посчитать количество суток

	MAR	*,AR7
	LACC	TMP+2
	AND	#0Fh
	SACL	*

	MAR	*,AR1

	SPM  	#0              ;Set P Register Output Shift Mode
				;multiplier output is left-shifted one place

	SPM	#0
	LT      *+
	MPY     #10
	PAC

	SPLK	#0,*	;попутно обнуляем количество суток

	MAR	*,AR7
	ADD	*
	SACL	*
	SUB	#24
	BCND	ClearSetRecQuit,LT	;если не переваливает, то выходим

	MAR	*,AR1
	LACC	*
	ADD	#1	;увеличиваем количество суток
	SACL	*

	MAR	*,AR7
	LACC	*
	SUB	#48
	BCND	ClearSetRecCompute,LT	;если не переваливает, то выходим

	MAR	*,AR1
	LACC	*
	ADD	#1	;увеличиваем количество суток
	SACL	*

	MAR	*,AR7
	LACC	*
	SUB	#72
	BCND	ClearSetRecCompute,LT	;если не переваливает, то выходим

	MAR	*,AR1
	LACC	*
	ADD	#1	;увеличиваем количество суток
	SACL	*

	MAR	*,AR7
	LACC	*
	SUB	#96
	BCND	ClearSetRecCompute,LT	;если не переваливает, то выходим

	MAR	*,AR1
	LACC	*
	ADD	#1	;увеличиваем количество суток
	SACL	*

ClearSetRecCompute
	MAR	*,AR1

	SPM	#0
	LT      *-
	MPY     #24

	MAR	*,AR7
	LACC	*-
	SPAC		;ACC-PREG

	CALL	ConvertBCD2BIN
	MAR	*+,AR7

	SACL	*
	LACC	*,12,AR1
	AND	#00F0H,12
	SACH	*-,AR7		;десятки часов

	LACC	*,AR1
	AND	#00FH
	SACL	*


ClearSetRecQuit
	MAR	*,AR7
	MAR	*+,AR7
	PSHD	*
	RET

ClearSetRecordTime
	mResetTime
	B	ClearSetRecQuit

;//преобразуем число в двоично десятичную системы
;//из бинарного числа, с проверкой до 24
ConvertBCD2BIN
	MAR     *,AR7
	POPD	*-

	SACL	*
	SUB	#10
	BCND	AlreadyConverted,LT

	LACC	*
	SUB	#20
	BCND	Converted10hours,LT
	ADD	#20h
	B	ConvertBCDQuit

Converted10hours
	LACC	*
	SUB	#10
	ADD	#10h
	SACL	*
AlreadyConverted
	LACC	*

ConvertBCDQuit
	MAR	*,AR7
	MAR	*+,AR7
	PSHD	*
	RET

* преобразование бинарного к двоично-десятичному виду
ConvertBIN2BCD
	MAR     *,AR7
	POPD	*-

	SPLK	#0,*-
	SACL	*

Converted10_1
	SUB	#10
	BCND	Converted10,LT
	SACL	*+
	LACC	*
	ADD	#10h
	SACL	*-
	LACC	*
	B	Converted10_1
Converted10
	LACC	*+
	ADD	*

;	MAR	*,AR7
	MAR	*+,AR7
	PSHD	*
	RET

* преобразование двоично-десятичного к бинарному  виду
ConvertBCD2BIN_
	MAR     *,AR7
	POPD	*-

	SPM	#0
	SACL	*
	LACC	*-,12		;выделяем старшую букву в байте
	AND	#0F0h,12
	SACH	*

	LT      *+
	MPY     #10		;умножаем на 10
				;результат в PREG

	LACC	*		;выделяем младшую букву в байте
	AND	#0Fh

;	PAC
	APAC			;складываем все это хозяйство

	MAR	*,AR7
	MAR	*+,AR7
	PSHD	*
	RET

************************
* добавляем к системному времени минуту
************************
Add1minutetoWatch
	MAR	*,AR1
	LAR	AR1,#WATCH+2
	LACC 	*,0          ;а если =60, то инкрементация минут
	ADD  	#1              ;единиц минут
	SACL 	*,0
	SUB  	#10
	RETC	LT
	SPLK 	#0,*+
*
	LACC 	*,0		;десятков минут
	ADD  	#1
	SACL 	*,0
	SUB  	#6
	RETC	LT
	SPLK 	#0,*+
*
	LACC 	*,0          ;единиц часов
	ADD  	#1
	SACL 	*,0
	SUB  	#10
	BCND 	CLK24,LT
	SPLK 	#0,*+
*
	LACC 	*,0          ;десятков часов
	ADD  	#1
	SACL 	*-,0

CLK24   MAR	*+,AR1
	LACC 	*-,4          ;Проверка на 24 часа
	OR   	*
	SUB  	#24h
	RETC	LT
	SPLK 	#0,*+
	SPLK 	#0,*+
	LACC	*
	ADD	#1
	SACL	*
	RET

ReadAllInterval
	MAR     *,AR7
	POPD	*-

******
* чтение дневного интервала
****
	SPLK	#0,FLADR+1
	SPLK	#0200h+IntervalDayLightSh,FLADR

	LAR     AR6,#TMP

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR6
	SACL	*+,0,AR1

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR6
	SACL	*+
	LAR     AR6,#TMP
	;преобразование времени минуты, десятки минут в секунды
	CALL	Hour2BIN
	LAR	AR6,#DayTimeInter
	SACL	*

******
* чтение ночного интервала
****
	SPLK	#0200h+IntervalDayNightSh,FLADR

	LAR     AR6,#TMP

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR6
	SACL	*+,0,AR1

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR6
	SACL	*+
	LAR     AR6,#TMP
	;преобразование времени минуты, десятки минут в секунды
	CALL	Hour2BIN
	LAR	AR6,#DayTimeInter+1
	SACL	*
******
* чтение специального интервала
****
	SPLK	#0200h+IntervalSpecSh,FLADR

	LAR     AR6,#TMP

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR6
	SACL	*+,0,AR1

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR6
	SACL	*+
	LAR     AR6,#TMP
	;преобразование времени минуты, десятки минут в секунды
	CALL	Hour2BIN
	LAR	AR6,#DayTimeInter+2
	SACL	*

	MAR	*,AR7
	MAR	*+,AR7
	PSHD	*
	RET

*******************************************************
* tmp+1 возвращает результат
CheckScheduler:
	MAR     *,AR7
	POPD	*-
        B	CheckIntervals	;!!! внимание, брэнч в другую процедуру

InitScheduler:
	MAR     *,AR7
	POPD	*-

	;здесь собраны все процедуры загрузки
	;параметров в память
	mLoadAllParametrs

	CALL	GetFlashCount
	BCND	Init_NetIzmereni,EQ
	SUB	#1
	CALL	GetRecordFlash
	CALL	SetWatchRecordTime
	CALL	Add1minutetoWatch
	CALL	GetFlashCount
	CLRC	SXM
	LACC	TMP+1
	XOR	#0FFFEh
	BCND	Init_On_Sheduler,NEQ
	B	Init_End_Preset
Init_NetIzmereni
	SPLK	#1,ShedulerReady
	B	Init_End_Preset

Init_On_Sheduler
	mOn_Interval

	mSetInterval3min
Init_End_Preset

CheckIntervals:
	MAR	*,AR6
	LAR	AR6,#WATCH+2
	CALL	CheckTime
	BCND	TimeOkey,EQ
	mResetTime
	mOff_Interval
	SPLK	#0,ShedulerReady
	SPLK	DispErrMeas,rMONITOR_NOT_PROGRAMM
TimeOkey
*************************************
* проверка интервалов измерения прибора
	LAR	AR6,#DayTimeInter
	MAR	*,AR6
	LACC	*+
	SUB	#3
	BCND	Interval_error,LT
	LACC	*+
	SUB	#3
	BCND	Interval_error,LT
	LACC	*
	SUB	#3
	BCND	Interval_ok,GEQ
Interval_error
	mOff_Interval
	SPLK	#0,ShedulerReady
	SPLK	DispErrMeas,rMONITOR_NOT_PROGRAMM
Interval_ok
*конец проверки интервалов
************************************
* проверка программирования детского режима
;изначально считаем, что
;команда не может быть выполнена из-за запрещенного сочетания параметров
;программирования
	SPLK	#0AAh,TMP+1
	MAR  	*,AR6
	LAR	AR6,#MayModify+1
	SPLK	#05Ah,*		;по умолчанию на детский режим
;по данному адресу находится Age
* Возраст Менее 14  лет - считается ребенком
	SPLK	#0,FLADR+1
	SPLK	#0200h+Age,FLADR
	CALL	FLREAD
;	AND	#0FFH
	SACL	TMP+2
;по данному адресу находится ChildMode
* Детский/взрослый 5Ah - детский A5h - взрослый
	SPLK	#0,FLADR+1
	SPLK	#0200h+ChildMode,FLADR
	CALL	FLREAD
;	AND	#0FFH
	SACL	TMP
	XOR	#05Ah
	BCND	Child_OK,EQ	;детский режим валиден
	XOR	#0FFh
	BCND	Child_OK,EQ	;взрослый режим валиден
Age_False:
	mOff_Interval
	SPLK	#0,ShedulerReady
	SPLK	DispErrMeas,rMONITOR_NOT_PROGRAMM
	B	Child_Check_OK
Child_OK:
	LACC	TMP+2		;проверяем возраст пациента
	SUB	#14
	;если он меньше 14, надо проверить байтовую
	;установку детского режима
	BCND	CheckChildSet,LT
	;иначе это взрослый режим
	LACC	TMP
	XOR	#0A5h
	BCND	Age_False,NEQ
	SPLK	#0h,TMP+1	;прибор запрограммирован на взрослый режим
	MAR  	*,AR6
	LAR	AR6,#MayModify+1
	SPLK	#0A5h,*		;взрослый режим
	B	ChildAge_Check_OK
CheckChildSet:
	;проверяем байтовую установку детского режима
	LACC	TMP
	XOR	#05Ah
	BCND	Age_False,NEQ
	SPLK	#066h,TMP+1	;прибор запрограммирован на детский режим
;	B	ChildAge_Check_OK

ChildAge_Check_OK:
Child_Check_OK:
* конец проверки программирования детского режима

* проверяем бит разрешения звукового сигнала
	mOffSound

	SPLK	#0,FLADR+1
	SPLK	#0200h+ParametrsSh,FLADR
	CALL	FLREAD
        SACL	TMP
	AND	#01h
        BCND	NoEnableSound,EQ
        mOnSound
NoEnableSound:
*конец проверки бита разрешения

* проверка бита разрешения выдачи результатов
	mOffResult

        LACC	TMP
	AND	#02h
        BCND	NoEnableResult,EQ
        mOnResult
NoEnableResult:
* конец проверки бита разрешения выдачи результатов

	MAR	*,AR7
	MAR	*+,AR7
	PSHD	*
	RET

CheckBabyLevel:
	;по умолчанию детский режим
	SPLK    #PRESS_160-08000h,PrevPressureLevel

	MAR  	*,AR1
	LAR	AR1,#MayModify+1
	LACC	*
	SUB	#0A5h		;взрослый режим
	BCND	ItIsBigMan,EQ
	SPLK    #PRESS_130-08000h,PrevPressureLevel
ItIsBigMan:
	RET
