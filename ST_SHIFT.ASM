;&D
* $Id: ST_SHIFT.ASM,v 1.9 2001-11-14 17:20:54 peter Exp $
Start_shift
	LACC    _SubroutMode,1
	ADD     #Start_shift_branch
	BACC

Start_shift_branch
	B	Start_shift1
	B	Start_shift1_1
	B	Start_shift2
	B	Start_shift3
Start_shift1
;AVR тоже надо смещение высчитывать
;поэтому "убыстрение" за счет памяти предыдущего смещения
;убираем
*	MAR  	*,AR2
*	LAR  	AR2,#LastMeas
	;в течении трех минут смещение действительно
*	LACC	*
*	BCND	Start_shift_without,NEQ	;поэтому считать его не будем

	mNext_sub_mode
	SPLK 	#3h,_MDSPL 	;переходим на уровень давления
 .if WriteDebug=0
	mWait 1			;лишние 3 секунды нам ни к чему
 .else
	mWait3sek		;3 секунды высвечиваем уровень давления
 .endif
	RET

Start_shift1_1:
	mDec_counter		;CNTMOD--
	RETC 	GT
	mNext_sub_mode
	LACC 	#0
	SACL 	Preset0		;Ноль в начальное значение давления
	SACL 	Preset0+1
	SACL 	Preset0+2

	SPLK 	#64,_ModeCnt  ;пусть фильтр выровняется
	RET

Start_shift2:
	mDec_counter		;CNTMOD--
	RETC 	GT

	SendToDAC

	mNext_sub_mode
	SPLK 	#256,_ModeCnt	;усреднение значения с канала
	RET

Start_shift3:
	CLRC 	SXM

	MAR	*,AR6
	LAR	AR6,#_ResultADC+6;AIN6 (PR0) значение на выходе датчика

*	LACC 	Channel_one,8  	;Вычисление среднего по 3-м каналам
	LACC 	*,8  	;Вычисление среднего по 3-м каналам
	ADD  	#4000h,9
	AND  	#0FFFFh,8
	ADD  	Preset0+1,16
	ADDS 	Preset0+2
	SACH 	Preset0+1,0
	SACL 	Preset0+2,0

	mDec_counter		;CNTMOD--
	RETC GT

*	PresetZero+1 ;preset
	LACC 	Preset0+1
	SACL	Preset0
*Start_shift_without
	MAR  	*,AR2
	LAR  	AR2,#LastMeas
	;в течении трех минут смещение действительно
	SPLK	#3*60,*		;в секундах время
*
;	Beep
*

	SPLK 	#PRESSURE_AUGMENT_40,_Mode
        mClear_subrout_mode_err_meas
	SPLK 	#iCURRENT_PRESSURE,_MDSPL 	;переходим на уровень давления
        RET
