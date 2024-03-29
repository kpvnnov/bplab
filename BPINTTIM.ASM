;&D
****************************************************************************
*       ������ ����� ����⨧�樨 - 200��.
* $Id: BPINTTIM.ASM,v 1.33 2002-08-13 11:43:13 zykov Exp $
****************************************************************************

INTTIM
	mPush_stack		;��࠭���� ���᫨⥫���
				;ॣ���஢ � �⥪�

	LDP  	#4
	MAR  	*,AR2      	;modify auxiliary register
				;������ ������� �� ���������⢠ LARP 1
				;�.�. �� ���쭥�襩 ����� �����ᮬ AR2
	LAR  	AR2,#IFR   	;����㦠�� 㪠��⥫� �� Interrupt
				;Flag Register
	SPLK 	#04h,*     	;Time Interrupt pending


	MAR	*,AR2
	LAR	AR2,#AVRProg+6
	LACC	*
	SUB	#1
	SACL	*
	BCND	NoPowerDown,GT
	SPLK	#1600,*
	LAR	AR2,#AVRProg
	SPLK	#1,*+
	SPLK	#1101h,*		;SystemState
;	CALL	SendCommandAVR
NoPowerDown
*** �⫠���
*	MAR	*,AR2
*	LAR	AR2,#AVRProg
*	SPLK	#1,*+
*	SPLK	#0000h,*		;SystemState
*	CALL	SendCommandAVR

****

	BIT 	_Jobs,8
	BCND 	NoAdc,NTC
	CALL 	ADCPRO
;	if (((MeasurementFlags )&( 1<<DIM_PRESSURE_FLAG )) == ( 1<<DIM_PRESSURE_FLAG ));
;          { Pressure_diminition_2(); }
	BIT	_MeasurementFlags,15-DIM_PRESSURE_FLAG
	BCND 	NoAdc,NTC
	CALL	Pressure_diminition_2
NoAdc:
	BIT 	_Jobs,15-BeepLittle_Flag     	;�����
	BCND 	NoBeep,NTC
	mBeepEnd
 .if AVRProcessor=1
	MAR	*,AR2
	LAR	AR2,#AVRProg
	SPLK	#1,*+
	SPLK	#0BB01h,*		;SetBuzzer
	CALL	SendCommandAVR
 .else
	SPLK 	#10,CNTBEEP
 .endif

NoBeep

**************************
* ������ ���
**************************
	BIT  	_Jobs,15-BeepLong_Flag
	BCND 	NootLongBeeping,NTC
 .if AVRProcessor=1
	mBeepLongEnd
	MAR	*,AR2
	LAR	AR2,#AVRProg
	SPLK	#1,*+
	SPLK	#0BB07h,*		;SetBuzzer
	CALL	SendCommandAVR
 .endif
NootLongBeeping
* ����砭�� ����� �������� ��᪠
************************************

	LACC 	CNTBEEP
	BCND	NoCountBeep,EQ
	SUB  	#1
	SACL 	CNTBEEP
	mBeeper_xor		;�������㥬 ���祭�� ��� �����
NoCountBeep

*�⫠���
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
;��襬 � CAD "0",ࠧ�蠥� ���뢠��� ��।��
*	OUT  	TMP,ASPCR 	;��ࠬ���� ASP. Enable transmit

*NoStartTransmit
* ����� �⫠���
********************************
* 	᫥��� �� ࠡ�⮩
*	�ᨭ�஭���� ��᫥����⥫쭮�� ���� (ASP)
* �᫨ ����� � "���⮥", � ��ॢ����
* � ०�� "��⮯����"
********************************
        BIT 	_Jobs,13     	;��᫥����⥫�� ���� ࠡ�⠥� ?
	BCND 	PortNotJob,NTC 	;���, �� ࠡ�⠥�. �஢����� �� �㤥�
	MAR  	*,AR2      	;modify auxiliary register
	LAR	AR2,#_iCNTASP
	LACC 	*,0
	SUB  	#1         	;���६����� ���稪�
	SACL 	*,0
	BCND 	PortNotJob,NEQ 	;���� �� �� ���⨣�� ���
	SPLK 	#0h,_MDSPL  	;�뢮��� �� ��࠭ �६�
	LACC 	_Jobs,0
	AND  	#0FFFBh
	SACL 	_Jobs     	;���� �� "��⮯����" ;)
********************************
* �뢮��� ���� �� "��⮯ਥ�"
********************************
* 24.06.00
	IN   	TMP,ADTR   	;�᫨ ��-� ���� �� �室��� ���� - �⠥�

	SPLK 	#ASPSRA,TMP	;Enable receiver A � �ਥ� ᨬ����� �����
	OUT  	TMP,ASPCR  	;ASPSRA -> ASPCR(IS@0FFF5h)
				;asynchronous serial-port
				;control register(ASPCR)
	LACC 	_rDIOSR
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
	IN   	TMP,ADTR   	;�᫨ ��-� ���� �� �室��� ���� - �⠥�

 .if Reset_BRD=1
	SPLK 	#CBRDR,TMP  	;baud rate generator
	OUT  	TMP,BRD    	;�� CLK   Fuart
				;�� 3,6864���. 9,6kdit/c  BRD=000Ch
				;�� 3,6864���. 19,2kdit/c BRD=0006h
				;�� 3,6864���. 38,4kdit/c BRD=0003h
				;�� 3,6864���. 57,6kdit/c BRD=0002h
 .endif
