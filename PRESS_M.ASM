;&D
***********************************************************************
* 	Pressure_measurement() - Процесс измерения давлени
* $Id: PRESS_M.ASM,v 1.13 2001-11-14 17:33:35 peter Exp $
***********************************************************************
;Pressure_measurement()
Pressure_measurement:
;{
;  if (( MeasurementFlags&(1<<DIFF_MAX_FLAG)) != 0 )
;  {

	MAR	*,AR2
	BIT	_MeasurementFlags,15-DIFF_MAX_FLAG
	BCND	Press_m_max_isnt,NTC

;    if ( Diff2Max[MaxNumber] > MIN_THRESHOLD_SISTOL)
;    {
	LAR	AR0,_MaxNumber
	LAR	AR2,#Diff2Max
	MAR	*0+,AR2
	LACC	*,0,AR2
	SUB	#MIN_THRESHOLD_SISTOL
	BCND	Press_m_small_impulse,LEQ

;      if ( Diff2Max[MaxNumber] < MAX_THRESHOLD_SISTOL)
;      {

	SUB     #MAX_THRESHOLD_SISTOL-MIN_THRESHOLD_SISTOL
	BCND	Press_m_big_impulse,GEQ

;        Maximum_analysis();

	CALL	Maximum_analysis

;        if ( MeasurementFlags &(1<<NEXT_MODE_FLAG) != 0 )
;        {

	BIT	_MeasurementFlags,15-NEXT_MODE_FLAG
	BCND	Press_m_end,NTC

;          if ( MaxAverageAmplitude <= AverageAmplitude[StepNumber])
;          {

	LAR	AR0,_StepNumber
	LAR	AR2,#AverageAmplitude
	MAR	*0+,AR2
	LACC	MaxAverageAmplitude
	SUB	*,0,AR2
	BCND	Press_m_check_meas_end,GT

;            MaxAverageAmplitude = AverageAmplitude[StepNumber];
;          }

	LACC    *,0,AR2
	SACL	MaxAverageAmplitude

Press_m_check_meas_end:
;          if (( 0.6*MaxAverageAmplitude > AverageAmplitude[StepNumber])&&
;              ( StepNumber > MIN_STEP_NUMBER ))

	LACC	_StepNumber
	SUB	#MIN_STEP_NUMBER
	BCND   	Press_m_next_mode,LEQ
	LACC	*,12,AR2
	LT	MaxAverageAmplitude
	MPY	#CONST_0_6
	SPAC
	BCND   	Press_m_next_mode,GEQ

;          { /* Определение систолического, среднего и диастолического */
;            Determination_s_a_d();
;          }

	CALL	Determination_s_a_d
	B	Press_m_end

Press_m_next_mode:
;          else
;          { /* Подготовка к следующему режиму */
;            Start_diminution_pressure();

	CALL	Start_diminution_pressure

;          }
;        }
;      }
	B	Press_m_end

Press_m_big_impulse:
;      else
;      {
;        Synchro_flag_is_reseted();
;        StartMaxNumber = MaxNumber;

	CALL	Synchro_flag_is_reseted
	LACC	_MaxNumber,0
	SACL	_StartMaxNumber,0

;      }
;    }
;  }

Press_m_small_impulse:
Press_m_end:
Press_m_max_isnt:
;  Pressure_for_display();
;  End_step_analysis();
;}
	CALL	Pressure_for_display
	CALL	End_step_analysis
	RET

 .if (Sertificarion==1)
* стоим на ступеньке две секунды
Pressure_measurement_Manual:

;  Pressure_for_display();

	CALL	Pressure_for_display

	LACC	_SampleNumber
	ADD	_SampleNumberShift
	ADD	TimeNakachka
	SUB     #TWO_MINUTES
	BCND	End_Sertification_mode_ret,LT
	mEnd_error_meas rTIME_MORE_2_MINUTES

End_Sertification_mode_ret:
	LACC	_SampleNumber

  .if (WriteDebug!=0)
* стоим на ступеньке десять секунд
	SUB     #TEN_SECOND
  .else
* стоим на ступеньке две секунды
	SUB     #TWO_SECOND
  .endif
	BCND	Pressure_m_manual_quit,LT
	CALL	Start_diminution_pressure
Pressure_m_manual_quit:
	LACC	_SampleNumber
	ADD	#1
	SACL	_SampleNumber
	RET

 .endif





;***********************************************************************
;*       Determinution_s_a_d() - Опpеделение систолического, сpеднего
;*                               и диастолического давлений
;*
;***********************************************************************

