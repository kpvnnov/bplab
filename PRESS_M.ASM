***********************************************************************
* 	Pressure_measurement() - Процесс измерения давлени
* $Id: PRESS_M.ASM,v 1.6 2001-03-20 16:07:21 peter Exp $
***********************************************************************
;Pressure_measurement()

Pressure_measurement

;{
; if ( SampleNumber > AnalysisStart )

        LACC    SampleNumber
        SUB     AnalysisStart
        BCND    Press_m_End,LEQ

; {
;  if ( DiffMaxFlag == TRUE )

	BIT	MeasurementFlags,15-DIFF_MAX_FLAG
        BCND    Press_m_MaxNotCentre,NTC

;  {   /* Если Max находится в 0.5 от конца интервала */

        MAR     *,AR1
        LAR     AR0,MaxNumber
        LAR     AR1,#Diff2Max
        MAR     *0+,AR1

;   if ( Diff2Max[MaxNumber] > 0.25*LastDiff2Max)

        LACC    *,16,AR1
        SUB     LastDiff2Max,14
        BCND    Press_m_SmallMax,LEQ

;   {
;    if ( Diff2Max[MaxNumber] < 4*LastDiff2Max)

        LACC    *,0,AR1
        SUB     LastDiff2Max,2
        BCND    Press_m_BigMax,GEQ

;    {
;     Maximum_analysis();

        CALL    Maximum_analysis

;     if ( NextModeFlag < 2 )

        LACC    NextModeFlag
        SUB     #2
        BCND    Press_m_NotEndStep,GEQ

;     {

        LAR     AR0,StepNumber
        LAR     AR1,#AverageAmplitude
        MAR     *0+,AR1

;      if ( MaxAverageAmplitude <= AverageAmplitude[StepNumber])

        LACC    MaxAverageAmplitude
        SUB     *,0,AR1
        BCND    Press_m_NotAmplMax,GT

;      {
;        MaxAverageAmplitude = AverageAmplitude[StepNumber];

        LACC    *,0,AR1
        SACL    MaxAverageAmplitude

;        MaxAmplStepNumber = StepNumber;

        LACC    StepNumber
        SACL    MaxAmplStepNumber

;      }

Press_m_NotAmplMax

;       if (( 0.6*MaxAverageAmplitude > AverageAmplitude[StepNumber])&
;	   ( StepNumber > MIN_STEP_NUMBER ))

        LACC    *,12,AR1
        LT      MaxAverageAmplitude
        MPY     #CONST_0_6
        SPAC
        BCND    Press_m_next_mode,GEQ
	LACC	StepNumber,0
	SUB	#MIN_STEP_NUMBER,0		; MIN_STEP_NUMBER = 5
        BCND    Press_m_next_mode,LEQ

;      {   /*  Определение систолического, среднего и диастолического */
;          Determination_s_a_d();

        CALL    Determination_s_a_d

;      }

        B       Press_m_NotEndStep

Press_m_next_mode
;      else
;      {
;       /*      Подготовка к следующему режиму */
;       Mode = PRESSURE_DIMINUTION;
;          NewPressure = NewPressure - EIGHT_MILL_OF_MERC;

        SPLK    #PRESSURE_DIMINUTION,Mode
	;LACC	NewPressure
        ;SUB     #EIGHT_MILL_OF_MERC
	;SACL	NewPressure
	mDim_pressure_init

;	   SubroutMode = 0;

	SPLK	#0,SubroutMode

;       MaxNumber = 0;
;       StartMaxNumber = 0;

        LACC    #0
        SACL    MaxNumber
        SACL    StartMaxNumber

;  SampleNumberShift = SampleNumberShift + SampleNumber + 1;

        LACC    SampleNumberShift
        ADD     SampleNumber
        ADD     #1
        SACL    SampleNumberShift

;  SampleNumber = -1;

        SPLK    #0FFFFh,SampleNumber

;	FinishMeasAdress[StepNumber] = SampleNumberShift;

	LAR	AR0,StepNumber
	LAR	AR1,#FinishMeasAdress
	MAR	*0+,AR1
	LACC	SampleNumberShift
	SUB	#1
	SACL	*,0,AR1

;      StepNumber++;

        LACC    StepNumber
        ADD     #1
        SACL    StepNumber

;      }
;     }

Press_m_NotEndStep

;    }

Press_m_BigMax:

	RET
;   }

Press_m_SmallMax

;  }
;   else
;   {
;     if ((( SampleNumber - AnalysisStart ) > 6*AnalysisInterval )&&
;          ( MaxNumber < 2 ))

	LACC	SampleNumber,0
        SUB	AnalysisStart,0
	SUB	AnalysisInterval,2
	SUB	AnalysisInterval,1
	RETC	LEQ
	LACC	MaxNumber,0
	SUB	#2
	RETC	GEQ

;     {
;
;       Press_m_next_mode();

	B	Press_m_next_mode

;     }
;   }

Press_m_MaxNotCentre

; }

Press_m_End

;}
        RET