PortNotJob
* ����� ����� ᫥����� �� ��᫥����⥫�� ���⮬ (ASP)
********************************

;=========================bpmode

	BIT     _Jobs,15			;����� ����७�� ����?
	BCND    NetIzmereniya,NTC


*	BIT     _Jobs,7			;��襬 �� 䫥� ?
*	BCND	NetIzmereniya1,NTC
*	CALL	MakeValue
*NetIzmereniya1

	BIT     _Jobs,5			;motor on?
	BCND	NotPumping,NTC

	LACC	Motor+2
	SUB	#1
	SACL	Motor+2

	LACC	Motor
	AND	#01Fh		;�� ����� 31 ��㯥�쪨
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

 .if DebugStop=1

	.global	_check_range
	call	_check_range,*,AR1
 .if WARNINGLDP=1
	LDP	#4
 .endif
	BCND	ok_range,EQ
	LAR  	AR2,#TimeOfBeginMeas
	MAR	*,AR2
        SACL	*
	mEnd_error_meas rCHECK_RANGE_ERROR
ok_range:
 .endif

	LAR	AR2,#iCNTCLK
	MAR	*,AR2

	BIT  	*,15  		;������ ��஥ ���뢠���
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
	MAR     *,AR2
	LAR     AR2,#Signal
	LAR     AR0,_SampleNumber
	MAR     *0+,AR2
	SACL    *,0
	CALL	ADC_value_processing
 .else
	SETC	SXM
	LACC	_OUTF
	SUB	Preset0
	MAR     *,AR2
	LAR     AR2,#Signal
	LAR     AR0,_SampleNumber
	MAR     *0+,AR2
	SACL    *,0
	CALL	ADC_value_processing
	BIT     _Jobs,7			;��襬 �� 䫥� ?
	BCND	NetIzmereniya,NTC
	CALL	MakeValue
 .endif
NetIzmereniya



;=========================bpmode

********************************
* ᫥��� �� ���뢠����, ��������饬
* �� ����⨨ �� ������
* � �⮬ ���뢠��� (INTKEY) ��� ��᪨������
* � �१ �����஥ �६� �� ���� ࠧ���� (ࠧ��᪨஢���)
**
* ᫥��� �� ���뢠����, ��������饬
* �� ᭨����� ��⠭��
* � �⮬ ���뢠��� (INTU) ��� ��᪨������
* � �१ �����஥ �६� �� ���� ࠧ���� (ࠧ��᪨஢���)
********************************

	MAR  	*,AR2      	;modify auxiliary register
				;������ ������� �� ���������⢠ LARP 1
				;�.�. �� ���쭥�襩 ����� �����ᮬ AR2
	LAR	AR2,#iCNTKEYB
	LACC 	*,0
	BCND 	NoEnable,EQ
	SUB  	#1         	;���६����� ���稪� ࠧ�襭��
				;���뢠��� �� ������
	SACL 	*,0

	BCND 	NoEnable,NEQ
	LAR  	AR2,#IMR   	;����㦠�� 㪠��⥫� �� Interrupt Mask Register
	LACC 	*          	;load accumulator with shift
	OR   	#02h       	;��⠭�������� ���� INT2
				;(ࠧ�蠥� �� ���뢠���)
	SACL 	*          	;store mask interrupts
	IN	TMP,ICR
	LACC	TMP
	AND  	#0FFF7h    	;�⮡� �� ���஭��� pending FINT3,
				;��� ��� ����塞
	SACL	TMP
	OUT	TMP,ICR

	LAR  	AR2,#IFR   	;����㦠�� 㪠��⥫� �� Interrupt Flag Register
	SPLK 	#02h,*     	;pending INT2
				;pending flag interrupts
NoEnable
	LAR	AR2,#iCNTKEYB+1
	LACC 	*,0
	BCND 	NoEnable1,EQ
	SUB  	#1         	;���६����� ���稪� ࠧ�襭��
				;���뢠��� �� ������
	SACL 	*,0
	BCND 	NoEnable1,NEQ
	LAR  	AR2,#IMR   	;����㦠�� 㪠��⥫� �� Interrupt Mask Register
	LACC 	*          	;load accumulator with shift
	OR   	#01h       	;��⠭�������� ���� INT1
				;(ࠧ�蠥� �� ���뢠���)
	SACL 	*          	;store mask interrupts
	LAR  	AR2,#IFR	;����㦠�� 㪠��⥫� �� Interrupt Flag Register
	MAR  	*,AR2      	;modify auxiliary register
				;������ ������� �� ���������⢠ LARP 1
				;�.�. �� ���쭥�襩 ����� �����ᮬ AR2
	SPLK 	#01h,*     	;pending INT1
NoEnable1
* ����� ����� ᫥��� �� ���뢠���� ������
********************************


********************************
* ࠡ�� � �ᠬ�
*
	LAR	AR2,#iCNTCLK
	MAR	*,AR2

*	LACC 	CNTCLK,0      	;������ �ᮢ
	LACC 	*,0      	;������ �ᮢ
	SUB  	#1		;���६����� �ணࠬ���� ⠩���
*	SACL 	CNTCLK,0
	SACL 	*,0
	BCND 	ENDTIME,GEQ     ;�᫨ ⠩��� < 0, � ����㧪� ⠩���

*	SPLK 	#CNSTCLK,CNTCLK ;�⮡� ��ਮ� ⠩��� = 1ᥪ.
	SPLK 	#CNSTCLK,* 	;�⮡� ��ਮ� ⠩��� = 1ᥪ.


