;&D
*****************************************************************************
*       ���뢠��� ��� ����� ����ᮢ �� ������
* $Id: BPINTKEY.ASM,v 1.21 2001-11-14 17:20:51 peter Exp $
*****************************************************************************
*

	.global	_load_avr_state


INTKEY
	mPush_stack		;��࠭���� ���᫨⥫���
				;ॣ���஢ � �⥪�
	LDP  	#4

	IN      *,ICR          ;ICR(IS@0FFECh) ->STACK

	LACC 	*          	;load accumulator
	AND	#04H
	BCND	ItIsKeybord,NEQ
	LACC 	*          	;load accumulator with shift
	AND  	#0FFFBh    	;�⮡� �� ���஭��� pending FINT2,
				;��� ��� ����塞
	SACL	*
	OUT 	*,ICR           ;ICR(IS@0FFECh) ->STACK
				;pending INT3 (store 1->FINT3)
	LAR  	AR2,#IFR	;����㦠�� 㪠��⥫� �� Interrupt Flag Register
	MAR  	*,AR2      	;modify auxiliary register
				;������ ������� �� ���������⢠ LARP 1
				;�.�. �� ���쭥�襩 ����� �����ᮬ AR2

	SPLK 	#02h,*     	;pending INT2

	BIT     _Jobs,15			;����� ����७�� ����?
	BCND    int3_IzmNeIdet,NTC
;//������� ���ﭨ� �訡�筮�� ���뢠���
;	mEnd_error_meas	rNeispraven
int3_IzmNeIdet
	B	QuitFromINTKEY

ItIsKeybord:
	MAR	*,AR7
	LAR	AR7,#iCNTKEYB

	SPLK 	#CNSTKEYB,*

	Beep

	LACC 	_MDSPL,1 ;��뢠�� ��楤��� � ����ᨬ��� �� ०���
	ADD  	#KEY1
	CALA


	LAR  	AR2,#IMR       	;load auxiliary reg #IMR -> AR2
				;interrupt mask register
	MAR  	*,AR2      	;modify auxiliary register
				;������ ������� �� ���������⢠ LARP 1
				;�.�. �� ���쭥�襩 ����� �����ᮬ AR2
	LACC 	*              	;load accumulator with shift
	AND  	#0FFFDh        	;��頥� ���� INT2(����頥� �� ���뢠���)
	SACL 	*              	;store mask interrupts

QuitFromINTKEY
	mPop_stack		;����⠭������� ���᫨⥫��� ॣ���஢
				;�� �⥪�
	CLRC 	INTM   		;ࠧ�襭�� ���뢠���
				;�� ��室� �� ���뢠���
	RET

****************************************************************************
*����� �맮��� ��楤�� ����⨩ �� ������
****************************************************************************
KEY1    B KEY10 ;�� ��࠭� �६�
	B KEY11 ;�� ��࠭� �६� � ᥪ㭤���
	B KEY12 ;����饥 �������� ����� 0->�� ��ᯫ��
	B KEY13 ;����饥 �������� ����� 1->�� ��ᯫ��
	B KEY14 ;����饥 �������� ����� 2->�� ��ᯫ��
	B KEY15 ;�뢮� ���� �訡�� �� ��࠭
	B KEY16 ;� ०��� ��砫� ����७�� ��������
	B KEY17 ;� ०��� �뢮�� �� ��࠭ ������⢠
		;�ਭ���� � ��।����� ���⮢
	B KEY18 ;�஢��� ���ᨬ��쭮�� ��������
	B KEY19 	;�������� ��⮫��᪮�� ��������
	B KEY110 	;�������� ����
	B KEY111 	;�������� ����⮫��᪮�� ��������
	B KEY112 	;�������� ⥪�饣� �������� (�� ����窥)
	B KEY10  	; �뢮� �६���, ᪮�쪮 ��⠫��� �� ����७��
KEY19
KEY110
KEY111
	SPLK 	#0h,_MDSPL
	RET
KEY112   SPLK 	#0h,_MDSPL
	mEnd_error_meas rCancelByUser
	RET

KEY10:
	MAR  	*,AR2      	;modify auxiliary register
	LAR  	AR2,#ProtectInterval	;����� ���ࢠ�?
	LACC	*
	BCND	MayPressed,EQ
        Beep
        RET
MayPressed:
	mManual_MeasOn
 .if WriteDebug=0
        ;�᫨ ��६�窠 �� �㤥� ���, � AVR ������ 
       	ResetAVRSet
        MAR	* ,AR1
	LALK	AVRProg
	SACL	*+
	CALL	_load_avr_state		;�஢��塞 ���� �� ��� � AVR
	MAR	*-
 .if WARNINGLDP=1
	LDP	#4
 .endif
	BCND	MayMeasurement,NEQ
	SPLK	#rAVR_SPI_BAD,_DispErrMeas
        RET
MayMeasurement:
 .endif
	BIT 	Flags,0
	BCND    MognoIzmerat,NTC
	SPLK	#rPowerLow,_DispErrMeas
	RET
MognoIzmerat

	LACC	_ShedulerReady
	BCND	NotVistrelShed,EQ
	mOn_Interval

