;&D
* $Id: BP206MAC.ASM,v 1.25 2002-04-18 14:30:38 peter Exp $

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
	SACL	*		;детский/взрослый
	CALL	SendCommandAVR
 .endm


mIncAddressToFlash .macro
	LACC IZFLLSB
	ADD  IZFLMSB,16
	ADD  #1
	SACL IZFLLSB
	SACH IZFLMSB


	SACH 	_FLADR+1,1  ;запоминаем старшую часть адреса
	AND   	#07FFFh
	SACL 	_FLADR    ;запоминаем младшую часть адреса
 .endm

*******************************
*включение аналогового питани
*******************************
PowerAnalogOn .macro
	mC5VAOnn		;записываем нолик в регистр выборки
	mOutDIOSR		;записываем выборку устройств в регистр вывода

 .endm
*******************************
*выключение аналогового питани
*******************************
PowerAnalogOff .macro
	mC5VAOff		;записываем единичку в регистр выборки
	mOutDIOSR		;записываем выборку устройств в регистр вывода
 .endm

*******************************
*включение процедуры обработки АЦП
*******************************
BeginADC .macro
	LACC _Jobs
	OR   #(1<<CallADCPRO_Flag)  	;надо начинать измерять(ADCPRO)
	SACL _Jobs
 .endm
*******************************
*выключение процедуры обработки АЦП
*******************************
EndADC .macro
	LACC _Jobs
	AND   #~(1<<CallADCPRO_Flag)  	;надо заканчивать измерять
	SACL _Jobs
 .endm

*******************************
*включение флага ручного измерения
*******************************
mManual_MeasOn .macro
	LACC _Jobs
	OR   #(1<<Manual_Meas)
	SACL _Jobs
 .endm
*******************************
*выключение флага ручного измерения
*******************************
mManual_MeasOff .macro
	LACC _Jobs
	AND   #~(1<<Manual_Meas)
	SACL _Jobs
 .endm


*******************************
*начинаем процесс измерения
*******************************
Begin_measurement .macro
	LACC _Jobs
;	OR   	#CallMeasur	;надо начинать
	OR	#(1<<CallMeasur_Flag)	;надо начинать
	SACL _Jobs
 .endm
*******************************
*заканчиваем процесс измерени
*******************************
End_measurement .macro
	LACC _Jobs
	AND	#~(1<<CallMeasur_Flag)	;сбрасываем бит
	SACL _Jobs
 .endm
*******************************
*один раз процедуру запись во флеш уже вызвали
*и подсчитали количество измерений во флеш
*******************************
mWeCountingFlash .macro
	LACC _Jobs
	OR	#(1<<WeCountingFlash)	;подсчитали количество измерений
	SACL _Jobs
 .endm
*******************************
*вызвали процедуру записи во флеш и закончили туда писАть
*флаг подсчета надо сбросить
*******************************
mWeCountingFlashEnd .macro
	LACC _Jobs
	AND	#~(1<<WeCountingFlash)	;сбрасываем бит
	SACL _Jobs
 .endm
*******************************
* устанавливаем флаг отсутствия места во флеш
*******************************
mNoPlaceInFlash .macro
	LACC _Jobs
	OR	#(1<<NoPlaceInFlash)	;подсчитали количество измерений
	SACL _Jobs
 .endm
*******************************
* сбрасываем флаг отсутствия места во флеш
*******************************
mNoPlaceInFlashClear .macro
	LACC _Jobs
	AND	#~(1<<NoPlaceInFlash)	;сбрасываем бит
	SACL _Jobs
 .endm
*******************************
*надо загнать в ЦАП значение,и
*установить сброс значения в канал
*******************************
SendToDAC .macro
	LACC _Jobs
;	OR   #SendValToDAC  	;надо загнать в ЦАП значение,и
;				;установить сброс значения в канал
	OR   #(1<<SendToDAC_Flag)	;надо загнать в ЦАП значение,и
					;установить сброс значения в канал

	SACL _Jobs
 .endm
*******************************
*значение в ЦАП загнали
*******************************
ClearSendToDAC .macro
	LACC _Jobs
