;&D
***********************************************************************
*       Average
* $Id: PROCEDUR.ASM,v 1.6 2001-10-22 13:38:16 peter Exp $
***********************************************************************
Average

;  AveragePeriodEvaluation = AveragePeriodEvaluation +
;		TempPeriod - AveragePeriodEvaluation/4;

        LACC    TempPeriod,16
        SUB     AveragePeriodEvaluation,14   ; AveragePeriodEvaluation
        ADD     AveragePeriodEvaluation,16   ; увеличино в 4 pаза
        SACH    AveragePeriodEvaluation,0

;  AveragePeriod = AveragePeriod + TempPeriod - AveragePeriod/16;

        LACC    TempPeriod,16                ; AveragePeriod
        SUB     AveragePeriod,12             ; увеличино в 16 pаза
        ADD     AveragePeriod,16
        SACH    AveragePeriod,0

Average_check_mode:

;  if (( Mode == PRESSURE_MEASUREMENT )||( Mode == CHECK_HIGHER_SISTOL_PRESSURE))
;  {

	LACC	Mode
	SUB	#PRESSURE_MEASUREMENT
	BCND	Average_impulse_not_in_center,EQ
	LACC    Mode
	SUB     #CHECK_HIGHER_SISTOL_PRESSURE
	BCND	Average_impulse_in_center,NEQ

Average_impulse_not_in_center:

;    AnalysisInterval = AveragePeriodEvaluation*1/4;

        LACC    AveragePeriodEvaluation,14
        SACH    AnalysisInterval,0

;    if ((MeasurementFlags & (1<<FIRST_IMPULSE_FLAG)) == 0)
;    {

       	BIT	MeasurementFlags,15-FIRST_IMPULSE_FLAG
	BCND	Average_first_impulse,TC

;      AnalysisStart = SampleNumber + AnalysisInterval/4;

        LACC    SampleNumber,16
        ADD     AnalysisInterval,14
	B	Average_finish

;    }

Average_first_impulse:

;    else
;    {
;      AnalysisStart = SampleNumber + AnalysisInterval/8;

        LACC    SampleNumber,16
        ADD     AnalysisInterval,13
	B	Average_finish

;    }
;  }

Average_impulse_in_center:

;  else
;  {

;    AnalysisInterval = AveragePeriodEvaluation*1.25/4;

        LACC    AveragePeriodEvaluation,14
        ADD     AveragePeriodEvaluation,12
        SACH    AnalysisInterval,0

;    AnalysisStart = SampleNumber + AnalysisInterval/4;

        LACC    SampleNumber,16
        ADD     AnalysisInterval,14

Average_finish:
        SACH    AnalysisStart
        RET

;  }


***********************************************************************
*       Average_2
***********************************************************************
Average_2

;AveragePeriodEvaluation = AveragePeriodEvaluation +
;		TempPeriod/2 - AveragePeriodEvaluation/4;

        LACC    TempPeriod,15
        SUB     AveragePeriodEvaluation,14   ; AveragePeriodEvaluation
        ADD     AveragePeriodEvaluation,16   ; увеличино в 4 pаза
        SACH    AveragePeriodEvaluation,0

; AveragePeriod = AveragePeriod + TempPeriod/2 - AveragePeriod/16;

        LACC    TempPeriod,15                ; AveragePeriod
        SUB     AveragePeriod,12             ; увеличино в 16 pаза
        ADD     AveragePeriod,16
        SACH    AveragePeriod,0

	B	Average_check_mode

;;***********************************************************************
;;	Start_diminution_pressure()
;;***********************************************************************
;void Start_diminution_pressure()

Start_diminution_pressure:

	MAR	*,AR1
	POPD    *+,AR1
	SAR	AR0,*+,AR2

;{
;  mDim_pressure_init();
;  Completion_of_mode();
;  Finish_Meas_Address();
;}
        mDim_pressure_init
	CALL	Completion_of_mode
	CALL	Finish_Meas_Address		; AR0,AR2 is used

	MAR	*,AR1
	MAR	*-,AR1
	LAR	AR0,*-,AR1
	PSHD    *,AR2
	RET
;
;;***********************************************************************
;;	Synchro_flag_is_reseted()
;;***********************************************************************
;
;#define MIN_ANALYSIS_INTERVAL 	40

MIN_ANALYSIS_INTERVAL 	.set	40

;
;void Synchro_flag_is_reseted()

Synchro_flag_is_reseted:

	MAR	*,AR1
	POPD    *+,AR1
	SAR	AR0,*+,AR2