;��ꥤ����� �맮� �஢�ન �� ���樠����樨
	CALL	CheckScheduler
	SPLK	#0,_ShedulerReady
	B	KEY10_1

NotVistrelShed
	SPLK	#1,Standartmeas		;����७�� �����������
KEY10_1

	SPLK 	#8h,_MDSPL
	SPLK 	#SUPPLY_UP,_Mode
	SPLK	#0,StartCode		;��� ��⠭����
					;०��� �� "��������"
	LACC	PrevPressureLevel	; "�����������" ��������
					; �����砥� ⥪�騬
	SACL	CurrPressureLevel

	SPLK	#0,_SubroutMode		;��� ��ࢮ��砫쭮�� case
	SPLK	#0,TimeNakachka		;�६� ����窨 �� 40 mm
 .if Only_Pusk=1
	mWait	1 		;1_100 ᥪ㭤� ��ᢥ稢��� �஢��� ��������
 .elseif Only_Pusk=0
	mWait3sek		;3 ᥪ㭤� ��ᢥ稢��� �஢��� ��������
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	Begin_measurement
	mClear_sample_number


	RET
KEY11
 .if Sertificarion=1
	SPLK 	#0h,_MDSPL
	RET
 .else
	SPLK 	#3h,_MDSPL
	BeginADC
 .endif
	RET
KEY12   SPLK 	#3h,_MDSPL
	LACC 	_DPA0,0     ;�몫�祭�� PUMP,VALV1 � VALV2
	AND  	#0FFE3h,0
	SACL 	_DPA0
	OUT  	_DPA0,PA0   ;�뢮� ���ﭨ� �祩�� � ����
	EndADC
	PowerAnalogOff
	SPLK 	#rCancelByUser,ErrMeas
	CALL 	WriteEnd
	RET
KEY13   SPLK  #0h,_MDSPL
        mEnd_error_meas rCancelByUser
        RET

KEY14   SPLK 	#0h,_MDSPL
	LACC 	_Jobs
	AND   	#0FFFEh     ;���砥� ����������
	SACL 	_Jobs
	EndADC
	PowerAnalogOff
	RET
KEY15   MAR	*,AR7
	LAR	AR7,#iCNTERROR
	SPLK 	#0h,*
	SPLK 	#0h,_MDSPL
	RET
KEY16   SPLK 	#0h,_MDSPL
	mEnd_error_meas rCancelByUser
	RET
KEY17   SPLK 	#0h,_MDSPL
	RET
KEY18
 .if Only_Pusk=1
	RET
 .elseif Only_Pusk=0
	mWait3sek		;3 ᥪ㭤� ��ᢥ稢��� �஢��� ��������
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	mClear_sample_number
	SETC 	SXM
*******************************************
* �᫨ ����� ������ ��砫�� �஢��� ����窨 ��������
* � �� �������� � ०��� 0
 .if PresetPressure=1
	LACC 	StartCode
	BCND	TnisNotRegim0,NEQ
	LACC    CurrPressureLevel
	ADD	#PRESS_20
	SACL    CurrPressureLevel
	SUB	#PRESS_250-08000h
	BCND	EndPresetPressure,LEQ

VeryBigPress
	SPLK	#PRESS_145-08000h,CurrPressureLevel
TnisNotRegim0
	LACC 	StartCode
	ADD	#1
	SACL	StartCode
EndPresetPressure
 .elseif PresetPressure=0
 .else
 .emsg _ERROR __ MISSING PARAMETER_
 .endif

********************************************
* �᫨ ०�� �⫠��筮� ����� �몫�祭,
* � ��᪠������ ��� ०��
********************************************
 .if WriteDebug=0
	LACC 	StartCode
	ADD	#1
	SACL	StartCode

	LACC 	StartCode
	SUB	#1
	BCND	NoWriteDebRegim,NEQ
	LACC 	StartCode
	ADD	#1
	SACL	StartCode
NoWriteDebRegim
 .elseif WriteDebug<3
	LACC 	StartCode
	BCND	NoWriteDebRegim,NEQ
        SPLK	#0,StartCode+1
        B	NoWriteDebRegim1
NoWriteDebRegim
	LACC 	StartCode
	SUB	#1
	BCND	NoWriteDebRegim1,NEQ
        LACC	StartCode+1
	ADD	#1
        SACL	StartCode+1
	SUB	#2
        BCND    NoWriteDebRegim2,LT
NoWriteDebRegim1
	LACC 	StartCode
	ADD	#1
	SACL	StartCode
NoWriteDebRegim2
 .endif
**********************************************
* �᫨ ०�� ��������� ०��� 饤㫥� �몫�祭
* � ��᪠������ ��� ०��
***********************************************
  .if Sheduler_Debug=0
	LACC 	StartCode
	SUB	#2
	BCND	ChangeSchedulerReg,EQ
	SUB	#1
	BCND	NoChangeScheduler,NEQ
ChangeSchedulerReg:
	LACC	StartCode
	ADD     #2
	SACL	StartCode
NoChangeScheduler:
 .endif
***********************************************
	LACC	StartCode
	SUB	#4
	BCND	NoLastRegim,LT
	SPLK	#0,StartCode
NoLastRegim


	RET
