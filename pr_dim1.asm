;***********************************************************************
; $Id: pr_dim1.asm,v 1.4 2001-08-22 14:17:46 peter Exp $
;*       Pressure_diminution_1() - Процесс подготовки данных после
;*	 понижения давления на 8 мм.рт.ст.
;*       При переключении в этот режим:
;***********************************************************************/
;Pressure_diminution()
;{
;    if ((( MeasurementFlags )&( 1<<DIM_PRESSURE_FLAG )) == 0 )
;    {
;  	DPTemp = ( Signal[SampleNumber] - Signal[SampleNumber-4])/4;
;       PredictionInterval = SampleNumber-4;
;       if ( PredictionInterval > PREDICTION_INTERVAL )
;       {
;          PredictionInterval = PREDICTION_INTERVAL;
;       }
;       for  ( i=0; i<PredictionInterval; i++; )
;       {
;	    Signal[SampleNumber-5-i] = Signal[SampleNumber-4-i] - DPTemp;
;           DPTemp = DPTemp - DPTemp/16;
;       }
;       /*      Подготовка к следующему режиму  */
;       Mode = PRESSURE_MEASUREMENT;
;       AnalysisStart = SampleNumber - 4 - PredictionInterval + AnalysisInterval + TIME_OUT;
;	StartMeasAdress[StepNumber] = SampleNumberShift + SampleNumber - 4;
;       MeasurementFlags = MeasurementFlags | (1<<FIRST_IMPULSE_FLAG);
;***********************************************************************/


PREDICTION_INTERVAL	.set	20

PredictionInterval	.equ	TMP
DPTemp			.equ	TMP+1

Pressure_diminution_1:

;    if ((( MeasurementFlags )&( 1<<DIM_PRESSURE_FLAG )) == 0 )

	BIT	MeasurementFlags,15-DIM_PRESSURE_FLAG
	RETC	TC

;    {
;  	DPTemp = ( Signal[SampleNumber] - Signal[SampleNumber-4])/4;
;       PredictionInterval = SampleNumber-4;

        MAR     *,AR2
        LAR     AR0,SampleNumber
        LAR     AR2,#Signal
        LAR     AR3,#Signal-4
        MAR     *0+,AR3
        MAR     *0+,AR2
	LACC	*,14,AR3
	SUB	*,14,AR3
	SACH	DPTemp,0
	LACC    SampleNumber
	SUB	#4
	SACL	PredictionInterval

;       if ( PredictionInterval > PREDICTION_INTERVAL )

	SUB	#PREDICTION_INTERVAL
	BCND	Dim1_prediction,LEQ

;       {
;          PredictionInterval = PREDICTION_INTERVAL;
;       }

	SPLK	#PREDICTION_INTERVAL,PredictionInterval

Dim1_prediction:

;       for  ( i=0; i<PredictionInterval; i++; )
;       {
;	    Signal[SampleNumber-5-i] = Signal[SampleNumber-4-i] - DPTemp;
;           DPTemp = DPTemp - DPTemp/16;
;       }

	LAR	AR0,PredictionInterval
Dim1_prediction_2:
	LACC	*-,0,AR3
	SUB	DPTemp,0
	SACL	*,0,AR0
	LACC	DPTemp,16
	SUB	DPTemp,12
	SACH	DPTemp,0
	BANZ	Dim1_prediction_2,*-,AR3

;       /*      Подготовка к следующему режиму  */

;       Mode = PRESSURE_MEASUREMENT;
 .if Sertificarion=1
        SPLK    #PRESSURE_MEASUREMENT_MANUAL,Mode
 .else
        SPLK    #PRESSURE_MEASUREMENT,Mode
 .endif

;       AnalysisStart = SampleNumber - 4 - PredictionInterval + AnalysisInterval + TIME_OUT;

	LACC	SampleNumber,16
	SUB	PredictionInterval,16
        ADD     AnalysisInterval,16
	ADD     #TIME_OUT*2-4*2,15
        SACH    AnalysisStart,0

;	StartMeasAdress[StepNumber] = SampleNumberShift + SampleNumber - 4;


	LAR	AR0,StepNumber
	LAR	AR3,#StartMeasAdress
	MAR	*0+,AR3
	LACC	SampleNumberShift
	ADD	SampleNumber,0
	SUB	#4
	SACL	*,0,AR2

;      MeasurementFlags = MeasurementFlags | (1<<FIRST_IMPULSE_FLAG);

	LACC	MeasurementFlags
	OR	#(1<<FIRST_IMPULSE_FLAG)
	SACL    MeasurementFlags

;    }
;    else      Сделано через "RETC"
;    {
;    }
;}
;    return

        RET
