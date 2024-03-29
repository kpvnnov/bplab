;&D
* $Id: BP206MAC.ASM,v 1.27 2002-04-24 14:03:10 peter Exp $

mCheckBabyLevel .macro
	CALL	CheckBabyLevel
 .endm

mSendBabyModeToAVR .macro
	MAR  	*,AR2
	LAR	AR2,#MayModify+1
	LACC	*
        OR	#09900h
	LAR	AR2,#AVRProg
	SPLK	#1,*+
	SACL	*		;���᪨�/�����
	CALL	SendCommandAVR
 .endm


mIncAddressToFlash .macro
	LACC IZFLLSB
	ADD  IZFLMSB,16
	ADD  #1
	SACL IZFLLSB
	SACH IZFLMSB


	SACH 	_FLADR+1,1  ;���������� ������ ���� ����
	AND   	#07FFFh
	SACL 	_FLADR    ;���������� ������� ���� ����
 .endm

*******************************
*����祭�� ����������� ��⠭�
*******************************
PowerAnalogOn .macro
	mC5VAOnn		;�����뢠�� ����� � ॣ���� �롮ન
	mOutDIOSR		;�����뢠�� �롮�� ���ன�� � ॣ���� �뢮��

 .endm
*******************************
*�몫�祭�� ����������� ��⠭�
*******************************
PowerAnalogOff .macro
	mC5VAOff		;�����뢠�� ������� � ॣ���� �롮ન
	mOutDIOSR		;�����뢠�� �롮�� ���ன�� � ॣ���� �뢮��
 .endm

*******************************
*����祭�� ��楤��� ��ࠡ�⪨ ���
*******************************
BeginADC .macro
	LACC _Jobs
	OR   #(1<<CallADCPRO_Flag)  	;���� ��稭��� ��������(ADCPRO)
	SACL _Jobs
 .endm
*******************************
*�몫�祭�� ��楤��� ��ࠡ�⪨ ���
*******************************
EndADC .macro
	LACC _Jobs
	AND   #~(1<<CallADCPRO_Flag)  	;���� �����稢��� ��������
	SACL _Jobs
 .endm

*******************************
*����祭�� 䫠�� ��筮�� ����७��
*******************************
mManual_MeasOn .macro
	LACC _Jobs
	OR   #(1<<Manual_Meas)
	SACL _Jobs
 .endm
*******************************
*�몫�祭�� 䫠�� ��筮�� ����७��
*******************************
mManual_MeasOff .macro
	LACC _Jobs
	AND   #~(1<<Manual_Meas)
	SACL _Jobs
 .endm


*******************************
*��稭��� ����� ����७��
*******************************
Begin_measurement .macro
	LACC _Jobs
;	OR   	#CallMeasur	;���� ��稭���
	OR	#(1<<CallMeasur_Flag)	;���� ��稭���
	SACL _Jobs
 .endm
*******************************
*�����稢��� ����� ����७�
*******************************
End_measurement .macro
	LACC _Jobs
	AND	#~(1<<CallMeasur_Flag)	;���뢠�� ���
	SACL _Jobs
 .endm
*******************************
*���� ࠧ ��楤��� ������ �� 䫥� 㦥 �맢���
*� �����⠫� ������⢮ ����७�� �� 䫥�
*******************************
mWeCountingFlash .macro
	LACC _Jobs
	OR	#(1<<WeCountingFlash)	;�����⠫� ������⢮ ����७��
	SACL _Jobs
 .endm
*******************************
*�맢��� ��楤��� ����� �� 䫥� � �����稫� �㤠 �����
*䫠� ������ ���� �����
*******************************
mWeCountingFlashEnd .macro
	LACC _Jobs
	AND	#~(1<<WeCountingFlash)	;���뢠�� ���
	SACL _Jobs
 .endm
*******************************
* ��⠭�������� 䫠� ������⢨� ���� �� 䫥�
*******************************
mNoPlaceInFlash .macro
	LACC _Jobs
	OR	#(1<<NoPlaceInFlash)	;�����⠫� ������⢮ ����७��
	SACL _Jobs
 .endm
*******************************
* ���뢠�� 䫠� ������⢨� ���� �� 䫥�
*******************************
mNoPlaceInFlashClear .macro
	LACC _Jobs
	AND	#~(1<<NoPlaceInFlash)	;���뢠�� ���
	SACL _Jobs
 .endm
*******************************
*���� ������� � ��� ���祭��,�
*��⠭����� ��� ���祭�� � �����
*******************************
SendToDAC .macro
	LACC _Jobs
;	OR   #SendValToDAC  	;���� ������� � ��� ���祭��,�
;				;��⠭����� ��� ���祭�� � �����
	OR   #(1<<SendToDAC_Flag)	;���� ������� � ��� ���祭��,�
					;��⠭����� ��� ���祭�� � �����

	SACL _Jobs
 .endm
*******************************
*���祭�� � ��� �������
*******************************
ClearSendToDAC .macro
	LACC _Jobs
;	AND   #SendToValDACmask
	AND   #~(1<<SendToDAC_Flag)	;���� ������� � ��� ���祭��,�
					;��⠭����� ��� ���祭�� � �����

	SACL _Jobs
 .endm

*******************************
*���� ����� ���祭�� ���
*******************************
ReadDAC .macro
	LACC _Jobs
;	OR   #ReadDACVal
	OR   #(1<<ReadDACVal_Flag)

	SACL _Jobs
 .endm
*******************************
*���祭�� ��� ��⠫� 㦥
*******************************
ClearReadDAC .macro
	LACC _Jobs
;	AND  #ReadDACValmask	;���祭�� ��� ��⠫� 㦥
	AND  #~(1<<ReadDACVal_Flag)
	SACL _Jobs
 .endm

*******************************
* ���� ���⪨� ������
*******************************
Beep .macro
 .newblock
        BIT	_Jobs,15-MayBeeping_Flag
	BCND 	$1,NTC
	LACC 	_Jobs
	OR	#(1<<BeepLittle_Flag)
	SACL 	_Jobs
$1
 .newblock
 .endm
*******************************
* �몫�砥� ���� ���⪨� ������
*******************************
mBeepEnd .macro
	LACC 	_Jobs
	AND	#~(1<<BeepLittle_Flag)	;���砥� ����������(�����)
	SACL 	_Jobs
 .endm

mOnSound .macro
	LACC 	_Jobs
	OR	#(1<<MayBeeping_Flag)
	SACL 	_Jobs

 .endm

mOffSound .macro
	LACC 	_Jobs
	AND	#~(1<<MayBeeping_Flag)
	SACL 	_Jobs
 .endm

mOnResult .macro
	LACC 	_Jobs
	OR	#(1<<MayShowRes_Flag)
	SACL 	_Jobs

 .endm

mOffResult .macro
	LACC 	_Jobs
	AND	#~(1<<MayShowRes_Flag)
	SACL 	_Jobs
 .endm

