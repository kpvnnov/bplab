;&D
* $Id: PR_A_T40.ASM,v 1.16 2001-11-14 17:20:53 peter Exp $
Pressure_augment_40:

	MAR	*,AR1
	POPD    *+,AR1
	SAR	AR0,*+,AR2

	LACC    _SubroutMode,1
	ADD     #Pr_aug_40_branch
	BACC

Pr_aug_40_branch:
	B	Pr_aug_40_case0
	B	Pr_aug_40_case1
	B	Pr_aug_40_case2
	B	Pr_aug_40_case3
	B	Pr_aug_40_case4
	B	Pr_aug_40_case5

Pr_aug_40_case0:
	mValve_on
	mWait_valve_hold
	mNext_sub_mode
	B	Pr_aug_40_quit

Pr_aug_40_case1:
	mDec_counter		;CNTMOD--
	BCND       Pr_aug_40_quit,GT
	mValve_hold
	mMotor_on
	LACL	CurrPressure
	SACL	LastCurrPressure
	SPLK    #2300,Motor+1	;23 секунд качаем в полную силу
TIME_TO_PUMPS .set 2300
	SPLK 	#TIME_TO_PUMPS,_ModeCnt
	mNext_sub_mode
	B       Pr_aug_40_quit

Pr_aug_40_case2:
	LACL 	CurrPressure       ;Проверка достижения верхнего предела+
				   ;PRESS_OVER+PRESS_PRESET мм.рт.ст.
	SUB  	#PRESS_OVER+PRESS_PRESET+PRESS_40
	BCND 	Pr_aug_40_case2_1,LEQ
	LACC	_ModeCnt
	SUB	#TIME_TO_PUMPS-20
	BCND    Pr_aug_40_trubka,GEQ
 .if Sertificarion=1
	SPLK    #PRESSURE_AUGMENT,_Mode
	CALL	Completion_of_mode
        LACC	#B0_5mm
	SACL	MaxAverageAmplitude
	SACL	SistolPressure
	SACL	DiastolPressure
	mBegin_write_flash
 	B       Pr_aug_40_quit
 .endif

	mMotor_off
	mNext_sub_mode
	B       Pr_aug_40_quit

Pr_aug_40_case2_1:

	LACC	_ModeCnt
	AND	#0Fh
	BCND	Pr_aug_40_case2_2,NEQ
	LACL	CurrPressure
	SUB	LastCurrPressure
	SUB	#PRESS_30
	BCND	Pr_aug_40_trubka,GEQ
	LACL	CurrPressure
	SACL	LastCurrPressure

Pr_aug_40_case2_2
	mDec_counter		;CNTMOD--
	BCND       Pr_aug_40_quit,GT
	LACL	CurrPressure
	SUB	#PRESS_02_5
	BCND	Pr_aug_40_nomanget,LEQ
	SUB	#PRESS_05
	BCND	Pr_aug_40_rCUFF_MAY_BE_BAD,LEQ
	mEnd_error_meas rCUFF_IS_PLASED_BAD
	B       Pr_aug_40_quit

Pr_aug_40_nomanget:
	mEnd_error_meas	rMangetAbsent
	B       Pr_aug_40_quit

Pr_aug_40_rCUFF_MAY_BE_BAD:
	mEnd_error_meas	rCUFF_MAY_BE_BAD
	B       Pr_aug_40_quit

Pr_aug_40_trubka:
	mEnd_error_meas	rBIG_SPEED_AUG_PR
	B       Pr_aug_40_quit


Pr_aug_40_case3:
	mValve_off
	mWait 100
	mNext_sub_mode
	B       Pr_aug_40_quit

Pr_aug_40_case4:
	LACL 	CurrPressure       ;Проверка стравливани
	SUB  	#PRESS_40+PRESS_01_25
	BCND 	Pr_aug_40_case4_2,GEQ
	mValve_on
	mWait_valve_hold
	mNext_sub_mode
	B       Pr_aug_40_quit

Pr_aug_40_case4_2:
	mDec_counter		;CNTMOD--
	BCND       Pr_aug_40_quit,GT
	mEnd_error_meas rErrorSpuskFromUp
	B       Pr_aug_40_quit

Pr_aug_40_case5:
	mDec_counter		;CNTMOD--
	BCND       Pr_aug_40_quit,GT
	mValve_hold
	SPLK 	#DAC_WORKING_CHECK,_Mode
	mClear_subrout_mode_err_meas
	B       Pr_aug_40_quit

Pr_aug_40_quit:
	LACC    TimeNakachka,0
	ADD	#1
	SACL    TimeNakachka,0
	MAR	*,AR1
	MAR	*-,AR1
	LAR	AR0,*-,AR1
	PSHD    *,AR2
	RET

