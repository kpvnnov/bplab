;&D
;***********************************************************************
; $Id: PR_A_STP.ASM,v 1.8 2001-11-14 17:20:53 peter Exp $
;* 	Pressure_augment_stop() - Процесс остановки нагнетания давлени
;*	При переключении в этот режим необходимо задать:
;*  	1. Время до выключения клапана (ModeCnt = WHITE_VALVE_OFF)!
;*	2. Определить давление включения клапана ( NewPressure )
;*      3. SubroutMode = 0;
;***********************************************************************/
;Pressure_augment_stop()

Pressure_augment_stop

;{

        MAR     *,AR2
        LAR     AR0,_SampleNumber
        LAR     AR2,#Signal
        MAR     *0+,AR2

; switch ( SubroutMode )
; {

        LACC    _SubroutMode,1
        ADD     #Pr_a_stp_branch
        BACC

Pr_a_stp_branch
        B    Pr_a_stp_case0
        B    Pr_a_stp_case1

Pr_a_stp_case0

;  case 0:
;   if ( ModeCnt-- <= 0 )

        LACC    _ModeCnt,0
        SUB     #1
        SACL    _ModeCnt
	BCND    Press_aug_st_is_end,GT

;   {
;     DimMode = 0;
;     DimModeSampleCounter = 0;
;     MeasurementFlags = (MeasurementFlags )|( 1<<DIM_PRESSURE_FLAG  );
;     Valve_off();

	LACC	#0
	SACL	_DimMode
	SACL    _DimModeSampleCounter
	LACC	_MeasurementFlags,0
	OR	#(1<<DIM_PRESSURE_FLAG)
	SACL	_MeasurementFlags,0

	mValve_off

;     SubroutMode = 1;

        SPLK    #1,_SubroutMode

;   }
;   break;

        B       Press_aug_st_is_end

Pr_a_stp_case1

;  case 1:
;    if (((( MeasurementFlags )&( 1<<DIM_PRESSURE_FLAG )) == 0 )&&
;       ( SampleNumber > PREDICTION_INTERVAL ))

	LACC	_SampleNumber
	SUB	#PREDICTION_INTERVAL
	BCND	Press_aug_st_is_end,LEQ
	BIT	_MeasurementFlags,15-DIM_PRESSURE_FLAG
	BCND	Press_aug_st_is_end,TC

;   {
;     /*  Подготовка к следующему режиму */
;     Mode = CHECK_HIGHER_SISTOL_PRESSURE;

 .if Sertificarion=1
        SPLK    #PRESSURE_MEASUREMENT_MANUAL,_Mode
 .else
        SPLK    #CHECK_HIGHER_SISTOL_PRESSURE,_Mode
 .endif

;     Completion_of_mode();

	CALL	Completion_of_mode

;     AnalysisInterval = AveragePeriodEvaluation/4;

        LACC    _AveragePeriodEvaluation,14
        SACH    _AnalysisInterval,0

;     AnalysisStart = AnalysisInterval + DIFF_BASIS*2;

        LACC    _AnalysisInterval,15
	ADD     #DIFF_BASIS*2,15
        SACH    _AnalysisStart,1

;     StartMeasAdress[StepNumber] = SampleNumberShift;

	MAR	*,AR2
	LAR	AR0,_StepNumber
	LAR	AR2,#StartMeasAdress
	MAR	*0+,AR2
	LACC	_SampleNumberShift
	SACL	*,0,AR2

;     MeasurementFlags = MeasurementFlags | (1<<FIRST_IMPULSE_FLAG)

	LACC	_MeasurementFlags
	OR	#(1<<FIRST_IMPULSE_FLAG)
	SACL    _MeasurementFlags

;   }
;   break;

        B       Press_aug_st_is_end

; }
Press_aug_st_is_end:

; if ( SampleNumber > 2*ONE_SECOND )

	LACC	_SampleNumber,0
	SUB	#ONE_SECOND*2
	BCND	Press_aug_st_check_anal_end,LT

; {
;   mEnd_error_meas(rTIME_PR_AUG_STOP_MORE_2_SEC);
; }

	mEnd_error_meas rTIME_PR_AUG_STOP_MORE_2_SEC

Press_aug_st_check_anal_end:
; Analysis_of_end();
; SampleNumber++;

	CALL	Analysis_of_end
	LACC    _SampleNumber,0
	ADD	#1
	SACL    _SampleNumber,0

;}
	RET
