* $Id: PR_A_T40.ASM,v 1.12 2001-02-26 11:47:00 peter Exp $
Pressure_augment_40

	LACC    SubroutMode,1
	ADD     #Pr_aug_40_branch
	BACC

Pr_aug_40_branch
	B	Pr_aug_40_case0
	B	Pr_aug_40_case1
	B	Pr_aug_40_case2
	B	Pr_aug_40_case3
	B	Pr_aug_40_case4
	B	Pr_aug_40_case5

Pr_aug_40_case0
	mValve_on
	mWait_valve_hold
	mNext_sub_mode
	RET
Pr_aug_40_case1
	mDec_counter		;CNTMOD--
	RETC 	GT
	mMotor_on
*	SPLK	#0,Motor
	SPLK    #1800,Motor+1	;18 секунд качаем в полную силу

	mNext_sub_mode
	mValve_hold
TimeToPumps .set 1800
	SPLK 	#TimeToPumps,ModeCnt


	RET
Pr_aug_40_case2
;	if ( PressPulseFrEv < PRESS_60)

	LACC	PressPulseFrEv
	SUB	#PRESS_60
	BCND	Pr_aug_40_case2_1,GEQ
;       {

	Clear_measurement
;	}
Pr_aug_40_case2_1
	LACL 	CurrPressure       ;Проверка достижения верхнего предела+
				;PRESS_OVER+PRESS_PRESET мм.рт.ст.
	SUB  	#PRESS_OVER+PRESS_PRESET
	SUB  	PressPulseFrEv
	BCND 	Pr_aug_40_1,LEQ
	LACC	ModeCnt
	SUB	#(TimeToPumps-100)	;1 секунда
	BCND	Pr_aug_40_trubka,GEQ	;если слишком быстро накачали
 .if Sertificarion=1
	SPLK    #PRESSURE_AUGMENT,Mode
	SPLK	#0,SubroutMode		;для первоначального case
	Clear_measurement
        LACC	#B0_5mm
	SACL	MaxAverageAmplitude
	SACL	SistolPressure
	SACL	DiastolPressure
	mBegin_write_flash
 	RET
 .endif

	mMotor_off
	mNext_sub_mode
	RET
Pr_aug_40_trubka
	mEnd_error_meas		rBIG_SPEED_AUG_PR
	RET
Pr_aug_40_1
;	if ( PressPulseFrEv < PRESS_60)

	LACC	PressPulseFrEv
	SUB	#PRESS_60
	BCND	Pr_aug_40_1_1,GEQ
;       {

	LACC	TimeNakachka
	ADD	#1
	SACL	TimeNakachka
;	}
Pr_aug_40_1_1
	mDec_counter		;CNTMOD--
	RETC 	GT
	LACL	CurrPressure
	SUB	#PRESS_02_5
	BCND	Pr_aug_40_nomanget,LEQ
	mEnd_error_meas rSystemDiryavaya1
	RET
Pr_aug_40_nomanget
	mEnd_error_meas		rMangetAbsent
	RET
Pr_aug_40_case3
	mValve_off
	mWait 100
	mNext_sub_mode
	RET
Pr_aug_40_case4
	LACL CurrPressure       ;Проверка достижения верхнего предела+
				;PRESS_OVER+PRESS_PRESET мм.рт.ст.
	SUB  PressPulseFrEv
	BCND Pr_aug_40_2,GEQ
	mValve_on
	mWait_valve_hold
	mNext_sub_mode
	RET

Pr_aug_40_2
;	if ( PressPulseFrEv < PRESS_60)

	LACC	PressPulseFrEv
	SUB	#PRESS_60
	BCND	Pr_aug_40_2_1,GEQ
;       {

	LACC	TimeNakachka
	ADD	#1
	SACL	TimeNakachka
;	}
Pr_aug_40_2_1
	mDec_counter		;CNTMOD--
	RETC 	GT
	mEnd_error_meas rErrorSpuskFromUp
	RET

Pr_aug_40_case5
;	if ( PressPulseFrEv < PRESS_60)

	LACC	PressPulseFrEv
	SUB	#PRESS_60
	BCND	Pr_aug_40_5_1,GEQ
;       {

	LACC	TimeNakachka
	ADD	#1
	SACL	TimeNakachka
;	}
Pr_aug_40_5_1
	mDec_counter		;CNTMOD--
	RETC 	GT
	mValve_hold

;	if ( PressPulseFrEv < PRESS_60)

	LACC	PressPulseFrEv
	SUB	#PRESS_60
	BCND	Pr_aug_40_case5_2,GEQ
;       {

	SPLK 	#DAC_WORKING_CHECK,Mode
	SPLK	#0,SubroutMode		;для первоначального case
	Clear_measurement
	RET

;       }

Pr_aug_40_case5_2:

;       else
;       {

	SPLK 	#PULSE_FREQUENCY_EVALUATION,Mode
	SPLK	#0,SubroutMode		;для первоначального case

;       MaxNumberShift = MaxNumber;

	LACC    MaxNumber,0
	SACL    MaxNumberShift
	SPLK    #0,MaxNumber

;     SampleNumberShift = SampleNumberShift + SampleNumber+1;

	LACC    SampleNumberShift
	ADD     SampleNumber
	ADD     #1
	SACL    SampleNumberShift

;     SampleNumber = -1;

	SPLK    #0FFFFh,SampleNumber

	SPLK	#32,AveragePeriod

	SPLK    #150,AnalysisInterval
        SPLK	#MAX_THRESHOLD_40MM,LastDiff2Max

	LACC    AnalysisInterval
	ADD     #DIFF_BASIS*2
	SACL    AnalysisStart
	RET

;       }
