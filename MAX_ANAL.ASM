***********************************************************************
* 	MaximumAnalysis()  - Анализ предпологаемого импульса
* $Id: MAX_ANAL.ASM,v 1.6 2001-08-22 14:17:43 peter Exp $
***********************************************************************/
;Maximum_analysis()

Maximum_analysis

;{
; NextModeFlag = 2;

        SPLK    #2,NextModeFlag

; switch ( MaxNumber - StartMaxNumber)

        LACC    MaxNumber,0
        SUB     StartMaxNumber,0

; {

        BCND    Max_an_case1,NEQ

;  case 0:
;   if (( abs( TempPeriod - 2*AveragePeriodEvaluation )) <
;           0.33*AveragePeriodEvaluation )

        LACC    TempPeriod,15
        SUB     AveragePeriodEvaluation,14
        ABS
        LT      AveragePeriodEvaluation
        MPY     #CONST_0_33
        SPAC
        BCND    Max_an_check_Period_0,GEQ

;   {
;    Average_2();

        CALL    Average_2

;    ThreeImpulseFlag = 0;

	LACC	MeasurementFlags,0
	AND	#~(1<<THREE_IMPULSE_FLAG)
	SACL	MeasurementFlags,0

;   }
        B       Max_an_End_Switch

Max_an_check_Period_0:

;   if (( abs( TempPeriod - AveragePeriodEvaluation )) <
;           0.33*AveragePeriodEvaluation )

        LACC    TempPeriod,15
        SUB     AveragePeriodEvaluation,13
        ABS
        LT      AveragePeriodEvaluation
        MPY     #CONST_0_33
        SPAC
        BCND    Max_an_Not_Period_0,GEQ

;   {
;    Average();

        CALL    Average

;    ThreeImpulseFlag = 0;

	LACC	MeasurementFlags,0
	AND	#~(1<<THREE_IMPULSE_FLAG)
	SACL	MeasurementFlags,0

;   }

        B       Max_an_End_Switch

Max_an_Not_Period_0

;   else
;   {
;    ThreeImpulseFlag = 1; // Флаг необходимости 3-х импульсов

	LACC	MeasurementFlags,0
	OR	#(1<<THREE_IMPULSE_FLAG)
	SACL	MeasurementFlags,0

;   }
;   break;

        B       Max_an_End_Switch

Max_an_case1

;  case 1:

        SUB     #1
        BCND    Max_an_default,NEQ

;   if ( ThreeImpulseFlag == 0)

	BIT	MeasurementFlags,15-THREE_IMPULSE_FLAG
        BCND    Max_an_ThreeImpulseFlag,TC

;   {
;    if (( abs( TempPeriodDiff)) < 0.33*AveragePeriodEvaluation)

        LACC    TempPeriodDiff,15
        ABS
        LT      AveragePeriodEvaluation
        MPY     #CONST_0_33
        SPAC
        BCND    Max_an_Not_Period_1,GEQ

;    {
;      if ( TempAmplitudeDiff < 0.35*Diff2Max[MaxNumber])

	LACC	TempAmplitudeDiff,13
	LT	*,AR2
	MPY	#CONST_0_35		;#CONST_0_3
	SPAC
        BCND    Max_an_TempAmpl_not_equal,GEQ

;      {
;        Average();

        CALL    Average

;        Trend_measurement_1();

        CALL    Trend_measurement_1

;        if ( abs( Max[1]-Max[0]) < 0.249 Max[1])

        MAR     *,AR2
        LAR     AR2,#Max+1
	LACC    *,14,AR2
	LT      *-,AR2
	MPY     #CONST_0_249
	SUB     *,14,AR2
	ABS
	SPAC
	BCND    Max_an_Max_not_equal_1,GEQ

;        {

        LAR     AR0,StepNumber
        LAR     AR2,#AverageAmplitude
        MAR     *0+,AR3
        LAR     AR3,#AvrPress
        MAR     *0+,AR4
        LAR     AR4,#Max

;      	   AverageAmplitude[StepNumber] = ( Max[0] + Max[1] )/2;

        LACC    *+,15,AR4
        ADD     *,15,AR2
        SACH    *,0,AR2

;          AvrPress[StepNumber] = ( MaxAvrPress[0] + MaxAvrPress[1] +
;            	 	     	    MinAvrPress[0] + MinAvrPress[1])/4;

        LAR     AR2,#MaxAvrPress
        LACC    *+,14,AR2
        ADD     *,14,AR2
        LAR     AR2,#MinAvrPress
        ADD     *+,14,AR2
        ADD     *,14,AR3
        SACH    *,0,AR2

;          NextModeFlag = 0;

        SPLK    #0,NextModeFlag

;        }

        B       Max_an_End_Switch

Max_an_Max_not_equal_1:

;        else
;        {
;          StartMaxNumber = StartMaxNumber + 1;
;          ThreeImpulseFlag = 1;
;        }
;      }

Max_an_TempAmpl_not_equal:

;      else
;      {
;        /* Если нет совпадения по амплитуде то анализируем этот и следующий импульс */
;        StartMaxNumber = StartMaxNumber + 1;
;        ThreeImpulseFlag = 1;
;      }
;    }

Max_an_Not_Period_1:

;    else
;    {
;     StartMaxNumber = StartMaxNumber + 1;
;     ThreeImpulseFlag = 1;

        LACC    StartMaxNumber,0
        ADD     #1
        SACL    StartMaxNumber

	LACC	MeasurementFlags,0
	OR	#(1<<THREE_IMPULSE_FLAG)
	SACL	MeasurementFlags,0

;    }
;   }

        B       Max_an_End_Switch


Max_an_ThreeImpulseFlag

;   else
;   {
;    if (( abs( TempPeriodDiff)) < 0.33*AveragePeriodEvaluation)

        LACC    TempPeriodDiff,15
        ABS
        LT      AveragePeriodEvaluation
        MPY     #CONST_0_33
        SPAC
        BCND    Max_an_Not_Period_1_2,GEQ

;    {
;      if ( TempAmplitudeDiff < 0.3*Diff2Max[MaxNumber])

	LACC	TempAmplitudeDiff,13
	LT	*,AR2
	MPY	#CONST_0_499			;#CONST_0_3
	SPAC
        BCND    Max_an_TempAmpl_not_equal_2,GEQ

;     {
;      Average();

        CALL    Average

;     }

        B       Max_an_End_Switch

Max_an_TempAmpl_not_equal_2

;     else                              ; Код повтоpяется ниже
;     {
;      StartMaxNumber = StartMaxNumber + 1;
;     }
;    }

Max_an_Not_Period_1_2

;    else
;    {
;     StartMaxNumber = StartMaxNumber + 1;

        LACC    StartMaxNumber,0
        ADD     #1
        SACL    StartMaxNumber

;    }
;   }
;   break;

        B       Max_an_End_Switch

Max_an_default
;  default:
;   if (( abs( TempPeriodDiff)) < 0.33*AveragePeriodEvaluation)

        LACC    TempPeriodDiff,15
        ABS
        LT      AveragePeriodEvaluation
        MPY     #CONST_0_33
        SPAC
        BCND    Max_an_Not_Period_Def,GEQ

;   {
;      if ( TempAmplitudeDiff < 0.3*Diff2Max[MaxNumber])

	LACC	TempAmplitudeDiff,13
	LT	*,AR2
	MPY	#CONST_0_499			;#CONST_0_3
	SPAC
        BCND    Max_an_TempAmpl_not_equal_Def,GEQ

;    {
;      Average();

        CALL    Average

;      Trend_measurement_2()

        CALL    Trend_measurement_2

;      if (( abs( Max[2]-Max[1]) < 0.35 Max[2])&&
;      	   ( abs( Max[1]-Max[0]) < 0.35 Max[1]))

        MAR     *,AR2
	LAR	AR2,#Max+2
	LACC    *,13,AR2         ;14
	LT      *-,AR2
	MPY     #CONST_0_35       ;CONST_0_2
	SUB     *,13,AR2         ;14
	ABS
	SPAC
        BCND    Max_an_Max_not_equal_Def,GEQ

	LACC    *,13,AR2         ;14
	LT      *-,AR2
	MPY     #CONST_0_35       ;CONST_0_2
	SUB     *,13,AR2         ;14
	ABS
	SPAC
        BCND    Max_an_Max_not_equal_Def,GEQ

;      {
;     	 /* Средние Амплитуда и Давление на этой ступеньке */

        LAR     AR0,StepNumber
        LAR     AR2,#AverageAmplitude
        MAR     *0+,AR3
        LAR     AR3,#AvrPress
        MAR     *0+,AR4
        LAR     AR4,#Max

;        AverageAmplitude[StepNumber] = ( Max[0] + Max[1] + Max[2] ) * 0.33;

        LACC    *+,14,AR4
        ADD     *+,14,AR4
        ADD     *,14,AR2
        SACH    *,0,AR2
	LT	*,AR2
	MPY	#CONST_0_33
	PAC
	SACH	*,5,AR2

;     	 AvrPress[StepNumber] = ( MaxAvrPress[0] + MinAvrPress[0] +
;                              MaxAvrPress[1] + MinAvrPress[1] +
;                              MaxAvrPress[2] + MinAvrPress[2])*0.1667;

        LAR     AR2,#MaxAvrPress
        LACC    *+,13,AR2
        ADD     *+,13,AR2
        ADD     *,13,AR2
        LAR     AR2,#MinAvrPress
        ADD     *+,13,AR2
        ADD     *+,13,AR2
        ADD     *,13,AR3
        SACH    *,0,AR3
	LT	*,AR3
	MPY	#CONST_0_33
	PAC
	SACH	*,5,AR2
;
;     	 NextModeFlag = 1;

        SPLK    #1,NextModeFlag

;      }

        B       Max_an_End_Switch

Max_an_Max_not_equal_Def:

;      else
;      {
;        StartMaxNumber = StartMaxNumber + 1;

        LACC    StartMaxNumber,0
        ADD     #1
        SACL    StartMaxNumber

;      }

        B       Max_an_End_Switch

;    }

Max_an_TempAmpl_not_equal_Def:

;    else
;    {
;     StartMaxNumber = StartMaxNumber + 2;

        LACC    StartMaxNumber,0
        ADD     #2
        SACL    StartMaxNumber
        B       Max_an_End_Switch

;    }
;   }

Max_an_Not_Period_Def

;   else
;   {
;    StartMaxNumber = StartMaxNumber + 2;

        LACC    StartMaxNumber,0
        ADD     #2
        SACL    StartMaxNumber

;    if ((( SampleNumber - AnalysisStart ) > 5*AnalysisInterval )&&
;         ( MaxNumber < 2 ))

	LACC	SampleNumber,0
	SUB	AnalysisStart,0
	SUB	AnalysisInterval,2
	SUB	AnalysisInterval,0
	BCND	Max_an_End_Switch,LEQ
	LACC	MaxNumber,0
	SUB	#2
	BCND	Max_an_End_Switch,GEQ

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

;    }
;   }
;   break;
; }