*******************************
* ���� ������ ������
*******************************
BeepLong .macro
	LACC 	_Jobs
	OR	#(1<<BeepLong_Flag)
	SACL 	_Jobs
 .endm
*******************************
* �몫�砥� ���� ������ ������
*******************************
mBeepLongEnd .macro
	LACC 	_Jobs
	AND	#~(1<<BeepLong_Flag)
	SACL 	_Jobs
 .endm

mMax_number_plus1 .macro
	LACC    _MaxNumber
	ADD     #1
	SACL    _MaxNumber
 .endm

mValve_on	.macro

	LACC _DPA0,0     ;����祭�� ������� (VALV1 � VALV2)
	OR   #0018h,0
	SACL _DPA0
	OUT  _DPA0,PA0

 .endm

mValve_hold	.macro

	LACC _DPA0,0     ;��ॢ�� ������� �� 㤥ঠ���
	AND  #0FFEFh,0  ;���뢠�� ��� VALV2
	SACL _DPA0
	OUT  _DPA0,PA0

 .endm

mValve_off	.macro

	LACC _DPA0,0     ;�몫�祭�� VALV (����⨥ �������)
	AND  #0FFE7h,0
	SACL _DPA0
	OUT  _DPA0,PA0

 .endm
******************************
* ����祭�� ����
******************************
mMotor_on	.macro

	LACC _DPA0,0     ;����祭�� ����
	OR   #0004h,0   ;��⠭�������� ��� PUMP
	SACL _DPA0
	OUT  _DPA0,PA0

	LACC _Jobs
;	OR   #MotorIsOnn
	OR   #(1<<MotorIsOnn_Flag)
	SACL _Jobs
	SPLK	#1,Motor
	SPLK    #33,Motor+1
	SPLK    #0,Motor+2

 .endm

*******************************
* �몫�祭�� ����
*******************************
mMotor_off	.macro

	LACC _DPA0,0     ;�몫�祭�� PUMP
	AND  #0FFFBh,0
	SACL _DPA0
	OUT  _DPA0,PA0
	LACC _Jobs
;	AND   #MotorIsOnnmask
	AND   #~(1<<MotorIsOnn_Flag)
	SACL _Jobs

 .endm

********************************
* �� �㭪樨 ����祭�� ���� � �몫�祭�
* �ᯮ������� �ணࠬ��� ��� �ࠢ����� ���஬
* � ��㣨� ����� "����" �ᯮ�짮����
* mMotor_onn � mMotor_off
********************************
mMotor_on_f	.macro
	LACC _DPA0,0     ;����祭�� ����
	OR   #0004h,0   ;��⠭�������� ��� PUMP
	SACL _DPA0
	OUT  _DPA0,PA0
 .endm

mMotor_off_f	.macro
	LACC _DPA0,0     ;�몫�祭�� PUMP
	AND  #0FFFBh,0
	SACL _DPA0
	OUT  _DPA0,PA0
 .endm

****************************
* 㬥��襭�� ���稪� ��宦����� �� ०���
****************************
mDec_counter	.macro
	LACC 	_ModeCnt,0
	SUB  	#1
	SACL 	_ModeCnt
 .endm

mWait3sek	.macro
	SPLK 	#300,_ModeCnt  ;3 ᥪ㭤�
 .endm

mWait 	.macro code
	SPLK 	#code,_ModeCnt
 .endm


mWait_valve_hold	.macro
	SPLK 	#VALVE_CLOSE,_ModeCnt
 .endm

mNext_sub_mode	.macro
	LACC 	_SubroutMode,0
	ADD  	#1
	SACL 	_SubroutMode
 .endm


*mEnd_error_meas .macro code
*	SPLK 	#0h,_MDSPL
*	mMotor_off
*	mValve_off
*	SPLK #code,ErrMeas
*	CALL WriteEnd
*        EndADC
*	PowerAnalogOff
*	End_measurement
* .endm

mEnd_error_meas .macro code
	SPLK 	#code,ErrMeas
	SPLK    #MEASUREMENT_FINISH,_Mode
 .endm

mEnd_meas .macro
;	SPLK #code,ErrMeas
 .newblock
	LACC    _MDSPL
	SUB	#5
	BCND	$3,EQ
	SPLK 	#0,_MDSPL
$3
        BIT	_Jobs,15-Manual_Meas
        BCND	$5,TC
        ;�� ��⮬���᪮� ����७��
        SPLK	#6,ProtectShow
$5
	LACC 	ProtectShow
	SUB	#5
        BCND	$4,LT
	BIT 	_Jobs,15-MayShowRes_Flag     	;�����뢠�� १�����
	BCND 	$2,NTC
$4
	LACC	ErrMeas
	BCND	$1,NEQ
        LACC	ProtectShow
        ADD	#1
        SACL	ProtectShow
	LACC    _MDSPL
	SUB	#5
	BCND	$1,EQ
	SPLK 	#iSYSTOL_PRESSURE,_MDSPL
	mWait_Display_Meas
	mNum_Display_Meas
	B	$2
$1
	LACC 	ProtectShow
	SUB	#5
        BCND	$6,GT
	SPLK	#1,Standartmeas
$6
	LACC	ErrMeas
	SACL	_DispErrMeas
$2
	mMotor_off
	mValve_off
	CALL WriteEnd
	EndADC
	PowerAnalogOff
	End_measurement
 .endm

mWait_Display_Meas .macro
	SPLK	#300,CountResult
 .endm

mNum_Display_Meas .macro
	SPLK	#5,CountResult+1
 .endm


mPush_stack	.macro
******
* ����� ��࠭���� ���᫨⥫��� ॣ���஢ �⥪�
* �⥪ �࣠������� � 0 ��࠭�� (DP 0)
* AR1 �ᯮ������ 㪠��⥫�� �� �⥪�
* AR1 �� ���樠����樨 ������ ࠢ�� 07Fh
*     (�� ������ ����� �ᯮ�짮������)
* ��࠭���� ACC,PREG,TREG,AR0-AR7
	SST     #0,SST0		;��࠭���� ������� ॣ���஢
	SST     #1,SST1		;0 � 1 � ��࠭�� DP 0
	MAR     *,AR1
	MAR     *+,AR1
	SACL    *+		; ���p������ � �⥪ ACC_L
	SACH    *+		; ���p������ � �⥪ ACC_H
	PAC
	MPY     #1              ;TREG -> PREG
	SPL     *+              ;TREG -> stack
	SACH    *+              ;PREG_H -> stack
	SACL    *+		;PREG_L -> stack
	SAR     AR0,*+
	SAR     AR2,*+
	SAR     AR3,*+
	SAR     AR4,*+
	SAR     AR5,*+
	SAR     AR6,*+
	SAR     AR7,*+
	POPD	*+
 .endm

