*****************************************************************************
* режимы прибора (измерение давления, вывод ошибки на экран и т.д.)
* $Id: BPMODE.ASM,v 1.11 2001-04-11 10:03:40 peter Exp $
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
* Оценка частоты пульса
***************************
	CALL    Pulse_frequency_evaluation
	B       End_mode

;HERMITICITY_CHECK

***************************
* Увеличение давления до систолическое + N мм.рт.ст.
***************************
	CALL    Pressure_augment
	B       End_mode

***************************
* Остановка увеличения давления
***************************
	CALL    Pressure_augment_stop
	B       End_mode

***************************
* Проверка превышения систолического давления
***************************
	CALL    Check_higher_sistol_pressure
	B       End_mode

***************************
* Измерение амплитуд пульсаций и уровня давления
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
        B	End_Debug_mode
 .endif


End_mode
	CALL	Analysis_of_end
End_Debug_mode:

; if ( MaxNumber >= 1)
; {
;      MeasurementFlags = MeasurementFlags & (1<<FIRST_IMPULSE_FLAG)

	LACC	MaxNumber
	BCND	End_next_sample_number,LEQ

	LACC	MeasurementFlags
	AND	#~(1<<FIRST_IMPULSE_FLAG)
	SACL    MeasurementFlags

; }

End_next_sample_number:

	LACC    SampleNumber
	ADD     #1
	SACL    SampleNumber
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