;	AND   #SendToValDACmask
	AND   #~(1<<SendToDAC_Flag)	;надо загнать в ЦАП значение,и
					;установить сброс значения в канал

	SACL _Jobs
 .endm

*******************************
*надо считать значение ЦАП
*******************************
ReadDAC .macro
	LACC _Jobs
;	OR   #ReadDACVal
	OR   #(1<<ReadDACVal_Flag)

	SACL _Jobs
 .endm
*******************************
*значение ЦАП считали уже
*******************************
ClearReadDAC .macro
	LACC _Jobs
;	AND  #ReadDACValmask	;значение ЦАП считали уже
	AND  #~(1<<ReadDACVal_Flag)
	SACL _Jobs
 .endm

*******************************
* один короткий звонок
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
* выключаем один короткий звонок
*******************************
mBeepEnd .macro
	LACC 	_Jobs
	AND	#~(1<<BeepLittle_Flag)	;кончаем баловаться(пищать)
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
* один длинный звонок
*******************************
BeepLong .macro
	LACC 	_Jobs
	OR	#(1<<BeepLong_Flag)
	SACL 	_Jobs
 .endm
*******************************
* выключаем один длинный звонок
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

	LACC _DPA0,0     ;Включение клапана (VALV1 и VALV2)
	OR   #0018h,0
	SACL _DPA0
	OUT  _DPA0,PA0

 .endm

mValve_hold	.macro

	LACC _DPA0,0     ;перевод клапана на удержание
	AND  #0FFEFh,0  ;сбрасываем бит VALV2
	SACL _DPA0
	OUT  _DPA0,PA0

 .endm

mValve_off	.macro

	LACC _DPA0,0     ;Выключение VALV (открытие клапана)
	AND  #0FFE7h,0
	SACL _DPA0
	OUT  _DPA0,PA0

 .endm
******************************
* включение мотора
******************************
mMotor_on	.macro

	LACC _DPA0,0     ;Включение мотора
	OR   #0004h,0   ;устанавливаем бит PUMP
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
* выключение мотора
*******************************
mMotor_off	.macro

	LACC _DPA0,0     ;Выключение PUMP
	AND  #0FFFBh,0
	SACL _DPA0
	OUT  _DPA0,PA0
	LACC _Jobs
;	AND   #MotorIsOnnmask
	AND   #~(1<<MotorIsOnn_Flag)
	SACL _Jobs

 .endm

********************************
* эти функции включения мотора и выключени
* используются программным ШИМ управления мотором
* в других случаях "лучше" использовать
* mMotor_onn и mMotor_off
********************************
mMotor_on_f	.macro
	LACC _DPA0,0     ;Включение мотора
	OR   #0004h,0   ;устанавливаем бит PUMP
	SACL _DPA0
	OUT  _DPA0,PA0
 .endm

mMotor_off_f	.macro
	LACC _DPA0,0     ;Выключение PUMP
	AND  #0FFFBh,0
	SACL _DPA0
	OUT  _DPA0,PA0
 .endm

****************************
* уменьшение счетчика нахождения на режиме
****************************
mDec_counter	.macro
	LACC 	_ModeCnt,0
	SUB  	#1
	SACL 	_ModeCnt
 .endm

mWait3sek	.macro
	SPLK 	#300,_ModeCnt  ;3 секунды
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
        ;это автоматическое измерение
        SPLK	#6,ProtectShow
$5
	LACC 	ProtectShow
	SUB	#5
        BCND	$4,LT
	BIT 	_Jobs,15-MayShowRes_Flag     	;показывать результаты
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
* Макрос сохранения вычислительных регистров стеке
* стек организуется в 0 странице (DP 0)
* AR1 используется указателем на стека
* AR1 при инициализации должен равен 07Fh
*     (не должен нигде использоваться)
* сохраняется ACC,PREG,TREG,AR0-AR7
	SST     #0,SST0		;сохранение статусных регистров
	SST     #1,SST1		;0 и 1 в странице DP 0
	MAR     *,AR1
	MAR     *+,AR1
	SACL    *+		; Сохpанение в стек ACC_L
	SACH    *+		; Сохpанение в стек ACC_H
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
* Макрос восстановления вычислительных регистров из стека
* стек организуется в 0 странице (DP 0)
* AR1 используется указателем на стек
*     (не должен нигде использоваться)
* восстановление обратно макросу mPush_stack
	MAR     *,AR1           ;  Восстановление пpедыдущего состояния
	MAR     *-,AR1          ;  выводим указатель на нужное место
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
	LACC    *-,16		;восстановление ACC_H
	OR      *-		;хитро восстанавливаем ACC_L
	LDP	#0
	LST     #1,SST1      	;восстановление статусных регистров 0 и 1
	LST     #0,SST0      	;первым надо восстанавливать ST1
 .endm