*********************
* sheduler
**
*****************************
* ���६����� ��直� ��६�����
* (�� � �஢�મ� ��室�� �� �� ���)
 .newblock
	MAR  	*,AR2
*******
	LAR  	AR2,#CounterToBegin
	LACC	*
	BCND	$1,EQ
	SUB	#1
	SACL	*
$1
********
	LAR  	AR2,#CounterFastToBegin
	LACC	*
	BCND	$2,EQ
	SUB	#1
	SACL	*
$2
********
	LAR  	AR2,#ProtectInterval
	LACC	*
	BCND	$3,EQ
	SUB	#1
	SACL	*
$3
************************
* ᫥���, ����� ��᫥���� ࠧ ���﫨 ��������
	LAR  	AR2,#LastMeas
	LACC	*
	BCND	EnsShpion3min,EQ
	SUB	#1
	SACL	*
EnsShpion3min

 .newblock




	BIT     _Jobs,6			;sheduler on?
	BCND	EndSheduler,NTC
	BIT     _Jobs,15			;����� ����७�� ����?
	BCND    EndSheduler,TC         ;�� ����
	MAR  	*,AR2
	LAR  	AR2,#CounterToBegin

	LACC	*,0		;������� ᥪ㭤
	BCND    SCHEnd,NEQ

	LAR  	AR2,#ProtectInterval	;����� ���ࢠ�?
	LACC	*
	BCND	SCHEnd,NEQ

;	BeepLong
	Beep

	CALL    KEY10_1
*	LACC    PressureCode		;��⠭��������� �஢��� ����窨
*	SACL	PressureTop
	B	EndSheduler
SCHEnd

*	SUB	#6
*	BCND	EndSheduler,GEQ
*	Beep

EndSheduler
************************


**�⫠���
	LACC _MDSPL
	SUB #3 ; �᫨ �� ��࠭� �뢮� ��������
	BCND NoPress1Chanal,NEQ
	SendToDAC
*	BeepLong
NoPress1Chanal
**
**�⫠���
;        LACC _MDSPL
;        BCND ItIsNoTime,NEQ
;        LACC _Jobs
;        OR   #02h     ;���砥� ����������
;        SACL _Jobs
;ItIsNoTime
***
;        LACC _Jobs
;        AND   #0FFFDh     ;���砥� ����������
;        SACL _Jobs
	MAR  	*,AR2      	;modify auxiliary register
				;������ ������� �� ���������⢠ LARP 1
				;�.�. �� ���쭥�襩 ����� �����ᮬ AR2
	LAR  	AR2,#_WATCH

 .if ShowBeginTime=1

	BIT     _Jobs,6			;sheduler on?
	BCND	NotfingBlank,NTC
	LACC	_MDSPL
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
	SPLK	#0,_MDSPL
	B	NotfingBlank
OnnWaiting
	SPLK	#13,_MDSPL

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
	BCND 	CLK001,LT	;�᫨ ���稪 ᥪ㭤 !=60,�
	SPLK 	#0,*+ 		;���室 � ����� ��ࠡ�⪨ �ᮢ
*
	LACC 	*,0
	ADD  	#1
	SACL 	*,0
	SUB  	#6
	BCND 	CLK001,LT 	;�᫨ ���稪 ᥪ㭤 !=60,�
	SPLK 	#0,*+        ;���室 � ����� ��ࠡ�⪨ �ᮢ
*
	CALL	Add1minutetoWatch
CLK001
 .if Sertificarion=1
* �᫨ ���䨪�樮���� �����, � ������ 㢥��稢��� �६�
* ��⮢�� �ᮢ
	LAR  	AR2,#TestTime
	LACC 	*,0
	ADD  	#1
	SACL 	*,0
	SUB  	#10
	BCND 	CLKSERT001,LT	;�᫨ ���稪  !=10,�
	SPLK 	#0,*+
*
	LACC 	*,0
	ADD  	#1
	SACL 	*,0
	SUB  	#6
	BCND 	CLKSERT001,LT 	;�᫨ ���稪 ᥪ㭤 !=60,�
	SPLK 	#0,*+
*
	LACC 	*,0          ;� �᫨ =60, � ���६����� �����
	ADD  	#1              ;������ �����
	SACL 	*,0
	SUB  	#10
	BCND 	CLKSERT001,LT 	;
	SPLK 	#0,*+
*
	LACC 	*,0		;����⪮� �����
	ADD  	#1
	SACL 	*,0
	SUB  	#6
	BCND 	CLKSERT001,LT 	;
	SPLK 	#0,*+
CLKSERT001


 .endif ;Sertificarion

* ᫥��� �� uart, �⮡� ࠭�� �६��� � ���� �� �室��
	MAR	*,AR7
        LAR	AR7,#_iCNTASP+1
        LACC	*
        BCND	Already_UART_ended,EQ
        SUB	#1
        SACL	*
	B	Uart_decremented
        ;�� �६�, ���� ��頥��� � UART
        ;���� ������� �⢫������� � ⠩��୮� ���뢠��� �� �����

Already_UART_ended:

 .if WriteDebug==0

; � �⮬ ����� ᫥��� �� AVR_TIME �� ���� ����७��
; �᫨ AVR ���㬠�� "��������" ����७�� ࠭�� ���
; � ⠪�� ��ࠧ�� �������஢��� �ਡ��, � �� ����⠥��� ���।��� ���


