;&D
*****************************************************************************
* режимы прибора (измерение давления, вывод ошибки на экран и т.д.)
* $Id: BPMODE.ASM,v 1.12 2001-10-22 13:38:14 peter Exp $
*****************************************************************************

	SETC    SXM
        SPM     #0
 .if DebugStop=1
	SPLK	#0,TMP
	CALL	CheckError
 .endif
	LACC    Mode,2
	ADD     #Mode_branch
	BACC

Mode_branch
***************************
* Включение питания аналоговой схемы.
***************************
	CALL	Level_zero
	B       End_mode

***************************
* Проверка начального смещения АЦП ( 1-й канал ).
***************************
	CALL	Start_shift
	B	End_mode

***************************
* Увеличение давления до 40  мм.рт.ст.
***************************
	CALL    Pressure_augment_40
	B       End_mode
;VALVE_WORKING_CHECK
***************************
* Проверка работы ЦАП(калибровка)
***************************
	CALL    DAC_working_check
	B       End_mode

***************************
* Оценка частоты пульса на 40 мм.рт.ст.
***************************
	CALL    Pulse_frequency_evaluation_40
	B       End_mode
;HERMITICITY_CHECK
***************************
* Увеличение давления до 80  мм.рт.ст.
***************************
	CALL    Pressure_augment_80
	B       End_mode
;VALVE_WORKING_CHECK
***************************
* Оценка частоты пульса на 80 мм.рт.ст.
***************************
	CALL    Pulse_frequency_evaluation_80
	B       End_mode
;HERMITICITY_CHECK
***************************
* Увеличение давления до систолическое + N мм.рт.ст.
***************************
	CALL    Pressure_augment
	B       End_mode

***************************
* Остановка увеличения давлени
***************************
	CALL    Pressure_augment_stop
	B       End_mode

***************************
* Проверка превышения систолического давлени
***************************
	CALL    Check_higher_sistol_pressure
	B       End_mode

***************************
* Измерение амплитуд пульсаций и уровня давлени
***************************
	CALL    Pressure_measurement
	B       End_mode

***************************
* Понижение уровня давления на 8 мм.рт.ст.
***************************
	CALL    Pressure_diminution_1
	B       End_mode

***************************
* Вывод результатов измерения на индикатор
***************************
	CALL	Measurment_finish
	B       End_mode

 .if Sertificarion=1
***************************
* пустое стояние на ступеньке 2-3 секунды
***************************
	CALL    Pressure_measurement_Manual
	B       End_mode
 .endif

 .if WriteDebug=0
 .elseif WriteDebug<3
****************************
* запись отладочная во флеш
****************************
        CALL	DebugWriting
        B	End_mode
 .endif


End_mode

 .if DebugStop=1
	SPLK	#1,TMP
	CALL	CheckError
 .endif
**отладка
*	SUB	#1152
*	BCND	NoOverFlow,LT
*	LACC	#0
*	SACL    SampleNumber
*NoOverFlow
**
	RET

 .if WriteDebug=0
 .elseif WriteDebug<3
DebugWriting:
	CALL	pStart_Debug_Write
	LACC	SampleNumber
	ADD	SampleNumberShift
*	ADD	TimeNakachka
	SUB     #TWO_MINUTES
	BCND	End_Debug_mode_ret,LT
	mEnd_error_meas rTIME_MORE_2_MINUTES
End_Debug_mode_ret:
	RET

 .endif