;{
;  MeasurementFlags = MeasurementFlags&(~(1<<SYNCHRO_FLAG));
;  if ( AnalysisInterval < MIN_ANALYSIS_INTERVAL*9/8 )

	LACC	MeasurementFlags
	AND 	#(~(1<<SYNCHRO_FLAG))
	SACL    MeasurementFlags
	LACC    AnalysisInterval
	SUB	#MIN_ANALYSIS_INTERVAL*9/8
	BCND    Synchro_flag_big_interval,GT

;  {
;    AnalysisInterval = MIN_ANALYSIS_INTERVAL;
;    AveragePeriodEvaluation = AnalysisInterval*4;
;  }

	SPLK	#MIN_ANALYSIS_INTERVAL,AnalysisInterval
	SPLK	#MIN_ANALYSIS_INTERVAL*4,AveragePeriodEvaluation
	B	Synchro_flag_quit

Synchro_flag_big_interval:
;  else
;  {
;    AnalysisInterval = AnalysisInterval - AnalysisInterval/8;
;    AveragePeriodEvaluation = AveragePeriodEvaluation -
;                              AveragePeriodEvaluation/8;
;  }
;}
	LACC	AnalysisInterval,16
	SUB     AnalysisInterval,13
	SACH    AnalysisInterval,0
	LACC	AveragePeriodEvaluation,16
	SUB     AveragePeriodEvaluation,13
	SACH    AveragePeriodEvaluation,0

Synchro_flag_quit:
	MAR	*,AR1
	MAR	*-,AR1
	LAR	AR0,*-,AR1
	PSHD    *,AR2
	RET

;
;
;;***********************************************************************
;;	Completion_of_mode()
;***********************************************************************
;
;void Completion_of_mode()

Completion_of_mode:

	MAR	*,AR1
	POPD    *+,AR1
	SAR	AR0,*+,AR2

;{
;    if ( MaxNumber > 0 )
;    {

	LACC    MaxNumber,0
	BCND    Compl_of_mode,LEQ

;      LastDiff2Max = Diff2Max[MaxNumber-1];

	LAR	AR0,MaxNumber
	LAR	AR2,#Diff2Max-1
	MAR	*0+,AR2
	LACC    *,0,AR3
	SACL    LastDiff2Max

;      i = MaxNumber - 1;
;      while ( i >= 0 )
;      {
;        Diff2MaxAdressFinish[MaxNumberShift+i] =
;    	      Diff2MaxAdress[i] + SampleNumberShift;
;        i--;
;      }
;    }

        LAR     AR0,MaxNumberShift
        LAR     AR3,#Diff2MaxAdressFinish
        MAR     *0+,AR0
        LAR     AR0,MaxNumber
        MAR     *-,AR2
        LAR     AR2,#Diff2MaxAdress
        MAR     *0+,AR3
        MAR     *0+,AR2
Pulse_f_for_i
        LACC    *-,0,AR3
	ADD	SampleNumberShift,0
        SACL    *-,0,AR0
        BANZ    Pulse_f_for_i,*-,AR2

Compl_of_mode:
;    MeasurementFlags = MeasurementFlags &(~((1<<NEXT_MODE_FLAG)|
;                       (1<<SYNCHRO_FLAG_WAS)));
;    MaxNumberShift = MaxNumber + MaxNumberShift;
;    SampleNumberShift = SampleNumberShift + SampleNumber + 1;
;    SampleNumber = -1;
;    StartMaxNumber = 0;
;    SubroutMode = 0;
;    MaxNumber = 0;
;}

	LACC	MeasurementFlags
	AND     #(~((1<<NEXT_MODE_FLAG)|(1<<SYNCHRO_FLAG_WAS)))
	SACL    MeasurementFlags
	LACC	MaxNumberShift,0
	ADD 	MaxNumber,0
	SACL	MaxNumberShift,0
	LACC	SampleNumberShift
	ADD     SampleNumber
	ADD     #1
	SACL    SampleNumberShift
	SPLK	#0FFFFh,SampleNumber
	LACL	#0
	SACL    StartMaxNumber
	SACL    SubroutMode
	SACL    MaxNumber

	MAR	*,AR1
	MAR	*-,AR1
	LAR	AR0,*-,AR1
	PSHD    *,AR2
	RET
;
;;***********************************************************************
;;  End_step_analysis();
;;***********************************************************************
;void End_step_analysis()

End_step_analysis:

	MAR	*,AR1
	POPD    *+,AR1
	SAR	AR0,*+,AR2