WIN_BL_5		.word   01A1h, 03248h, 07FFFh, 03248h, 01A1h
;WIN_BL_5		.word   01A1h, 03248h, 07FFFh, 03248h, 01A1h

;int	i,j
;int	TempStepNumber
;int	StepAveragePressure
;int	NewMaxAverageAmplitude
;int	Flag
;int    TempStartMeasAdress[MAX_STEP_NUMBER]
;int    TempFinishMeasAddress[MAX_STEP_NUMBER]
;int    TempAvrPress[MAX_STEP_NUMBER]
;int    TempAverageAmplitude[MAX_STEP_NUMBER]

TempAvrPress            .equ  	Signal
TempAverageAmplitude 	.equ  	TempAvrPress + MAX_STEP_NUMBER + 4
NewAverageAmplitude   	.equ  	TempAverageAmplitude + MAX_STEP_NUMBER

CounterI		.equ	TMP+3
TempStepNumber		.equ	TMP+4
Flag			.equ	TMP+5
NewMaxAverageAmplitude	.equ  	TMP+5
StepAveragePressure     .equ  	TMP+6

;Determinution_s_a_d()

Determination_s_a_d

;{

;  Completion_of_mode();

	CALL	Completion_of_mode

;  FinishMeasAddress[StepNumber] = SampleNumberShift + SampleNumber;

        MAR     *,AR2
	LAR	AR0,_StepNumber
	LAR	AR2,#FinishMeasAddress
	MAR	*0+,AR2
	LACC	_SampleNumberShift
	SUB	#1
	SACL	*,0,AR2

;  // Перемещаем значения амплитуд и соответ. давлений во врем.массив
;  TempStepNumber = StepNumber - 1;

	LACC	_StepNumber
	SUB	#1
	SACL	TempStepNumber

;  for ( j=TempStepNumber; j>0, j--)
;  {
;    TempAvrPress[j-1] = AvrPress[j];
;    TempAverageAmplitude[j-1] = AverageAmplitude[j];
;  }

	LAR	AR2,#AvrPress+1
	RPT	TempStepNumber
	BLDD	*+,#TempAvrPress,AR2
	LAR	AR2,#AverageAmplitude+1
	RPT	TempStepNumber
	BLDD	*+,#TempAverageAmplitude,AR2

;

Deter_check_zero_in_start:
;  // Удаляем точки с нулевой амплитудой в начале массива
;  while ( TempAverageAmplitude[0] == 0)

	LAR	AR2,#TempAverageAmplitude
	LACC	*+,0,AR2
	BCND	Deter_zero_isnt_in_start,NEQ

;  {
;    for ( j=1; j=TempStepNumber, j++)
;    {
;      TempAvrPress[j-1] = TempAvrPress[j];
;      TempAverageAmplitude[j-1] = TempAverageAmplitude[j];
;    }
;  TempStepNumber = TempStepNumber - 1;
;  }

	LAR	AR2,#TempAvrPress+1
	RPT	TempStepNumber
	BLDD	*+,#TempAvrPress,AR2
	LAR	AR2,#TempAverageAmplitude+1
	RPT	TempStepNumber
	BLDD	*+,#TempAverageAmplitude,AR2
	LACC	TempStepNumber
	SUB	#1
	SACL	TempStepNumber
	B	Deter_check_zero_in_start

;

Deter_zero_isnt_in_start:
;  // Удаляем точки с нулевой амплитудой ( оставшиеся - результат
;  // артефакта или аритмии )
;  // TempAverageAmplitude[0] != 0 ,т.к. есть предыдущий сдвиг.
;  // TempAverageAmplitude[TempStepNumber] != 0 ,т.к. мы здесь
;  i=1;

	SPLK	#1,CounterI

;  while ( i < TempStepNumber )
;  {

Deter_check_end_of_array:
	LACC	TempStepNumber
	SUB	CounterI
	BCND	Deter_while_flag_1,LEQ

;    while (( TempAverageAmplitude[i] == 0)&&( i < TempStepNumber ))

Deter_check_zero_in_array:
	LACC	TempStepNumber
	SUB	CounterI
	BCND	Deter_inc_counterI,LEQ
	;SUB	#1
	SACL	TMP
	LAR	AR4,TMP
	LAR	AR0,CounterI
	LAR	AR2,#TempAverageAmplitude
	MAR	*0+,AR3
	LAR	AR3,#TempAvrPress+1
	MAR	*0+,AR2
	LACC	*+,0,AR2
	BCND	Deter_inc_counterI,NEQ

;    {
;      for ( j=i; j<TempStepNumber, j++)
;      {
;        TempAvrPress[j] = TempAvrPress[j+1];
;        TempAverageAmplitude[j] = TempAverageAmplitude[j+1];
;      }
;      TempStepNumber = TempStepNumber - 1;

Deter_for_clear_from_zero:
	LACC	*-,0,AR2
	SACL	*+,0,AR2
	MAR	*+,AR3
	LACC	*-,0,AR3
	SACL	*+,0,AR3
	MAR	*+,AR4
	BANZ	Deter_for_clear_from_zero,*-,AR2
	LACC	TempStepNumber
	SUB	#1
	SACL	TempStepNumber
	B	Deter_check_zero_in_array

Deter_inc_counterI:
;    }
;    i++;
;  }

	LACC    CounterI
	ADD	#1
	SACL    CounterI
	B	Deter_check_end_of_array

Deter_while_flag_1:

;  while ( Flag == 1)
;  {
;    Flag = 0;

	MAR	*,AR0
	SPLK	#0,Flag
	LAR	AR0,TempStepNumber
	MAR	*-,AR2
	LAR	AR2,#TempAvrPress
	LAR	AR3,#TempAverageAmplitude

Deter_for_i_0:

;    for ( i=0; i<TempStepNumber; i++)
;    {
;      if ( TempAvrPress[i] < TempAvrPress[i+1])

	LACC	*+,0,AR2
	SUB	*,0,AR3
	BCND 	Deter_sequence_press_ok,GEQ

;      {
;         Temp = TempAverageAmplitude[i+1];
;         TempAverageAmplitude[i+1] = TempAverageAmplitude[i];
;         TempAverageAmplitude[i] = Temp;

	MAR	*+,AR3
	LACC	*-,0,AR3
	DMOV    *,AR3
	SACL    *,0,AR2

;         Temp = TempAvrPress[i+1];
;         TempAvrPress[i+1] = TempAvrPress[i];
;         TempAvrPress[i] = Temp;

	LACC	*-,0,AR2
	DMOV    *,AR2
	SACL    *+,0,AR3

;         Flag = 1;

	SPLK	#1,Flag

;      }

Deter_sequence_press_ok:

	MAR	*+,AR0
	BANZ    Deter_for_i_0,*-,AR2

;    }

	BIT     Flag,15
	BCND	Deter_while_flag_1,TC

;  }

;  for ( i=TempStepNumber; i>=0; i--)
;  {
;     TempAverageAmplitude[i+2] = TempAverageAmplitude[i];
;  }
;  TempAverageAmplitude[1] = 0,5*TempAverageAmplitude[2];
;  TempAverageAmplitude[0] = 0,25*TempAverageAmplitude[2];
;  i=TempStepNumber+2;
;  TempAverageAmplitude[i+2] = 0,25*TempAverageAmplitude[i];
;  TempAverageAmplitude[i+1] = 0,5*TempAverageAmplitude[i];
;

	MAR	*,AR2
	LAR	AR0,TempStepNumber
	LAR	AR2,#TempAverageAmplitude
	MAR	*0+,AR2
	RPT	TempStepNumber
	DMOV	*-,AR2
	LAR	AR2,#TempAverageAmplitude+1
	MAR	*0+,AR2
	RPT	TempStepNumber
	DMOV	*-,AR2
	MAR	*+,AR2
	LACC	*,15,AR2
	SACH	*-,0,AR2
	SFR
	SACH	*,0,AR2
	LAR	AR2,#TempAverageAmplitude+2
	MAR	*0+,AR2
	LACC	*+,15,AR2
	SACH	*+,0,AR2
	SFR
	SACH	*,0,AR2

;  NewMaxAverageAmplitude = 0;

	SPLK	#0,NewMaxAverageAmplitude

;  for ( i=TempStepNumber; i>=0; i--)
;  {

	LAR	AR2,#TempAverageAmplitude+4
	MAR	*0+,AR4
	LAR	AR4,#NewAverageAmplitude
	MAR	*0+,AR3

Deter_for_i_1:
	SAR	AR2,TMP
	LAR	AR3,TMP

;    for ( k=0; k<5; k++)
;    {
;      NewAverageAmplitude[i] = TempAverageAmplitude[i-k]*WIN_BL_5[k];

        MAC  	WIN_BL_5,*-,AR3
	LACC 	#0
	RPT  	#3
	MAC 	WIN_BL_5+1,*-,AR3
	APAC
	MAR	*,AR4
	SACH 	*,4,AR4

;    }
;    if ( NewMaxAverageAmplitude <= NewAverageAmplitude[i])

	SUB	NewMaxAverageAmplitude,12
	BCND	Deter_not_of_max,LT

;    {
;      NewMaxAverageAmplitude = NewAverageAmplitude[i];
;      StepAveragePressure = i;

	LACC	*,0,AR4
	SACL    NewMaxAverageAmplitude
	SAR	AR0,StepAveragePressure

;    }

Deter_not_of_max:
	MAR	*-,AR2
	MAR	*-,AR0
	BANZ	Deter_for_i_1,*-,AR3
;  }
;  AveragePressure = TempAvrPress[StepAveragePressure];

	LAR	AR0,StepAveragePressure
        LAR     AR3,#TempAvrPress
	MAR	*0+,AR3
	LACC	*,0,AR2
	SACL	AveragePressure,0

;  if ( NewAverageAmplitude[0] <= THRESHOLD_OF_SISTOL*NewMaxAverageAmplitude )

        LAR     AR2,#NewAverageAmplitude
        LACC    *,12,AR2
        LT     	NewMaxAverageAmplitude
	MPY     #THRESHOLD_OF_SISTOL
	SPAC
        BCND    Deter_not_sistol,GT

;  {
;     i=0;

        LAR     AR0,#0

;     while ( NewAverageAmplitude[i] <=
;	      THRESHOLD_OF_SISTOL*NewMaxAverageAmplitude )

Deter_next_step_1

        LACC    *+,12,AR0
	SPAC
        BCND    Deter_sistol,GT

;     {
;       i++;
;     }

        B       Deter_next_step_1,*+,AR2


Deter_sistol

        MAR     *,AR2
        LAR     AR2,#NewAverageAmplitude
        LAR     AR3,#TempAvrPress-1
        MAR     *0+,AR3
        MAR     *0+,AR2

;     SistolPressure = TempAvrPress[i] + ( TempAvrPress[i-1] - TempAvrPress[i])*
;                 ( NewAverageAmplitude[i] -
;                   THRESHOLD_OF_SISTOL*NewMaxAverageAmplitude )/
;                 ( NewAverageAmplitude[i] - NewAverageAmplitude[i-1]);

                ; ( NewAverageAmplitude[i] - NewAverageAmplitude[i-1]);

        LACC    *-,0,AR2
        SUB     *+,0,AR2
        SACL    TMP

                ; 2^9*( NewAverageAmplitude[i] -
		;       THRESHOLD_OF_SISTOL*NewMaxAverageAmplitude )

        LACC    *,12,AR3
        SPAC
	SACH	TMP+1,4
	LACC	TMP+1,9

                ; 2^9*()/()

        RPT     #15
        SUBC    TMP
        SACL    TMP
        LT      TMP

                ;2^0*( TempAvrPress[i-1] - TempAvrPress[i])

        LACC    *+,0,AR3
        SUB     *,0,AR3
        SACL    TMP

                ;2^0*()*2^9*()/()

        MPY     TMP
        PAC     ;2^9*()*()/()

                ; + 2^9*TempAvrPress[i]

        ADD     *,9,AR2

                ; SistolPressure/2^7

        SACH    SistolPressure,7        ; SistolPressure
                                        ; 9_ть значащих pазpядов

;    if ( FirstMeasFlag == TRUR )

	BIT	_MeasurementFlags,15-FIRST_MEAS_FLAG
	BCND	Deter_not_FirstMeasFlag,NTC

;    {
;      SistolPressureAmplitude = MaxAverageAmplitude/2;
;      FirstMeasFlag = FALSE;

	LACC    MaxAverageAmplitude,15
	SACH    _SistolPressureAmplitude,0
	LACC	_MeasurementFlags,0
	AND	#~(1<<FIRST_MEAS_FLAG)
	SACL  	_MeasurementFlags,0

;    }

        B       Deter_diastol_1

;    else

Deter_not_FirstMeasFlag:

;    {
;    SistolPressureAmplitude = SistolPressureAmplitude*3/4 +
;          		       MaxAverageAmplitude/8;

	LACC	_SistolPressureAmplitude,15
	ADD     _SistolPressureAmplitude,14
	ADD     MaxAverageAmplitude,13
	SACH    _SistolPressureAmplitude,0

;    }
;  }

        B       Deter_diastol_1

Deter_not_sistol

;  else
;  {
;     if (( NewAverageAmplitude[0] >=
;           THRESHOLD_OF_AVERAGE*NewMaxAverageAmplitude )||
;         ( StepAveragePressure < 2 ))

        LAR     AR2,#NewAverageAmplitude
        LACC    *,12,AR2
        LT     	NewMaxAverageAmplitude
	MPY     #THRESHOLD_OF_AVERAGE
	SPAC
        BCND    Deter_not_s_a_d,GEQ
	LACC    StepAveragePressure,0
	SUB	#2
	BCND    Deter_not_s_only,GT

;     {

Deter_not_s_a_d:

;         mEnd_error_meas( rNOT_SISTOL_AVR_DIASTOL_PRESSURE );
;        return;

	mEnd_error_meas	rNOT_SISTOL_AVR_DIASTOL_PRESSURE
	RET

;     }

Deter_not_s_only:

;     else
;     {
;	if ( ArtefactCount > 0 )      ????????????????????

	LACC	ArtefactCount
	BCND	Deter_not_s_only_2,GT

;       {
;         mEnd_error_meas( rNOT_SISTOL_PRESSURE_ARTEFACT );

	mEnd_error_meas	rNOT_SISTOL_PRESSURE_ARTEFACT

;       }

	B	Deter_diastol_1

Deter_not_s_only_2:

;       elce
;       {
;         mEnd_error_meas( rNOT_SISTOL_PRESSURE );
;       }

	mEnd_error_meas	rNOT_SISTOL_PRESSURE

;     }
;  }


Deter_diastol_1

;  if ( NewAverageAmplitude[TempStepNumber] <=
;       THRESHOLD_OF_DIASTOL*NewMaxAverageAmplitude )

        MAR     *,AR2
        LAR     AR0,TempStepNumber
        LAR     AR2,#NewAverageAmplitude
        MAR     *0+,AR2
        LACC    *,12,AR2
        LT      NewMaxAverageAmplitude
	MPY     #THRESHOLD_OF_DIASTOL
        SPAC
        BCND    Deter_not_diastol,GT

;  {
;     i=StepNumber;  Уже в AR0


;     while ( NewAverageAmplitude[i] <=
;             THRESHOLD_OF_DIASTOL*NewMaxAverageAmplitude )

Deter_next_step_2

        LACC    *-,12,AR0
        SPAC
        BCND    Deter_diastol_2,GT

;     {
;       i--;
;     }

        B       Deter_next_step_2,*-,AR2


Deter_diastol_2

        MAR     *,AR2
        LAR     AR2,#NewAverageAmplitude
        LAR     AR3,#TempAvrPress
        MAR     *0+,AR3
        MAR     *0+,AR2

;     DiastolPressure = TempAvrPress[i] - ( TempAvrPress[i] - TempAvrPress[i+1])*
;                ( NewAverageAmplitude[i] -
;                  THRESHOLD_OF_DIASTOL*NewMaxAverageAmplitude )/
;                ( NewAverageAmplitude[i] - NewAverageAmplitude[i+1]);


               ; ( NewAverageAmplitude[i] - NewAverageAmplitude[i+1]);

        LACC    *+,0,AR2
        SUB     *-,0,AR2
        SACL    TMP

                ; 2^9*( NewAverageAmplitude[i] -
		; THRESHOLD_OF_DIASTOL*NewMaxAverageAmplitude )

        LACC    *,12,AR3
        SPAC
	SACH	TMP+1,4
	LACC	TMP+1,9

                ; 2^9*()/()

        RPT     #15
        SUBC    TMP
        SACL    TMP
        LT      TMP

                ;2^0*( TempAvrPress[i] - TempAvrPress[i+1])

        LACC    *+,0,AR3
        SUB     *-,0,AR3
        SACL    TMP

                ;2^0*()*2^9*()/()

        MPY     TMP                     ;2^9*()*()/()

        LACC    *,9,AR2                 ; 2^9*TempAvrPress[i]

        SPAC                            ; DiastolPressure/2^7

        SACH    DiastolPressure,7       ; DiastolPressure
                                        ; 9_ть значащих pазpядов
;  }

        B       Deter_next_mode

Deter_not_diastol

;  else
;  { //  once more step
;    mDim_pressure_init();
;    Finish_Meas_Address();

        mDim_pressure_init
	CALL	Finish_Meas_Address		; AR0,AR2 is used

;  }

	B	Deter_quit

Deter_next_mode

;     Mode = MEASUREMENT_FINISH

	SPLK    #MEASUREMENT_FINISH,_Mode

;}

	.if SIM == 1
	MAR	*,AR2
	LAR	AR2,#Diff2MaxAdressFinish
	RPT	#64
	OUT	*+,3
	NOP
	.endif

Deter_quit:

        RET
