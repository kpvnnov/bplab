;//***********************************************************************
;//  Pressure_augment( PressureTop ) -
;//      Увеличение давления до систолическое+30 мм.рт.ст.
; $Id: PRESSAUG.ASM,v 1.6 2001-02-15 14:10:40 peter Exp $
;//***********************************************************************

AvrOfTwoDiff2Max	.equ	TMP


Pressure_augment

;
;{
;  if ( SampleNumber > DIFF_BASIS_OF_PR_AUG_1)

	LACC	SampleNumber,0
	SUB	#DIFF_BASIS_OF_PR_AUG_1
	BCND	Pulse_aug_check_error_2,LEQ

;  {
;    DiffSignal = Signal[SampleNumber] -
;		  Signal[SampleNumber-DIFF_BASIS_OF_PR_AUG_1];

	MAR	*,AR1
	LAR	AR0,SampleNumber
	LAR	AR1,#Signal
	MAR	*0+,AR2
	LAR	AR2,#Signal - DIFF_BASIS_OF_PR_AUG_1
	MAR	*0+,AR1
	LACC	*,0,AR2
	SUB	*

;    if ( DiffSignal < ZERO_ZERO_FIVE_MM_PER_SAMPLE )

	SUB	#ZERO_ZERO_FIVE_MM_PER_SAMPLE
	BCND	Pulse_aug_check_error_2,GEQ

;    {  /* маленькая скоpость наpастания давления ( система стpавливает)*/

	.if SIM == 0
	mEnd_error_meas rSMALL_SPEED_AUG_PR
	.endif
	RET

;    }
;  }

Pulse_aug_check_error_2:

;  if ( SampleNumber > DIFF_BASIS_OF_PR_AUG_2)

	LACC	SampleNumber,0
	SUB	#DIFF_BASIS_OF_PR_AUG_2
	BCND	Pulse_aug_AnalysisStart,LEQ

;  {
;    DiffSignal = Signal[SampleNumber] -
;       	  Signal[SampleNumber-DIFF_BASIS_OF_PR_AUG_2];

	MAR	*,AR1
	LAR	AR0,SampleNumber
	LAR	AR1,#Signal
	MAR	*0+,AR2
	LAR	AR2,#Signal - DIFF_BASIS_OF_PR_AUG_2
	MAR	*0+,AR1
	LACC	*,0,AR2
	SUB	*

;    if ( DiffSignal > ONE_MM_PER_SAMPLE )

	SUB	#ONE_MM_PER_SAMPLE
	BCND	Pulse_aug_AnalysisStart,LEQ

;    {  /* Большая скоpость наpастания давления ( пеpежат шланг)*/

	.if SIM == 0
	mEnd_error_meas rBIG_SPEED_AUG_PR
	.endif
	RET

;    }
;  }

Pulse_aug_AnalysisStart:

; if ( SampleNumber > AnalysisStart )

        LACC    SampleNumber
        SUB     AnalysisStart
        BCND    Pulse_aug_End,LEQ

; {
;  if ( DiffMaxFlag == TRUE )

	BIT	MeasurementFlags,15-DIFF_MAX_FLAG
        BCND    Pulse_aug_MaxNotCentre,NTC

;  {

        MAR     *,AR2
        LAR     AR0,MaxNumber
        LAR     AR2,#Diff2Max
        MAR     *0+,AR2                 ;AR2 = & Diff2Max[MaxNumber]

;  // Если Max находится в 0.5 от конца интервала
;   if ( Diff2Max[MaxNumber] > 0.25*LastDiff2Max)

	LACC    *,16,AR2        ;AR2 = & Diff2Max[MaxNumber]
	SUB     LastDiff2Max,14
	BCND    Pulse_aug_SmallMax,LT

;   {
;    if ( Diff2Max[MaxNumber] < 4*LastDiff2Max)

        LACC    *,0,AR2                 ;AR2 = & Diff2Max[MaxNumber]
        SUB     LastDiff2Max,2
;        SUB     LastDiff2Max,0
        BCND    Pulse_aug_MoreMax,GEQ

;    {
;     Temporary1 = MaxNumber;

        LACC    MaxNumber
        SACL    TMP+7

;     if (( abs( TempPeriod - AveragePeriodEvaluation )) <
;       0.33*AveragePeriodEvaluation )

        LT      AveragePeriodEvaluation
        MPY     #CONST_0_33
        LACC    TempPeriod,15
        SUB     AveragePeriodEvaluation,13
        ABS
        SPAC
        BCND    Pulse_aug_2Period,GEQ

;     {
;      Average();

        CALL    Average

;      MaxNumber++;

        LACC    MaxNumber
        ADD     #1
        SACL    MaxNumber

;     }

Pulse_aug_2Period

;     if (( abs( TempPeriod - 2*AveragePeriodEvaluation )) <
;               0.375*AveragePeriodEvaluation )

        LT      AveragePeriodEvaluation
        MPY     #CONST_0_375
        LACC    TempPeriod,15
        SUB     AveragePeriodEvaluation,14
        ABS
        SPAC
        BCND    Pulse_aug_3Period,GEQ

;     {
;      Average_2();

        CALL    Average_2

;      MaxNumber++;

        LACC    MaxNumber
        ADD     #1
        SACL    MaxNumber

;     }

Pulse_aug_3Period

;     if (( abs( TempPeriod - 3*AveragePeriodEvaluation )) <
;                       0.375*AveragePeriodEvaluation )

        LT      AveragePeriodEvaluation
        MPY     #CONST_0_375
        LACC    TempPeriod,15
        SUB     AveragePeriodEvaluation,14
        SUB     AveragePeriodEvaluation,13
        ABS
        SPAC
        BCND    Pulse_aug_End_3Period,GEQ

;     {
;      AveragePeriodEvaluation = AveragePeriodEvaluation +
;		( TempPeriod - 3*AveragePeriodEvaluation )/16;

        LACC    AveragePeriodEvaluation,16
        ADD     TempPeriod,14
        SUB     AveragePeriodEvaluation,12
        SUB     AveragePeriodEvaluation,13
        SACH    AveragePeriodEvaluation,0

;      AveragePeriod = AveragePeriod + ( TempPeriod*0.33 - AveragePeriod)/16;

        LT      TempPeriod
        MPY     #CONST_0_33
        LACC    AveragePeriod,15
        SUB     AveragePeriod,11
        APAC
        SACH    AveragePeriod,1

;      AnalysisInterval = AveragePeriodEvaluation*1.25;

        LACC    AveragePeriodEvaluation,14
        ADD     AveragePeriodEvaluation,12                   ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!
        SACH    AnalysisInterval,0

;      AnalysisStart = SampleNumber + AnalysisInterval/4;

        LACC    SampleNumber,16
        ADD     AnalysisInterval,14
	SACH    AnalysisStart

;      MaxNumber++;

        LACC    MaxNumber
        ADD     #1
        SACL    MaxNumber

;     }

Pulse_aug_End_3Period

;     if ( Temporary1 != MaxNumber)

        LACC    TMP+7
        SUB     MaxNumber
        BCND    Pulse_aug_BadPulse,EQ

;     {
;	PulseCounter++;

	LACC    PulseCounter
	ADD	#1
	SACL    PulseCounter

;       SynchroFlag = True;

	LACC	MeasurementFlags,0
	OR	#(1<<SYNCHRO_FLAG)
	SACL	MeasurementFlags,0

;       if ( MaxDiffSignal < Diff2Max[MaxNumber-1])
;                               Здесь "MaxNumber-1" потому, что
;                               уже было "MaxNumber+1", AR2 не изменялось

        LACC    *,0,AR2                 ;AR2 = & Diff2Max[MaxNumber]
        SUB     MaxDiffSignal
        BCND    Pulse_aug_CheckAmpl,LEQ

;       {
;        MaxDiffSignal = Diff2Max[MaxNumber-1];

        LACC    *,0,AR2                 ;AR2 = & Diff2Max[MaxNumber]
        SACL    MaxDiffSignal

;       }

Pulse_aug_CheckAmpl

;   AvrOfTwoDiff2Max = Diff2Max[MaxNumber-1] + LastDiff2Max;

        LACC    *,0,AR2
        ADD     LastDiff2Max
        SACL    AvrOfTwoDiff2Max

;   LastDiff2Max = Diff2Max[MaxNumber-1];
;   /* Здесь "MaxNumber-1" потому, что уже было "MaxNumber+1" */

        LACC    *,0,AR3
        SACL    LastDiff2Max

        LAR     AR0,MaxNumber
        LAR     AR3,#Diff2MaxAdress-1
        MAR     *0+,AR4
        LAR     AR0,MaxNumberShift
        LAR     AR4,#Diff2MaxAdressFinish
        MAR     *0+,AR3

;       Diff2MaxAdressFinish[MaxNumberShift] = Diff2MaxAdress[MaxNumber-1] +
;                                              SampleNumberShift;
;                                  Здесь "MaxNumber-1" потому, что
;                                  уже было "MaxNumber+1"

        LACC    *,0,AR4
        ADD     SampleNumberShift,0
        SACL    *,0,AR2

;       MaxNumberShift++;

        LACC    MaxNumberShift,0
        ADD     #1
        SACL    MaxNumberShift

;       MaxNumber = 0;

        SPLK    #0,MaxNumber

;      if(( MaxDiffSignal*0.5 > ( Diff2Max[MaxNumber-1] +
;			          Diff2Max[MaxNumber-2])/2) &&
;				( PulseCounter > 5 ))
;                               Здесь "MaxNumber-1" потому, что
;                               уже было "MaxNumber+1", AR2 не изменялось

	LACC	PulseCounter,0
	SUB	#5
	BCND    Pulse_aug_CheckPress,LEQ
	LACC    MaxDiffSignal,15
	;;;;; SUB     MaxDiffSignal,12
	SUB	AvrOfTwoDiff2Max,15
	BCND    Pulse_aug_CheckPress,LEQ

;      {
;        if ( PressureMoreSystolFlag != TRUE )

	BIT	MeasurementFlags,15-PRESS_MORE_SYSTOL_FLAG
	BCND	Pulse_aug_CheckPress,TC

;        {
;          PressureTop = Signal[SampleNumber] +
;			 RESERVE_MILL_OF_MERC + PRESS_02_5;

        MAR     *,AR1
        LAR     AR0,#Signal
        LAR     AR1,SampleNumber
        MAR     *0+,AR1
        LACC    *,0
	ADD	#RESERVE_MILL_OF_MERC + PRESS_02_5,0
	SACL	PressureTop

;          PressureMoreSystolFlag = TRUE;

	LACC	MeasurementFlags,0
	OR	#(1<<PRESS_MORE_SYSTOL_FLAG)
	SACL	MeasurementFlags,0
	B       Pulse_aug_CheckPress

;        }
;      }

Pulse_aug_BadPulse

;      else
;      { //   Вероятная потеря синхронизации
;       SynchroFlag = False;

	LACC	MeasurementFlags,0
	AND	#~(1<<SYNCHRO_FLAG)
	SACL	MeasurementFlags,0

;      }
;     }

Pulse_aug_MoreMax

;    }

Pulse_aug_SmallMax

;   }
;   if (( SampleNumber - AnalysisStart ) > 1.5*AnalysisInterval )

	LACC	SampleNumber,1
	SUB	AnalysisStart,1
	SUB	AnalysisInterval,1
	SUB	AnalysisInterval,0
	BCND	Pulse_aug_SmallTime,LEQ

;   {  //   Вероятная потеря синхронизации
;      SynchroFlag = False;

	LACC	MeasurementFlags,0
	AND	#~(1<<SYNCHRO_FLAG)
	SACL	MeasurementFlags,0

;   }

Pulse_aug_SmallTime

Pulse_aug_CheckPress


;   if ( SampleNumber >= ( ONE_SECOND*9 ))

	LACC	SampleNumber,0
	SUB	#ONE_SECOND*9
	BCND	Pulse_aug_MaxNotCentre,LT

;   {
;     for ( i = 0; i <= ONE_SECOND*2; i++)
;       {
;         Signal[i] = Signal[SampleNumber - ONE_SECOND*2 + i];
;       }

	MAR	*,AR1
	LAR	AR0,SampleNumber
	LAR	AR1,#Signal - ONE_SECOND*2
	MAR	*0+,AR1
	RPT	#ONE_SECOND*2
	BLDD	*+,#Signal

;     SampleNumberShift = SampleNumberShift + SampleNumber - ONE_SECOND*2;
;     SampleNumber = ONE_SECOND*2 - 1;

	LACC	SampleNumberShift,0
	ADD 	SampleNumber,0
	SUB	#ONE_SECOND*2
	SACL	SampleNumberShift,0
	SPLK	#ONE_SECOND*2,SampleNumber

;     AnalysisStart = AnalysisStart - ONE_SECOND*7 );

	LACC	AnalysisStart,0
	SUB	#ONE_SECOND*7
	SACL	AnalysisStart,0

;     if ( AnalysisStart < 0 )
;       {
;         AnalysisStart = 0;
;       }

	BCND	Pulse_aug_MaxNotCentre,GEQ
	SPLK	#0,AnalysisStart

;   }

Pulse_aug_MaxNotCentre:

;   if ( Signal[SampleNumber] > PressureTop )

        MAR     *,AR1
        LAR     AR0,#Signal
        LAR     AR1,SampleNumber
        MAR     *0+,AR1
        LACC    *
        SUB     PressureTop
        BCND    Pulse_aug_End,LEQ
;   {

Pulse_aug_Next_Mode

;    // Next Mode
;    Mode = PRESSURE_AUGMENT_STOP;

        SPLK    #PRESSURE_AUGMENT_STOP,Mode

;    Pump_off();

	mMotor_off

;    NewPressure = Signal[SampleNumber] - RESERVE_MILL_OF_MERC/2;

	MAR	*,AR1
        LAR     AR0,SampleNumber
	LAR	AR1,#Signal
	MAR	*0+,AR1
	LACC	*
	SUB     #RESERVE_MILL_OF_MERC/2
	SACL	NewPressure

;    ModeCnt = WHITE_VALVE_OFF;

        SPLK    #WHITE_VALVE_OFF,ModeCnt

;    SubroutMode = 0;

	SPLK	#0,SubroutMode

;    StartMaxNumber = 0;

        LACC    #0
        SACL    StartMaxNumber

;  SampleNumberShift = SampleNumberShift + SampleNumber + 1;

        LACC    SampleNumberShift
        ADD     SampleNumber
        ADD     #1
        SACL    SampleNumberShift

;  SampleNumber = -1;

        SPLK    #0FFFFh,SampleNumber

;  if ( SynchroFlag == False )

	BIT     MeasurementFlags,15-SYNCHRO_FLAG
	BCND 	Pulse_aug_End,TC

;  {
;  	PulseCounter = 0;

	SPLK	#0,PulseCounter

;  }
;   }
;  }
; }

Pulse_aug_End

        RET

;}