;***********************************************************************
;*       Determinution_s_a_d() - Опpеделение систолического, сpеднего
;*                               и диастолического давлений
;*
;***********************************************************************

WIN_BL_5		.word   01A1h, 03248h, 07FFFh, 03248h, 01A1h
;WIN_BL_5		.word   01A1h, 03248h, 07FFFh, 03248h, 01A1h

TempAverageAmplitude 	.equ  	Signal + 32
NewAverageAmplitude   	.equ  	Signal
Flag			.equ	TMP+5
NewMaxAverageAmplitude	.equ  	TMP+5
StepAveragePressure     .equ  	TMP+6
;Temp			.equ	TMP+6

;Determinution_s_a_d()

Determination_s_a_d

;{

        MAR     *,AR1

;	FinishMeasAdress[StepNumber] = SampleNumberShift;

	LAR	AR0,StepNumber
	LAR	AR1,#FinishMeasAdress
	MAR	*0+,AR1
	LACC	SampleNumberShift
	ADD	SampleNumber
	SACL	*,0,AR0

Deter_while_flag_1:

;  while ( Flag == 1)
;  {
;    Flag = 0;

	MAR	*,AR0
	SPLK	#0,Flag
	LAR	AR0,StepNumber
	MAR	*-,AR1
	LAR	AR1,#AvrPress
	LAR	AR2,#AverageAmplitude

Deter_for_i_0:

;    for ( i=0; i<StepNumber; i++)
;    {
;      if ( AvrPress[k] < AvrPress[k+1])

	LACC	*+,0,AR1
	SUB	*,0,AR2
	BCND 	Deter_sequence_press_ok,GEQ

;      {
;	  Temp = AverageAmplitude[k+1];
;         AverageAmplitude[k+1] = AverageAmplitude[k];
;         AverageAmplitude[k] = Temp;

	MAR	*+,AR2
	LACC	*-,0,AR2
	DMOV    *,AR2
	SACL    *,0,AR1

;         Temp = AvrPress[k+1];
;         AvrPress[k+1] = AvrPress[k];
;         AvrPress[k] = Temp;

	LACC	*-,0,AR1
	DMOV    *,AR1
	SACL    *+,0,AR2

;	  Flag = 1;

	SPLK	#1,Flag

;      }

Deter_sequence_press_ok:

	MAR	*+,AR0
	BANZ    Deter_for_i_0,*-,AR1

;    }

	BIT     Flag,15
	BCND	Deter_while_flag_1,TC

;  }

;  TempAverageAmplitude[0] = 0,25*AverageAmplitude[0];
;  TempAverageAmplitude[1] = 0,5*AverageAmplitude[0];
;  for ( i=0; i<=StepNumber; i++)
;  {
;     TempAverageAmplitude[i+2] = AverageAmplitude[i];
;  }
;  TempAverageAmplitude[StepNumber+3] = 0,5*AverageAmplitude[StepNumber];
;  TempAverageAmplitude[StepNumber+4] = 0,25*AverageAmplitude[StepNumber];
;

	LAR	AR0,StepNumber
	LAR	AR1,#AverageAmplitude
	LAR	AR2,#TempAverageAmplitude
	LACC	*,14,AR2
	SACH	*+,0,AR1
	LACC	*,15,AR2
	SACH	*+,0,AR2
	RPT	StepNumber
	BLDD	#AverageAmplitude,*+,AR2
	MAR	*,AR1
	MAR	*0+,AR1
	LACC	*,15,AR2
	SACH	*+,0,AR1
	LACC	*,14,AR2
	SACH	*,0,AR1

;  NewMaxAverageAmplitude = 0;

	SPLK	#0,NewMaxAverageAmplitude

;  for ( i=StepNumber; i>=0; i--)
;  {

	LAR	AR1,#TempAverageAmplitude+4
	MAR	*0+,AR3
	LAR	AR3,#NewAverageAmplitude
	MAR	*0+,AR2

Deter_for_i_1:
	SAR	AR1,TMP
	LAR	AR2,TMP

;    for ( k=0; k<5; k++)
;    {
;      NewAverageAmplitude[i] = TempAverageAmplitude[i-k]*WIN_BL_5[k];

        MAC  	WIN_BL_5,*-,AR2
	LACC 	#0
	RPT  	#3
	MAC 	WIN_BL_5+1,*-,AR2
	APAC
	MAR	*,AR3
	SACH 	*,4,AR3

;    }
;    if ( NewMaxAverageAmplitude <= NewAverageAmplitude[i])

	SUB	NewMaxAverageAmplitude,12
	BCND	Deter_not_of_max,LT

;    {
;      NewMaxAverageAmplitude = NewAverageAmplitude[i];
;      StepAveragePressure = i;

	LACC	*,0,AR3
	SACL    NewMaxAverageAmplitude
	SAR	AR0,StepAveragePressure

;    }

Deter_not_of_max:
	MAR	*-,AR1
	MAR	*-,AR0
	BANZ	Deter_for_i_1,*-,AR2
;  }
;  AveragePressure = AvrPress[StepAveragePressure];

	LAR	AR0,StepAveragePressure
        LAR     AR2,#AvrPress
	MAR	*0+,AR2
	LACC	*,0,AR1
	SACL	AveragePressure,0

;  if ( NewAverageAmplitude[0] <= THRESHOLD_OF_SISTOL*NewMaxAverageAmplitude )

        LAR     AR1,#NewAverageAmplitude
        LACC    *,12,AR1
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

        B       Deter_next_step_1,*+,AR1


Deter_sistol

        MAR     *,AR1
        LAR     AR1,#NewAverageAmplitude
        LAR     AR2,#AvrPress-1
        MAR     *0+,AR2
        MAR     *0+,AR1

;     SistolPressure = AvrPress[i] + ( AvrPress[i-1] - AvrPress[i])*
;                 ( NewAverageAmplitude[i] -
;		    THRESHOLD_OF_SISTOL*NewMaxAverageAmplitude )/
;                 ( NewAverageAmplitude[i] - NewAverageAmplitude[i-1]);

               ; ( NewAverageAmplitude[i] - NewAverageAmplitude[i-1]);

        LACC    *-,0,AR1
        SUB     *+,0,AR1
        SACL    TMP

                ; 2^9*( NewAverageAmplitude[i] -
		;       THRESHOLD_OF_SISTOL*NewMaxAverageAmplitude )

        LACC    *,12,AR2
        SPAC
	SACH	TMP+1,4
	LACC	TMP+1,9

                ; 2^9*()/()

        RPT     #15
        SUBC    TMP
        SACL    TMP
        LT      TMP

                ;2^0*( AvrPress[i-1] - AvrPress[i])

        LACC    *+,0,AR2
        SUB     *,0,AR2
        SACL    TMP

                ;2^0*()*2^9*()/()

        MPY     TMP
        PAC     ;2^9*()*()/()

                ; + 2^9*AvrPress[i]

        ADD     *,9,AR1

                ; SistolPressure/2^7

        SACH    SistolPressure,7        ; SistolPressure
                                        ; 9_ть значащих pазpядов

;    if ( FirstMeasFlag == TRUR )

	BIT	MeasurementFlags,15-FIRST_MEAS_FLAG
	BCND	Deter_not_FirstMeasFlag,NTC

;    {
;      SistolPressureAmplitude = MaxAverageAmplitude/2;
;      FirstMeasFlag = FALSE;

	LACC    MaxAverageAmplitude,15
	SACH    SistolPressureAmplitude,0
	LACC	MeasurementFlags,0
	AND	#~(1<<FIRST_MEAS_FLAG)
	SACL  	MeasurementFlags,0

;    }

        B       Deter_diastol_1

;    else

Deter_not_FirstMeasFlag:

;    {
;    SistolPressureAmplitude = SistolPressureAmplitude*3/4 +
;          		       MaxAverageAmplitude/8;

	LACC	SistolPressureAmplitude,15
	ADD     SistolPressureAmplitude,14
	ADD     MaxAverageAmplitude,13
	SACH    SistolPressureAmplitude,0

;    }
;  }

        B       Deter_diastol_1