mImp_ssp	.macro
	CLRC 	XF
	SETC 	XF
 .endm

mBeeper_xor	.macro
	LACC 	_DPA0,0     	;инвертируем значение бипера
	XOR  	#01h
	SACL 	_DPA0
	OUT  	_DPA0,PA0   	;вывод состояние ячейки в порт
 .endm

**************************
* начинаем запись во флеш
**************************
mBegin_write_flash	.macro

	LACC _Jobs
;	OR   #BeginWriteFlash
	OR   #(1<<BegWrFlash_Flag)
	SACL _Jobs
	CALL	MakeValue	;чтобы создать таблицу
 .endm


**************************
* сбрасываем бит записи во флеш
**************************
mEnd_write_flash	.macro
	LACC _Jobs
;	AND   #BeginWriteFlashm
	AND   #~(1<<BegWrFlash_Flag)
	SACL _Jobs
 .endm

* установка текущего времени в ноль :(
mResetTime	.macro
	MAR	*,AR7
	LAR	AR7,#_WATCH
	LACC	#0
	RPT	#6
	SACL	*+
 .endm

* загрузка интервала в зависимости от суток
* а также с учетом специнтервала
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
	;сейчас в
	;TMP+0 - единицы часов начала дн
	;TMP+1 - десятки часов начала дн
	;TMP+2 - единицы часов окончания дня (до)
	;TMP+3 - десятки часов окончания дня (до)
	;спец интервал
	;TMP+4 - единицы часов начала дн
	;TMP+5 - десятки часов начала дн
	;TMP+6 - единицы часов окончания дня (до)
	;TMP+7 - десятки часов окончания дня (до)

;преобразуем времена к бинарному виду и в младших ячейках запоминаем
	LACC	TMP+1,3		;*8
	ADD	TMP+1,1		;+*2
	ADD	TMP+0
	SACL	TMP+0		;начало дн

	LACC	TMP+3,3		;*8
	ADD	TMP+3,1		;+*2
	ADD	TMP+2
	SACL	TMP+2		;окончание дн

	LACC	TMP+5,3		;*8
	ADD	TMP+5,1		;+*2
	ADD	TMP+4
	SACL	TMP+4		;начало дн

	LACC	TMP+7,3		;*8
	ADD	TMP+7,1		;+*2
	ADD	TMP+6
	SACL	TMP+6		;окончание дн

	LAR	AR6,#_WATCH+5
	MAR	*,AR6

	LACC	*,3		;*8
	ADD	*-,1
	ADD	*
	SACL	TMP+7		;текущее врем

	;сейчас в
	;TMP+0 - часов начала дн
	;TMP+2 - часов окончания дня (до)
	;спец интервал
	;TMP+4 - часов начала дн
	;TMP+6 - часов окончания дня (до)
	;TMP+7 - часов текущего времени


	LACC	TMP+6
	SUB	TMP+4
	BCND	SpecNaoborot,LT	;специнтервал наоборот

	LACC	TMP+7
	SUB	TMP+4
	BCND	NotSpecial,LT	;в спец интервал не попадает

	LACC	TMP+6
	SUB	TMP+7
	BCND	NotSpecial,LEQ	;в спец интервал не попадает
	;СПЕЦИАЛЬНЫЙ ИНТЕРВАЛ!!!
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

	;сейчас в
	;TMP+0 - часов начала дн
	;TMP+2 - часов окончания дня (до)
	;спец интервал
	;TMP+4 - часов начала дн
	;TMP+6 - часов окончания дня (до)
	;TMP+7 - часов текущего времени

	LACC	TMP+2
	SUB	TMP+0
	BCND	DayNaoborot,LT	;специнтервал наоборот
	LACC	TMP+7
	SUB	TMP+0
	BCND	NotDay,LT	;в дневной интервал не попадает

	LACC	TMP+2
	SUB	TMP+7
	BCND	NotDay,LEQ	;в дневной интервал не попадает
	;Дневной ИНТЕРВАЛ!!!
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

	;Ночной ИНТЕРВАЛ!!!
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
	SPLK	#180,*		;3*60 секунд
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
	SPLK	#5,*		;пять секунд
 .endm
mSetInterval3min .macro
	MAR	*,AR2
	LAR	AR2,#CounterToBegin

	SPLK	#180,*		;3*60 секунд
 .endm

mOn_Interval	.macro
 .newblock

	LACC _Jobs
	OR   #(1<<OnInterval_Flag)
	SACL _Jobs
*	mLoadInterval
	SUB	#1	;если интервал не в пределах
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

;чтение интервалов измерений
; дневного, ночного, специального
; преобразование в секунды
; и помещение в специальные ячейки

*!! пока не будем
; чтение промежутков времени
; когда день, когда ночь, когда спец интервал?

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
	IN   	TMP,SDTR     ;команда лишнего чтени
				;для стабильности(надежности) работы с SSP

	SPLK 	#0EC00h,TMP  ;software power down
	OUT  	TMP,SDTR

	mImp_ssp              ;подгоняем SSP к началу передачи MSB
	mImp_ssp
	mImp_ssp

	mOnADC
	mOutDIOSR

	CALL 	CLKXF           ;1-передаем первое слово

	mOffPeriph
	mOutDIOSR

	IN   	TMP,SDTR     ;команда лишнего чтени
	IN   	TMP,SDTR     ;команда лишнего чтени

	SPLK 	#SSPR,TMP    ;RESET SSP
	OUT  	TMP,SSPCR

 .endm


;записываем выборку устройств в регистр вывода
mOutDIOSR	.macro
	OUT  	_rDIOSR,IOSR      ;записываем в IO status register
 .endm


******************
*версия без дешифратора
* IO0 - #CSADC
* IO1 - #CSDAC
* IO2 - #C5VA
* IO3
*версия с дешифратором
* IO0,IO1,IO2 на дешифратор, поэтому
* 000 - #CSADC
* 001 - #CSDAC
* 010 - #CSF0	-выборка первой флеши
* 011 - #CSF1	-выборка второй флеши
*
* IO3 - #C5VA
******************


;выключаем всю выборку
 .if VersionFerrum=1		;без дешифратора

mOffPeriph	.macro
	LACC 	_rDIOSR
	OR	#03H		;уст в 1 IO0(#CS0),IO1(#CS1)
	SACL 	_rDIOSR
 .endm
 .elseif VersionFerrum=2        ;с дешифратором
mOffPeriph	.macro
	LACC 	_rDIOSR
	OR	#07H		;дешифратор
	SACL 	_rDIOSR
 .endm
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

;включаем выборку АЦП
 .if VersionFerrum=1		;без дешифратора

mOnADC	.macro
	LACC 	_rDIOSR
	AND  	#0EH  		;сбрасываем в ноль IO0(#CS0)
	SACL 	_rDIOSR
 .endm
 .elseif VersionFerrum=2        ;с дешифратором
mOnADC	.macro
	LACC 	_rDIOSR
	AND  	#08H  		;сбрасываем в ноль #CSADC
	SACL 	_rDIOSR
 .endm
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

;включаем выборку ЦАП
 .if VersionFerrum=1		;без дешифратора
mOnDAC	.macro
	LACC 	_rDIOSR
	AND  	#0DH  		;сбрасываем в ноль IO1(#CS1)
	SACL 	_rDIOSR
 .endm

 .elseif VersionFerrum=2        ;с дешифратором
mOnDAC	.macro
	LACC 	_rDIOSR
	AND  	#08H
	OR	#01h		;устанавливаем в ноль #CSDAC
	SACL 	_rDIOSR
 .endm
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif



*************

 .if VersionFerrum=1		;без дешифратора
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

 .elseif VersionFerrum=2        ;с дешифратором
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

 .if VersionFerrum=1		;без дешифратора

 .elseif VersionFerrum=2        ;с дешифратором
mOnFlash0	.macro
	LACC 	_rDIOSR
	AND  	#08H
	OR	#02h		;устанавливаем в ноль #CSF0
	SACL 	_rDIOSR
 .endm
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

 .if VersionFerrum=1		;без дешифратора
mRead_512b	.macro
 .newblock
*  ASFLMSB     15-20bit
*  AFLLSB      0-14bit
* чтение страницы
*  адрес для чтения, из него выбрать адрес страницы
*  ASFLMSB     15-20bit
*  AFLLSB      0-14bit
*	AR7 - куда загружать
* процедура берет байты из флеш и загружает парами в слова AR7
* то есть начальный адрес должен быть четным
*	AR7 - куда загружать

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
	LACC	*+,0,AR1	;берем четный байт
	AND	#0FFh
	SACL	*,0,AR2		;записываем в стек

	LACC	*+,8,AR1	;берем нечетный байт
	AND	#0FF00H
*	OR	*		;складываем со значением в стеке
*	MAR	*,AR7
	OR	*,AR7
	SACL	*+,0,AR0	;записываем в буффер
	BANZ    $1,*-,AR2	;считаем 256 слов
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
 .elseif VersionFerrum=2        ;с дешифратором
mRead_512b	.macro
 .newblock
*  PA11-0 - адрес страницы
*  BA9-0  - адрес байта внутри страницы
*  X      - неважно что
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
	IN   	*,SDTR     ;команда лишнего чтени
				;для стабильности(надежности) работы с SSP
	SPLK	#0,*
	OUT  	*,SDTR     	;0.нулевое :) слово для передачи

	LACC    _FLADR+1,1
 .if Mem=20	;одна микросхема на 2 Mbyte
	AND	#003Fh,1
 .elseif Mem=40	;одна микросхема на 4 Mbyte
	AND	#007Fh,1
 .elseif Mem=44	;две микросхемы на 4 Mbyte
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
	OUT  	*,SDTR     	;1.первое слово для передачи
				;([code][page_msb])

	mImp_ssp              	;подгоняем SSP к началу передачи MSB
	mImp_ssp
