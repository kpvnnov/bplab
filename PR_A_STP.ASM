;***********************************************************************
; $Id: PR_A_STP.ASM,v 1.4 2001-02-15 14:10:40 peter Exp $
;* 	Pressure_augment_stop() - Процесс остановки нагнетания давления
;*	При переключении в этот режим необходимо задать:
;*  	1. Время до выключения клапана (ModeCnt = VALVE_WHITE_TIME)!
;*	2. Определить давление включения клапана ( NewPressure )
;*      3. SubroutMode = 0;
;***********************************************************************/
;Pressure_augment_stop()

Pressure_augment_stop

;{

        MAR     *,AR1
        LAR     AR0,SampleNumber
        LAR     AR1,#Signal
        MAR     *0+,AR1

; switch ( SubroutMode )
; {

        LACC    SubroutMode,1
        ADD     #Pr_a_stp_branch
        BACC

Pr_a_stp_branch
        B    Pr_a_stp_case0
        B    Pr_a_stp_case1
        B    Pr_a_stp_case2
        B    Pr_a_stp_case3

Pr_a_stp_case0

;  case 0:
;   if ( ModeCnt-- <= 0 )

        LACC    ModeCnt,0
        SUB     #1
        SACL    ModeCnt
	RETC    GT

;   {
;     Valve_off();

        mValve_off

;     SubroutMode = 1;

        SPLK    #1,SubroutMode

;   }
;   break;

        RET

Pr_a_stp_case1

;  case 1:
;   if ( Signal[SampleNumber] < NewPressure )

        LACC    *,0,AR1
        SUB     NewPressure
        RETC    GEQ

;   {
;     Valve_on();

        mValve_on

;     SubroutMode = 2;

        SPLK    #2,SubroutMode

;     ModeCnt = VALVE_CLOSE;

        SPLK    #VALVE_CLOSE,ModeCnt

;   }
;   break;

        RET

Pr_a_stp_case2

;  case 2:
;   if ( ModeCnt-- <= 0 )

        LACC    ModeCnt,0
        SUB     #1
        SACL    ModeCnt
	RETC    GT

;   {
;     Valve_hold();

        mValve_hold

;     SubroutMode = 3;

        SPLK    #3,SubroutMode

;   }
;   break;

        RET

Pr_a_stp_case3

;  case 3:
;   if ( Signal[SampleNumber] > Signal[SampleNumber-1] )

        LACC    *-,0,AR1
        SUB     *
        RETC    LEQ

;   {
;     /*  Подготовка к следующему режиму */
;     Mode = CHECK_HIGHER_SISTOL_PRESSURE;

        SPLK    #CHECK_HIGHER_SISTOL_PRESSURE,Mode

;     SampleNumberShift = SampleNumberShift + SampleNumber+1;

        LACC    SampleNumberShift
        ADD     SampleNumber
        ADD     #1
        SACL    SampleNumberShift

;     SampleNumber = -1;

        SPLK    #0FFFFh,SampleNumber

;    AnalysisInterval = AveragePeriodEvaluation*1;

        LACC    AveragePeriodEvaluation,14
        SACH    AnalysisInterval,0

;     AnalysisStart = AnalysisInterval + TIME_OUT;

        LACC    AnalysisInterval,15
	ADD     #TIME_OUT,15           ; TIME_OUT
        SACH    AnalysisStart,1

;     StartMeasAdress[StepNumber] = SampleNumberShift;

	LAR	AR1,#StartMeasAdress
	LACC	SampleNumberShift
	SACL	*,0,AR1

;     if ( SynchroFlag == FALSE)
;     {
;       LastDiff2Max = MIN_THRESHOLD_SISTOL*4;
;     }

	BIT     MeasurementFlags,15-SYNCHRO_FLAG
	RETC	TC
	SPLK	#MIN_THRESHOLD_SISTOL*4,LastDiff2Max

;	ArtefactCount = 0;

	SPLK	#0,ArtefactCount

;      MeasurementFlags = MeasurementFlags | (1<<FIRST_IMPULSE_FLAG)

	LACC	MeasurementFlags
	OR	#(1<<FIRST_IMPULSE_FLAG)
	SACL    MeasurementFlags

;   }
;   break;

        RET

; }
;}