mPop_stack	.macro
******
* ����� ����⠭������� ���᫨⥫��� ॣ���஢ �� �⥪�
* �⥪ �࣠������� � 0 ��࠭�� (DP 0)
* AR1 �ᯮ������ 㪠��⥫�� �� �⥪
*     (�� ������ ����� �ᯮ�짮������)
* ����⠭������� ���⭮ ������ mPush_stack
	MAR     *,AR1           ;  ����⠭������� �p����饣� ���ﭨ�
	MAR     *-,AR1          ;  �뢮��� 㪠��⥫� �� �㦭�� ����
	PSHD	*-
	LAR     AR7,*-
	LAR     AR6,*-
	LAR     AR5,*-
	LAR     AR4,*-
	LAR     AR3,*-
	LAR     AR2,*-
	LAR     AR0,*-
	LT      *-
	MPY     #1
	LPH     *-
	LT      *-
	LACC    *-,16		;����⠭������� ACC_H
	OR      *-		;��� ����⠭�������� ACC_L
	LDP	#0
	LST     #1,SST1      	;����⠭������� ������� ॣ���஢ 0 � 1
	LST     #0,SST0      	;���� ���� ����⠭�������� ST1
 .endm

mImp_ssp	.macro
	CLRC 	XF
	SETC 	XF
 .endm

mBeeper_xor	.macro
	LACC 	_DPA0,0     	;�������㥬 ���祭�� �����
	XOR  	#01h
	SACL 	_DPA0
	OUT  	_DPA0,PA0   	;�뢮� ���ﭨ� �祩�� � ����
 .endm

**************************
* ��稭��� ������ �� 䫥�
**************************
mBegin_write_flash	.macro

	LACC _Jobs
;	OR   #BeginWriteFlash
	OR   #(1<<BegWrFlash_Flag)
	SACL _Jobs
	CALL	MakeValue	;�⮡� ᮧ���� ⠡����
 .endm


**************************
* ���뢠�� ��� ����� �� 䫥�
**************************
mEnd_write_flash	.macro
	LACC _Jobs
;	AND   #BeginWriteFlashm
	AND   #~(1<<BegWrFlash_Flag)
	SACL _Jobs
 .endm

