* $Id: ANAL_END.ASM,v 1.7 2001-03-20 16:07:18 peter Exp $
;Analysis_of_end()
 .if WriteDebug!=0

	LACC 	StartCode
	SUB	#1

	RETC	EQ
 .endif

Analysis_of_end:

;{
; if (( SampleNumber + SampleNumberShift) < TWO_MINUTES )
; {

	LACC	SampleNumber
	ADD	SampleNumberShift
	ADD	TimeNakachka
	SUB     #TWO_MINUTES
	BCND	Anal_end_time_more_two_minutes,GEQ

;   if ( CurrPressure > PRESS_280 )

 .if NotCheck280mm=1
	B	Anal_end_anal_time
 .else
	LACL	CurrPressure
	SUB	#PRESS_140,1
	BCND	Anal_end_anal_time,LEQ
 .endif

;   {
;     NewPressure = PRESS_275_MILL_OF_MERC;

	SPLK	#PRESS_275_MILL_OF_MER,NewPressure
	SPLK 	#PRESSURE_DIMINUTION,Mode
	mMotor_off
	mDim_pressure_init

;     MaxNumberShift = MaxNumber;

	LACC    MaxNumber
	SACL    MaxNumberShift

;     SubroutMode = 0;
;     MaxNumber = 0;
;     StartMaxNumber = 0;

	LACC    #0
	SACL    SubroutMode
	SACL    StartMaxNumber
	SACL    MaxNumber

;     SampleNumberShift = SampleNumberShift + SampleNumber + 1;
;     SampleNumber = -1;

	LACC    SampleNumberShift
	ADD     SampleNumber
	ADD     #1
	SACL    SampleNumberShift
	SPLK    #0FFFFh,SampleNumber

;     return;
;   }

Anal_end_anal_time:

;   if ( Mode == PRESSURE_MEASUREMENT && CurrPressure < PRESS_30 )
* если проводим измерение и очень низкий уровень давления
	LACC	Mode
	SUB	#PRESSURE_MEASUREMENT
	BCND	Anal_end_anal_meas,NEQ

	LACL	CurrPressure
	SUB	#PRESS_30
	BCND	Anal_end_anal_meas,GT

;   {
	mEnd_error_meas rMEASURMENT_ON_LOW
	RET
;   }

Anal_end_anal_meas
;   if ( SampleNumber > TEN_SECOND )
;   {

	LACC	SampleNumber
	SUB     #TEN_SECOND
	RETC	LT

;     switch( Mode)

	LACC    Mode,1
	ADD     #Anal_end_mode_branch
	BACC

;      {
Anal_end_mode_branch:

	.if SIM != 1
        B  	Anal_end_SUPPLY_UP
        B  	Anal_end_START_SHIFT
        B  	Anal_end_PRESSURE_AUGMENT_40
        B  	Anal_end_DAC_WORKING_CHECK
	.endif
	B  	Anal_end_PULSE_FREQ_EVALUATION
        B  	Anal_end_PRESSURE_AUGMENT
        B  	Anal_end_PRESSURE_AUGMENT_STOP
	B  	Anal_end_CHECK_HIGHER_SISTOL_PR
	B  	Anal_end_PRESSURE_MEASUREMENT
        B  	Anal_end_PRESSURE_DIMINUTION
        B  	Anal_end_MEASUREMENT_FINISH
        B  	Anal_end_START_DEBUG_WRITE

;        case:  Anal_end_SUPPLY_UP
;        case:  Anal_end_START_SHIFT
;        case:  Anal_end_DAC_working_check
;        case:  Anal_end_MEASUREMENT_FINISH
;        case:  Anal_end_START_DEBUG_WRITE
;		Error = TIME_MORE_TEN_SECOND;
;               return;

Anal_end_SUPPLY_UP:
Anal_end_START_SHIFT:
Anal_end_DAC_WORKING_CHECK:
Anal_end_MEASUREMENT_FINISH:
Anal_end_START_DEBUG_WRITE:
	mEnd_error_meas rCancelByUser	;i don't know ?!
	RET

;        case:  Anal_end_PRESSURE_AUGMENT_40 /*!!!!!! ПИЩАТЬ ПИЩАТЬ...*/
;		Error = TIME_PR_AUG_40_MORE_10_SEC;
;               return;

Anal_end_PRESSURE_AUGMENT_40:                ; /*!!!!!! ПИЩАТЬ ПИЩАТЬ...*/
	mEnd_error_meas rTIME_PR_AUG_40_MORE_10_SEC
	RET

;        case:  Anal_end_PULSE_FREQUENCY_EVALUATION

Anal_end_PULSE_FREQ_EVALUATION:

;		if ( CurrPressure < PRESS_60 )

	LACL	CurrPressure
	SUB	#PRESS_60,0
	BCND	Anal_end_CurrPress_MORE_60,GEQ

;		{
;	 	  Mode = PRESSURE_AUGMENT_40;
;		  PressPulseFrEv = PRESS_80;
;		  SubroutMode = 0;
;		  Clear_measurement();
;	 	  MDSPL = iCURRENT_PRESSURE;
;        	}

	.if SIM != 1
	SPLK 	#PRESSURE_AUGMENT_40,Mode
	SPLK	#PRESS_80,PressPulseFrEv
	.endif

;	if ( MaxNumber != 0)

	LACC  	 MaxNumber,0
	BCND	Anal_end_max_number_eq_zero,EQ
;	{
;         i = MaxNumber - 1;
;         while ( i >= 0 )

	MAR     *,AR2
        LAR     AR0,MaxNumberShift
        LAR     AR2,#Diff2MaxAdressFinish
        MAR     *0+,AR0
        LAR     AR0,MaxNumber
        MAR     *-,AR1
        LAR     AR1,#Diff2MaxAdress
        MAR     *0+,AR2
        MAR     *0+,AR1

;         {
;           Diff2MaxAdressFinish[MaxNumberShift+i] = Diff2MaxAdress[i];
;           i--;
;         }
;	}

Anal_end_for_i:
        LACC    *-,AR2
        SACL    *-,AR0
        BANZ    Anal_end_for_i,*-,AR1

Anal_end_max_number_eq_zero:

;       MaxNumberShift = MaxNumber;
;       SampleNumberShift = SampleNumberShift + SampleNumber + 1;
;       SampleNumber = -1;

        LACC	MaxNumber
        SACL	MaxNumberShift
	LACC    SampleNumberShift
	ADD     SampleNumber
	ADD     #1
	SACL    SampleNumberShift
	SPLK    #0FFFFh,SampleNumber

	LACC	#0
	SACL	SubroutMode			;для первоначального case
	SACL	SynchCount
	SACL    StartMaxNumber
	SACL    MaxNumber
	SPLK	#32,AveragePeriod
	SPLK    #32,AnalysisInterval
	LACC    AnalysisInterval
	ADD     #DIFF_BASIS*2
	SACL    AnalysisStart

	.if SIM != 1
*	SPLK 	#iCURRENT_PRESSURE,MDSPL 	;переходим на уровень давления
	.endif

	RET

Anal_end_CurrPress_MORE_60:
;		else
;		{
;		  Error = ERROR_PULS_FREQ_EVAL;
;		}
;               return;

	mEnd_error_meas rERROR_PULS_FREQ_EVAL
	RET

;        case:  Anal_end_PRESSURE_AUGMENT
;		if (( SampleNumberShift + SampleNumber -
;		      StartMeasAdress[StepNumber]) >= 3*TEN_SECOND )

Anal_end_PRESSURE_AUGMENT:
	MAR	*,AR1
	LAR	AR0,StepNumber
	LAR	AR1,#StartMeasAdress
	MAR	*0+,AR1
	LACC	SampleNumberShift,0
	ADD	SampleNumber,0
	SUB	*
	SUB	#TEN_SECOND,0
	SUB	#TEN_SECOND,1
	RETC	LT

;		{
;		  Error = TIME_PR_AUG_MORE_30_SEC;
;     		}
;               return;

	mEnd_error_meas rTIME_PR_AUG_MORE_30_SEC
	RET

;        case:  Anal_end_PRESSURE_AUGMENT_STOP
;		Error = ;
;               return;

Anal_end_PRESSURE_AUGMENT_STOP:     	; /*!!!!!! ПИЩАТЬ ПИЩАТЬ...*/
	mEnd_error_meas rTIME_PR_AUG_STOP_MORE_10_SEC
	RET

;        case:  Anal_end_CHECK_HIGHER_SISTOL_PR
;        case:  Anal_end_PRESSURE_MEASUREMENT
;        	LastMold = Mode;
;          	Mode = PRESSURE_DIMINUTION;
;   	   	Valve_off();

Anal_end_CHECK_HIGHER_SISTOL_PR:
Anal_end_PRESSURE_MEASUREMENT:

;          	NewPressure = NewPressure - EIGHT_MILL_OF_MERC;

	;LACC	NewPressure
	;SUB    #EIGHT_MILL_OF_MERC
	;SACL	NewPressure
	SPLK 	#PRESSURE_DIMINUTION,Mode
	mDim_pressure_init

;	   	SubroutMode = 0;
;          	MaxNumber = 0;
;          	StartMaxNumber = 0;

	LACC    #0
	SACL    SubroutMode
	SACL    StartMaxNumber
	SACL    MaxNumber

;          	SampleNumberShift = SampleNumberShift + SampleNumber + 1;
;          	SampleNumber = -1;

	LACC    SampleNumberShift
	ADD     SampleNumber
	ADD     #1
	SACL    SampleNumberShift
	SPLK    #0FFFFh,SampleNumber

;              if ( StepNumber < 4 )
;	       {
;                 ArtefactCount++;
;              }

	LACC	StepNumber
	SUB	#4
	RETC	GEQ
	LACC	ArtefactCount
	ADD	#1
	SACL    ArtefactCount
	RET

;        case:  Anal_end_PRESSURE_DIMINUTION   /*!!!!!! ПИЩАТЬ ПИЩАТЬ...*/
;		Error = TIME_PR_DIMIN_MORE_10_SEC;
;               return;

Anal_end_PRESSURE_DIMINUTION:   ;/*!!!!!! ПИЩАТЬ ПИЩАТЬ...*/
	mEnd_error_meas rTIME_PR_DIMIN_MORE_10_SEC
	RET

;     }
;   }
; }

Anal_end_time_more_two_minutes
; else
; {
;   Error = TIME_MORE_2_MINUTES;

	mEnd_error_meas rTIME_MORE_2_MINUTES
	RET
; }
;}