Deter_not_sistol

;  else
;  {
;     if (( NewAverageAmplitude[0] >=
;	    THRESHOLD_OF_AVERAGE*NewMaxAverageAmplitude )||
;	  ( StepAveragePressure < 2 ))

        LAR     AR1,#NewAverageAmplitude
        LACC    *,12,AR1
        LT     	NewMaxAverageAmplitude
	MPY     #THRESHOLD_OF_AVERAGE
	SPAC
        BCND    Deter_not_s_a_d,GEQ
	LACC    StepAveragePressure,0
	SUB	#2
	BCND    Deter_not_s_only,GT

;     {

Deter_not_s_a_d:

;        Error = NOT_SISTOL_AVR_DIASTOL_PRESSURE;
;        return;

	SPLK    #rNOT_SISTOL_AVR_DIASTOL_PRESSURE,ErrMeas
	RET

;     }

Deter_not_s_only:

;     else
;     {
;	if ( ArtefactCount > 0 )

	LACC	ArtefactCount
	BCND	Deter_not_s_only_2,GT

;       {
;         Error = NOT_SISTOL_PRESSURE_ARTEFACT;

	SPLK    #rNOT_SISTOL_PRESSURE_ARTEFACT,ErrMeas

;       }

	B	Deter_diastol_1

Deter_not_s_only_2:

;       elce
;       {
;         Error = NOT_SISTOL_PRESSURE;
;       }

	SPLK    #rNOT_SISTOL_PRESSURE,ErrMeas

;     }
;  }