* ��⠭���� ⥪�饣� �६��� � ���� :(
mResetTime	.macro
	MAR	*,AR7
	LAR	AR7,#_WATCH
	LACC	#0
	RPT	#6
	SACL	*+
 .endm

* ����㧪� ���ࢠ�� � ����ᨬ��� �� ��⮪
* � ⠪�� � ��⮬ ᯥ樭�ࢠ��
mResetInterval .macro
	SPLK	#0200h+DayLightTimeSh,_FLADR

	LAR     AR7,#TMP

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+,0,AR2

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+,0,AR2

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+,0,AR2

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+,0,AR2

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+,0,AR2

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+,0,AR2

	CALL	FLREAD
	AND	#0FFh
	MAR  	*,AR7
	SACL	*+
	;ᥩ�� �
	;TMP+0 - ������� �ᮢ ��砫� ��
	;TMP+1 - ����⪨ �ᮢ ��砫� ��
	;TMP+2 - ������� �ᮢ ����砭�� ��� (��)
	;TMP+3 - ����⪨ �ᮢ ����砭�� ��� (��)
	;ᯥ� ���ࢠ�
	;TMP+4 - ������� �ᮢ ��砫� ��
	;TMP+5 - ����⪨ �ᮢ ��砫� ��
	;TMP+6 - ������� �ᮢ ����砭�� ��� (��)
	;TMP+7 - ����⪨ �ᮢ ����砭�� ��� (��)

;�८�ࠧ㥬 �६��� � ����୮�� ���� � � ������ �祩��� ����������
	LACC	TMP+1,3		;*8
	ADD	TMP+1,1		;+*2
	ADD	TMP+0
	SACL	TMP+0		;��砫� ��

	LACC	TMP+3,3		;*8
	ADD	TMP+3,1		;+*2
	ADD	TMP+2
	SACL	TMP+2		;����砭�� ��

	LACC	TMP+5,3		;*8
	ADD	TMP+5,1		;+*2
	ADD	TMP+4
	SACL	TMP+4		;��砫� ��

	LACC	TMP+7,3		;*8
	ADD	TMP+7,1		;+*2
	ADD	TMP+6
	SACL	TMP+6		;����砭�� ��

	LAR	AR6,#_WATCH+5
	MAR	*,AR6

	LACC	*,3		;*8
	ADD	*-,1
	ADD	*
	SACL	TMP+7		;⥪�饥 �६

	;ᥩ�� �
	;TMP+0 - �ᮢ ��砫� ��
	;TMP+2 - �ᮢ ����砭�� ��� (��)
	;ᯥ� ���ࢠ�
	;TMP+4 - �ᮢ ��砫� ��
	;TMP+6 - �ᮢ ����砭�� ��� (��)
	;TMP+7 - �ᮢ ⥪�饣� �६���


	LACC	TMP+6
	SUB	TMP+4
	BCND	SpecNaoborot,LT	;ᯥ樭�ࢠ� �������

	LACC	TMP+7
	SUB	TMP+4
	BCND	NotSpecial,LT	;� ᯥ� ���ࢠ� �� ��������

	LACC	TMP+6
	SUB	TMP+7
	BCND	NotSpecial,LEQ	;� ᯥ� ���ࢠ� �� ��������
	;����������� ��������!!!
Load_Special
	LAR	AR3,#_DayTimeInter+2
        mOnSound
	B	LoadInterval_1

SpecNaoborot
	LACC	TMP+7
	SUB	TMP+4
	BCND	Load_Special,GEQ
	LACC	TMP+7
	SUB	TMP+6
	BCND	Load_Special,LT

NotSpecial

	;ᥩ�� �
	;TMP+0 - �ᮢ ��砫� ��
	;TMP+2 - �ᮢ ����砭�� ��� (��)
	;ᯥ� ���ࢠ�
	;TMP+4 - �ᮢ ��砫� ��
	;TMP+6 - �ᮢ ����砭�� ��� (��)
	;TMP+7 - �ᮢ ⥪�饣� �६���

	LACC	TMP+2
	SUB	TMP+0
	BCND	DayNaoborot,LT	;ᯥ樭�ࢠ� �������
	LACC	TMP+7
	SUB	TMP+0
	BCND	NotDay,LT	;� ������� ���ࢠ� �� ��������

	LACC	TMP+2
	SUB	TMP+7
	BCND	NotDay,LEQ	;� ������� ���ࢠ� �� ��������
	;������� ��������!!!
Load_Day
	LAR	AR3,#_DayTimeInter
        mOnSound
	B	LoadInterval_1

DayNaoborot
	LACC	TMP+7
	SUB	TMP+0
	BCND	Load_Day,GEQ
	LACC	TMP+7
	SUB	TMP+2
	BCND	Load_Day,LT

NotDay

	;��筮� ��������!!!
        mOffSound
	LAR	AR3,#_DayTimeInter+1

LoadInterval_1
	MAR	*,AR3
	LAR	AR2,#CounterToBegin
*	LAR	AR3,#_DayTimeInter
	LACC	*+,AR2
	SACL	*
 .endm

mResetFastInterval .macro
	MAR	*,AR2
	LAR	AR2,#CounterFastToBegin
	SPLK	#180,*		;3*60 ᥪ㭤
 .endm

mLoadFastInterval .macro
	MAR	*,AR2
	LAR	AR2,#CounterFastToBegin
	LACC	*
	LAR	AR2,#CounterToBegin
	SACL	*
 .endm

mSetInterval5s .macro
	MAR	*,AR2
	LAR	AR2,#CounterToBegin
	SPLK	#5,*		;���� ᥪ㭤
 .endm
mSetInterval3min .macro
	MAR	*,AR2
	LAR	AR2,#CounterToBegin

	SPLK	#180,*		;3*60 ᥪ㭤
 .endm

mOn_Interval	.macro
 .newblock

	LACC _Jobs
	OR   #(1<<OnInterval_Flag)
	SACL _Jobs
*	mLoadInterval
	SUB	#1	;�᫨ ���ࢠ� �� � �।����
	BCND	$1,NEQ
	mOff_Interval
	SPLK	#rMONITOR_NOT_PROGRAMM,_DispErrMeas
	B	$2

$1
	mSetInterval5s
	mCheckBabyLevel
$2

*	CALL	KEY10_1
 .endm

mOff_Interval	.macro

	LACC _Jobs
;	AND   #OnIntervalmask
	AND   #~(1<<OnInterval_Flag)
	SACL _Jobs

 .endm

;�⥭�� ���ࢠ��� ����७��
; ��������, ��筮��, ᯥ樠�쭮��
; �८�ࠧ������ � ᥪ㭤�
; � ����饭�� � ᯥ樠��� �祩��

*!! ���� �� �㤥�
; �⥭�� �஬���⪮� �६���
; ����� ����, ����� ����, ����� ᯥ� ���ࢠ�?

mLoadInterval .macro
	CALL	ReadAllInterval
 .endm

mSetWatchToInit	.macro
	CALL	SetWatchToInit
 .endm

mLoadAllParametrs .macro
	mSetWatchToInit
	mLoadInterval
 .endm

;sofware power down
mADCPowerDown	.macro
	SETC 	XF
	SPLK 	#SSPS,TMP    ;SSP start
	OUT  	TMP,SSPCR    ;Synchronous Serial Port Control Register
	IN   	TMP,SDTR     ;������� ��譥�� �⥭�
				;��� �⠡��쭮��(���������) ࠡ��� � SSP

	SPLK 	#0EC00h,TMP  ;software power down
	OUT  	TMP,SDTR

	mImp_ssp              ;������塞 SSP � ��砫� ��।�� MSB
	mImp_ssp
	mImp_ssp

	mOnADC
	mOutDIOSR

	CALL 	CLKXF           ;1-��।��� ��ࢮ� ᫮��

	mOffPeriph
	mOutDIOSR

	IN   	TMP,SDTR     ;������� ��譥�� �⥭�
	IN   	TMP,SDTR     ;������� ��譥�� �⥭�

	SPLK 	#SSPR,TMP    ;RESET SSP
	OUT  	TMP,SSPCR

 .endm


;�����뢠�� �롮�� ���ன�� � ॣ���� �뢮��
mOutDIOSR	.macro
	OUT  	_rDIOSR,IOSR      ;�����뢠�� � IO status register
 .endm


******************
*����� ��� �������
* IO0 - #CSADC
* IO1 - #CSDAC
* IO2 - #C5VA
* IO3
*����� � ������஬
* IO0,IO1,IO2 �� �������, ���⮬�
* 000 - #CSADC
* 001 - #CSDAC
* 010 - #CSF0	-�롮ઠ ��ࢮ� 䫥�
* 011 - #CSF1	-�롮ઠ ��ன 䫥�
*
* IO3 - #C5VA
******************


;�몫�砥� ��� �롮��
 .if VersionFerrum=1		;��� �������

mOffPeriph	.macro
	LACC 	_rDIOSR
	OR	#03H		;��� � 1 IO0(#CS0),IO1(#CS1)
	SACL 	_rDIOSR
 .endm
 .elseif VersionFerrum=2        ;� ������஬
mOffPeriph	.macro
	LACC 	_rDIOSR
	OR	#07H		;�������
	SACL 	_rDIOSR
 .endm
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

;����砥� �롮�� ���
 .if VersionFerrum=1		;��� �������

mOnADC	.macro
	LACC 	_rDIOSR
	AND  	#0EH  		;���뢠�� � ���� IO0(#CS0)
	SACL 	_rDIOSR
 .endm
 .elseif VersionFerrum=2        ;� ������஬
mOnADC	.macro
	LACC 	_rDIOSR
	AND  	#08H  		;���뢠�� � ���� #CSADC
	SACL 	_rDIOSR
 .endm
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

;����砥� �롮�� ���
 .if VersionFerrum=1		;��� �������
mOnDAC	.macro
	LACC 	_rDIOSR
	AND  	#0DH  		;���뢠�� � ���� IO1(#CS1)
	SACL 	_rDIOSR
 .endm

 .elseif VersionFerrum=2        ;� ������஬
mOnDAC	.macro
	LACC 	_rDIOSR
	AND  	#08H
	OR	#01h		;��⠭�������� � ���� #CSDAC
	SACL 	_rDIOSR
 .endm
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif



*************

 .if VersionFerrum=1		;��� �������
mC5VAOnn	.macro
	LACC 	_rDIOSR
	AND  	#0BH  		;IO2(#C+5VA)
	SACL 	_rDIOSR
 .endm
mC5VAOff	.macro
	LACC 	_rDIOSR
	OR  	#04H  		;IO2(#C+5VA)
	SACL 	_rDIOSR
 .endm

 .elseif VersionFerrum=2        ;� ������஬
mC5VAOnn	.macro
	LACC 	_rDIOSR
	AND  	#07H  		;IO3(#C+5VA)
	SACL 	_rDIOSR
 .endm
mC5VAOff	.macro
	LACC 	_rDIOSR
	OR  	#08H  		;IO3(#C+5VA)
	SACL 	_rDIOSR
 .endm
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

*************

 .if VersionFerrum=1		;��� �������

 .elseif VersionFerrum=2        ;� ������஬
mOnFlash0	.macro
	LACC 	_rDIOSR
	AND  	#08H
	OR	#02h		;��⠭�������� � ���� #CSF0
	SACL 	_rDIOSR
 .endm
mOnFlash1	.macro
	LACC 	_rDIOSR
	AND  	#08H
	OR	#03h		;��⠭�������� � ���� #CSF0
	SACL 	_rDIOSR
 .endm
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

 .if VersionFerrum=1		;��� �������
mRead_512b	.macro
 .newblock
*  ASFLMSB     15-20bit
*  AFLLSB      0-14bit
* �⥭�� ��࠭���
*  ���� ��� �⥭��, �� ���� ����� ���� ��࠭���
*  ASFLMSB     15-20bit
*  AFLLSB      0-14bit
*	AR7 - �㤠 ����㦠��
* ��楤�� ���� ����� �� 䫥� � ����㦠�� ��ࠬ� � ᫮�� AR7
* � ���� ��砫�� ���� ������ ���� ���
*	AR7 - �㤠 ����㦠��

	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+
	SAR     AR2,*+
	SAR     AR0,*+

	LACC 	_DPA0
	AND  	#01Fh
	ADD  	_FLADR+1,6
	SACL 	_DPA0
	OUT  	_DPA0,PA0
	OR   	#20h
	SACL 	_DPA0

	LACC    _FLADR
	OR	#08000H
	SACL	*
	LAR  	AR2,*
	LAR	AR0,#255
	MAR	*,AR2
$1
	LACC	*+,0,AR1	;��६ ��� ����
	AND	#0FFh
	SACL	*,0,AR2		;�����뢠�� � �⥪

	LACC	*+,8,AR1	;��६ ����� ����
	AND	#0FF00H
*	OR	*		;᪫��뢠�� � ���祭��� � �⥪�
*	MAR	*,AR7
	OR	*,AR7
	SACL	*+,0,AR0	;�����뢠�� � �����
	BANZ    $1,*-,AR2	;��⠥� 256 ᫮�
	OUT  	_DPA0,PA0

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR0,*-
	LAR     AR2,*-
	LAR     AR7,*-
	PSHD	*
	RET
 .newblock

 .endm
 .elseif VersionFerrum=2        ;� ������஬
mRead_512b	.macro
 .newblock
*  PA11-0 - ���� ��࠭���
*  BA9-0  - ���� ���� ����� ��࠭���
*  X      - ������� ��
* 1.[52h],[r,r,PA11-6],
* 2.[PA5-0,BA9-8],[BA7-0],
* 3.[X],[X],
* 4.[X],[X]
	LACC 	#07FFFh
$4	SUB  	#1
	RPT  	#10
	NOP
	RETC	LEQ
	BCND 	$4,BIO

	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+
	SAR     AR0,*+

	SPLK 	#SSPS,*    ;SSP start
	OUT  	*,SSPCR    ;Synchronous Serial Port Control Register
	IN   	*,SDTR     ;������� ��譥�� �⥭�
				;��� �⠡��쭮��(���������) ࠡ��� � SSP
	SPLK	#0,*
	OUT  	*,SDTR     	;0.�㫥��� :) ᫮�� ��� ��।��

	LACC    _FLADR+1,1
 .if Mem=20	;���� �����奬� �� 2 Mbyte
	AND	#003Fh,1
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
	AND	#007Fh,1
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
	AND	#007Fh,1
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

	OR	#5200h,1

	BIT	_FLADR,1
	BCND	$3,NTC
	OR	#0001H