*	mImp_ssp

	CALL 	$2           ;0-передаем нулевое ;) слово


	;включить выборку флеш
	mOnFlash0
	mOutDIOSR


	LACC    _FLADR,2
	AND     #0FC00h,1
	SACL 	*
	OUT  	*,SDTR     	;2.второе слово для передачи
				;([page_lsb][adress])
	mImp_ssp		; передаем "лишний" бит

	CALL 	$2           ;1-передаем первое слово
	IN   	*,SDTR     	;(0)чтение нулевого результата (мусор)
	IN   	*,SDTR     	;(1)чтение первого результата (мусор)
	OUT	*,SDTR     	;3.четвертое слово для передачи
				;([неважно что])

	CALL 	$2           ;2-передаем второе слово
	IN   	*,SDTR     	;(2)чтение второго результата (мусор)
	OUT	*,SDTR     	;4.пятое слово для передачи
				;([неважно что])

	CALL 	$2           ;3-передаем третье слово
	IN   	*,SDTR     	;(3)чтение третьего результата (мусор)
	OUT	*,SDTR     	;5.шестое слово для передачи
				;([неважно что])

	CALL 	$2           ;4-передаем четвертое слово
	IN   	*,SDTR     	;(4)чтение четвертого результата (мусор)
	OUT	*,SDTR,AR7     	;6.шестое слово для передачи
				;([неважно что])

	LAR	AR0,#255-2



