;&D
;*********************************************************************
;    Check_higher_sistol_pressure()   - Проверка превышения
*                                       систолического давления
;***********************************************************************
;
;void Check_higher_sistol_pressure()

Check_higher_sistol_pressure:
;{
;  if (( MeasurementFlags&(1<<DIFF_MAX_FLAG)) != 0 )

	MAR	*,AR2
	BIT	MeasurementFlags,15-DIFF_MAX_FLAG
	BCND	Check_hsp_max_isnt,NTC
;  {
;    //MeasurementFlags = MeasurementFlags &(~(1<<NEXT_MODE_FLAG));
;    if ( Diff2Max[MaxNumber] > MIN_THRESHOLD_SISTOL )

     ;	LACC	MeasurementFlags
     ;	AND     #(~(1<<NEXT_MODE_FLAG))
     ;	SACL    MeasurementFlags
	LAR	AR0,MaxNumber
	LAR	AR2,#Diff2Max
	MAR	*0+,AR2
	LACC	*,0,AR2
	SUB	#MIN_THRESHOLD_SISTOL
	BCND	Check_hsp_impulse_small,LEQ

;    {
;      if ( Diff2Max[MaxNumber] < MAX_THRESHOLD_SISTOL )

	SUB	#MAX_THRESHOLD_SISTOL-MIN_THRESHOLD_SISTOL
	BCND	Check_hsp_impulse_high,GEQ

;      {
;        Maximum_analysis();

	CALL	Maximum_analysis

;        if (( MeasurementFlags&(1<<NEXT_MODE_FLAG)) != 0 )

	BIT	MeasurementFlags,15-NEXT_MODE_FLAG
	BCND	Check_hsp_next_mode_isnt,NTC

;        {
;          if (( MeasurementFlags&(1<<PRESS_MORE_SYSTOL_FLAG)) != 0 )

	BIT	MeasurementFlags,15-PRESS_MORE_SYSTOL_FLAG
	BCND	Check_hsp_pr_m_s_flag_0,NTC

;          {
;            Start_diminution_pressure();
;          }

	CALL	Start_diminution_pressure
	B	Check_hsp_end_step_analysis

Check_hsp_pr_m_s_flag_0:
;          else
;          {
;            if (( Max[0]+Max[1])/2 < 0.8 SistolPressureAmplitude )

	MAR	*,AR2
	LAR	AR2,#Max
	LACC	*+,11,AR2
	ADD	*,11,AR2
	LT	SistolPressureAmplitude
	MPY	#CONST_0_8
	SPAC
	BCND	Check_hsp_check_new_aug,GEQ

;            { //SistolPressureAmplitude = 0.5  last RS
;              Start_diminution_pressure();
;            }

	CALL	Start_diminution_pressure
	B	Check_hsp_end_step_analysis

Check_hsp_check_new_aug:
;            else
;            { // Augment pressure at 30 .
;              if ( AugmentPressureNumber < 2 )

	LACC    AugmentPressureNumber,0
	SUB	#2
	BCND	Check_hsp_start_dim,GEQ

;              {
;                Next_augment_pressure();
;              }

	CALL	Next_augment_pressure
	B	Check_hsp_end_step_analysis

Check_hsp_start_dim:
;              else
;              {
;                Start_diminution_pressure();

	CALL	Start_diminution_pressure

;              }
;            }
;          }
;        }
;      }
	B	Check_hsp_end_step_analysis

Check_hsp_impulse_high:
;      elso
;      {
;        StartMaxNumber = MaxNumber;
;        Synchro_flag_is_reseted();

	LACC	MaxNumber,0
	SACL    StartMaxNumber,0
	CALL	Synchro_flag_is_reseted

;      }
;    }

Check_hsp_end_step_analysis:
Check_hsp_next_mode_isnt:
Check_hsp_impulse_small:
;  }
Check_hsp_max_isnt:
;  End_step_analysis();

	CALL	End_step_analysis
	RET

;}
;
;;***********************************************************************
;;	Next_augment_pressure()
;;***********************************************************************
;void Next_augment_pressure()

Next_augment_pressure:

	MAR	*,AR1
	POPD    *+,AR1
	SAR	AR0,*+,AR2
;{
;  Mode=PRESSURE_AUGMENT;
;  MaxDiffSignal = 0;
;  mMotor_on();
;  PressureTop = Signal[SampleNumber] + PRESS_30 + PRESS_PRESET;
;  MeasurementFlags = MeasurementFlags&(~(1<<SYNCHRO_FLAG));
;  Completion_of_mode();
;  AnalysisStart = TIME_OF_MAX_PRESSURE + 0,5*AnalysisInterval;
;  AugmentPressureNumber++;
;  AvrPress[StepNumber] = 0;
;  mZeroToAverageAmplitude();
;  Finish_Meas_Address();
;}
	SPLK	#PRESSURE_AUGMENT,Mode
	SPLK	#0,MaxDiffSignal
	mMotor_on
	LAR	AR0,SampleNumber
	LAR     AR2,#Signal
	MAR	*0+,AR2
	LACC	*,0,AR2
	ADD	#PRESS_30+RESERVE_MILL_OF_MERC
	SACL	PressureTop
	LACC	MeasurementFlags
	AND 	#(~(1<<SYNCHRO_FLAG))
	SACL    MeasurementFlags
	CALL	Completion_of_mode
	LACC	AnalysisInterval,14
	ADD	#TIME_OF_MAX_PRESSURE,15
	SACH    AnalysisStart,1
	LACC    AugmentPressureNumber
	ADD	#1
	SACL    AugmentPressureNumber
	mZeroToAverageAmplitude
        CALL	Finish_Meas_Address

	MAR	*,AR1
	MAR	*-,AR1
	LAR	AR0,*-,AR1
	PSHD    *,AR2
	RET
;