* �⫠���
;       MAR	* ,AR1
;	LALK	AVRProg
;	SACL	*+
;	.global _load_avr_state
;	CALL	_load_avr_state
;	MAR	*-,AR7
* ����� �⫠���


        MAR	* ,AR1
	LALK	AVRProg
	SACL	*+
	.global _load_avr_time
	CALL	_load_avr_time
        MAR	*-,AR7
  .if WARNINGLDP=1
	LDP	#4
  .endif

        BCND	time_loaded,NEQ		;�᫨ ��楤�� ���㫠 0, � �� �����-� ��稭�
        				;����� �� 㤠���� - avaria

	BIT     _Jobs,15			;����� ����७�� ����?
	BCND    ne_idet_izmer,NTC

        mEnd_error_meas	rAVR_SPI_BAD
	CALL	Measurment_finish

ne_idet_izmer:
	SPLK	#rAVR_SPI_BAD,_DispErrMeas
        B	NetIdet

time_loaded:

        LAR	AR7,#AVRProg
        LACC	*
        AND	#0FFh
        SUB	#115
;        SUB	#60			;��� ०��� �⫠���
        BCND	NoWarningStop,LT

	BIT     _Jobs,15			;����� ����७�� ����?
	BCND    NetIdet,NTC

	mEnd_error_meas	rAVR_TIME_BAD

	CALL	Measurment_finish

NetIdet:
	mMotor_off
	mValve_off
	EndADC
	PowerAnalogOff
	End_measurement

NoWarningStop:

 .endif

Uart_decremented:


************************
 .if Sertificarion=1
* �᫨ ���䨪�樮���� �����, � �஢��塞, ����室��� �� �������
* ०�� 室� ��⮢��
	MAR	*,AR7
	LAR	AR7,#TestTime+4
	LACC	*
	BCND	NoTestTime,EQ
	SUB	#1
	BCND	BeginTestTime,EQ
	SUB	#6		;���� ᥪ㭤� ����প� ����祭�� ��⮢��� ०���
	BCND	WaitThreeSecond,LEQ
	SUB	#1
	BCND	WaitEndOfTestTimeReg,EQ
;�������� ��⮢� ०��
	SPLK	#0,*
	B	NoTestTime
BeginTestTime
;	Beep
	B	WaitThreeSecond_1
WaitThreeSecond
	BCND	WaitThreeSecond_1,NEQ
	Beep
WaitThreeSecond_1
	LACC	*
	ADD	#1
	SACL	*
	LAR	AR7,#TestTime
	LACC	#0
	SACL	*+
	SACL	*+
	SACL	*+
	SACL	*+
	SPLK	#1,_MDSPL	;�뢮� �६��� �� ��ᯫ�� � ᥪ㭤���
	B	NoTestTime
WaitEndOfTestTimeReg
	LAR	AR7,#TestTime+3
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
	LAR	AR7,#TestTime+4
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
	LACC	_MDSPL
	SUB	#iSYSTOL_PRESSURE
	BCND	NotDisplayed,LT
	SUB	#iDIASTOL_PRESSURE-iSYSTOL_PRESSURE
	BCND	NotDisplayed,GT
	BCND	NotLastDisplayed,NEQ
*	SPLK	#0,_MDSPL
	SPLK	#iSYSTOL_PRESSURE,_MDSPL
	mWait_Display_Meas
	LACC    CountResult+1
	BCND	OffResult,EQ
	SUB     #1
	SACL	CountResult+1
	B	NotDisplayed
OffResult
	SPLK 	#0h,_MDSPL
	B	NotDisplayed
NotLastDisplayed
	LACC	_MDSPL
	ADD	#1
	SACL	_MDSPL
	mWait_Display_Meas
NotDisplayed
*�� �祭� ����� (�� ��砫� �६��� �⭮�⥫쭮 ���뢠��� ⠩���)
*��楤�ન
	MAR	*,AR7
	LAR	AR7,#iCNTERROR
*	LACC CNTERROR,0
	LACC *,0
	BCND COUNTERR,NEQ 	;���稪 �� ࠢ�� ���?
	;���稪 ࠢ�� ��� - �஢��塞 䫠�� �訡��
	LACC 	_DispErrMeas,0
	BCND ENDCOUNTERR,EQ ;�᫨ �訡�� ���,
			    ;� ������ �����ᥩ �� �뢮���
	ADD	#ERRORS_TABLE
	TBLR 	TMP
	LACC	TMP,8
	SACH	ZERROR
	BeepLong
	MAR	*,AR7
	LAR	AR7,#iCNTERROR
*	SPLK 	#CNTERRDISPL,CNTERROR
	SPLK 	#CNTERRDISPL,*
	SPLK 	#5h,_MDSPL
	SPLK	#0,_DispErrMeas
	B    ENDCOUNTERR
COUNTERR     ;��, �� �� ��⠥� �뢮� �訡��
	SUB  	#1
*	SACL CNTERROR,0
	SACL 	*,0

	BCND ERRNOZERO,NEQ ;���稪 �� �� �⠫ ࠢ�� ���?
	;���稪 �訡�� �⠫ ࠢ�� ��� - ��ॢ���� �뢮� �� ���
	LACC 	_MDSPL
	SUB	#5
	BCND	ENDCOUNTERR,NEQ
	SPLK 	#0h,_MDSPL
ERRNOZERO
ENDCOUNTERR