$1
	CALL 	$2           ;передаем 5+N слово (N=0..255)
*************************************************
* для новой платы данные идут с инверсией
* здесь будет жить дополнительный блок инверсии данных
 .if NewFerrum=1
	IN   	*,SDTR     	;чтение 5+N результата (слово данных N=0..255)
	LACC	#0FFFFH
	XOR	*
	SACL	*+
 .else
* в старых платах инверсии нет
	IN   	*+,SDTR     	;чтение 5+N результата (слово данных N=0..255)
 .endif
	;;в * данные

	OUT	*,SDTR,AR0     	;7+N слово для передачи
				;([неважно что])
*	MAR	*,AR0
	BANZ    $1,*-,AR7

	CALL 	$2           	;предпоследнее слово(N=254)
*************************************************
* для новой платы данные идут с инверсией
* здесь будет жить дополнительный блок инверсии данных
 .if NewFerrum=1
	IN   	*,SDTR     	;чтение результата (слово данных N=254)
	;;в * данные
	LACC	#0FFFFH
	XOR	*
	SACL	*+
 .else
* в старых платах инверсии нет
	IN   	*+,SDTR     	;чтение результата (слово данных N=254)
	;;в * данные
 .endif

	CALL 	$2           	;последнее слово(N=255)
*************************************************
* для новой платы данные идут с инверсией
* здесь будет жить дополнительный блок инверсии данных
 .if NewFerrum=1
	IN   	*,SDTR    	;чтение результата (слово данных N=255)
	;;в * данные
	LACC	#0FFFFH
	XOR	*
	SACL	*+,0,AR1
 .else