;{
;  if (( MeasurementFlags&(1<<NEXT_MODE_FLAG)) == 0 )

	BIT	MeasurementFlags,15-NEXT_MODE_FLAG
	BCND	End_step_anal_next_mode_is,TC

;  {
;    if ((( SampleNumber > 8*AnalysisInterval )&&( MaxNumber < 2 ))||
;         ( SampleNumber > TEN_SECOND ))

	LACC	MaxNumber
	SUB     #2
	BCND    End_step_anal_max_n_more_1,GEQ
	LACC    SampleNumber,0
	SUB	AnalysisInterval,3
	;ADD     AnalysisInterval,0
	BCND    End_step_anal_start_dim,GEQ
End_step_anal_max_n_more_1:
	LACC    SampleNumber,0
 .if Sertificarion=1
* стоим на ступеньке две секунды
	SUB     #TWO_SECOND
 .else
	SUB     #TEN_SECOND
 .endif
	BCND    End_step_anal_sn_less_10,LEQ

;    {
;      //if ( SampleNumber > TEN_SECOND ))
;      //{
;      //  ArtefactCount++;
;      //}

End_step_anal_start_dim:
;      Synchro_flag_is_reseted();
;      mZeroToAverageAmplitude();
;      Start_diminution_pressure();

	CALL	Synchro_flag_is_reseted
	mZeroToAverageAmplitude
	CALL    Start_diminution_pressure

;    }
;  }

End_step_anal_sn_less_10:
End_step_anal_next_mode_is:
;  Analysis_of_end();
;  SampleNumber++;

	CALL	Analysis_of_end
	LACC    SampleNumber,0
	ADD	#1
	SACL    SampleNumber,0

;}

	MAR	*,AR1
	MAR	*-,AR1
	LAR	AR0,*-,AR1
	PSHD    *,AR2
	RET

;;***********************************************************************
;;    Analysis_of_end()
;;***********************************************************************
;void Analysis_of_end()

Analysis_of_end:

 	.if WriteDebug!=0	;??????????????????????
	LACC 	StartCode
	SUB	#1
	RETC	EQ
 	.endif

;{

	MAR	*,AR1
	POPD    *+,AR1
	SAR	AR0,*+,AR2

;  if (( SampleNumber + SampleNumberShift) < TWO_MINUTES )
;  {

	LACC	SampleNumber,0
	ADD	SampleNumberShift,0
	ADD	TimeNakachka,0
	SUB	#TWO_MINUTES
	BCND    Anal_of_end_two_minutes,GEQ

;    if ( CurrPressure > PRESS_280 )
;    {

	MAR  	*,AR2
	LAR	AR2,#MayModify+1
	LACC	*
	SUB	#0A5h		;взрослый режим
	BCND	Anal_of_end_over_280_stop,EQ
;работает детский режим

        LACL	CurrPressure
	SUB	#PRESS_95,1		;*2=190
	BCND	Anal_of_end_check_30_mm,LEQ

;      NewPressure = PRESS_170_MILL_OF_MER;

        SPLK	#LPRESS_170,NewPressure
	B	Anal_of_end_motor_off

Anal_of_end_over_280_stop:
        LACL	CurrPressure
	SUB	#PRESS_140,1		;*2=280
	BCND    Anal_of_end_check_30_mm,LT


;      NewPressure = PRESS_275_MILL_OF_MER;

	SPLK	#PRESS_275_MILL_OF_MER,NewPressure

Anal_of_end_motor_off:

;      mMotor_off();
;      mDim_pressure_init();
;      Completion_of_mode();

        mMotor_off
        mDim_pressure_init
	CALL	Completion_of_mode

;    }

Anal_of_end_check_30_mm:
;    else
;    {
;      if (( Mode == PRESSURE_MEASUREMENT) && ( CurrPressure < PRESS_30 ))
;      // Если проводим измерение и очень низкий уровень давлени

	LACC	Mode,0
	SUB	#PRESSURE_MEASUREMENT
	BCND	Anal_of_end_quit,NEQ
	LACL	CurrPressure
	SUB	#PRESS_30
	BCND    Anal_of_end_quit,GEQ

;      {
;        mEnd_error_meas(rMEASURMENT_ON_LOW);

        mEnd_error_meas 	rMEASURMENT_ON_LOW
	B    	Anal_of_end_quit

;      }
;    }
;  }

Anal_of_end_two_minutes:
;  else
;  {
;    mEnd_error_meas(rTIME_MORE_2_MINUTES);

    	mEnd_error_meas		rTIME_MORE_2_MINUTES
;  }
;}

Anal_of_end_quit:

	MAR	*,AR1
	MAR	*-,AR1
	LAR	AR0,*-,AR1
	PSHD    *,AR2
	RET

;***********************************************************************
;	Finish_Meas_Address()
;***********************************************************************
;Finish_Meas_Address()
Finish_Meas_Address:

;  FinishMeasAddress[StepNumber] = SampleNumberShift;
;  StepNumber++;
;  if( StepNumber > MAX_STEP_NUMBER )
;  {
;    mEnd_error_meas(rSTEP_NUMBER_IS_BIG);
;  }

	MAR	*,AR1
	POPD    *+,AR1
	SAR	AR0,*+,AR2


	MAR	*,AR2
	LAR	AR0,StepNumber
	LAR	AR2,#FinishMeasAddress
	MAR	*0+,AR2
	LACL    SampleNumberShift
	SACL	*,0,AR2
	LACC	StepNumber
	ADD	#1
	SACL    StepNumber
	SUB	#MAX_STEP_NUMBER,0
	BCND	Step_number_error_isnt,LT
    	mEnd_error_meas	rSTEP_NUMBER_IS_BIG
Step_number_error_isnt:

	MAR	*,AR1
	MAR	*-,AR1
	LAR	AR0,*-,AR1
	PSHD    *,AR2
	RET