************************
* �뢮� �� ��࠭ (��ᯫ��)
************************
	MAR  	*,AR2      	;modify auxiliary register
				;������ ������� �� ���������⢠ LARP 1
				;�.�. �� ���쭥�襩 ����� �����ᮬ AR2

 .if DisableDisplay=1
	BIT 	_Jobs,13     	;��᫥����⥫�� ���� ࠡ�⠥� ?
	BCND 	ENDDISPLAY,TC 	;ࠡ�⠥�. ������ �� �㤥�
 .elseif DisableDisplay=0
* gh
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif


	LAR	AR2,#iCNTDISP

*	LACC 	CNTDISP,0
	LACC 	*,0
	SUB  	#1
*	SACL 	CNTDISP,0
	SACL 	*,0
	BCND 	ENDDISPLAY,GT
*	SPLK 	#CNSTDISP,CNTDISP     ;���� ���������� ��ᯫ�� (���稪)
	SPLK 	#CNSTDISP,*		;���� ���������� ��ᯫ�� (���稪)	

	LACC 	_MDSPL,1
	ADD  	#MDSPLV,0
	CALA
	CALL 	MODIFSB

	LACC 	_MDSPL,0
	SUB  	#2
	BCND 	ENDPOINTSEC,GEQ ;�뢮��� "��" ���?

	LAR	AR2,#iCNTCLK
	LAR	AR7,#iDISPL
	MAR	*,AR2

*	LACC	CNTCLK,1
	LACC	*,1,AR7
	SUB	#CNSTCLK

*	BIT  	CLK0,15    	;�뢮��� ᥪ㭤��� ���
*	BCND 	ENDPOINTSEC,TC

	BCND 	ENDPOINTSEC,GEQ
	LACC 	#080h,0
*	XOR  	DISPL
*	SACL 	DISPL
	XOR  	*
	SACL 	*+

 .if ShowSecondPoint=1
	BIT     _Jobs,6			;���塞
	BCND	ENDPOINTSEC,NTC
	LACC 	#080h,0
	XOR  	*
	SACL 	*
 .endif

ENDPOINTSEC

*******************************
*ᬥ�� ����୮�� ��� LCD
*******************************
	MAR  	*,AR2      	;modify auxiliary register
				;������ ������� �� ���������⢠ LARP 1
				;�.�. �� ���쭥�襩 ����� �����ᮬ AR2
	LAR	AR2,#iCNTDISP+1
*	LACC 	CNTDISP+1,0  	;㬥��蠥� ���稪 ����
	LACC 	*,0  	;㬥��蠥� ���稪 ����
	SUB  	#1
*	SACL 	CNTDISP+1,0
	SACL 	*,0
	BCND 	ENDREFRESH,NEQ  ;refresh ���� �� ������ (ACC!=0)
	LAR	AR7,#iDISPL

*	SPLK 	#CNSTREFDISP,CNTDISP+1
				;���� refresh ��ᯫ�� (���稪)
	SPLK 	#CNSTREFDISP,*,AR7
				;���� refresh ��ᯫ�� (���稪)
*	LACC 	DISPL          	;�ந������ refresh
	LACC 	*          	;�ந������ refresh
	CMPL
*	SACL 	DISPL
	SACL 	*+
*	LACC 	DISPL+1
	LACC 	*
	CMPL
*	SACL 	DISPL+1
	SACL    *
ENDREFRESH

	CALL 	DISPLAY    	;�뢮� �祥� ����� �������� �� ��ᯫ��
				;����⠭������� ���稪�
ENDDISPLAY
* ����� ����� �뢮�� �� ��ᯫ��
************************

	mPop_stack		;����⠭������� ���᫨⥫��� ॣ���஢
				;�� �⥪�
	CLRC 	INTM   		;ࠧ�襭�� ���뢠��� �� ��室� ��
				;���뢠���
	RET

*********
* �८�ࠧ������ �६��� ������, ����⪨ ����� � ᥪ㭤�
* AR7 - 㪠��⥫� �� ��� �祩��, ᮤ�ঠ騥 ������ � ����⪨ �����
* ACC - १����
*  ==1 �訡�� ���ࢠ��
*********

Hour2BIN
	;([AR7+1]*10   +[AR7])*60
	;([AR7+1]*(8+2)+[AR7])*60
	MAR	*,AR7
	LACC	*+
	SUB	#9
	BCND	ErrorMinute,GT	;������⢮ ������ ����� >9
	LACC	*
	SUB	#9
	BCND	ErrorMinute,GT	;������⢮ ����⮪ ����� >9
	LACC 	*,3
	ADD	*-,1		;ACC=[AR7+1]*(8+2)
	ADD	*               ;ACC=([AR7+1]*(8+2)+[AR7])
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
* �����뢠�� ⥪�饥 �६� � �ଠ� ᥪ, ���(BCD), �� �� 㪠��⥫� AR7
* use ACC,AR6
*********
SaveTimeOfBeginMeas
	MAR  	*,AR6      	;modify auxiliary register
	LAR  	AR6,#_WATCH+1

	LACC 	*,3
	ADD  	*-,1
	ADD  	*+,AR7       	;����⠫� ������⢮ ᥪ㭤
	SACL    *+,AR6          ;����ᠫ� � [AR7]

	MAR	*+,AR6
	LACC 	*+	     	;������� �����
	ADD  	*+,4,AR7		;����⪨ �����
	SACL    *+,AR6          ;����ᠫ� � [AR7]

	LACC 	*+		;������� �ᮢ
	ADD  	*+,4,AR7	;����⪨ �ᮢ
	SACL    *+,AR6	        ;����ᠫ� � [AR7]

	LACC 	*+,AR7		;����� ��⮪
	SACL 	*+		;����� ��⮪ ����ᠫ� � [AR7]



	RET