* в старых платах инверсии нет
	IN   	*+,SDTR,AR1    	;чтение результата (слово данных N=255)
	;;в * данные
 .endif

	;выключить выборку флеш
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

 .if VersionFerrum=1		;без дешифратора

 .elseif VersionFerrum=2        ;с дешифратором
* gh
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif


mDelay250mks	.macro

* время посчитать !!!!!!!!
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

	LACC 	_DPA0,0     ;инвертируем значение бипера
	XOR  	#01h
	SACL 	_DPA0
	OUT  	_DPA0,PA0   ;вывод состояние ячейки в порт
 .endm
WriteParams .macro code

 .if code=00
**      записываем 0
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

**** чтение с первого канала АЦП
	CLRC 	SXM
	LAR  	AR2,#SR30       ;Адреса начала сдвиг.рег.ФНЧ
	MAR  	*,AR2
	LACC 	*,12       ;считываем значение полученное с АЦП
	ADD  	#1000h,15 ; на 16 сдвигать нельзя, поэтому так извратились
	AND  	#0FFFh,16

	SUB 	BeginLevel,16
	BCND 	$1,GEQ ;больше или равно нулю
	SetC 	SXM
	SACH 	TMP
	LACC 	TMP
	ADD  	#7FH
	BCND 	$2,GEQ
	SPLK 	#0FF80H,TMP   ;записываем максимальную величину приращени
	B 	$2
;Abovech2
$1
	SACH 	TMP
	LACC 	TMP
	SUB 	#07Fh
	BCND 	$2,LT
	SPLK 	#07EH,TMP   ;записываем максимальную величину приращени
;LessOverCh2
$2
	LACC 	BeginLevel
	ADD  	TMP
	SACL 	BeginLevel
	CLRC 	SXM            ;записываем канал до фильтра байт
	CALL 	FLPROG

	LACC 	AFLLSB    ;увеличиваем адрес на единицу
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

**** чтение с первого канала после фильтра
	CLRC 	SXM
	LACC 	_OUTF+2,12

	SUB 	BeginLevel+1,16
	BCND 	$1,GEQ ;больше или равно нулю
	SetC 	SXM
	SACH 	TMP
	LACC 	TMP
	ADD  	#7FH
	BCND 	$2,GEQ
	SPLK 	#0FF80H,TMP   ;записываем максимальную величину приращени
	B 	$2
$1
	SACH 	TMP
	LACC 	TMP
	SUB 	#07Fh
	BCND 	$2,LT
	SPLK 	#07EH,TMP   ;записываем максимальную величину приращени
$2
	LACC 	BeginLevel+1
	ADD  	TMP
	SACL 	BeginLevel+1
	CLRC 	SXM            ;записываем канал до фильтра байт
	CALL 	FLPROG

	LACC 	AFLLSB    ;увеличиваем адрес на единицу
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

**** чтение со второго канала (мл. часть) с АЦП
	CLRC 	SXM
