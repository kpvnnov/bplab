;&D
* $Id: MAX_ANAL.ASM,v 1.8 2001-11-14 17:20:53 peter Exp $
***********************************************************************
* 	MaximumAnalysis()  - Анализ предпологаемого импульса
***********************************************************************/
;Maximum_analysis()

Maximum_analysis:
;{
; //MeasurementFlags = MeasurementFlags &(~(1<<NEXT_MODE_FLAG));

     ;	LACC	_MeasurementFlags
     ;	AND     #(~(1<<NEXT_MODE_FLAG))
     ;	SACL    _MeasurementFlags

; switch ( MaxNumber - StartMaxNumber)

	MAR	*,AR2
	LACC	_MaxNumber,1
	SUB	_StartMaxNumber,1
	ADD	#Max_switch
	BACC
Max_switch:
	B	Max_switch_case0
	B       Max_switch_case1
	B       Max_switch_default
; {

Max_switch_case0:
;  case 0:
;    if (( MeasurementFlags &(1<<SYNCHRO_FLAG)) != 0 )
;    {

	BIT	_MeasurementFlags,15-SYNCHRO_FLAG
	BCND	Max_case0_not_synchro,NTC

;      if ( Diff2Max[MaxNumber] > 0.25*LastDiff2Max)
;      {

	LAR	AR0,_MaxNumber
	LAR	AR2,#Diff2Max
	MAR	*0+,AR2
	LACC	*,2,AR2
	SUB	LastDiff2Max
	BCND	Max_case0_small_impulse,LEQ

;        if ( Diff2Max[MaxNumber] < 4*LastDiff2Max)
;        {

	LACC	*,0,AR2
	SUB	LastDiff2Max,2
	BCND	Max_case0_big_impulse,GEQ

;          if (( abs( TempPeriod*4 - 2*AveragePeriodEvaluation )) <
;                                 0.33*AveragePeriodEvaluation )
;          {

        LACC    _TempPeriod,15
        SUB     _AveragePeriodEvaluation,14
        ABS
        LT      _AveragePeriodEvaluation
        MPY     #CONST_0_33
        SPAC
	BCND	Max_case0_not_two_intervales,GEQ

;            Average_2();
;          }

	CALL	Average_2
	B	Max_end_case0

Max_case0_not_two_intervales:
;          else
;          {
;            if (( abs( TempPeriod*4 - AveragePeriodEvaluation )) <
;                                 0.33*AveragePeriodEvaluation )

        LACC    _TempPeriod,15
        SUB     _AveragePeriodEvaluation,13
        ABS
        LT      _AveragePeriodEvaluation
        MPY     #CONST_0_33
        SPAC
	BCND	Max_case0_not_ones_intervale,GEQ

;            {
;              Average();
;            }

	CALL	Average
	B	Max_end_case0

Max_case0_not_ones_intervale:
;            else
;            { // необходимо 3-и импульса
;              Synchro_flag_is_reseted();
;            }
;          }
;        }

Max_case0_big_impulse:
;        else
;        { // необходимо 3-и импульса
;          Synchro_flag_is_reseted();
;        }
;      }

Max_case0_small_impulse:
;      else
;      { // необходимо 3-и импульса
;        Synchro_flag_is_reseted();
;      }
;    }

	CALL	Synchro_flag_is_reseted

Max_end_case0:
Max_case0_not_synchro:
;    mArrays_are_shifted();
;    mIncrement_max_number();
;    break;

	mArrays_are_shifted
	mIncrement_max_number
	B	Max_end_switch

Max_switch_case1:
;  case 1:
;    if (( MeasurementFlags &(1<<SYNCHRO_FLAG)) != 0 )
;    {

	BIT	_MeasurementFlags,15-SYNCHRO_FLAG
	BCND	Max_case1_not_synchro,NTC

;      if (( abs( TempPeriodDiff*4)) < 0.33*AveragePeriodEvaluation)
;      {


        LACC    _TempPeriodDiff,15
        ABS
        LT      _AveragePeriodEvaluation
        MPY     #CONST_0_33
        SPAC
	BCND	Max_case1_bad_intervales,GEQ

;        if ( TempAmplitudeDiff < 0.35*
;           ( Diff2Max[MaxNumber-1]+Diff2Max[MaxNumber])/2)
;        {

	LAR	AR0,_MaxNumber
	LAR	AR2,#Diff2Max-1
	MAR	*0+,AR2
	LACC	*+,15,AR2
	ADD	*,15,AR2
	SACH	TmpAmplitude_2,0
	LACC    _TempAmplitudeDiff,13
	LT	TmpAmplitude_2
	MPY	#CONST_0_35
	SPAC
	BCND	Max_case1_bad_impulse,GEQ

;          Average();
;          Trend_measurement_1();

	CALL	Average
        CALL	Trend_measurement_1

;          if ( abs( Max[1]-Max[0]) < 0.249 Max[1])
;          {

        MAR     *,AR2
        LAR     AR2,#Max+1
	LACC    *,14,AR2
	LT      *-,AR2
	MPY     #CONST_0_249
	SUB     *,14,AR2
	ABS
	SPAC
	BCND	Max_case1_impulse_isnt_equal,GEQ


        LAR     AR0,_StepNumber
        LAR     AR2,#AverageAmplitude
        MAR     *0+,AR3
        LAR     AR3,#AvrPress
        MAR     *0+,AR4
        LAR     AR4,#Max

;            AverageAmplitude[StepNumber] = ( Max[0] + Max[1] )/2;

        LACC    *+,15,AR4
        ADD     *,15,AR2
        SACH    *,0,AR2

;            AvrPress[StepNumber] = ( MaxAvrPress[0] + MaxAvrPress[1] +
;                                     MinAvrPress[0] + MinAvrPress[1])/4;

        LAR     AR2,#MaxAvrPress
        LACC    *+,14,AR2
        ADD     *,14,AR2
        LAR     AR2,#MinAvrPress
        ADD     *+,14,AR2
        ADD     *,14,AR3
        SACH    *,0,AR2

;            MeasurementFlags = MeasurementFlags |(1<<NEXT_MODE_FLAG);
;          }

	LACC	_MeasurementFlags
	OR      #1<<NEXT_MODE_FLAG
	SACL	_MeasurementFlags
	B	Max_end_case1


Max_case1_impulse_isnt_equal:
;          else
;          { // необходимо 3-и импульса
;            MeasurementFlags = MeasurementFlags |(1<<SYNCHRO_FLAG_WAS);
;            Synchro_flag_is_reseted();
;          }
;        }

Max_case1_bad_impulse:
;        else
;        { /* Если нет совпадения по амплитуде то сбрасываем SYNCHRO_FLAG */
;          MeasurementFlags = MeasurementFlags |(1<<SYNCHRO_FLAG_WAS);
;          Synchro_flag_is_reseted();
;        }
;      }

	LACC	_MeasurementFlags,0
	OR	#(1<<SYNCHRO_FLAG_WAS)
	SACL    _MeasurementFlags,0
	CALL	Synchro_flag_is_reseted
	B	Max_end_case1

Max_case1_bad_intervales:
;      else
;      {
;        MeasurementFlags = MeasurementFlags & (~(1<<SYNCHRO_FLAG_WAS));
;        Synchro_flag_is_reseted();
;      }
;    }

	LACC	_MeasurementFlags,0
	AND	#(~(1<<SYNCHRO_FLAG_WAS))
	SACL    _MeasurementFlags,0
	CALL	Synchro_flag_is_reseted

Max_end_case1:
Max_case1_not_synchro:
;    mArrays_are_shifted();
;    mIncrement_max_number();
;    break;

	mArrays_are_shifted
	mIncrement_max_number
	B	Max_end_switch

Max_switch_default:
;  default:
;    Pulse_frequency_evaluation(CONST_0_499);

	LACC	#CONST_0_499
	CALL	Pulse_frequency_evaluation

;    if (( MeasurementFlags &(1<<SYNCHRO_FLAG)) != 0 )
;    {

	BIT	_MeasurementFlags,15-SYNCHRO_FLAG
	BCND	Max_def_not_synchro,NTC

;      Average();
;      Trend_measurement_2();

	CALL	Average
	CALL	Trend_measurement_2

;      if (( abs( Max[2]-Max[1]) < 0.35 Max[2])&&
;          ( abs( Max[1]-Max[0]) < 0.35 Max[1]))
;      {

        MAR     *,AR2
	LAR	AR2,#Max+2
	LACC    *,13,AR2
	LT      *-,AR2
	MPY     #CONST_0_35
	SUB     *,13,AR2
	ABS
	SPAC
	BCND	Max_def_max_isnt_equal,GEQ

	LACC    *,13,AR2
	LT      *-,AR2
	MPY     #CONST_0_35
	SUB     *,13,AR2
	ABS
	SPAC
	BCND	Max_def_max_isnt_equal,GEQ

;     	 /* Средние Амплитуда и Давление на этой ступеньке */

        LAR     AR0,_StepNumber
        LAR     AR2,#AverageAmplitude
        MAR     *0+,AR3
        LAR     AR3,#AvrPress
        MAR     *0+,AR4
        LAR     AR4,#Max

;       AverageAmplitude[StepNumber] = ( Max[0] + Max[1] + Max[2])*0.33;

        LACC    *+,14,AR4
        ADD     *+,14,AR4
        ADD     *,14,AR2
        SACH    *,0,AR2
	LT	*,AR2
	MPY	#CONST_0_33
	PAC
	SACH	*,5,AR2           ;??????????????????????????

;     	 AvrPress[StepNumber] = ( MaxAvrPress[0] + MinAvrPress[0] +
;                                 MaxAvrPress[1] + MinAvrPress[1] +
;                                 MaxAvrPress[2] + MinAvrPress[2])*0.1667;

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
	SACH	*,5,AR2           ;?????????????????????????

;
;        MeasurementFlags = MeasurementFlags |(1<<NEXT_MODE_FLAG);
;      }

	LACC	_MeasurementFlags
	OR      #1<<NEXT_MODE_FLAG
	SACL    _MeasurementFlags
	B	Max_end_def

Max_def_max_isnt_equal:
;      else
;      {
;        mArrays_are_shifted();
;        Synchro_flag_is_reseted();
;        StartMaxNumber = StartMaxNumber + 1;

	mArrays_are_shifted
	CALL	Synchro_flag_is_reseted
	LACC	_StartMaxNumber
	ADD 	#1
	SACL    _StartMaxNumber

;      }
;    }
;    break;

Max_def_not_synchro:
Max_end_def:
Max_end_switch:
;  }
;}
	RET
