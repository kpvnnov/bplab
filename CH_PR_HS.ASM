***********************************************************************
*       Check_higher_sistol_pressure() - Проверка превышения
*                                        систолического давлени
* $Id: CH_PR_HS.ASM,v 1.6 2001-03-20 16:07:20 peter Exp $
***********************************************************************
Check_higher_sistol_pressure:
;{

; if ( SampleNumber > AnalysisStart )
; {

        LACC    SampleNumber,0
        SUB     AnalysisStart
        BCND    Ch_Pr_End_Function,LEQ

;  if ( DiffMaxFlag == TRUE )

	BIT	MeasurementFlags,15-DIFF_MAX_FLAG
        BCND    Ch_Pr_MaxNotCenter,NTC

;  {  /* Если Max находится в 0.5 от конца интервала */
;     NextModeFlag = 2;

        SPLK    #2,NextModeFlag

;  Подготовка адpеса  Diff2Max[MaxNumber]

        MAR     *,AR1
        LAR     AR0,MaxNumber
        LAR     AR1,#Diff2Max
        MAR     *0+,AR1

;   if ( SynchroFlag == True )

	BIT     MeasurementFlags,15-SYNCHRO_FLAG
        BCND    Ch_Pr_Not_Synchro,NTC

;   {   // Синхронизация есть.
;    if ( Diff2Max[MaxNumber] > 0.25*LastDiff2Max )

	LACC    *,13,AR1
	SUB     LastDiff2Max,11
	BCND    Ch_Pr_Synchro_Small_Impulse,LEQ

;    {
;     if ( Diff2Max[MaxNumber] < 4*LastDiff2Max)

	LACC    *,12,AR1
	SUB     LastDiff2Max,14
	BCND    Ch_Pr_Synchro_Big_Impulse,GEQ

;     {
;      Maximum_analysis();

        CALL    Maximum_analysis

;     }

Ch_Pr_Synchro_Big_Impulse

;    }

Ch_Pr_Synchro_Small_Impulse

;    if (( SampleNumber - AnalysisStart ) > 2*AnalysisInterval )

	LACC	SampleNumber,0
	SUB	AnalysisStart,0
	SUB	AnalysisInterval,1
	BCND	Ch_Pr_NextModeCheck,LEQ

;    {  /* ┬хЁю Єэр  яюЄхЁ  ёшэїЁюэшчрЎшш */
;    	SynchroFlag = False;

	LACC	MeasurementFlags,0
	AND	#~(1<<SYNCHRO_FLAG)
	SACL	MeasurementFlags,0

;    	StartMaxNumber = MaxNumber;

	LACC	MaxNumber,0
	SACL	StartMaxNumber,0

;    }
;   }

        B       Ch_Pr_NextModeCheck

Ch_Pr_Not_Synchro

;   else
;   {   // Синхронизации нет.( Анализ формы, пока просто по длительности импульсов)
;    if ( Diff2Max[MaxNumber] > MIN_THRESHOLD_SISTOL )  // > 0.2 мм.рт.ст.

        LACC    *,AR1
        SUB     #MIN_THRESHOLD_SISTOL
        BCND    Ch_Pr_Not_S_Small_Impulse,LEQ

;    {
;     if ( Diff2Max[MaxNumber] < MAX_THRESHOLD_SISTOL )  // < 10 мм.рт.ст.

        LACC    *,AR1
        SUB     #MAX_THRESHOLD_SISTOL
        BCND    Ch_Pr_Not_S_Big_Impulse,GEQ

;     {
;      switch ( MaxNumber - StartMaxNumber)

        LACC    MaxNumber
        SUB     StartMaxNumber

;      {

        BCND    Ch_Pr_Next_MaxNumber,EQ

;       case 0:
;        break;

        SUB     #1
        BCND    Ch_Pr_Not_S_default,NEQ

;       case 1:
;        if (( abs( TempPeriodDiff)) < 0.33*AveragePeriodEvaluation)

        LACC    TempPeriodDiff,15
        ABS
        LT      AveragePeriodEvaluation
        MPY     #CONST_0_33
        SPAC
        BCND    Ch_Pr_Not_Period,GEQ

;        {
;	  if ( TempAmplitudeDiff < 0.499*Diff2Max[MaxNumber])

	LACC	TempAmplitudeDiff,13
	LT	*,AR1
	MPY	#CONST_0_499			;#CONST_0_3
	SPAC
        BCND    Ch_Pr_TempAmpl_not_equal,GEQ

;         {
;          Average();

        CALL    Average

;         }

        B       Ch_Pr_Next_MaxNumber

Ch_Pr_TempAmpl_not_equal

;         else
;         {
;          StartMaxNumber = StartMaxNumber + 1;
;        }

Ch_Pr_Not_Period

;        else
;        {
;         StartMaxNumber = StartMaxNumber + 1;

        LACC    StartMaxNumber
        ADD     #1
        SACL    StartMaxNumber

;        }
;        break;

        B       Ch_Pr_Next_MaxNumber


Ch_Pr_Not_S_default

;       default:
;        if (( abs( TempPeriodDiff)) < 0.33*AveragePeriodEvaluation)

        LACC    TempPeriodDiff,15
        ABS
        LT      AveragePeriodEvaluation
        MPY     #CONST_0_33
        SPAC
        BCND    Ch_Pr_Not_Period_2,GEQ

;        {
;	  if ( TempAmplitudeDiff < 0.3*Diff2Max[MaxNumber])

	LACC	TempAmplitudeDiff,13
	LT	*,AR1
	MPY	#CONST_0_499			;#CONST_0_3
	SPAC
        BCND    Ch_Pr_TempAmpl_not_equal_2,GEQ

;         {
;          Average();

        CALL    Average

;          /* Вычисление Trend-а, средней амплитуды импульсов,
;             среднего уровня давления и подготовка к следующему
;             режиму ( снижение давления на 8 мм.рт.ст. или до 0)*/
;
;          Trend_measurement_2()

        CALL    Trend_measurement_2

;	    if (( abs( Max[2]-Max[1]) < 0.35 Max[2])&&
; 	        ( abs( Max[1]-Max[0]) < 0.35 Max[1]))

        MAR     *,AR1
	LAR	AR1,#Max+2
	LACC	*,13                    ;14
	LT	*-
	MPY	#CONST_0_35              ;CONST_0_2
	SUB	*,13                    ;14
	ABS
	SPAC
	BCND	Ch_Pr_Max_not_equal,GEQ
	LACC	*,13                    ;14
	LT	*-
	MPY	#CONST_0_35              ;CONST_0_2
	SUB	*,13                    ;14
	SPAC
	BCND	Ch_Pr_Max_not_equal,GEQ

; 	    {
;          /* Средние Амплитуда и Давление на этой ступеньке */

        LAR     AR0,StepNumber
        LAR     AR1,#AverageAmplitude
        MAR     *0+,AR2
        LAR     AR2,#AvrPress
        MAR     *0+,AR3
        LAR     AR3,#Max

;             AverageAmplitude[StepNumber] = ( Max[0] + Max[1] + Max[2])*0.33;

        LACC    *+,14,AR3
        ADD     *+,14,AR3
        ADD     *,14,AR1
        SACH    *,0,AR1
	LT	*,AR1
	MPY	#CONST_0_33
	PAC
	SACH	*,5,AR1

;             AvrPress[StepNumber] = ( MaxAvrPress[0] + MinAvrPress[0] +
;                                      MaxAvrPress[1] + MinAvrPress[1] +
;                                      MaxAvrPress[2] + MinAvrPress[2])*0.1667;

        LAR     AR1,#MaxAvrPress
        LACC    *+,13,AR1
        ADD     *+,13,AR1
        ADD     *,13,AR1
        LAR     AR1,#MinAvrPress
        ADD     *+,13,AR1
        ADD     *+,13,AR1
        ADD     *,13,AR2
        SACH    *,0,AR2
	LT	*,AR2
	MPY	#CONST_0_33
	PAC
	SACH	*,5,AR1

;             /* Подготовка к следующему режиму */
;             NextModeFlag = 1;

        SPLK    #1,NextModeFlag

;             }

        B       Ch_Pr_Next_MaxNumber

Ch_Pr_Max_not_equal:

;             else
;             {
;             	StartMaxNumber = StartMaxNumber + 1;

        LACC    StartMaxNumber
        ADD     #1
        SACL    StartMaxNumber

;             }
;         }

        B       Ch_Pr_Next_MaxNumber

Ch_Pr_TempAmpl_not_equal_2

;         else
;         {
;          StartMaxNumber = StartMaxNumber + 2;

        LACC    StartMaxNumber
        ADD     #2
        SACL    StartMaxNumber
        B       Ch_Pr_Next_MaxNumber

;         }

Ch_Pr_Not_Period_2

;        else
;        {
;         StartMaxNumber = StartMaxNumber + 2;

        LACC    StartMaxNumber
        ADD     #2
        SACL    StartMaxNumber

;    if ((( SampleNumber - AnalysisStart ) > 5*AnalysisInterval )&&
;         ( MaxNumber < 2 ))

	LACC	SampleNumber,0
	SUB	AnalysisStart,0
	SUB	AnalysisInterval,2
	SUB	AnalysisInterval,0
	BCND	Ch_Pr_Next_MaxNumber,LEQ
	LACC	MaxNumber,0
	SUB	#2
	BCND	Ch_Pr_Next_MaxNumber,GEQ

;    {
;	AnalysisInterval = AnalysisInterval - AnalysisInterval/16;
;	AveragePeriodEvaluation = AveragePeriodEvaluation -
;				  AveragePeriodEvaluation/16;

	LACC	AnalysisInterval,16
	SUB	AnalysisInterval,12
	SACH	AnalysisInterval,0
	LACC    AveragePeriodEvaluation,16
	SUB     AveragePeriodEvaluation,12
	SACH    AveragePeriodEvaluation,0

;        }
;        break;
;      }

Ch_Pr_Next_MaxNumber

        MAR     *,AR2
        LAR     AR0,MaxNumber
        LAR     AR2,#Diff2Max
        MAR     *0+,AR2

;   LastDiff2Max = Diff2Max[MaxNumber];

        LACC    *,0,AR3
        SACL    LastDiff2Max

        LAR     AR3,#Diff2MaxAdress
        MAR     *0+,AR4
        LAR     AR0,MaxNumberShift
        LAR     AR4,#Diff2MaxAdressFinish
        MAR     *0+,AR3

;       Diff2MaxAdressFinish[MaxNumberShift] = Diff2MaxAdress[MaxNumber] +
;                                              SampleNumberShift;

        LACC    *,AR4
        ADD     SampleNumberShift,0
        SACL    *,AR1

;        MaxNumberShift++;

        LACC    MaxNumberShift
        ADD     #1
        SACL    MaxNumberShift

;        MaxNumber++;

        LACC    MaxNumber
        ADD     #1
        SACL    MaxNumber

;        Max2DiffAdress[2] = Max2DiffAdress[1];
;        Max2DiffAdress[1] = Max2DiffAdress[0];

	LAR	AR1,#Max2DiffAdress+1
	DMOV	*-,AR1
	DMOV	*,AR1

;        MaxAvrPress[2] = MaxAvrPress[1];
;        MaxAvrPress[1] = MaxAvrPress[0];

	LAR	AR1,#MaxAvrPress+1
	DMOV	*-,AR1
	DMOV	*,AR1

;        MinAvrPress[2] = MinAvrPress[1];
;        MinAvrPress[1] = MinAvrPress[0];

	LAR	AR1,#MinAvrPress+1
	DMOV	*-,AR1
	DMOV	*,AR1

;     }

Ch_Pr_Not_S_Big_Impulse:

	B	Ch_Pr_Max_Fl_more1

;    }

Ch_Pr_Not_S_Small_Impulse

;   }
;   else
;   {
;     if ((( SampleNumber - AnalysisStart ) > 6*AnalysisInterval )&&
;          ( MaxNumber < 2 ))

	LACC	SampleNumber,0
	SUB	AnalysisStart,0
	SUB	AnalysisInterval,2
	SUB	AnalysisInterval,1
	BCND	Ch_Pr_Max_Fl_more1,LEQ
	LACC	MaxNumber,0
	SUB	#2
	BCND	Ch_Pr_Max_Fl_more1,LT

;     { // ═рўрЄ№ шчьхЁхэшх фртыхэш .
;       Start_diminution_pressure();
;       LastDiff2Max = MIN_THRESHOLD_SISTOL*4;

	SPLK	#MIN_THRESHOLD_SISTOL*4,LastDiff2Max
	B	Start_diminution_pressure

;     }
;   }

Ch_Pr_Max_Fl_more1:

Ch_Pr_NextModeCheck:

;      if ( NextModeFlag < 2)

        LACC    NextModeFlag
        SUB     #2
        BCND    Ch_Pr_MaxNotCenter,GEQ

;      {
;  	if ( PressureMoreSystolFlag == TRUE )

	BIT	MeasurementFlags,15-PRESS_MORE_SYSTOL_FLAG
	BCND	Ch_Pr_Pr_more_sys_fl_not,NTC

;       {
;          // ═рўрЄ№ шчьхЁхэшх фртыхэш .
;          Start_diminution_pressure();

	B	Start_diminution_pressure

;       }

Ch_Pr_Pr_more_sys_fl_not:
;       else
;       {
;         if (( Max[0]+Max[1])/2 < 0.8 SistolPressureAmplitude )

	MAR	*,AR1
	LAR	AR1,#Max
	LACC	*+,11,AR1
	ADD     *,11,AR1
	LT	SistolPressureAmplitude
	MPY	#CONST_0_8
	SPAC
	BCND	Start_diminution_pressure,LT

;         {  //SistolPressureAmplitude = 0.5  last RS
;           Start_diminution_pressure();
;         }
;         else
;         {  // Augment pressure at 30 .
;           if ( AugmentPressureNumber < 2 )

	LACC	AugmentPressureNumber
	SUB	#1
	BCND	Next_augment_pressure,LEQ

;           {
;             Next_augment_pressure();
;           }
;           else
;           {
;             Start_diminution_pressure();

	B	Start_diminution_pressure

;           }
;         }
;       }
;     }

Ch_Pr_MaxNotCenter

;  }

Ch_Pr_End_Function

; }
;}

        RET

;Start_diminution_pressure()

Start_diminution_pressure:

;{
;	Mode = PRESSURE_DIMINUTION;
;	NewPressure = NewPressure - EIGHT_MILL_OF_MERC;

        SPLK #PRESSURE_DIMINUTION,Mode
	;LACC	NewPressure
        ;SUB     #EIGHT_MILL_OF_MERC
	;SACL	NewPressure
	mDim_pressure_init

;	SubroutMode = 0;

	SPLK	#0,SubroutMode

;	StepNumber++;

        SPLK    #1,StepNumber

;	MaxNumber = 0;
;	StartMaxNumber = 0;

        LACC    #0
        SACL    StartMaxNumber
        SACL    MaxNumber

;	SampleNumberShift = SampleNumberShift + SampleNumber+1;

        LACC    SampleNumberShift
        ADD     SampleNumber
        ADD     #1
        SACL    SampleNumberShift

;	SampleNumber = -1;

        SPLK    #0FFFFh,SampleNumber

;	FinishMeasAdress[StepNumber] = SampleNumberShift;

	LAR	AR1,#FinishMeasAdress
	LACC	SampleNumberShift
	SACL	*,0,AR1

;	return;

	RET

;}
;Next_augment_pressure()

Next_augment_pressure:

;{
;    Mode=PRESSURE_AUGMENT;

	SPLK	#PRESSURE_AUGMENT,Mode
	mMotor_on

;    PressureTop = Signal[SampleNumber] + PRESS_30 + PRESS_PRESET;

	MAR	*,AR1
	LAR	AR0,#Signal
	LAR	AR1,SampleNumber
	MAR	*0+,AR1
	LACC	*
	ADD	#PRESS_30 + PRESS_PRESET
	SACL	PressureTop

;    SynchroFlag = False;
;    MaxNumber = 0;
;    StartMaxNumber = 0;

	LACC	MeasurementFlags,0
	AND	#~(1<<SYNCHRO_FLAG)
	SACL	MeasurementFlags,0
	LACC	#0
	SACL    MaxNumber
	SACL    StartMaxNumber

;    SampleNumberShift = SampleNumberShift + SampleNumber + 1;

	LACC 	SampleNumberShift
	ADD     SampleNumber
	ADD     #1
	SACL    SampleNumberShift

;    SampleNumber = -1;

        SPLK    #0FFFFh,SampleNumber

; ++        AnalysisStart = TIME_OF_MAX_PRESSURE + 0,5*AnalysisInterval;

        LACC    AnalysisInterval,14
	ADD	#TIME_OF_MAX_PRESSURE,15
        SACH    AnalysisStart,1

;    AugmentPressureNumber++;

    	LACC	AugmentPressureNumber
	ADD	#1
    	SACL	AugmentPressureNumber

;    return;

	RET

;}
