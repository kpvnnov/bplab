***********************************************************************
*       Average
* $Id: PROCEDUR.ASM,v 1.5 2001-02-15 14:10:40 peter Exp $
***********************************************************************
Average

;  AveragePeriodEvaluation = AveragePeriodEvaluation +
;		         ( TempPeriod - AveragePeriodEvaluation )/4;

        LACC    TempPeriod,16
        SUB     AveragePeriodEvaluation,14   ; AveragePeriodEvaluation
        ADD     AveragePeriodEvaluation,16   ; увеличино в 4 pаза
        SACH    AveragePeriodEvaluation,0

;  AveragePeriod = AveragePeriod + ( TempPeriod - AveragePeriod)/16;

        LACC    TempPeriod,16
        SUB     AveragePeriod,12
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

;    AnalysisInterval = AveragePeriodEvaluation*1;

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
;      AnalysisStart = SampleNumber;

        LACC    SampleNumber,16
	B	Average_finish

;    }
;  }

Average_impulse_in_center:

;  else
;  {

;    AnalysisInterval = AveragePeriodEvaluation*1.25;

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
;		( TempPeriod - 2*AveragePeriodEvaluation )/4;

        LACC    TempPeriod,15
        SUB     AveragePeriodEvaluation,14   ; AveragePeriodEvaluation
        ADD     AveragePeriodEvaluation,16   ; увеличино в 4 pаза
        SACH    AveragePeriodEvaluation,0

;AveragePeriod = AveragePeriod + ( TempPeriod/2 - AveragePeriod)/16;

        LACC    TempPeriod,15
        SUB     AveragePeriod,12
        ADD     AveragePeriod,16
        SACH    AveragePeriod,0

	B	Average_check_mode