Deter_diastol_1

;  if ( NewAverageAmplitude[StepNumber] <=
;	THRESHOLD_OF_DIASTOL*NewMaxAverageAmplitude )

        MAR     *,AR1
        LAR     AR0,StepNumber
        LAR     AR1,#NewAverageAmplitude
        MAR     *0+,AR1
        LACC    *,12,AR1
        LT      NewMaxAverageAmplitude
	MPY     #THRESHOLD_OF_DIASTOL
        SPAC
        BCND    Deter_not_diastol,GT

;  {
;     i=StepNumber;  Уже в AR0


;     while ( NewAverageAmplitude[i] <=
;	      THRESHOLD_OF_DIASTOL*NewMaxAverageAmplitude )

Deter_next_step_2

        LACC    *-,12,AR0
        SPAC
        BCND    Deter_diastol_2,GT

;     {
;       i--;
;     }

        B       Deter_next_step_2,*-,AR1


Deter_diastol_2

        MAR     *,AR1
        LAR     AR1,#NewAverageAmplitude
        LAR     AR2,#AvrPress
        MAR     *0+,AR2
        MAR     *0+,AR1

;     DiastolPressure = AvrPress[i] - ( AvrPress[i] - AvrPress[i+1])*
;                  ( NewAverageAmplitude[i] -
;		     THRESHOLD_OF_DIASTOL*NewMaxAverageAmplitude )/
;                  ( NewAverageAmplitude[i] - NewAverageAmplitude[i+1]);


               ; ( NewAverageAmplitude[i] - NewAverageAmplitude[i+1]);

        LACC    *+,0,AR1
        SUB     *-,0,AR1
        SACL    TMP

                ; 2^9*( NewAverageAmplitude[i] -
		; THRESHOLD_OF_DIASTOL*NewMaxAverageAmplitude )

        LACC    *,12,AR2
        SPAC
	SACH	TMP+1,4
	LACC	TMP+1,9

                ; 2^9*()/()

        RPT     #15
        SUBC    TMP
        SACL    TMP
        LT      TMP

                ;2^0*( AvrPress[i] - AvrPress[i+1])

        LACC    *+,0,AR2
        SUB     *-,0,AR2
        SACL    TMP

                ;2^0*()*2^9*()/()

        MPY     TMP                     ;2^9*()*()/()

        LACC    *,9,AR1                 ; 2^9*AvrPress[i]

        SPAC                            ; DiastolPressure/2^7

        SACH    DiastolPressure,7       ; DiastolPressure
                                        ; 9_ть значащих pазpядов
;  }

        B       Deter_next_mode

Deter_not_diastol

;  else
;  {
;     Error = NOT_DIASTOL_PRESSURE;

	SPLK    #rNOT_DIASTOL_PRESSURE,ErrMeas

;  }

Deter_next_mode

;     Mode = MEASUREMENT_FINISH

	SPLK    #MEASUREMENT_FINISH,Mode

;}

	.if SIM == 1
	MAR	*,AR1
	LAR	AR1,#Diff2MaxAdressFinish
	RPT	#64
	OUT	*+,3
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	.endif

        RET