$3

	SACL 	*
	OUT  	*,SDTR     	;1.��ࢮ� ᫮�� ��� ��।��
				;([code][page_msb])

	mImp_ssp              	;������塞 SSP � ��砫� ��।�� MSB
	mImp_ssp
*	mImp_ssp

	CALL 	$2           ;0-��।��� �㫥��� ;) ᫮��


	;������� �롮�� 䫥�
	LACC    _FLADR+1,1
        AND	#080H
        BCND	$5,NEQ
        mOnFlash0
        B	$6
$5:	mOnFlash1
$6:
	mOutDIOSR


	LACC    _FLADR,2
	AND     #0FC00h,1
	SACL 	*
	OUT  	*,SDTR     	;2.��஥ ᫮�� ��� ��।��
				;([page_lsb][adress])
	mImp_ssp		; ��।��� "��譨�" ���

	CALL 	$2           ;1-��।��� ��ࢮ� ᫮��
	IN   	*,SDTR     	;(0)�⥭�� �㫥���� १���� (����)
	IN   	*,SDTR     	;(1)�⥭�� ��ࢮ�� १���� (����)
	OUT	*,SDTR     	;3.�⢥�⮥ ᫮�� ��� ��।��
				;([������� ��])

	CALL 	$2           ;2-��।��� ��஥ ᫮��
	IN   	*,SDTR     	;(2)�⥭�� ��ண� १���� (����)
	OUT	*,SDTR     	;4.��⮥ ᫮�� ��� ��।��
				;([������� ��])

	CALL 	$2           ;3-��।��� ���� ᫮��
	IN   	*,SDTR     	;(3)�⥭�� ���쥣� १���� (����)
	OUT	*,SDTR     	;5.��⮥ ᫮�� ��� ��।��
				;([������� ��])

	CALL 	$2           ;4-��।��� �⢥�⮥ ᫮��
	IN   	*,SDTR     	;(4)�⥭�� �⢥�⮣� १���� (����)
	OUT	*,SDTR,AR7     	;6.��⮥ ᫮�� ��� ��।��
				;([������� ��])

	LAR	AR0,#255-2



$1
	CALL 	$2           ;��।��� 5+N ᫮�� (N=0..255)
*************************************************
* ��� ����� ����� ����� ���� � �����ᨥ�
* ����� �㤥� ���� �������⥫�� ���� �����ᨨ ������
 .if NewFerrum=1
	IN   	*,SDTR     	;�⥭�� 5+N १���� (᫮�� ������ N=0..255)
	LACC	#0FFFFH
	XOR	*
	SACL	*+
 .else
* � ����� ����� �����ᨨ ���
	IN   	*+,SDTR     	;�⥭�� 5+N १���� (᫮�� ������ N=0..255)
 .endif
	;;� * �����

	OUT	*,SDTR,AR0     	;7+N ᫮�� ��� ��।��
				;([������� ��])
*	MAR	*,AR0
	BANZ    $1,*-,AR7

	CALL 	$2           	;�।��᫥���� ᫮��(N=254)
*************************************************
* ��� ����� ����� ����� ���� � �����ᨥ�
* ����� �㤥� ���� �������⥫�� ���� �����ᨨ ������
 .if NewFerrum=1
	IN   	*,SDTR     	;�⥭�� १���� (᫮�� ������ N=254)
	;;� * �����
	LACC	#0FFFFH
	XOR	*
	SACL	*+
 .else
* � ����� ����� �����ᨨ ���
	IN   	*+,SDTR     	;�⥭�� १���� (᫮�� ������ N=254)
	;;� * �����
 .endif

	CALL 	$2           	;��᫥���� ᫮��(N=255)
*************************************************
* ��� ����� ����� ����� ���� � �����ᨥ�
* ����� �㤥� ���� �������⥫�� ���� �����ᨨ ������
 .if NewFerrum=1
	IN   	*,SDTR    	;�⥭�� १���� (᫮�� ������ N=255)
	;;� * �����
	LACC	#0FFFFH
	XOR	*
	SACL	*+,0,AR1
 .else