Max_an_End_Switch

        MAR     *,AR3
        LAR     AR0,MaxNumber
        LAR     AR3,#Diff2Max
        MAR     *0+,AR3

;   LastDiff2Max = Diff2Max[MaxNumber];

        LACC    *,0,AR4
        SACL    LastDiff2Max

        LAR     AR4,#Diff2MaxAdress
        MAR     *0+,AR5
        LAR     AR0,MaxNumberShift
        LAR     AR5,#Diff2MaxAdressFinish
        MAR     *0+,AR4

;   Diff2MaxAdressFinish[MaxNumberShift] = Diff2MaxAdress[MaxNumber] +
;                                          SampleNumberShift;

        LACC    *,AR5
        ADD     SampleNumberShift,0
        SACL    *,AR2

;   MaxNumberShift++;

        LACC    MaxNumberShift
        ADD     #1
        SACL    MaxNumberShift

;   MaxNumber++;

        LACC    MaxNumber
        ADD     #1
        SACL    MaxNumber

;   Max2DiffAdress[2] = Max2DiffAdress[1];
;   Max2DiffAdress[1] = Max2DiffAdress[0];

	LAR	AR2,#Max2DiffAdress+1
	DMOV	*-,AR2
	DMOV	*,AR2

;   MaxAvrPress[2] = MaxAvrPress[1];
;   MaxAvrPress[1] = MaxAvrPress[0];

	LAR	AR2,#MaxAvrPress+1
	DMOV	*-,AR2
	DMOV	*,AR2

;   MinAvrPress[2] = MinAvrPress[1];
;   MinAvrPress[1] = MinAvrPress[0];

	LAR	AR2,#MinAvrPress+1
	DMOV	*-,AR2
	DMOV	*,AR2

;}

        RET