*******************
* �஢���� �६� �� ����������
* �६� �� 㪠��⥫� AR7
* �ଠ� ������� �����, ����⪨ �����, ������� �ᮢ, ����⪨ �ᮢ
* ACC=0 �� OK

CheckTime
	MAR	*,AR7
	LACC	*+
	SUB	#9
	BCND	ErrorCheck,GT	;������⢮ ������ ����� >9
	LACC	*+
	SUB	#5
	BCND	ErrorCheck,GT	;������⢮ ����⮪ ����� >5
	LACC	*
	SUB	#9
	BCND	ErrorCheck,GT	;������⢮ ������ ����� >9
	LACC	*+
	SUB	#3
	BCND	CheckHour,GT	;������⢮ ������ ����� >3
				;����⪨ ����� ������ ���� 0-1

	LACC	*
	SUB	#2		;� ��⨢��� ��砥 ����� ���� 0-2
	BCND	ErrorCheck,GT	;������⢮ ������ ����� >1
	LACC	#0
	RET

CheckHour
	LACC	*
	SUB	#1
	BCND	ErrorCheck,GT	;������⢮ ������ ����� >1
	LACC	#0
ErrorCheck
	RET
***************
* ��⠭�������� ��⥬��� �६� �� �६� ���樠����樨
* use AR2,AR3
**************
SetWatchToInit
	MAR     *,AR1
	POPD	*+
	SAR     AR3,*+

	SPLK	#0,_FLADR+1
;�� ������� ����� ��室���� �६� ���樠����樨
*    4 ���� - ������ - �������, ����⪨
*              ����   - �������, ����⪨,
*              � ����筮� ����
	SPLK	#0200h+TimeInitSh,_FLADR

	LAR	AR3,#_WATCH+2
	;��⠭�������� �६� (ᬥ饭�� + TimeInitSh)
	CALL	FLREAD
	MAR	*,AR3
	AND	#0Fh
	SACL	*+,AR2		;��稭��� � ������ �����

	CALL	FLREAD
	MAR	*,AR3
	AND	#0Fh
	SACL	*+,AR2		;����⪨ �����

	CALL	FLREAD
	MAR	*,AR3
	AND	#0Fh
	SACL	*+,AR2          ;������� �ᮢ

	CALL	FLREAD
	MAR	*,AR3
	AND	#0Fh
	SACL	*+,AR3          ;����⪨ �ᮢ

	SPLK	#0,*		;����� ��⮪


	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR3,*-
	PSHD	*
	RET
*************
* ��⠭�������� ��⥬��� �६� �� �६� � tmp
* (��室���� ������ � �ଠ� ����७��)
*************
SetWatchRecordTime
	MAR     *,AR1
	POPD	*+

	MAR	*,AR2
	LAR	AR2,#_WATCH+2
	LACC	TMP+1
	AND	#0Fh
	SACL	*+		;������� �����
;//�஢��塞 ������ �� ����������
	SUB	#9
	BCND	ClearSetRecordTime,GT

	LACC	TMP+1,12
	AND	#00F0H,12
	SACH	*		;����⪨ �����
;//�஢��塞 ������ �� ����������
	LACC	*+
	SUB	#5
	BCND	ClearSetRecordTime,GT

	LACC	TMP+2
	AND	#0Fh
	SACL	*		;������� �ᮢ
;//�஢��塞 ������ �� ����������
	LACC	*+
	SUB	#9
	BCND	ClearSetRecordTime,GT

	LACC	TMP+2,12
	AND	#00F0H,12
	SACH	*		;����⪨ �ᮢ
;//�஢��塞 ������ �� ����������
	LACC	*
	SUB	#9
	BCND	ClearSetRecordTime,GT
;//⥯��� ���� ������� ������⢮ ��⮪

	MAR	*,AR1
	LACC	TMP+2
	AND	#0Fh
	SACL	*

	MAR	*,AR2

	SPM  	#0              ;Set P Register Output Shift Mode
				;multiplier output is left-shifted one place

	SPM	#0
	LT      *+
	MPY     #10
	PAC

	SPLK	#0,*	;����⭮ ����塞 ������⢮ ��⮪

	MAR	*,AR1
	ADD	*
	SACL	*
	SUB	#24
	BCND	ClearSetRecQuit,LT	;�᫨ �� ��ॢ�������, � ��室��

	MAR	*,AR2
	LACC	*
	ADD	#1	;㢥��稢��� ������⢮ ��⮪
	SACL	*

	MAR	*,AR1
	LACC	*
	SUB	#48
	BCND	ClearSetRecCompute,LT	;�᫨ �� ��ॢ�������, � ��室��

	MAR	*,AR2
	LACC	*
	ADD	#1	;㢥��稢��� ������⢮ ��⮪
	SACL	*

	MAR	*,AR1
	LACC	*
	SUB	#72
	BCND	ClearSetRecCompute,LT	;�᫨ �� ��ॢ�������, � ��室��

	MAR	*,AR2
	LACC	*
	ADD	#1	;㢥��稢��� ������⢮ ��⮪
	SACL	*

	MAR	*,AR1
	LACC	*
	SUB	#96
	BCND	ClearSetRecCompute,LT	;�᫨ �� ��ॢ�������, � ��室��

	MAR	*,AR2
	LACC	*
	ADD	#1	;㢥��稢��� ������⢮ ��⮪
	SACL	*