***********************************************************
*	Pressure_augment_80
***********************************************************
Pressure_augment_80:

	MAR	*,AR1
	POPD    *+,AR1
	SAR	AR0,*+,AR2

	LACC    _SubroutMode,1
	ADD     #Pr_aug_80_branch
	BACC

Pr_aug_80_branch
	B	Pr_aug_80_case0
	B	Pr_aug_80_case1
	B	Pr_aug_80_case2
	B	Pr_aug_80_case3
	B	Pr_aug_80_case4
	B	Pr_aug_80_case5

Pr_aug_80_case0:
	mValve_on
	mWait_valve_hold
	mNext_sub_mode
	B       Pr_aug_80_quit

Pr_aug_80_case1:
	mDec_counter		;CNTMOD--
	BCND       Pr_aug_80_quit,GT
	mValve_hold
	mMotor_on
	LACL	CurrPressure
	SACL	LastCurrPressure
	SPLK    #1800,Motor+1	;18 секунд качаем в полную силу
TIME_TO_PUMPS_80 .set 1800
	SPLK 	#TIME_TO_PUMPS_80,_ModeCnt
	mNext_sub_mode
	B       Pr_aug_80_quit

Pr_aug_80_case2:
	LACL 	CurrPressure       ;Проверка достижения верхнего предела+
				   ;PRESS_OVER+PRESS_PRESET мм.рт.ст.
	SUB  	#PRESS_OVER+PRESS_PRESET+PRESS_80
	BCND 	Pr_aug_80_case2_1,LEQ
	LACC	_ModeCnt
	SUB	#TIME_TO_PUMPS_80-20
	BCND    Pr_aug_80_trubka,GEQ
	mMotor_off
	mNext_sub_mode
	B       Pr_aug_80_quit

Pr_aug_80_case2_1:
	LACC	_ModeCnt
	AND	#0Fh
	BCND	Pr_aug_80_case2_2,NEQ
	LACL	CurrPressure
	SUB	LastCurrPressure
	SUB	#PRESS_30
	BCND	Pr_aug_80_trubka,GEQ
	LACL	CurrPressure
	SACL	LastCurrPressure

Pr_aug_80_case2_2
	mDec_counter		;CNTMOD--
	BCND       Pr_aug_80_quit,GT
	LACL	CurrPressure
	SUB	#PRESS_02_5
	BCND	Pr_aug_80_nomanget,LEQ
	SUB	#PRESS_10
	BCND	Pr_aug_80_rCUFF_MAY_BE_BAD,LEQ
	mEnd_error_meas rCUFF_IS_PLASED_BAD
	B       Pr_aug_80_quit

Pr_aug_80_nomanget:
	mEnd_error_meas		rMangetAbsent
	B       Pr_aug_80_quit

Pr_aug_80_rCUFF_MAY_BE_BAD:
	mEnd_error_meas	rCUFF_MAY_BE_BAD
	B       Pr_aug_80_quit

Pr_aug_80_trubka:
	mEnd_error_meas		rBIG_SPEED_AUG_PR
	B       Pr_aug_80_quit

Pr_aug_80_case3:
	mValve_off
	mWait 100
	mNext_sub_mode
	B       Pr_aug_80_quit

Pr_aug_80_case4:
	LACL CurrPressure       ;Проверка достижения верхнего предела+
				;PRESS_OVER+PRESS_PRESET мм.рт.ст.
	SUB  	#PRESS_80
	BCND Pr_aug_80_2,GEQ
	mValve_on
	mWait_valve_hold
	mNext_sub_mode
	B       Pr_aug_80_quit

Pr_aug_80_2:
	mDec_counter		;CNTMOD--
	BCND       Pr_aug_80_quit,GT
	mEnd_error_meas rErrorSpuskFromUp
	B       Pr_aug_80_quit

Pr_aug_80_case5:
	mDec_counter		;CNTMOD--
	BCND       Pr_aug_80_quit,GT
	mValve_hold

	SPLK 	#PULSE_FREQ_EVALUATION_80,_Mode
	CALL	Completion_of_mode

;     AnalysisInterval = 40;
;     AnalysisStart = AnalysisInterval + DIFF_BASIS*2;

	SPLK    #40,_AnalysisInterval

	LACC    _AnalysisInterval
	ADD     #DIFF_BASIS*2
	SACL    _AnalysisStart
	B       Pr_aug_80_quit

Pr_aug_80_quit:
	LACC    _SampleNumber,0
	ADD	#1
	SACL    _SampleNumber,0
	SUB     #TEN_SECOND
	BCND    Pr_aug_80_quit_2,LT
	LACC    _SampleNumberShift
	ADD     _SampleNumber
	SACL    _SampleNumberShift
	SPLK    #0,_SampleNumber
Pr_aug_80_quit_2:
	MAR	*,AR1
	MAR	*-,AR1
	LAR	AR0,*-,AR1
	PSHD    *,AR2
	RET