* � ����� ����� �����ᨨ ���
	IN   	*+,SDTR,AR1    	;�⥭�� १���� (᫮�� ������ N=255)
	;;� * �����
 .endif

	;�몫���� �롮�� 䫥�
	mOffPeriph
	mOutDIOSR

	SPLK 	#SSPR,*    	;RESET SSP
	OUT  	*,SSPCR

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR0,*-
	LAR     AR7,*-
	PSHD	*
	RET
$2
	mImp_ssp	;1
	mImp_ssp        ;2
	mImp_ssp        ;3
	mImp_ssp        ;4
	mImp_ssp        ;5
	mImp_ssp        ;6
	mImp_ssp        ;7
	mImp_ssp        ;8
	mImp_ssp        ;9
	mImp_ssp        ;10
	mImp_ssp        ;11
	mImp_ssp        ;12
	mImp_ssp        ;13
	mImp_ssp        ;14
	mImp_ssp        ;15
	mImp_ssp        ;16
	RET
 .newblock
 .endm

 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

 .if VersionFerrum=1		;��� �������

 .elseif VersionFerrum=2        ;� ������஬
* gh
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif


mDelay250mks	.macro

* �६� ������� !!!!!!!!
 .newblock
	LACC 	#30
$1
	RPT 	#5          	;+12
	NOP
	SUB 	#1          	;+2
	BCND 	$1,NEQ 	;+3
 .newblock
 .endm
mBeepXOR	.macro

	LACC 	_DPA0,0     ;�������㥬 ���祭�� �����
	XOR  	#01h
	SACL 	_DPA0
	OUT  	_DPA0,PA0   ;�뢮� ���ﭨ� �祩�� � ����
 .endm
WriteParams .macro code

 .if code=00
**      �����뢠�� 0
	CLRC 	SXM
	AND  	#0
	SACL 	TMP
	CALL 	FLPROG


	AND  	#0
	SACL 	TMP
	CALL 	FLPROG
 .newblock
 .elseif code=10

 .elseif code=11

**** �⥭�� � ��ࢮ�� ������ ���
	CLRC 	SXM
	LAR  	AR2,#SR30       ;���� ��砫� ᤢ��.ॣ.���
	MAR  	*,AR2
	LACC 	*,12       ;���뢠�� ���祭�� ����祭��� � ���
	ADD  	#1000h,15 ; �� 16 ᤢ����� �����, ���⮬� ⠪ ����⨫���
	AND  	#0FFFh,16

	SUB 	BeginLevel,16
	BCND 	$1,GEQ ;����� ��� ࠢ�� ���
	SetC 	SXM
	SACH 	TMP
	LACC 	TMP
	ADD  	#7FH
	BCND 	$2,GEQ
	SPLK 	#0FF80H,TMP   ;�����뢠�� ���ᨬ����� ����稭� ���饭�
	B 	$2
;Abovech2
$1
	SACH 	TMP
	LACC 	TMP
	SUB 	#07Fh
	BCND 	$2,LT
	SPLK 	#07EH,TMP   ;�����뢠�� ���ᨬ����� ����稭� ���饭�
;LessOverCh2
$2
	LACC 	BeginLevel
	ADD  	TMP
	SACL 	BeginLevel
	CLRC 	SXM            ;�����뢠�� ����� �� 䨫��� ����
	CALL 	FLPROG

	LACC 	AFLLSB    ;㢥��稢��� ���� �� �������
	ADD  	#1
	SACL 	AFLLSB
	AND  	#07FFFh
	BCND 	$3,NEQ
	LACC 	AFLMSB
	ADD  	#1
	SACL 	AFLMSB
$3
 .newblock

 .elseif code=12

**** �⥭�� � ��ࢮ�� ������ ��᫥ 䨫���
	CLRC 	SXM
	LACC 	_OUTF+2,12

	SUB 	BeginLevel+1,16
	BCND 	$1,GEQ ;����� ��� ࠢ�� ���
	SetC 	SXM
	SACH 	TMP
	LACC 	TMP
	ADD  	#7FH
	BCND 	$2,GEQ
	SPLK 	#0FF80H,TMP   ;�����뢠�� ���ᨬ����� ����稭� ���饭�
	B 	$2
$1
	SACH 	TMP
	LACC 	TMP
	SUB 	#07Fh
	BCND 	$2,LT
	SPLK 	#07EH,TMP   ;�����뢠�� ���ᨬ����� ����稭� ���饭�
$2
	LACC 	BeginLevel+1
	ADD  	TMP
	SACL 	BeginLevel+1
	CLRC 	SXM            ;�����뢠�� ����� �� 䨫��� ����
	CALL 	FLPROG

	LACC 	AFLLSB    ;㢥��稢��� ���� �� �������
	ADD  	#1
	SACL 	AFLLSB
	AND  	#07FFFh
	BCND 	$3,NEQ
	LACC 	AFLMSB
	ADD  	#1
	SACL 	AFLMSB
$3
 .newblock
 .elseif code=20
 .elseif code=21

**** �⥭�� � ��ண� ������ (��. ����) � ���
	CLRC 	SXM
*	LAR  	AR2,#SR30+16       ;���� ��砫� ᤢ��.ॣ.���
*	MAR  	*,AR2
*	LACC 	*,12

	MAR	*,AR6
	LAR	AR6,#_ResultADC+9;AIN9 (PR3)

*	LACC	Channel_two,12
	LACC	*,12
	SACH 	TMP
	CALL 	FLPROG


**** �⥭�� � ��ண� ������ (��. ����) � ���
*	LAR  	AR2,#SR30+16       ;���� ��砫� ᤢ��.ॣ.���
*	MAR  	*,AR2
*	LACC 	*,4

	MAR	*,AR6
	LAR	AR6,#_ResultADC+9;AIN9 (PR3)
*	LACC	Channel_two,4
	LACC	*,4
	ADD  	#100h,11
	AND  	#0Fh,16

	SACH 	TMP
	CALL 	FLPROG

 .newblock
 .elseif code=211

**** �⥭�� � ��ண� ������ (��. ����) � ���
*!! �᪫��� ���
	CLRC 	SXM
	LAR  	AR2,#SR30+16       ;���� ��砫� ᤢ��.ॣ.���
	MAR  	*,AR2
	LACC 	*,16
	BCND 	$3,NEQ
	ADD  	#16,15
$3
	SACH 	TMP
	CALL 	FLPROG

	LACC 	AFLLSB    ;㢥��稢��� ���� �� �������
	ADD  	#1
	SACL 	AFLLSB
	AND  	#07FFFh
	BCND 	$1,NEQ
	LACC 	AFLMSB
	ADD  	#1
	SACL 	AFLMSB
$1