*	LAR  	AR2,#SR30+16       ;Адреса начала сдвиг.рег.ФНЧ
*	MAR  	*,AR2
*	LACC 	*,12

	MAR	*,AR6
	LAR	AR6,#_ResultADC+9;AIN9 (PR3)

*	LACC	Channel_two,12
	LACC	*,12
	SACH 	TMP
	CALL 	FLPROG


**** чтение с второго канала (ст. часть) с АЦП
*	LAR  	AR2,#SR30+16       ;Адреса начала сдвиг.рег.ФНЧ
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

**** чтение со второго канала (мл. часть) с АЦП
*!! исключая нуль
	CLRC 	SXM
	LAR  	AR2,#SR30+16       ;Адреса начала сдвиг.рег.ФНЧ
	MAR  	*,AR2
	LACC 	*,16
	BCND 	$3,NEQ
	ADD  	#16,15
$3
	SACH 	TMP
	CALL 	FLPROG

	LACC 	AFLLSB    ;увеличиваем адрес на единицу
	ADD  	#1
	SACL 	AFLLSB
	AND  	#07FFFh
	BCND 	$1,NEQ
	LACC 	AFLMSB
	ADD  	#1
	SACL 	AFLMSB
$1

**** чтение с второго канала (ст. часть) с АЦП
	LAR  	AR2,#SR30+16       ;Адреса начала сдвиг.рег.ФНЧ
	MAR  	*,AR2
	LACC 	*,8
	ADD  	#100h,15

	SACH 	TMP
	CALL 	FLPROG

	LACC 	AFLLSB    ;увеличиваем адрес на единицу
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
**** чтение со второго канала после фильтра (мл. часть)
	CLRC 	SXM
	LACC 	_OUTF+1,16   ;второй сигнал - младшая часть после фильтра
*        ;для 12 разрядов   LACC _OUTF+1,12
	SACH 	TMP
	CALL 	FLPROG

	LACC 	AFLLSB    ;увеличиваем адрес на единицу
	ADD  	#1
	SACL 	AFLLSB
	AND  	#07FFFh
	BCND 	$1,NEQ
	LACC 	AFLMSB
	ADD  	#1
	SACL 	AFLMSB
$1
	LACC 	_OUTF+1,8    ;
*        ;для 12 разрядов   LACC _OUTF+1,4
	SACH 	TMP
	CALL 	FLPROG

	LACC 	AFLLSB    ;увеличиваем адрес на единицу
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
**** чтение с усиленного канала (мл. часть) с АЦП
	CLRC 	SXM
	LACC 	TMPADC+1,12
	SACH 	TMP
	CALL 	FLPROG

	LACC 	AFLLSB    ;увеличиваем адрес на единицу
	ADD  	#1
	SACL 	AFLLSB
	AND  	#07FFFh
	BCND 	$1,NEQ
	LACC 	AFLMSB
	ADD  	#1
	SACL 	AFLMSB
$1

**** чтение с усиленного канала (ст. часть) с АЦП
	LACC 	TMPADC+1,4
	ADD  	#10h,15
	AND  	#0Fh,16

	SACH 	TMP
	CALL 	FLPROG

	LACC 	AFLLSB    ;увеличиваем адрес на единицу
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
**** чтение с усиленного канала после фильтра (мл. часть)
;	CLRC 	SXM
	SETC	SXM
	LACC 	_OUTF   ;усиленный сигнал - младшая часть после фильтра
*	LAR  	AR2,#SR30       ;Адреса начала сдвиг.рег.ФНЧ
*	MAR  	*,AR2
*	LACC 	*       ;считываем значение полученное с АЦП

	SUB	Preset0
	ADD	#4000h,1

*        ;для 12 разрядов   LACC _OUTF,12
	SACL 	TMP
	CALL 	FLPROG

	LACC 	_OUTF,8    ;усиленный сигнал - старшая часть
*	LAR  	AR2,#SR30       ;Адреса начала сдвиг.рег.ФНЧ
*	MAR  	*,AR2
*	LACC 	*,8       ;считываем значение полученное с АЦП

	SUB	Preset0,8
	ADD	#4000h,9
*        ;для 12 разрядов   LACC _OUTF,4
	SACH 	TMP
	CALL 	FLPROG

 .newblock
 .elseif code=33

