;&D
* $Id: AN_SP_UP.ASM,v 1.18 2001-10-22 13:38:10 peter Exp $
Level_zero
	LACC    SubroutMode,1
	ADD     #LevelZero_branch
	BACC

LevelZero_branch
	B	LevelZero0
	B	LevelZero1
	B	LevelZero2

Onn_Izmer
	SPLK 	#0h,_MDSPL
	mOn_Interval
	Beep
	End_measurement
	RET
Off_Izmer
	SPLK 	#0h,_MDSPL
	mOff_Interval
	Beep
	End_measurement

;	MAR	*,AR2
;	LAR	AR2,#AVRProg
;	SPLK	#1,*+
;	SPLK	#1101h,*		;SystemState
;	CALL	SendCommandAVR

	RET

LevelZero0
	mDec_counter		;CNTMOD--
	RETC 	GT
	LACC 	StartCode,0
	SUB 	#2
	BCND	Onn_Izmer,EQ
	LACC 	StartCode,0
	SUB 	#3
	BCND	Off_Izmer,EQ

	SPLK 	#6h,_MDSPL 	;переходим на номер измерения
 .if WriteDebug=0
	mWait 1			;лишнее время ждать ни к чему
 .else
	mWait3sek		;3 секунды высвечиваем номер измерения
 .endif
	mNext_sub_mode
* включаем питание
	CALL 	SuperBeep
	PowerAnalogOn
	mClear_sample_number
	LAR	AR7,#TimeOfBeginMeas
	CALL	SaveTimeOfBeginMeas
	mResetInterval		;загружаем интервал следующего измерения
	mResetFastInterval	;запоминаем три минуты
	CALL	MakeValue

	RET

LevelZero1			;высвечиваем номер измерения
	mDec_counter		;CNTMOD--
	RETC 	GT
	mNext_sub_mode
 .if WriteDebug=0
	mWait   250		; 2.5 секунды с включенным аналоговым питанием
 .else
	SPLK 	#64,ModeCnt	;
 .endif
	mClear_sample_number
	BeginADC       ;начинаем измерять ADC
*	SPLK 	#3h,_MDSPL 	;переходим на уровень давления
* отладка
       Beep
* конец отладки
	RET

LevelZero2
	mDec_counter		;CNTMOD--
	RETC 	GT
 .if WriteDebug=0
 .elseif WriteDebug<3
	LACC    StartCode,0
	SUB	#1
	BCND	NoWriteThis,NEQ
	SPLK 	#START_DEBUG_WRITE,Mode
	SPLK	#0,SubroutMode		;для первоначального case
	mClear_sample_number
	RET
NoWriteThis
 .else
 .endif

*	LACC 	PressureTop,0
*	SACL	PressureCode
*	ADD  	#TablePressValue
*	TBLR 	PressureTop

	LACC	CurrPressureLevel
	SACL	PrevPressureLevel
	ADD	#PRESS_PRESET
	SACL	PressureTop

	SPLK 	#START_SHIFT,Mode
	SPLK	#0,SubroutMode		;для первоначального case
	mClear_sample_number
;проверить питание прибора - если очень низкое, то измерение остановить
;#####################################

	RET
* .if PresetPressure=1
*TablePressValue .word  PRESS_145+PRESS_PRESET-08000h,PRESS_160+PRESS_PRESET-08000h
*		.word  PRESS_190+PRESS_PRESET-08000h,PRESS_220+PRESS_PRESET-08000h
*		.word  PRESS_250+PRESS_PRESET-08000h
* .elseif PresetPressure=0
* .else
* .emsg _ERROR __ MISSING PARAMETER_
* .endif
 .if WriteDebug=0
 .elseif WriteDebug<3
*		.word  PRESS_260+PRESS_PRESET-08000h

pStart_Debug_Write
	LACC    SubroutMode,1
	ADD     #Start_Debug_Write_branch
	BACC

Start_Debug_Write_branch
	B	Write_branch0
	B	Write_branch1
	B	Write_branch2
	B	Write_branch3
	B	Write_branch4
Write_branch0
	mNext_sub_mode
	SPLK 	#3h,_MDSPL

	LACC 	#0
	SACL 	Preset0		;Ноль в начальное значение давления
	SACL 	Preset0+1
	SACL 	Preset0+2
	SACL 	Preset1		;Ноль в начальное значение давления
	SACL 	Preset1+1
	SACL 	Preset1+2

	SPLK 	#64,ModeCnt  ;пусть фильтр выровняется
	RET

Write_branch1
	mDec_counter		;CNTMOD--
	RETC 	GT

	SendToDAC

	mNext_sub_mode
	SPLK 	#256,ModeCnt	;усреднение значения с канала
	RET

Write_branch2
	CLRC 	SXM

	MAR	*,AR6
	LAR	AR6,#_ResultADC+6;AIN6 (PR0) значение на выходе датчика

	LACC 	*,8  	;Вычисление среднего по 3-м каналам
	ADD  	#4000h,9
	AND 	#0FFFFh,8
	ADD  	Preset0+1,16
	ADDS 	Preset0+2
	SACH 	Preset0+1,0
	SACL 	Preset0+2,0
	LAR	AR6,#_ResultADC+9;AIN9 (аварийный) значение на выходе датчика

	LACC 	*,8  	;Вычисление среднего по 3-м каналам
	ADD  	#4000h,9
	AND 	#0FFFFh,8
	ADD  	Preset1+1,16
	ADDS 	Preset1+2
	SACH 	Preset1+1,0
	SACL 	Preset1+2,0

	mDec_counter		;CNTMOD--
	RETC GT

	LACC 	Preset0+1
	SACL	Preset0

	LACC 	Preset1+1
	SACL	Preset1

*
;	Beep
	mClear_sample_number

	mValve_on
	mWait_valve_hold
	mNext_sub_mode
	RET

Write_branch3
	mDec_counter		;CNTMOD--
	RETC 	GT
;	mMotor_on
	mNext_sub_mode
	mValve_hold
	mBegin_write_flash
	Beep
*	SPLK 	#iCURRENT_PRESSURE,_MDSPL 	;переходим на уровень давления
	SPLK 	#3,_MDSPL 	;переходим на уровень давления
	LACC	StartCode+1
	BCND	largeTime,NEQ
	SPLK 	#10500,ModeCnt
	RET
largeTime:
	SPLK 	#15000,ModeCnt
	RET

Write_branch4
	mClear_sample_number
	mDec_counter		;CNTMOD--
	RETC 	GT
*	mEnd_meas
	mEnd_error_meas	rCancelByUser
	RET

 .endif