ClearSetRecCompute
	MAR	*,AR2

	SPM	#0
	LT      *-
	MPY     #24

	MAR	*,AR1
	LACC	*+
	SPAC		;ACC-PREG

	CALL	ConvertBCD2BIN
	MAR	*-,AR1

	SACL	*
	LACC	*,12,AR2
	AND	#00F0H,12
	SACH	*-,AR1		;����⪨ �ᮢ

	LACC	*,AR2
	AND	#00FH
	SACL	*


ClearSetRecQuit
	MAR	*,AR1
	MAR	*-,AR1
	PSHD	*
	RET

ClearSetRecordTime
	mResetTime
	B	ClearSetRecQuit

;//�८�ࠧ㥬 �᫮ � ����筮 �������� ��⥬�
;//�� ����୮�� �᫠, � �஢�મ� �� 24
ConvertBCD2BIN
	MAR     *,AR1
	POPD	*+

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
	MAR	*,AR1
	MAR	*-,AR1
	PSHD	*
	RET

* �८�ࠧ������ ����୮�� � ����筮-�����筮�� ����
ConvertBIN2BCD
	MAR     *,AR1
	POPD	*+

	SPLK	#0,*+
	SACL	*

Converted10_1
	SUB	#10
	BCND	Converted10,LT
	SACL	*-
	LACC	*
	ADD	#10h
	SACL	*+
	LACC	*
	B	Converted10_1
Converted10
	LACC	*-
	ADD	*

;	MAR	*,AR1
	MAR	*-,AR1
	PSHD	*
	RET

* �८�ࠧ������ ����筮-�����筮�� � ����୮��  ����
ConvertBCD2BIN_
	MAR     *,AR1
	POPD	*+

	SPM	#0
	SACL	*
	LACC	*+,12		;�뤥�塞 ������ �㪢� � ����
	AND	#0F0h,12
	SACH	*

	LT      *-
	MPY     #10		;㬭����� �� 10
				;१���� � PREG

	LACC	*		;�뤥�塞 ������� �㪢� � ����
	AND	#0Fh

;	PAC
	APAC			;᪫��뢠�� �� �� 宧��⢮

	MAR	*,AR1
	MAR	*-,AR1
	PSHD	*
	RET

************************
* ������塞 � ��⥬���� �६��� ������
************************
Add1minutetoWatch
	MAR	*,AR2
	LAR	AR2,#_WATCH+2
	LACC 	*,0          ;� �᫨ =60, � ���६����� �����
	ADD  	#1              ;������ �����
	SACL 	*,0
	SUB  	#10
	RETC	LT
	SPLK 	#0,*+
*
	LACC 	*,0		;����⪮� �����
	ADD  	#1
	SACL 	*,0
	SUB  	#6
	RETC	LT
	SPLK 	#0,*+
*
	LACC 	*,0          ;������ �ᮢ
	ADD  	#1
	SACL 	*,0
	SUB  	#10
	BCND 	CLK24,LT
	SPLK 	#0,*+
*
	LACC 	*,0          ;����⪮� �ᮢ
	ADD  	#1
	SACL 	*-,0

CLK24   MAR	*+,AR2
	LACC 	*-,4          ;�஢�ઠ �� 24 ��
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
	MAR     *,AR1
	POPD	*+

******
* �⥭�� �������� ���ࢠ��
****
	SPLK	#0,_FLADR+1
	SPLK	#0200h+IntervalDayLightSh,_FLADR

	LAR     AR7,#TMP

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+,0,AR2

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+
	LAR     AR7,#TMP
	;�८�ࠧ������ �६��� ������, ����⪨ ����� � ᥪ㭤�
	CALL	Hour2BIN
	LAR	AR7,#_DayTimeInter
	SACL	*

******
* �⥭�� ��筮�� ���ࢠ��
****
	SPLK	#0200h+IntervalDayNightSh,_FLADR

	LAR     AR7,#TMP

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+,0,AR2

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+
	LAR     AR7,#TMP
	;�८�ࠧ������ �६��� ������, ����⪨ ����� � ᥪ㭤�
	CALL	Hour2BIN
	LAR	AR7,#_DayTimeInter+1
	SACL	*
******
* �⥭�� ᯥ樠�쭮�� ���ࢠ��
****
	SPLK	#0200h+IntervalSpecSh,_FLADR

	LAR     AR7,#TMP

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+,0,AR2

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+
	LAR     AR7,#TMP
	;�८�ࠧ������ �६��� ������, ����⪨ ����� � ᥪ㭤�
	CALL	Hour2BIN
	LAR	AR7,#_DayTimeInter+2
	SACL	*

	MAR	*,AR1
	MAR	*-,AR1
	PSHD	*
	RET

*******************************************************
* tmp+1 �����頥� १����
CheckScheduler:
	MAR     *,AR1
	POPD	*+
        B	CheckIntervals	;!!! ��������, ����� � ����� ��楤���

InitScheduler:
	MAR     *,AR1
	POPD	*+

	;����� ᮡ࠭� �� ��楤��� ����㧪�
	;��ࠬ��஢ � ������
	mLoadAllParametrs

        SPLK	#0,ProtectShow
	CALL	GetFlashCount
	BCND	Init_NetIzmereni,EQ
        SPLK	#6,ProtectShow
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
	SPLK	#1,_ShedulerReady
	B	Init_End_Preset

