* $Id: PUL_F_E.ASM,v 1.7 2001-04-26 13:54:26 zykov Exp $
; /* При инициализации процесса измерения */
; MaxNumber = 0;                                   // Номер максимума.
; MaxNumberShift = 0;                              // Номер максимума.
; SampleNumberShift = 0;
; AnalysisInterval = AveragePeriod*1.25;   // при старте измерени
;                                          // AveragePeriod = 32.
; AnalysisStart = AnalysisInterval + 2*DIFF_BASIS;

 .if SIM == 1
*** используется для симулятора
InitPulse
	LDP     #4       ;??????????????????????????????????
	SPLK    #0,SampleNumber
	SPLK    #0,SampleNumberShift
	SPLK    #32,AnalysisInterval
        SPLK    #1000h,PressureTop
        LACC    AnalysisInterval
        ADD     #DIFF_BASIS*2
        SACL    AnalysisStart
	RET
 .endif

ThresholdOfMax	.equ	TMP

;void Pulse_frequency_evaluation()
;{

Pulse_frequency_evaluation

;if ( SampleNumber > AnalysisStart )

        LACC    SampleNumber
        SUB     AnalysisStart
	BCND    Pulse_f_end,LEQ

; {
;  if ( DiffMaxFlag == TRUE )

	BIT	MeasurementFlags,15-DIFF_MAX_FLAG
        BCND    Pulse_f_MaxNotCentre,NTC

;  {
;  if ( Diff2Max[MaxNumber] > MIN_THRESHOLD_40MM )  // > 0.1 мм.рт.ст

        LAR     AR0,MaxNumber
        LAR     AR2,#Diff2Max
        LAR     AR1,#Diff2MaxAdress
        MAR     *,AR2
        MAR     *0+,AR1                 ;AR2 = & Diff2Max[MaxNumber]
        MAR     *0+,AR2                 ;AR1 = & Diff2MaxAdress[MaxNumber]
        LACC    *,0,AR2                 ;AR2 = & Diff2Max[MaxNumber]
        SUB     #MIN_THRESHOLD_40MM
        BCND    Pulse_f_MaxLessTh,LEQ

;   {
;     ThresholdOfMax = MAX_THRESHOLD_40MM-MIN_THRESHOLD_40MM;

	SPLK	#MAX_THRESHOLD_40MM-MIN_THRESHOLD_40MM,ThresholdOfMax

;     if ( PressPulseFrEv > PRESS_60 )

	LACC	PressPulseFrEv,0
	SUB	#PRESS_60
	BCND    Pulse_f_MaxMoreTh_Anal,LT

;     {
;       ThresholdOfMax = MAX_THRESHOLD_SISTOL;

	SPLK	#MAX_THRESHOLD_SISTOL,ThresholdOfMax

;     }
;   if ( Diff2Max[MaxNumber] < ThresholdOfMax )  // < 4 мм.рт.ст

Pulse_f_MaxMoreTh_Anal:

        LACC    *-,0,AR2                ;AR2 = & Diff2Max[MaxNumber-1]
        SUB     ThresholdOfMax
        BCND    Pulse_f_MaxMoreTh,GT

;    {
;     switch ( MaxNumber )
;      {

        LACC    MaxNumber
        BCND    Pulse_f_case1,NEQ

;      case 0:
;       MaxNumber++;

        SPLK    #1,MaxNumber

;       break;

        B       Pulse_f_End_switch

Pulse_f_case1
        SUB     #1
        BCND    Pulse_f_case2,NEQ

;      case 1:
;       AveragePeriodEvaluation = TempPeriod;

        LACC    TempPeriod,2
	SACL    AveragePeriodEvaluation

;       if ( TempAmplitudeDiff < 0.499*Diff2Max[0])

					 ; AR2 = & Diff2Max[MaxNumber-1]
	LT      *+,AR2                   ; AR2 = & Diff2Max[MaxNumber]
	MPY     #CONST_0_499
	PAC
	SUB     TempAmplitudeDiff,13
	BCND    Pulse_f_NotMax1,LEQ

;        {
;         if ( AveragePeriodEvaluation > MIN_DURATION)

	LACC    AveragePeriodEvaluation
        SUB     #MIN_DURATION,2
        BCND    Pulse_f_End_switch,LEQ

;         {
;          if ( AveragePeriodEvaluation < MAX_DURATION)

        SUB     #MAX_DURATION-MIN_DURATION,2
        BCND    Pulse_f_Max1_moreMaxDur_1,GEQ

;          {
;           MaxNumber++;

        SPLK    #2,MaxNumber

;	   }

        B       Pulse_f_End_switch

Pulse_f_Max1_moreMaxDur_1

;         else
;          {
;           Numbers_change(0,1);
;             Diff2Max[0] = Diff2Max[1];

                                        ;AR2 = & Diff2Max[MaxNumber]
        LACC    *-,0,AR2                ;AR2 = & Diff2Max[MaxNumber-1]
        SACL    *,AR1                   ;AR1 = & Diff2MaxAdress[MaxNumber]

;             Diff2MaxAdress[MaxNumber-1] = Diff2MaxAdress[MaxNumber];

        LACC    *-                      ;AR1 = & Diff2MaxAdress[MaxNumber-1]
        SACL    *                       ;AR1 = & Diff2MaxAdress[MaxNumber-1]

;	   }

        B       Pulse_f_End_switch

;	  }
;	 }

Pulse_f_NotMax1

;       else
;        {
;        if ( AveragePeriodEvaluation < MAX_DURATION )

	LACC    AveragePeriodEvaluation
        SUB     #MAX_DURATION,2
        BCND    Pulse_f_Max1_moreMaxDur_2,GEQ

;         {
;          if ( Diff2Max[1] > Diff2Max[0])

                                        ; AR2 = &Diff2Max[1]
        LACC    *-,0,AR2                ; AR2 = &Diff2Max[0]
        SUB     *+,0,AR2                ; AR2 = &Diff2Max[1]
        BCND    Pulse_f_End_switch,LEQ

;           {
;            Numbers_change(0,1);
;           }
;         }
;        B       Pulse_f_End_switch     Закоментиpовано т.к.
;                                       код дальше повтоpяется

Pulse_f_Max1_moreMaxDur_2

;        else
;         {
;	 Numbers_change(0,1);
;             Diff2Max[0] = Diff2Max[1];

                                        ;AR2 = & Diff2Max[MaxNumber]
        LACC    *-,0,AR2                ;AR2 = & Diff2Max[MaxNumber-1]
        SACL    *,AR1                   ;AR1 = & Diff2MaxAdress[MaxNumber]

;             Diff2MaxAdress[MaxNumber-1] = Diff2MaxAdress[MaxNumber];

        LACC    *-                      ;AR1 = & Diff2MaxAdress[MaxNumber-1]
        SACL    *                       ;AR1 = & Diff2MaxAdress[MaxNumber-1]

;         }
;        }
;        break;

        B       Pulse_f_End_switch

Pulse_f_case2
        SUB     #1
        BCND    Pulse_f_def,NEQ

;      case 2:
;       SynchCount=0;

        SPLK    #0,SynchCount

;       if ( TempAmplitudeDiff < 0.499*Diff2Max[1])

					 ; AR2 = & Diff2Max[MaxNumber-1]
	LT      *+,AR2                   ; AR2 = & Diff2Max[MaxNumber]
	MPY     #CONST_0_499
	PAC
	SUB     TempAmplitudeDiff,13
        BCND    Pulse_f_NotMax2,LEQ

;       {
;        if (( abs( TempPeriodDiff)) < 0.33*AveragePeriodEvaluation)

	LT      AveragePeriodEvaluation
        MPY     #CONST_0_33
	LACC    TempPeriodDiff,15
	ABS
        SPAC
        BCND    Pulse_f_MorePeriodDiff_2,GEQ

;        {
;         AveragePeriodEvaluation = AveragePeriodEvaluation +
;                                   TempPeriodDiff/2;

	LACC    TempPeriodDiff,1
	ADD     AveragePeriodEvaluation
	SACL    AveragePeriodEvaluation

;         AnalysisInterval = AveragePeriodEvaluation*1.25;

	LACC    AveragePeriodEvaluation,14
      	ADD     AveragePeriodEvaluation,12                   ;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	SACH    AnalysisInterval,0

;         AnalysisStart = SampleNumber + AnalysisInterval/4;

        LACC    AnalysisInterval
        SFR
        SFR
        ADD     SampleNumber
        SACL    AnalysisStart

;         MaxNumber = 3;

        SPLK    #3,MaxNumber

;         }

        B       Pulse_f_End_switch

Pulse_f_MorePeriodDiff_2

;        else
;         {
                                        ; AR2 = & Diff2Max[MaxNumber]
        MAR    *-,AR1                   ; AR2 = & Diff2Max[MaxNumber-1]
        MAR    *-,AR2                   ; AR1 = & Diff2MaxAdress[MaxNumber-1]

;          Numbers_change(0,1);
;             Diff2Max[0] = Diff2Max[1];

                                        ; AR2 = & Diff2Max[MaxNumber-1]
        LACC    *-,0,AR2                ; AR2 = & Diff2Max[MaxNumber-2]
        SACL    *+,0,AR1                ; AR2 = & Diff2Max[MaxNumber-1]

;             Diff2MaxAdress[MaxNumber-1] = Diff2MaxAdress[MaxNumber];

                                        ; AR1 = & Diff2MaxAdress[MaxNumber-1]
        LACC    *-,0,AR1                ; AR1 = & Diff2MaxAdress[MaxNumber-2]
        SACL    *+,0,AR2                ; AR1 = & Diff2MaxAdress[MaxNumber-1]

        MAR     *+,AR1                  ; AR2 = & Diff2Max[MaxNumber]
        MAR     *+,AR2                  ; AR1 = & Diff2MaxAdress[MaxNumber]

;          Numbers_change(1,2);
;             Diff2Max[1] = Diff2Max[2];

                                        ;AR2 = & Diff2Max[MaxNumber]
        LACC    *-,0,AR2                ;AR2 = & Diff2Max[MaxNumber-1]
        SACL    *,0,AR1                 ;AR1 = & Diff2MaxAdress[MaxNumber]

;             Diff2MaxAdress[MaxNumber-1] = Diff2MaxAdress[MaxNumber];

        LACC    *-,0,AR1                ;AR1 = & Diff2MaxAdress[MaxNumber-1]
        SACL    *,0,AR1                 ;AR1 = & Diff2MaxAdress[MaxNumber-1]

;        AveragePeriodEvaluation = Diff2MaxAdress[1] - Diff2MaxAdress[0];

        LACC    *-,2,AR1                ;AR1 = & Diff2MaxAdress[MaxNumber-2]
        SUB     *,2
	SACL    AveragePeriodEvaluation

;         }
;	}

        B       Pulse_f_End_switch

Pulse_f_NotMax2

;       else
;        {
;         if ( AveragePeriodEvaluation < MAX_DURATION )

	LACC    AveragePeriodEvaluation
        SUB     #MAX_DURATION,2
        BCND    Pulse_f_Max2_moreMaxDur,GEQ

;         {
;          if ( Diff2Max[2] > Diff2Max[1])
;          {
                                        ; AR2 = & Diff2Max[MaxNumber]
        LACC    *-                      ; AR2 = & Diff2Max[MaxNumber-1]
        SUB     *+                      ; AR2 = & Diff2Max[MaxNumber]
        BCND    Pulse_f_End_switch ,LEQ

;           Numbers_change(0,2);
;           MaxNumber = 1;
;        B       Pulse_f_End_switch      Закоментиpовано т.к.
;                                        код дальше повтоpяется

Pulse_f_Max2_moreMaxDur

;         Numbers_change(0,2);
;            Diff2Max[0] = Diff2Max[2];
					; AR2 = & Diff2Max[MaxNumber]
	LACC    *-                      ; AR2 = & Diff2Max[MaxNumber-1]
	MAR     *-                      ; AR2 = & Diff2Max[MaxNumber-2]
	SACL    *,AR1                   ; AR1 = & Diff2MaxAdress[MaxNumber]

;            Diff2MaxAdress[0] = Diff2MaxAdress[2];

        LACC    *-                      ; AR1 = & Diff2MaxAdress[MaxNumber-1]
        MAR     *-                      ; AR1 = & Diff2MaxAdress[MaxNumber-2]
        SACL    *,AR2                   ; AR1 = & Diff2MaxAdress[MaxNumber-2]

;         MaxNumber = 1;

        SPLK    #1,MaxNumber

;         }
;        }
;       break;

        B       Pulse_f_End_switch


Pulse_f_def

;      default:
;       if (( abs( TempPeriodDiff)) < 0.33*AveragePeriodEvaluation)

        LT      AveragePeriodEvaluation
        MPY     #CONST_0_33
        LACC    TempPeriodDiff,15
        ABS
        SPAC
        BCND    Pulse_f_MorePeriodDiff_def,GEQ

;       {
;        if ( TempAmplitudeDiff < 0.499*Diff2Max[MaxNumber-1])

					 ; AR2 = & Diff2Max[MaxNumber-1]
        LT      *+,AR2                   ; AR2 = & Diff2Max[MaxNumber]
        MPY     #CONST_0_499
        PAC
        SUB     TempAmplitudeDiff,13
        BCND    Pulse_f_End_switch,LEQ

;        {
;         Average();

        CALL    Average

;         AveragePeriod=AveragePeriodEvaluation;

        LACC    AveragePeriodEvaluation,2
        SACL    AveragePeriod

;         MaxNumber++;

        LACC    MaxNumber
        ADD     #1
        SACL    MaxNumber

;         SynchCount++;

        LACC    SynchCount
        ADD     #1
        SACL    SynchCount

;        }
;       }

        B       Pulse_f_End_switch


Pulse_f_MorePeriodDiff_def

;       else
;       {
;        if (( abs( TempPeriod - 2*AveragePeriodEvaluation)) <
;               0.33*AveragePeriodEvaluation)

        LT      AveragePeriodEvaluation
        MPY     #CONST_0_33
        LACC    TempPeriod,15
        SUB     AveragePeriodEvaluation,14
        ABS
        SPAC
        BCND    Pulse_f_More2PeriodDiff_def,GEQ

;        {
;         if ( TempAmplitudeDiff < 0.499*Diff2Max[MaxNumber-1])

                                         ; AR2 = & Diff2Max[MaxNumber-1]
        LT      *+,AR2                   ; AR2 = & Diff2Max[MaxNumber]
        MPY     #CONST_0_499
        PAC
        SUB     TempAmplitudeDiff,13
        BCND    Pulse_f_moreTemp1_def,LEQ

;         {
;          Average_2();

        CALL    Average_2

;          AveragePeriod=AveragePeriodEvaluation;

        LACC    AveragePeriodEvaluation,2
        SACL    AveragePeriod

;	  MaxNumber++;

        LACC    MaxNumber
        ADD     #1
        SACL    MaxNumber

;          SynchCount--;

        LACC    SynchCount
        SUB     #1
        SACL    SynchCount

;	  }

        B       Pulse_f_End_switch

Pulse_f_moreTemp1_def

;         else
;         {
;          MaxNumber = 0;               Закоментиpовано т.к.
;         }                             код дальше повтоpяется
;        }
;       B       Pulse_f_End_switch

Pulse_f_More2PeriodDiff_def

;        else
;        {
;          MaxNumber = 0;

        SPLK    #0,MaxNumber

;        }
;       }
;       break;
;      }// End_switch

Pulse_f_End_switch

;      if ( SynchCount > 0 )

        LACC    SynchCount
;        SUB     #1
        BCND    Pulse_f_MaxLessTh,LEQ

;       {
;        //подготовка следующего режима
;        MaxDiffSignal = 0;

        SPLK    #0,MaxDiffSignal

;        Mode=PRESSURE_AUGMENT;

        SPLK    #PRESSURE_AUGMENT,Mode
	mMotor_on

;       i = MaxNumber - 1;
;       while ( i >= 0 )

        MAR     *,AR2
        LAR     AR0,MaxNumberShift
        LAR     AR2,#Diff2MaxAdressFinish
        MAR     *0+,AR0
        LAR     AR0,MaxNumber
        MAR     *-,AR1
        LAR     AR1,#Diff2MaxAdress
        MAR     *0+,AR2
        MAR     *0+,AR3

        LAR     AR3,#Diff2Max
        MAR     *0+,AR3

;   LastDiff2Max = Diff2Max[MaxNumber-1];

        LACC    *,0,AR1
        SACL    LastDiff2Max

;       {
;         Diff2MaxAdressFinish[MaxNumberShift+i] = Diff2MaxAdress[i];
;         i--;

Pulse_f_for_i
        LACC    *-,AR2
        SACL    *-,AR0
        BANZ    Pulse_f_for_i,*-,AR1

;       }
;       MaxNumberShift = MaxNumber;
;       SynchroFlag = False;
;	StepNumber = 0;
;       MaxNumber = 0;
;       StartMaxNumber = 0;
;	PulseCounter = 0;
;	AugmentPressureNumber = 0;
;       PressureMoreSystolFlag = False;
;       SampleNumberShift = SampleNumberShift + SampleNumber + 1;
;       SampleNumber = -1;

        LACC    MaxNumber,0
        SACL    MaxNumberShift
        LACC    SampleNumberShift,0
        ADD     SampleNumber
        ADD     #1
        SACL    SampleNumberShift
        LACC    #0
	SACL	StepNumber
        SACL    MaxNumber
	SACL    StartMaxNumber
	SACL    PulseCounter
	SACL    AugmentPressureNumber
        SPLK    #0FFFFh,SampleNumber
	LACC	MeasurementFlags,0
	AND	#~(1<<SYNCHRO_FLAG)
	AND	#~(1<<PRESS_MORE_SYSTOL_FLAG)
	SACL	MeasurementFlags,0

; ++        AnalysisStart = TIME_OF_MAX_PRESSURE + 0,5*AnalysisInterval;

        LACC    AnalysisInterval,14
	ADD	#TIME_OF_MAX_PRESSURE,15
        SACH    AnalysisStart,1

;	StartMeasAdress[StepNumber] = SampleNumberShift;

	LAR	AR1,#StartMeasAdress
	LACC	SampleNumberShift
	SACL	*,0,AR1

;       }

        B       Pulse_f_MaxLessTh

;     }

Pulse_f_MaxMoreTh

;     else
;     { //вышли за диапазон верхней границы
;      MaxNumber = 0;

        SPLK    #0,MaxNumber

;     }
;    }// End Max > 0.1 мм.рт.ст


Pulse_f_MaxLessTh

;   }

Pulse_f_MaxNotCentre

;  }

Pulse_f_end

;}
        RET
