;&D
;***********************************************************************
; $Id: pr_dim1.asm,v 1.7 2001-11-14 17:33:36 peter Exp $
;*       Pressure_diminution_1() - Процесс подготовки данных после
;*	 понижения давления на 8 мм.рт.ст.
;*       При переключении в этот режим:
;***********************************************************************/


PREDICTION_INTERVAL	.equ	DIFF_BASIS+8

DPTemp			.equ	TMP+1

Pressure_diminution_1:

;    if (((( MeasurementFlags )&( 1<<DIM_PRESSURE_FLAG )) == 0 )&&
;       ( SampleNumber > PREDICTION_INTERVAL ))

	LACC	_SampleNumber
	SUB	#PREDICTION_INTERVAL
	BCND	Press_dim_1_end,LEQ
	BIT	_MeasurementFlags,15-DIM_PRESSURE_FLAG
	BCND	Press_dim_1_end,TC

;    {
;  	DPTemp = (( Signal[SampleNumber] - Signal[SampleNumber-4]) +
;  	         (Signal[SampleNumber-1] - Signal[SampleNumber-5]) +
;  	         (Signal[SampleNumber-2] - Signal[SampleNumber-6]) +
;  	         (Signal[SampleNumber-3] - Signal[SampleNumber-7]))/16;

        MAR     *,AR2
        LAR     AR0,_SampleNumber
        LAR     AR2,#Signal
        MAR     *0+,AR2
	LACC	*-,12,AR2
	RPT	#2
	ADD     *-,12,AR2
	RPT	#3
	SUB	*-,12,AR2
	SACH	DPTemp,0

;       for  ( i=0; i<=PREDICTION_INTERVAL-1; i++; )
;       {
;	    Signal[SampleNumber-1-i] = Signal[SampleNumber-i] - DPTemp;
;           DPTemp = DPTemp - DPTemp/16;
;       }

        LAR     AR2,#Signal
        MAR     *0+,AR2
	LAR	AR0,#PREDICTION_INTERVAL-1
Dim1_prediction_2:
	LACC	*-,0,AR2
	SUB	DPTemp,0
	SACL	*,0,AR0
	LACC	DPTemp,16
	SUB	DPTemp,12
	SACH	DPTemp,0
	BANZ	Dim1_prediction_2,*-,AR2

;    Temp0 = 0;
;    for ( k=0; k<8; k++ )
;    {
;      Temp0 = Temp0 +
;        ((long int)(Signal[SampleNumber-k]))*Win_blackman[k] -
;        ((long int)(Signal[SampleNumber-k-DIFF_BASIS]))*Win_blackman[k];
;    }
;    DiffSignal[0] = (int)(Temp0>>14);

	MAR	*,AR2
        LAR     AR0,_SampleNumber
        LAR     AR2,#Signal
	MAR	*0+,AR3                 ; AR2 = & Signal[SampleNumber]
        LAR     AR3,#Signal-DIFF_BASIS
        MAR     *0+,AR2  		; AR3 = & Signal[SampleNumber-DIFF_BASIS]

        MAC  	WIN_BL,*-,AR2
	LACC 	#0
	RPT  	#2
	MAC 	WIN_BL+1,*-,AR2
	MAR	*,AR3
	RPT  	#3
	MAC 	WIN_BL_MINUS,*-,AR3
	MAR	*,AR2
	RPT  	#3
	MAC 	WIN_BL+4,*-,AR2
	MAR	*,AR3
	RPT  	#3
	MAC 	WIN_BL_MINUS+4,*-,AR3
	MAR	*,AR2
	LAR	AR2,#DiffSignal
	APAC
	SACH 	*+,2,AR2

;    for ( i=1; i<=PREDICTION_INTERVAL; i++ )
;    {
;      DiffSignal[i] = DiffSignal[0];
;    }

	RPT	#PREDICTION_INTERVAL
	SACH    *+,2,AR2

;       /* 	Давление для дисплея*/

	LACL    CurrPressure
	ADD	#B0_5mm*2,0
	SACL	PressureForDisplay+0,0
	CALL	Pressure_for_display

;       /*      Подготовка к следующему режиму  */
;       Mode = PRESSURE_MEASUREMENT;
 .if Sertificarion=1
        SPLK    #PRESSURE_MEASUREMENT_MANUAL,_Mode
 .else
        SPLK    #PRESSURE_MEASUREMENT,_Mode
 .endif

;       AnalysisStart = SampleNumber - PREDICTION_INTERVAL
;		         + DIFF_BASIS*4/3 + AnalysisInterval;

	LACC	_SampleNumber,16
	SUB	#(PREDICTION_INTERVAL-DIFF_BASIS*4/3)*2,15
        ADD     _AnalysisInterval,16
        SACH    _AnalysisStart,0

;	StartMeasAdress[StepNumber] = SampleNumberShift + SampleNumber;

	MAR	*,AR3
	LAR	AR0,_StepNumber
	LAR	AR3,#StartMeasAdress
	MAR	*0+,AR3
	LACC	_SampleNumberShift
	ADD	_SampleNumber,0
	SACL	*,0,AR2

;      MeasurementFlags = MeasurementFlags | (1<<FIRST_IMPULSE_FLAG);

	LACC	_MeasurementFlags
	OR	#(1<<FIRST_IMPULSE_FLAG)
	SACL    _MeasurementFlags

;    }

Press_dim_1_end:
;    else
;    {
;    }
;    if ( SampleNumber > 2*ONE_SECOND )

	LACC	_SampleNumber,0
	SUB	#ONE_SECOND*2
	BCND	Press_dim_1_check_anal_end,LT

;    {
;      mEnd_error_meas(rTIME_PR_DIM_MORE_2_SEC);
;    }

	mEnd_error_meas rTIME_PR_DIM_MORE_2_SEC

Press_dim_1_check_anal_end:
;    Analysis_of_end();
;    SampleNumber++;

	CALL	Analysis_of_end
	LACC    _SampleNumber,0
	ADD	#1
	SACL    _SampleNumber,0

;}
;    return

        RET