Init_On_Sheduler
	mOn_Interval

	mSetInterval3min
Init_End_Preset

CheckIntervals:
	MAR	*,AR7
	LAR	AR7,#_WATCH+2
	CALL	CheckTime
	BCND	TimeOkey,EQ
	mResetTime
	mOff_Interval
	SPLK	#0,_ShedulerReady
	SPLK	#rMONITOR_NOT_PROGRAMM,_DispErrMeas
TimeOkey
*************************************
* �஢�ઠ ���ࢠ��� ����७�� �ਡ��
	LAR	AR7,#_DayTimeInter
	MAR	*,AR7
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
	SPLK	#0,_ShedulerReady
	SPLK	#rMONITOR_NOT_PROGRAMM,_DispErrMeas
Interval_ok
*����� �஢�ન ���ࢠ���
************************************
* �஢�ઠ �ணࠬ��஢���� ���᪮�� ०���
;����砫쭮 ��⠥�, ��
;������� �� ����� ���� �믮����� ��-�� ����饭���� ��⠭�� ��ࠬ��஢
;�ணࠬ��஢����
	SPLK	#0AAh,TMP+1
	MAR  	*,AR7
	LAR	AR7,#MayModify+1
	SPLK	#05Ah,*		;�� 㬮�砭�� �� ���᪨� ०��
;�� ������� ����� ��室���� Age
* ������ ����� 15  ��� - ��⠥��� ॡ�����
	SPLK	#0,_FLADR+1
	SPLK	#0200h+Age,_FLADR
	CALL	FLREAD
;	AND	#0FFH
	SACL	TMP+2
;�� ������� ����� ��室���� ChildMode
* ���᪨�/����� 5Ah - ���᪨� A5h - �����
	SPLK	#0,_FLADR+1
	SPLK	#0200h+ChildMode,_FLADR
	CALL	FLREAD
;	AND	#0FFH
	SACL	TMP
	XOR	#05Ah
	BCND	Child_OK,EQ	;���᪨� ०�� �������
	XOR	#0FFh
	BCND	Child_OK,EQ	;����� ०�� �������
Age_False:
	mOff_Interval
	SPLK	#0,_ShedulerReady
	SPLK	#rMONITOR_NOT_PROGRAMM,_DispErrMeas
	B	Child_Check_OK
Child_OK:
	LACC	TMP+2		;�஢��塞 ������ ��樥��
	SUB	#15
	;�᫨ �� ����� 15, ���� �஢���� ���⮢��
	;��⠭���� ���᪮�� ०���
	BCND	CheckChildSet,LT
	;���� �� ����� ०��
	LACC	TMP
	XOR	#0A5h
	BCND	Age_False,NEQ
	SPLK	#0h,TMP+1	;�ਡ�� ���ணࠬ��஢�� �� ����� ०��
	MAR  	*,AR7
	LAR	AR7,#MayModify+1
	SPLK	#0A5h,*		;����� ०��
	B	ChildAge_Check_OK
CheckChildSet:
	;�஢��塞 ���⮢�� ��⠭���� ���᪮�� ०���
	LACC	TMP
	XOR	#05Ah
	BCND	Age_False,NEQ
	SPLK	#066h,TMP+1	;�ਡ�� ���ணࠬ��஢�� �� ���᪨� ०��
;	B	ChildAge_Check_OK

ChildAge_Check_OK:
Child_Check_OK:
* ����� �஢�ન �ணࠬ��஢���� ���᪮�� ०���

* �஢��塞 ��� ࠧ�襭�� ��㪮���� ᨣ����
	mOffSound

	SPLK	#0,_FLADR+1
	SPLK	#0200h+ParametrsSh,_FLADR
	CALL	FLREAD
        SACL	TMP
	AND	#01h
        BCND	NoEnableSound,EQ
        mOnSound
NoEnableSound:
*����� �஢�ન ��� ࠧ�襭��

* �஢�ઠ ��� ࠧ�襭�� �뤠� १���⮢
	mOffResult

        LACC	TMP
	AND	#02h
        BCND	NoEnableResult,EQ
        mOnResult
NoEnableResult:
* ����� �஢�ન ��� ࠧ�襭�� �뤠� १���⮢

	MAR	*,AR1
	MAR	*-,AR1
	PSHD	*
	RET

CheckBabyLevel:
	;�� 㬮�砭�� ���᪨� ०��
; .if (WriteDebug!=0) & (Sertificarion=1)
;        SPLK    #PRESS_260-08000h,PrevPressureLevel
; .else
        SPLK    #PRESS_160-08000h,PrevPressureLevel
; .endif

	MAR  	*,AR2
	LAR	AR2,#MayModify+1
	LACC	*
	SUB	#0A5h		;����� ०��
	BCND	ItIsBigMan,EQ
	SPLK    #PRESS_130-08000h,PrevPressureLevel
ItIsBigMan:
	RET

SuperBeep:
        BIT	_Jobs,15-MayBeeping_Flag
	BCND 	NotSuperBeep,NTC
	MAR	*,AR2
	LAR	AR2,#AVRProg
	SPLK	#1,*+
	SPLK	#0BB18h,*		;SetBuzzer
	CALL	SendCommandAVR
NotSuperBeep:
	RET