**** чтение с усиленного канала (мл. часть) с АЦП
	CLRC SXM
	LAR  AR2,#SR30+32       ;Адреса начала сдвиг.рег.ФНЧ
	MAR  *,AR2
	LACC *,16
	SACH TMP
	CALL FLPROG

	LACC AFLLSB    ;увеличиваем адрес на единицу
	ADD  #1
	SACL AFLLSB
	AND  #07FFFh
	BCND $1,NEQ
	LACC AFLMSB
	ADD  #1
        SACL AFLMSB
$1

**** чтение с усиленного канала (ст. часть) с АЦП
        LAR  AR2,#SR30+32       ;Адреса начала сдвиг.рег.ФНЧ
        MAR  *,AR2
        LACC *,8
        ADD  #100h,15

	SACH TMP
        CALL FLPROG

        LACC AFLLSB    ;увеличиваем адрес на единицу
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
**** запись переменной DAC2
        CLRC SXM
        LACC DAC2,12
	SACH TMP
        CALL FLPROG

	LACC AFLLSB    ;увеличиваем адрес на единицу
        ADD  #1
        SACL AFLLSB
        AND  #07FFFh
	BCND $1,NEQ
        LACC AFLMSB
        ADD  #1
        SACL AFLMSB
$1

**** запись переменной DAC2 старшей части
        LACC DAC2,4
        ADD  #10h,15
        AND  #0Fh,16

	SACH TMP
        CALL FLPROG

        LACC AFLLSB    ;увеличиваем адрес на единицу
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
**** запись переменной DAC2
        CLRC SXM
        LACC TMPADC1,12
	SACH TMP
        CALL FLPROG

        LACC AFLLSB    ;увеличиваем адрес на единицу
        ADD  #1
        SACL AFLLSB
	AND  #07FFFh
        BCND $1,NEQ
        LACC AFLMSB
        ADD  #1
        SACL AFLMSB
$1

**** запись переменной DAC2 старшей части
        LACC TMPADC1,4
        ADD  #10h,15
        AND  #0Fh,16

	SACH TMP
        CALL FLPROG

	LACC AFLLSB    ;увеличиваем адрес на единицу
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
	LAR     AR7,#_ResultADC+0       ;Адреса PL3
	MAR     *,AR7
	LACC	*
	ADD     #4000h,1
;	AND     #0FFFFh


	SACL 	TMP
	CALL 	FLPROG

	LAR  AR7,#_ResultADC+0      ;Адреса  PL3
	MAR  *,AR7

	LACC 	*,8
	ADD     #4000h,1+8
	SACH 	TMP
	CALL 	FLPROG
 .elseif code =2
	SETC	SXM
	LAR  AR7,#_ResultADC+2       ;Адреса PL3
	MAR  *,AR7

	LACC 	*
	ADD     #4000h,1

	SACL 	TMP
	CALL 	FLPROG

	LAR  AR7,#_ResultADC+2      ;Адреса  PL3
	MAR  *,AR7

	LACC 	*,8
	ADD     #4000h,1+8
	SACH 	TMP
	CALL 	FLPROG
 .endif
 .endm

**************************************************************************
; Алгоритм стравливания "Pressure_diminition_2" требует инициализации
; следующих переменных:
**************************************************************************
; перед измерением.
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

; после включения питания.
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
; /* При инициализации процесса измерения */
; StartMeasAdress[StepNumber] = 0;
; SubroutMode = 0;
; MaxNumber = 0;                           // Номер максимума.
; StartMaxNumber = 0;
; MaxNumberShift = 0;
; StepNumber = 0;
; SampleNumber = 0;
; SampleNumberShift = 0;
; ErrMeas = 0;
; MaxAverageAmplitude = 0;
; SistolPressure = 0;
; DiastolPressure = 0;
; AnalysisInterval = 32*1.25;  // минимальный AnalysisInterval
; AnalysisStart = AnalysisInterval + 2*DIFF_BASIS;
; MeasurementFlags = MeasurementFlags &
;                 (~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)));
*
*       Макрос mMeasurement_ находится в файле BP206mac.asm
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