**** �⥭�� � ��ண� ������ (��. ����) � ���
	LAR  	AR2,#SR30+16       ;���� ��砫� ᤢ��.ॣ.���
	MAR  	*,AR2
	LACC 	*,8
	ADD  	#100h,15

	SACH 	TMP
	CALL 	FLPROG

	LACC 	AFLLSB    ;㢥��稢��� ���� �� �������
	ADD  	#1
	SACL 	AFLLSB
	AND  	#07FFFh
	BCND 	$2,NEQ
	LACC 	AFLMSB
	ADD  	#1
	SACL 	AFLMSB
$2
 .newblock
 .elseif code=22
**** �⥭�� � ��ண� ������ ��᫥ 䨫��� (��. ����)
	CLRC 	SXM
	LACC 	_OUTF+1,16   ;��ன ᨣ��� - ������ ���� ��᫥ 䨫���
*        ;��� 12 ࠧ�冷�   LACC _OUTF+1,12
	SACH 	TMP
	CALL 	FLPROG

	LACC 	AFLLSB    ;㢥��稢��� ���� �� �������
	ADD  	#1
	SACL 	AFLLSB
	AND  	#07FFFh
	BCND 	$1,NEQ
	LACC 	AFLMSB
	ADD  	#1
	SACL 	AFLMSB
$1
	LACC 	_OUTF+1,8    ;
*        ;��� 12 ࠧ�冷�   LACC _OUTF+1,4
	SACH 	TMP
	CALL 	FLPROG

	LACC 	AFLLSB    ;㢥��稢��� ���� �� �������
	ADD  	#1
	SACL 	AFLLSB
	AND  	#07FFFh
	BCND 	$2,NEQ
	LACC 	AFLMSB
	ADD  	#1
	SACL 	AFLMSB
$2
 .newblock
 .elseif code=30
 .elseif code=31
**** �⥭�� � �ᨫ������ ������ (��. ����) � ���
	CLRC 	SXM
	LACC 	TMPADC+1,12
	SACH 	TMP
	CALL 	FLPROG

	LACC 	AFLLSB    ;㢥��稢��� ���� �� �������
	ADD  	#1
	SACL 	AFLLSB
	AND  	#07FFFh
	BCND 	$1,NEQ
	LACC 	AFLMSB
	ADD  	#1
	SACL 	AFLMSB
$1

**** �⥭�� � �ᨫ������ ������ (��. ����) � ���
	LACC 	TMPADC+1,4
	ADD  	#10h,15
	AND  	#0Fh,16

	SACH 	TMP
	CALL 	FLPROG

	LACC 	AFLLSB    ;㢥��稢��� ���� �� �������
	ADD  	#1
	SACL 	AFLLSB
	AND  	#07FFFh
	BCND 	$2,NEQ
	LACC 	AFLMSB
	ADD  	#1
	SACL 	AFLMSB
$2
 .newblock
 .elseif code=32
**** �⥭�� � �ᨫ������ ������ ��᫥ 䨫��� (��. ����)
;	CLRC 	SXM
	SETC	SXM
	LACC 	_OUTF   ;�ᨫ���� ᨣ��� - ������ ���� ��᫥ 䨫���
*	LAR  	AR2,#SR30       ;���� ��砫� ᤢ��.ॣ.���
*	MAR  	*,AR2
*	LACC 	*       ;���뢠�� ���祭�� ����祭��� � ���

	SUB	Preset0
	ADD	#4000h,1

*        ;��� 12 ࠧ�冷�   LACC _OUTF,12
	SACL 	TMP
	CALL 	FLPROG

	LACC 	_OUTF,8    ;�ᨫ���� ᨣ��� - ����� ����
*	LAR  	AR2,#SR30       ;���� ��砫� ᤢ��.ॣ.���
*	MAR  	*,AR2
*	LACC 	*,8       ;���뢠�� ���祭�� ����祭��� � ���

	SUB	Preset0,8
	ADD	#4000h,9
*        ;��� 12 ࠧ�冷�   LACC _OUTF,4
	SACH 	TMP
	CALL 	FLPROG

 .newblock
 .elseif code=33

**** �⥭�� � �ᨫ������ ������ (��. ����) � ���
	CLRC SXM
	LAR  AR2,#SR30+32       ;���� ��砫� ᤢ��.ॣ.���
	MAR  *,AR2
	LACC *,16
	SACH TMP
	CALL FLPROG

	LACC AFLLSB    ;㢥��稢��� ���� �� �������
	ADD  #1
	SACL AFLLSB
	AND  #07FFFh
	BCND $1,NEQ
	LACC AFLMSB
	ADD  #1
        SACL AFLMSB
$1

**** �⥭�� � �ᨫ������ ������ (��. ����) � ���
        LAR  AR2,#SR30+32       ;���� ��砫� ᤢ��.ॣ.���
        MAR  *,AR2
        LACC *,8
        ADD  #100h,15

	SACH TMP
        CALL FLPROG

        LACC AFLLSB    ;㢥��稢��� ���� �� �������
        ADD  #1
        SACL AFLLSB
        AND  #07FFFh
	BCND $2,NEQ
        LACC AFLMSB
        ADD  #1
        SACL AFLMSB
$2
 .newblock
 .elseif code=41
**** ������ ��६����� DAC2
        CLRC SXM
        LACC DAC2,12
	SACH TMP
        CALL FLPROG

	LACC AFLLSB    ;㢥��稢��� ���� �� �������
        ADD  #1
        SACL AFLLSB
        AND  #07FFFh
	BCND $1,NEQ
        LACC AFLMSB
        ADD  #1
        SACL AFLMSB
$1

**** ������ ��६����� DAC2 ���襩 ���
        LACC DAC2,4
        ADD  #10h,15
        AND  #0Fh,16

	SACH TMP
        CALL FLPROG

        LACC AFLLSB    ;㢥��稢��� ���� �� �������
        ADD  #1
        SACL AFLLSB
        AND  #07FFFh
	BCND $2,NEQ
        LACC AFLMSB
        ADD  #1
        SACL AFLMSB
$2
 .newblock
 .elseif code=42
**** ������ ��६����� DAC2
        CLRC SXM
        LACC TMPADC1,12
	SACH TMP
        CALL FLPROG

        LACC AFLLSB    ;㢥��稢��� ���� �� �������
        ADD  #1
        SACL AFLLSB
	AND  #07FFFh
        BCND $1,NEQ
        LACC AFLMSB
        ADD  #1
        SACL AFLMSB
$1

**** ������ ��६����� DAC2 ���襩 ���
        LACC TMPADC1,4
        ADD  #10h,15
        AND  #0Fh,16

	SACH TMP
        CALL FLPROG

	LACC AFLLSB    ;㢥��稢��� ���� �� �������
        ADD  #1
        SACL AFLLSB
        AND  #07FFFh
	BCND $2,NEQ
	LACC AFLMSB
	ADD  #1
	SACL AFLMSB
