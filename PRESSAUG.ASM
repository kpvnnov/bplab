;&D
;/********************************************************************
;  Pressure_augment( PressureTop ) -
;  Увеличение давления до систолическое+30 мм.рт.ст.
; $Id: PRESSAUG.ASM,v 1.11 2001-11-14 17:33:35 peter Exp $
;***********************************************************************/
;int	AvrOfTwoDiff2Max
;int	TMPMaxNumber

AvrOfTwoDiff2Max	.equ	TMP
TMPMaxNumber            .equ	TMP+7

Pressure_augment

;
;{
;  if ( SampleNumber > DIFF_BASIS_OF_PR_AUG_1)

	LACC	_SampleNumber,0
	SUB	#DIFF_BASIS_OF_PR_AUG_1
	BCND	Pulse_aug_check_error_2,LEQ

;  {
;    DiffSignalOfAugMode = Signal[SampleNumber] -
;		           Signal[SampleNumber-DIFF_BASIS_OF_PR_AUG_1];

	MAR	*,AR2
	LAR	AR0,_SampleNumber
	LAR	AR2,#Signal
	MAR	*0+,AR3
	LAR	AR3,#Signal - DIFF_BASIS_OF_PR_AUG_1
	MAR	*0+,AR2
	LACC	*,0,AR3
	SUB	*

;    if ( DiffSignalOfAugMode < ZERO_ZERO_FIVE_MM_PER_SAMPLE )

	SUB	#ZERO_ZERO_FIVE_MM_PER_SAMPLE
	BCND	Pulse_aug_check_error_2,GEQ

;    {  /* маленькая скоpость наpастания давления ( система стpавливает)*/
;      mEnd_error_meas( rSMALL_SPEED_AUG_PR );

	mEnd_error_meas rSMALL_SPEED_AUG_PR
	B	Pulse_aug_analysis_end

;    }
;  }

Pulse_aug_check_error_2:

;  if ( SampleNumber > DIFF_BASIS_OF_PR_AUG_2)

	LACC	_SampleNumber,0
	SUB	#DIFF_BASIS_OF_PR_AUG_2
	BCND	Pulse_aug_AnalysisStart,LEQ

;  {
;    DiffSignalOfAugMode = Signal[SampleNumber] -
;       	           Signal[SampleNumber-DIFF_BASIS_OF_PR_AUG_2];

	MAR	*,AR2
	LAR	AR0,_SampleNumber
	LAR	AR2,#Signal
	MAR	*0+,AR3
	LAR	AR3,#Signal - DIFF_BASIS_OF_PR_AUG_2
	MAR	*0+,AR2
	LACC	*,0,AR3
	SUB	*

;    if ( DiffSignalOfAugMode > ONE_MM_PER_SAMPLE )

	SUB	#ONE_MM_PER_SAMPLE
	BCND	Pulse_aug_AnalysisStart,LEQ

;    {  /* Большая скоpость наpастания давления ( пеpежат шланг)*/
;      mEnd_error_meas( rBIG_SPEED_AUG_PR );

	mEnd_error_meas rBIG_SPEED_AUG_PR
	B	Pulse_aug_analysis_end

;    }
;  }

Pulse_aug_AnalysisStart:

;  if ( MeasurementFlags & (1<<DIFF_MAX_FLAG) != 0 )

	BIT	_MeasurementFlags,15-DIFF_MAX_FLAG
        BCND    Pulse_aug_MaxNotCentre,NTC

;  {

        MAR     *,AR3
        LAR     AR0,_MaxNumber
        LAR     AR3,#Diff2Max
        MAR     *0+,AR3                 ;AR3 = & Diff2Max[MaxNumber]

;    if ( Diff2Max[MaxNumber] > 0.25*LastDiff2Max)

	LACC    *,16,AR3        ;AR3 = & Diff2Max[MaxNumber]
	SUB     LastDiff2Max,14
	BCND    Pulse_aug_SmallMax,LT

;    {
;      if ( Diff2Max[MaxNumber] < 4*LastDiff2Max)

        LACC    *,0,AR3                 ;AR3 = & Diff2Max[MaxNumber]
        SUB     LastDiff2Max,2
        BCND    Pulse_aug_MoreMax,GEQ

;      {
;        TMPMaxNumber  = MaxNumber;

        LACC    _MaxNumber
        SACL    TMPMaxNumber

;        if (( abs( TempPeriod*4 - AveragePeriodEvaluation )) <
;                             0.33*AveragePeriodEvaluation )

        LT      _AveragePeriodEvaluation
        MPY     #CONST_0_33
        LACC    _TempPeriod,15
        SUB     _AveragePeriodEvaluation,13
        ABS
        SPAC
        BCND    Pulse_aug_2Period,GEQ

;        {
;          Average();
;          mIncrement_max_number();

        CALL    Average
	mIncrement_max_number

;        }

Pulse_aug_2Period

;        if (( abs( TempPeriod*4 - 2*AveragePeriodEvaluation )) <
;                              0.375*AveragePeriodEvaluation )

        LT      _AveragePeriodEvaluation
        MPY     #CONST_0_375
        LACC    _TempPeriod,15
        SUB     _AveragePeriodEvaluation,14
        ABS
        SPAC
        BCND    Pulse_aug_3Period,GEQ

;        {
;          Average_2();
;          mIncrement_max_number();

        CALL    Average_2
	mIncrement_max_number

;        }

Pulse_aug_3Period

;        if (( abs( TempPeriod*4 - 3*AveragePeriodEvaluation )) <
;                              0.375*AveragePeriodEvaluation )

        LT      _AveragePeriodEvaluation
        MPY     #CONST_0_375
        LACC    _TempPeriod,15
        SUB     _AveragePeriodEvaluation,14
        SUB     _AveragePeriodEvaluation,13
        ABS
        SPAC
        BCND    Pulse_aug_End_3Period,GEQ

;        {
;          AveragePeriodEvaluation = AveragePeriodEvaluation +
;                 ( TempPeriod*4 - 3*AveragePeriodEvaluation )/16;

        LACC    _AveragePeriodEvaluation,16
        ADD     _TempPeriod,14
        SUB     _AveragePeriodEvaluation,12
        SUB     _AveragePeriodEvaluation,13
        SACH    _AveragePeriodEvaluation,0

;          AveragePeriod = AveragePeriod + ( TempPeriod*16*0.33 -
;                          AveragePeriod)/16;

        LT      _TempPeriod
        MPY     #CONST_0_33
        LACC    _AveragePeriod,13
        SUB     _AveragePeriod,9
        APAC
        SACH    _AveragePeriod,3

;          AnalysisInterval = AveragePeriodEvaluation*1.25/4;

        LACC    _AveragePeriodEvaluation,14
        ADD     _AveragePeriodEvaluation,12                   ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!
        SACH    _AnalysisInterval,0

;          AnalysisStart = SampleNumber + AnalysisInterval/4;

        LACC    _SampleNumber,16
        ADD     _AnalysisInterval,14
	SACH    _AnalysisStart

;          mIncrement_max_number();

	mIncrement_max_number

;        }

Pulse_aug_End_3Period

;        if ( TMPMaxNumber != MaxNumber)

        LACC    TMP+7
        SUB     _MaxNumber
        BCND    Pulse_aug_BadPulse,EQ

;        {
;          PulseCounter++;

	LACC    _PulseCounter
	ADD	#1
	SACL    _PulseCounter

;          MeasurementFlags = MeasurementFlags | (1<<SYNCHRO_FLAG);

	LACC	_MeasurementFlags,0
	OR	#(1<<SYNCHRO_FLAG)
	SACL	_MeasurementFlags,0

;          if ( MaxDiffSignal < Diff2Max[MaxNumber-1])
;          // Здесь "MaxNumber-1" потому, что уже было "MaxNumber+1"

        LACC    *,0,AR3                 ;AR3 = & Diff2Max[MaxNumber]
        SUB     MaxDiffSignal
        BCND    Pulse_aug_CheckAmpl,LEQ

;          {
;            MaxDiffSignal = Diff2Max[MaxNumber-1];

        LACC    *,0,AR3                 ;AR3 = & Diff2Max[MaxNumber]
        SACL    MaxDiffSignal

;          }

Pulse_aug_CheckAmpl

;          AvrOfTwoDiff2Max = Diff2Max[MaxNumber-1] + LastDiff2Max;

        LACC    *,0,AR3
        ADD     LastDiff2Max
        SACL    AvrOfTwoDiff2Max

;          LastDiff2Max = Diff2Max[MaxNumber-1];
;          /* Здесь "MaxNumber-1" потому, что уже было "MaxNumber+1" */

        LACC    *,0,AR4
        SACL    LastDiff2Max

        LAR     AR0,_MaxNumber
        LAR     AR4,#Diff2MaxAdress-1
        MAR     *0+,AR5
        LAR     AR0,_MaxNumberShift
        LAR     AR5,#Diff2MaxAdressFinish
        MAR     *0+,AR4

;          Diff2MaxAdressFinish[MaxNumberShift] = Diff2MaxAdress[MaxNumber-1] +
;                                                 SampleNumberShift;
;          // Здесь "MaxNumber-1" потому, что уже было "MaxNumber+1"

        LACC    *,0,AR5
        ADD     _SampleNumberShift,0
        SACL    *,0,AR3

;          MaxNumberShift++;
;          MaxNumber = 0;

        LACC    _MaxNumberShift,0
        ADD     #1
        SACL    _MaxNumberShift
        SPLK    #0,_MaxNumber

;          if(( MaxDiffSignal*0.5 > AvrOfTwoDiff2Max)&&
;             ( PulseCounter > 5 ))

	LACC	_PulseCounter,0
	SUB	#5
	BCND    Pulse_aug_check_sample_number,LEQ
	LACC    MaxDiffSignal,15
	SUB	AvrOfTwoDiff2Max,15
	BCND    Pulse_aug_check_sample_number,LEQ

;          {
;            if ( MeasurementFlags&(1<<PRESS_MORE_SYSTOL_FLAG) == 0 )

	BIT	_MeasurementFlags,15-PRESS_MORE_SYSTOL_FLAG
	BCND	Pulse_aug_check_sample_number,TC

;            {
;              PressureTop = Signal[SampleNumber] +
;                            RESERVE_MILL_OF_MERC; // + PRESS_02_5;

        MAR     *,AR2
        LAR     AR0,#Signal
        LAR     AR2,_SampleNumber
        MAR     *0+,AR2
        LACC    *,0
	ADD	#RESERVE_MILL_OF_MERC,0   ;// + PRESS_02_5,0
	SACL	_PressureTop

;              MeasurementFlags = MeasurementFlags|(1<<PRESS_MORE_SYSTOL_FLAG);

	LACC	_MeasurementFlags,0
	OR	#(1<<PRESS_MORE_SYSTOL_FLAG)
	SACL	_MeasurementFlags,0
	B       Pulse_aug_check_sample_number

;            }
;          }

Pulse_aug_BadPulse

;          else
;          { //   Вероятная потеря синхронизации
;            MeasurementFlags = MeasurementFlags & (~(1<<SYNCHRO_FLAG));

	LACC	_MeasurementFlags,0
	AND	#~(1<<SYNCHRO_FLAG)
	SACL	_MeasurementFlags,0
	B       Pulse_aug_check_sample_number

;          }

;        }
;        else
;        {
;          if (( SampleNumber - AnalysisStart ) > 1.5*AnalysisInterval )

	LACC	_SampleNumber,1
	SUB	_AnalysisStart,1
	SUB	_AnalysisInterval,1
	SUB	_AnalysisInterval,0
	BCND	Pulse_aug_SmallTime,LEQ

;          {  //   Вероятная потеря синхронизации
;            MeasurementFlags = MeasurementFlags & (~(1<<SYNCHRO_FLAG));

	LACC	_MeasurementFlags,0
	AND	#~(1<<SYNCHRO_FLAG)
	SACL	_MeasurementFlags,0

;          }

Pulse_aug_SmallTime:
;        }

Pulse_aug_check_sample_number:
;      }


Pulse_aug_MoreMax:
;    }

Pulse_aug_SmallMax:
;    if ( SampleNumber >= ( ONE_SECOND*9 ))

	LACC	_SampleNumber,0
	SUB	#ONE_SECOND*9
	BCND	Pulse_aug_MaxNotCentre,LT

;    {
;      for ( i = 0; i <= ONE_SECOND*2; i++)
;      {
;        Signal[i] = Signal[SampleNumber - ONE_SECOND*2 + i];
;      }

	MAR	*,AR2
	LAR	AR0,_SampleNumber
	LAR	AR2,#Signal - ONE_SECOND*2
	MAR	*0+,AR2
	RPT	#ONE_SECOND*2
	BLDD	*+,#Signal

;        SampleNumberShift = SampleNumberShift + SampleNumber - ONE_SECOND*2;
;        SampleNumber = ONE_SECOND*2;

	LACC	_SampleNumberShift,0
	ADD 	_SampleNumber,0
	SUB	#ONE_SECOND*2
	SACL	_SampleNumberShift,0
	SPLK	#ONE_SECOND*2,_SampleNumber

;        AnalysisStart = AnalysisStart - ONE_SECOND*7 );

	LACC	_AnalysisStart,0
	SUB	#ONE_SECOND*7
	SACL	_AnalysisStart,0

;        if ( AnalysisStart < 0 )
;        {
;          AnalysisStart = 0;
;        }

	BCND	Pulse_aug_MaxNotCentre,GEQ
	SPLK	#0,_AnalysisStart

;      }

Pulse_aug_MaxNotCentre:

;      if ( Signal[SampleNumber] > PressureTop )

        MAR     *,AR2
        LAR     AR0,#Signal
        LAR     AR2,_SampleNumber
        MAR     *0+,AR2
        LACC    *
        SUB     _PressureTop
        BCND    Pulse_aug_End,LEQ
;      {

Pulse_aug_Next_Mode

;        // Next Mode
;        Mode = PRESSURE_AUGMENT_STOP;

        SPLK    #PRESSURE_AUGMENT_STOP,_Mode

;        Pump_off();

	mMotor_off

;        NewPressure = Signal[SampleNumber] - RESERVE_MILL_OF_MERC/4;

	MAR	*,AR2
        LAR     AR0,_SampleNumber
	LAR	AR2,#Signal
	MAR	*0+,AR2
	LACC	*
	SUB     #RESERVE_MILL_OF_MERC/4
	SACL	_NewPressure

;        ModeCnt = WHITE_VALVE_OFF;

        SPLK    #WHITE_VALVE_OFF,_ModeCnt

;        SubroutMode = 0;
;        StartMaxNumber = 0;

        LACC    #0
	SACL	_SubroutMode
        SACL    _StartMaxNumber

;        SampleNumberShift = SampleNumberShift + SampleNumber + 1;
;        SampleNumber = -1;

        LACC    _SampleNumberShift
        ADD     _SampleNumber
        ADD     #1
        SACL    _SampleNumberShift
        SPLK    #0FFFFh,_SampleNumber

;        if ( SynchroFlag == False )

	BIT     _MeasurementFlags,15-SYNCHRO_FLAG
	BCND 	Pulse_aug_End,TC

;        {
;          PulseCounter = 0;

	SPLK	#0,_PulseCounter

;        }
;      }
;    }
;  }

Pulse_aug_End:

;  if(( SampleNumberShift + SampleNumber -
;       FinishMeasAddress[StepNumber-1])>= TEN_SECOND*4 )

	MAR	*,AR2
	LAR	AR0,_StepNumber
	LAR	AR2,#FinishMeasAddress-1
	MAR	*0+,AR2
	LACC	_SampleNumberShift
	ADD     _SampleNumber
	SUB     *,0,AR2
	SUB	#TEN_SECOND*4
	BCND	Pulse_aug_analysis_end,LEQ

;  {
;    mEnd_error_meas(rLONG_AUGMENT);

        mEnd_error_meas 	rLONG_AUGMENT

;  }

Pulse_aug_analysis_end:
;  Pressure_for_display();
;  Analysis_of_end();

	CALL	Pressure_for_display
	CALL	Analysis_of_end
	LACC    _SampleNumber,0
	ADD	#1
	SACL    _SampleNumber,0

        RET

;}

