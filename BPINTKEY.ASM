*****************************************************************************
*       Прерывание или запуск процессов по кнопке
* $Id: BPINTKEY.ASM,v 1.15 2001-06-07 07:10:45 peter Exp $
*****************************************************************************
*

INTKEY
	mPush_stack		;сохранение вычислительных
				;регистров в стеке
	LDP  	#4

	IN      *,ICR          ;ICR(IS@0FFECh) ->STACK

	LACC 	*          	;load accumulator
	AND	#04H
	BCND	ItIsKeybord,NEQ
	LACC 	*          	;load accumulator with shift
	AND  	#0FFFBh    	;чтобы не затронуть pending FINT2,
				;его бит обнуляем
	SACL	*
	OUT 	*,ICR           ;ICR(IS@0FFECh) ->STACK
				;pending INT3 (store 1->FINT3)
	LAR  	AR1,#IFR	;загружаем указатель на Interrupt Flag Register
	MAR  	*,AR1      	;modify auxiliary register
				;данная команда из подмножества LARP 1
				;т.е. при дальнейшей записи индексом AR1

	SPLK 	#02h,*     	;pending INT2

	BIT     Jobs,15			;процесс измерения идет?
	BCND    int3_IzmNeIdet,NTC
;//записать состояние ошибочного прерывания
	mEnd_error_meas	rNeispraven
int3_IzmNeIdet
	B	QuitFromINTKEY

ItIsKeybord:
	MAR	*,AR6
	LAR	AR6,#iCNTKEYB

	SPLK 	#CNSTKEYB,*

	Beep

	LACC 	MDSPL,1 ;вызываем процедуру в зависимости от режима
	ADD  	#KEY1
	CALA


	LAR  	AR1,#IMR       	;load auxiliary reg #IMR -> AR1
				;interrupt mask register
	MAR  	*,AR1      	;modify auxiliary register
				;данная команда из подмножества LARP 1
				;т.е. при дальнейшей записи индексом AR1
	LACC 	*              	;load accumulator with shift
	AND  	#0FFFDh        	;очищаем маску INT2(запрещаем эти прерывания)
	SACL 	*              	;store mask interrupts

QuitFromINTKEY
	mPop_stack		;восстановление вычислительных регистров
				;из стека
	CLRC 	INTM   		;разрешение прерываний
				;при выходе из прерывания
	RET

****************************************************************************
*вектора вызовов процедур нажатий на кнопки
****************************************************************************
KEY1    B KEY10 ;на экране время
	B KEY11 ;на экране время с секундами
	B KEY12 ;Текущее давление Канал 0->на дисплей
	B KEY13 ;Текущее давление Канал 1->на дисплей
	B KEY14 ;Текущее давление Канал 2->на дисплей
	B KEY15 ;вывод кода ошибки на экран
	B KEY16 ;в режиме начала измерения давления
	B KEY17 ;в режиме вывода на экран количества
		;принятых и переданных байтов
	B KEY18 ;уровень максимального давления
	B KEY19 	;индикация систолического давления
	B KEY110 	;индикация пульса
	B KEY111 	;индикация диастолического давления
	B KEY112 	;индикация текущего давления (при накачке)
	B KEY10  	; вывод времени, сколько осталось до измерения
KEY19
KEY110
KEY111
	SPLK 	#0h,MDSPL
	RET
KEY112   SPLK 	#0h,MDSPL
	mEnd_error_meas rCancelByUser
	RET

KEY10:
	LAR  	AR1,#ProtectInterval	;защитный интервал?
	LACC	*
	BCND	MayPressed,EQ
        Beep
        RET
MayPressed:
	mManual_MeasOn
	BIT 	Flags,0
	BCND    MognoIzmerat,NTC
	SPLK	#rPowerLow,DispErrMeas
	RET
MognoIzmerat

	LACC	ShedulerReady
	BCND	NotVistrelShed,EQ
	mOn_Interval

;объеденить вызов проверки при инициализации
	CALL	CheckScheduler
	SPLK	#0,ShedulerReady
	B	KEY10_1

NotVistrelShed
	SPLK	#1,Standartmeas		;измерение внеплановое
KEY10_1

	SPLK 	#8h,MDSPL
	SPLK 	#SUPPLY_UP,Mode
	SPLK	#0,StartCode		;код установки
					;режима на "давление"
	LACC	PrevPressureLevel	; "запомненное" давление
					; назначаем текущим
	SACL	CurrPressureLevel

	SPLK	#0,SubroutMode		;для первоначального case
	SPLK	#0,TimeNakachka		;время накачки до 40 mm
 .if Only_Pusk=1
	mWait	1 		;1_100 секунды высвечиваем уровень давления
 .elseif Only_Pusk=0
	mWait3sek		;3 секунды высвечиваем уровень давления
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	Begin_measurement
	Clear_measurement


	RET
KEY11
 .if Sertificarion=1
	SPLK 	#0h,MDSPL
	RET
 .else
	SPLK 	#3h,MDSPL
	BeginADC
 .endif
	RET
KEY12   SPLK 	#3h,MDSPL
	LACC 	DPA0,0     ;Выключение PUMP,VALV1 и VALV2
	AND  	#0FFE3h,0
	SACL 	DPA0
	OUT  	DPA0,PA0   ;вывод состояние ячейки в порт
	EndADC
	PowerAnalogOff
	SPLK 	#rCancelByUser,ErrMeas
	CALL 	WriteEnd
	RET
KEY13   SPLK  #0h,MDSPL
        mEnd_error_meas rCancelByUser
        RET

KEY14   SPLK 	#0h,MDSPL
	LACC 	Jobs
	AND   	#0FFFEh     ;кончаем баловаться
	SACL 	Jobs
	EndADC
	PowerAnalogOff
	RET
KEY15   MAR	*,AR6
	LAR	AR6,#iCNTERROR
	SPLK 	#0h,*
	SPLK 	#0h,MDSPL
	RET
KEY16   SPLK 	#0h,MDSPL
	mEnd_error_meas rCancelByUser
	RET
KEY17   SPLK 	#0h,MDSPL
	RET
KEY18
 .if Only_Pusk=1
	RET
 .elseif Only_Pusk=0
	mWait3sek		;3 секунды высвечиваем уровень давления
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	Clear_measurement
	SETC 	SXM
*******************************************
* если можно менять начальный уровень накачки давления
* то это делается в режиме 0
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
* если режим отладочной записи выключен,
* то проскакиваем этот режим
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
* если режим изменения режима щедулера выключен
* то проскакиваем этот режим
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