$2
 .newblock
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
 .endm

WriteEKG    .macro code
 .if code=1

	SETC	SXM

*	LAR     AR7,#_ResultADC+0       ;���� PL3
*	MAR     *,AR7
*	LACC	*
	LACC	_OUTF_EKG1,0

	ADD     #4000h,1
;	AND     #0FFFFh


	SACL 	TMP
	CALL 	FLPROG

*	LAR  AR7,#_ResultADC+0      ;����  PL3
*	MAR  *,AR7

*	LACC 	*,8
	LACC	_OUTF_EKG1,8

	ADD     #4000h,1+8
	SACH 	TMP
	CALL 	FLPROG
 .elseif code =2
	SETC	SXM
*	LAR  AR7,#_ResultADC+2       ;���� PL3
*	MAR  *,AR7

*	LACC 	*
	LACC	_OUTF_EKG2,0

	ADD     #4000h,1

	SACL 	TMP
	CALL 	FLPROG

*	LAR  AR7,#_ResultADC+2      ;����  PL3
*	MAR  *,AR7

*	LACC 	*,8
	LACC	_OUTF_EKG2,8

	ADD     #4000h,1+8
	SACH 	TMP
	CALL 	FLPROG
 .endif
 .endm

**************************************************************************
; ������ ��ࠢ������� "Pressure_diminition_2" �ॡ�� ���樠����樨
; ᫥����� ��६�����:
**************************************************************************
; ��। ����७���.
; Mode = PRESSURE_DIMINUTION;
; DimMode = 0;
; DimModeSampleCounter = 0;
; MeasurementFlags = (MeasurementFlags )|( 1<<DIM_PRESSURE_FLAG  );

mDim_pressure_init	.macro

	SPLK	#PRESSURE_DIMINUTION,_Mode
	LACC	#0
	SACL	_DimMode
	SACL    _DimModeSampleCounter
	LACC	_MeasurementFlags,0
	OR	#(1<<DIM_PRESSURE_FLAG)
	SACL	_MeasurementFlags,0

	mValve_off

	.endm

; ��᫥ ����祭�� ��⠭��.
; Perror = 0;
; Preturn = B4mm+B0_5mm*4;

mDim_pressure_supply_up_init	.macro

	SPLK	#0,_Perror
	SPLK	#B4mm+B0_5mm*4,_Preturn

	.endm
**************************************************************************
;/***********************************************************
;*   mMeasurement_initialization
;***********************************************************/
;
; /* �� ���樠����樨 ����� ����७�� */
; StartMeasAdress[StepNumber] = 0;
; SubroutMode = 0;
; MaxNumber = 0;                           // ����� ���ᨬ㬠.
; StartMaxNumber = 0;
; MaxNumberShift = 0;
; StepNumber = 0;
; SampleNumber = 0;
; SampleNumberShift = 0;
; ErrMeas = 0;
; MaxAverageAmplitude = 0;
; SistolPressure = 0;
; DiastolPressure = 0;
; AnalysisInterval = 32*1.25;  // ��������� AnalysisInterval
; AnalysisStart = AnalysisInterval + 2*DIFF_BASIS;
; MeasurementFlags = MeasurementFlags &
;                 (~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)));
*
*       ����� mMeasurement_ ��室���� � 䠩�� BP206mac.asm
*
mMeasurement_init	.macro

	MAR	*,AR2
	LAR	AR2,#StartMeasAdress
	LACL	#0
	SACL	*,0,AR2
	SACL	_SubroutMode
	SACL    _StartMaxNumber
	SACL    _MaxNumber
	SACL    _MaxNumberShift
	SACL    TimeNakachka
	SACL    _StepNumber
	SACL    _SampleNumber
	SACL    _SampleNumberShift
	SACL	ErrMeas
	SACL	MaxAverageAmplitude
	SACL	SistolPressure
	SACL	DiastolPressure
	SPLK    #40,_AnalysisInterval
	LACC    _AnalysisInterval
	ADD     #DIFF_BASIS*2
	SACL    _AnalysisStart
	LACC    _MeasurementFlags
	AND	#(~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)))
	SACL	_MeasurementFlags

	.if Emulator=1
	SPLK    #0,massiv
	.endif

	.endm
**************************************************************************
mClear_subrout_mode_err_meas	.macro
	LACL	#0
	SACL	_SubroutMode
	SACL	ErrMeas
	.endm
**************************************************************************
mClear_sample_number	.macro
	LACL	#0
	SACL    _StartMaxNumber
	SACL    _MaxNumber
	SACL    _MaxNumberShift
	SACL    _StepNumber
	SACL    _SampleNumber
	SACL    _SampleNumberShift
	SACL	ErrMeas
	SACL	MaxAverageAmplitude
	SACL	SistolPressure
	SACL	DiastolPressure
	SPLK    #40,_AnalysisInterval
	LACC    _AnalysisInterval
	ADD     #DIFF_BASIS*2
	SACL    _AnalysisStart
	.if Emulator=1
	SPLK    #0,massiv
	.endif
	.endm

;***********************************************************************
;*      mArrays_are_shifted();
;***********************************************************************
;void   mArrays_are_shifted();
;(
;   Max2DiffAdress[2] = Max2DiffAdress[1];
;   Max2DiffAdress[1] = Max2DiffAdress[0];
;   MaxAvrPress[2] = MaxAvrPress[1];
;   MaxAvrPress[1] = MaxAvrPress[0];
;   MinAvrPress[2] = MinAvrPress[1];
;   MinAvrPress[1] = MinAvrPress[0];
; }
mArrays_are_shifted	.macro
	MAR     *,AR2
	LAR     AR2,#_Max2DiffAdress+1
	DMOV	*-,AR2
	DMOV	*,AR2
	LAR     AR2,#MaxAvrPress+1
	DMOV	*-,AR2
	DMOV	*,AR2
	LAR     AR2,#MinAvrPress+1
	DMOV	*-,AR2
	DMOV	*,AR2
		   	.endm


;***********************************************************************
;	mIncrement_max_number();
;***********************************************************************
mIncrement_max_number     .macro

;  MaxNumber++;
;  MeasurementFlags = MeasurementFlags & (1<<FIRST_IMPULSE_FLAG)

	LACC    _MaxNumber
	ADD 	#1
	SACL    _MaxNumber
	LACC	_MeasurementFlags
	AND	#~(1<<FIRST_IMPULSE_FLAG)
	SACL    _MeasurementFlags

	.endm

;***********************************************************************
;	mZeroToAverageAmplitude();
;***********************************************************************
mZeroToAverageAmplitude     .macro

	MAR	*,AR2
	LAR	AR0,_StepNumber
	LAR	AR2,#AverageAmplitude
	MAR	*0+,AR2
	LACL	#0
	SACL	*,0,AR2
	LAR	AR2,#AvrPress
	MAR	*0+,AR2
	SACL	*,0,AR2

	.endm
