****************************************************************
* $Id: ADC_V_P5.ASM,v 1.3 2001-02-15 14:10:38 peter Exp $
*  Процесс обработки значений ADC -
*
*  void ADC_value_processing(){
*
*  Глобальные пеpеменные к котоpым обpащается функция.
*
*  В pежиме пpямой адpесации
*
*     SampleNumber
*     MaxNumber
*     AnalysisStart
*     AnalysisInterval
*     AveragePeriodEvaluation
*     TempPeriod
*     TempPeriodDiff
*     Temp2PeriodDiff
*     TempAmplitudeDiff
*     Temporary1_L
*     Temporary1_H
*     Temporary2_L
*     Temporary2_H
*
*  В pежиме косвенной адpесации
*
*     Signal[]
*     Diff2Max[MAX_NUMBER]
*     Diff2MaxAdress[MAX_NUMBER]
*     MaxAvrPress[3]
*     MinAvrPress[3]
*     Max2DiffAdress[0]
*
*
*  Номеp веpсии   Дата изменения   Пpичина
*
*     1.0.0.        26.01.2000.
*     1.0.1.        21.04.2000.    Изменение алгоpитма обнаpужения
*                                  и оценки амплитуды импульсов.
*
****************************************************************

;void ADC_value_processing()
;{
;long int Win_blackman[8]={417,4233,16655,30465,30465,16655,4233,417};
;int DiffSignalMax,DiffSignal;
;int i,k;
;long int Temp0;

;  Использование ячеек памяти TMP в модуле ADC_value_processing

DiffSignal              .equ   TMP
DiffSignalMax           .equ   TMP+1
SignalSampleNumber      .equ   TMP+2	; & SignalSampleNumber
NumberOfMaxSample       .equ   TMP+3
DiffMaxNumber           .equ   TMP+4
MaxSampleNumber         .equ   TMP+5

MIN_INTERVAL_TO_VERGE			.equ	25
FIRST_THRESHOLD_OF_INTERVAL        	.equ    65
SECOND_THRESHOLD_OF_INTERVAL        	.equ    80

        .text

*              ;Коэфициенты ОКОН

WIN_BL  	.word	417, 4233, 16655, 30465, 30465, 16655, 4233, 417
WIN_BL_MINUS  	.word  -417,-4233,-16655,-30465,-30465,-16655,-4233,-417
WIN_BL_075  	.word	313, 3175, 12491, 22849, 22849, 12491, 3175, 313
WIN_BL_025  	.word	104, 1058,  4164,  7616,  7616,  4164, 1058, 104

ADC_value_processing:

        SETC    SXM            ;!!!!!!!!!!!!!!!!!!!!!!!!!
        SPM     #0             ;!!!!!!!!!!!!!!!!!!!!!!!!!

;  DiffMaxFlag = False;

	LACC	MeasurementFlags
	AND	#~(1<<DIFF_MAX_FLAG)
	SACL	MeasurementFlags

;  if ( SampleNumber > AnalysisStart )

        LACC    SampleNumber,0
        SUB     AnalysisStart,0
        BCND    ADC_v_end_p,LEQ

;  { /* Поиск максимума на интервале ANALYSIS_INTERVAL */ // DIFF_BASIS=12 при Fs=100Гц
;    DiffSignalMax = MIN_NUMBER;

	SPLK	#MIN_NUMBER,DiffSignalMax

;    Определение номера максимального отсчета ( где искать Max )
;    if (( Mode == PRESSURE_MEASUREMENT )||( Mode == CHECK_HIGHER_SISTOL_PRESSURE))
;    {
;      if ((MeasurementFlags & (1<<FIRST_IMPULSE_FLAG)) == 0)
;      {
;        if (AveragePeriodEvaluation => 65)
;        {
;          if (AveragePeriodEvaluation <= 80)
;          {
;            MaxSampleNumber = 25
;          }
;          else
;          {
;            MaxSampleNumber = AnalysisInterval * 0.3
;          }
;        }
;        else
;        {
;          MaxSampleNumber = AnalysisInterval/2
;        }
;      }
;      else
;      {
;        if (AveragePeriodEvaluation => 65)
;        {
;          if (AveragePeriodEvaluation <= 80)
;          {
;            MaxSampleNumber = AnalysisInterval - 25
;          }
;          else
;          {
;            MaxSampleNumber = AnalysisInterval * 0.7
;          }
;        }
;        else
;        {
;          MaxSampleNumber = AnalysisInterval/2
;        }
;      }
;    }
;    else
;    {
;      MaxSampleNumber = AnalysisInterval/2
;    }


;    Определение номера максимального отсчета ( где искать Max )
;    if (( Mode == PRESSURE_MEASUREMENT )||( Mode == CHECK_HIGHER_SISTOL_PRESSURE))
;    {

	LACC	Mode
	SUB	#PRESSURE_MEASUREMENT
	BCND	ADC_v_impulse_not_in_center,EQ
	LACC    Mode
	SUB     #CHECK_HIGHER_SISTOL_PRESSURE
	BCND	ADC_v_impulse_in_center,NEQ

ADC_v_impulse_not_in_center:

;      if ((MeasurementFlags & (1<<FIRST_IMPULSE_FLAG)) == 0)

       	BIT	MeasurementFlags,15-FIRST_IMPULSE_FLAG
	BCND	ADC_v_first_impulse,TC

;      {
;        if ( AveragePeriodEvaluation => FIRST_THRESHOLD_OF_INTERVAL )

	LACC	AveragePeriodEvaluation
	SUB	#FIRST_THRESHOLD_OF_INTERVAL
	BCND	ADC_v_impulse_in_center,LT

;        {
;          if ( AveragePeriodEvaluation <= SECOND_THRESHOLD_OF_INTERVAL )

	LACC	AveragePeriodEvaluation
	SUB	#SECOND_THRESHOLD_OF_INTERVAL
	BCND	ADC_v_impl_30_to_end,GT

;          {
;            MaxSampleNumber = MIN_INTERVAL_TO_VERGE

      	SPLK	#MIN_INTERVAL_TO_VERGE,MaxSampleNumber
	B	ADC_v_impulse_plase_finish

;          }

ADC_v_impl_30_to_end:

;          else
;          {
;            MaxSampleNumber = AnalysisInterval * 0.31

	LACC    AnalysisInterval,14
	ADD     AnalysisInterval,12
      	SACH	MaxSampleNumber,0
	B	ADC_v_impulse_plase_finish

;          }
;        }
;        else
;        {
;          MaxSampleNumber = AnalysisInterval/2
;        }
;      }
;      }

ADC_v_first_impulse:

;      else
;      {
;        if (AveragePeriodEvaluation => FIRST_THRESHOLD_OF_INTERVAL)

	LACC	AveragePeriodEvaluation
	SUB	#FIRST_THRESHOLD_OF_INTERVAL
	BCND	ADC_v_impulse_in_center,LT

;        {
;          if (AveragePeriodEvaluation <= SECOND_THRESHOLD_OF_INTERVAL)

	LACC	AveragePeriodEvaluation
	SUB	#SECOND_THRESHOLD_OF_INTERVAL
	BCND	ADC_v_first_impl_30_to_end,GT

;          {
;            MaxSampleNumber = AnalysisInterval - MIN_INTERVAL_TO_VERGE

	LACC    AnalysisInterval,0
	SUB     #MIN_INTERVAL_TO_VERGE
      	SACH	MaxSampleNumber,0
	B	ADC_v_impulse_plase_finish

;          }

ADC_v_first_impl_30_to_end:

;          else
;          {
;            MaxSampleNumber = AnalysisInterval * 0.69

	LACC    AnalysisInterval,15
	ADD     AnalysisInterval,14
	SUB     AnalysisInterval,12
      	SACH	MaxSampleNumber,0
	B	ADC_v_impulse_plase_finish

;          }
;        }
;        else
;        {
;          MaxSampleNumber = AnalysisInterval/2
;        }
;    }

ADC_v_impulse_in_center:

;    else
;    {
;      MaxSampleNumber = AnalysisInterval/2

      	LACC	AnalysisInterval,0
	SFR
      	SACL	MaxSampleNumber

;    }
ADC_v_impulse_plase_finish:

;    for ( i=SampleNumber ; i > (SampleNumber - AnalysisInterval) ; i-- )

        LACC    SampleNumber,0
        ADD     #Signal,0
        SACL    SignalSampleNumber      ; & SignalSampleNumber
        LAR     AR1,SignalSampleNumber  ; AR1 = & Signal[SampleNumber]
        SUB     #DIFF_BASIS
        SACL    SignalSampleNumber
        LAR     AR2,SignalSampleNumber  ; AR2 = & Signal[SampleNumber-DIFF_BASIS]
	LAR	AR0,AnalysisInterval
	MAR	*,AR3

	 .if SIM != 0
	SPLK	#1,TMP+7
	.endif

;    {
;      Temp0 = 0;
;      for ( k=0; k<8; k++ )

ADC_v_for_i1
	SAR	AR1,SignalSampleNumber
        LAR     AR3,SignalSampleNumber  ; & Signal[i-k]
	SAR	AR2,SignalSampleNumber
        LAR     AR4,SignalSampleNumber 	; & Signal[i-k-DIFF_BASIS]

;      {
;      Temp0 = Temp0 + ((long int)(Signal[i-k]))*Win_blackman[k] -
;      		((long int)(Signal[i-k-DIFF_BASIS]))*Win_blackman[k];
;      }
;      DiffSignal = (int)(Temp0>>14);

        MAC  	WIN_BL,*-,AR3
	LACC 	#0
	RPT  	#2
	MAC 	WIN_BL+1,*-,AR3
	MAR	*,AR4
	RPT  	#3
	MAC 	WIN_BL_MINUS,*-,AR4
	MAR	*,AR3
	RPT  	#3
	MAC 	WIN_BL+4,*-,AR3
	MAR	*,AR4
	RPT  	#3
	MAC 	WIN_BL_MINUS+4,*-,AR4
	APAC
	SACH 	DiffSignal,2

	 .if SIM != 0
	BIT 	TMP+7,15
	BCND	SimDiffSignal,NTC
	SPLK	#0,TMP+7
        OUT     DiffSignal,0
SimDiffSignal:
	.endif


;      if ( DiffSignalMax < DiffSignal)

	LACC	DiffSignal,0
	SUB	DiffSignalMax,0
	BCND	ADC_v_for_i2,LEQ

;      {
;      	DiffSignalMax = DiffSignal;
;      	DiffMaxNumber = i;

	LACC	DiffSignal,0
	SACL    DiffSignalMax,0
	SAR	AR1,NumberOfMaxSample

;      }

ADC_v_for_i2

	MAR	*,AR1
	MAR	*-,AR2
	MAR	*-,AR0
	BANZ	ADC_v_for_i1,*-,AR3

;    }
;    DiffMaxNumber = SampleNumber - DiffMaxNumber;

	LACC    #Signal
	ADD	SampleNumber,0
	SUB 	NumberOfMaxSample,0
	SACL	DiffMaxNumber,0

;    /*  DiffMaxNumber = i ( сеpедина фpонта + HALF_OF_WIN) */
;    if ( DiffMaxNumber == MaxSampleNumber )

	LACC    MaxSampleNumber,0
	SUB	DiffMaxNumber,0
        BCND    ADC_MaxNotCenter,NEQ

;    {
;      DiffMaxFlag = True;

	LACC	MeasurementFlags
	OR	#(1<<DIFF_MAX_FLAG)
	SACL	MeasurementFlags

;      DiffSignalMax = MIN_NUMBER;

	SPLK	#MIN_NUMBER,DiffSignalMax

;      for ( i=SampleNumber - DiffMaxNumber;
;            i >= ( SampleNumber - DiffMaxNumber - DIFF_BASIS - 2 ); i-- )

	LAR	AR0,#DIFF_BASIS+1
        LAR     AR1,NumberOfMaxSample	; AR1 = & Signal[i]
	MAR	*,AR2
        LAR     AR2,NumberOfMaxSample
	SBRK	#DIFF_BASIS		; AR2 = & Signal[i-DIFF_BASIS]
	MAR	*,AR3
        LAR     AR3,NumberOfMaxSample
	SBRK	#DIFF_BASIS*4/3         ; AR3 = & Signal[i-DIFF_BASIS*4/3]
	MAR	*,AR4

;      {
;	DiffSignal = 0;
;	for ( k=0; k<8; k++ )

ADC_v_for_i3

	SAR	AR1,SignalSampleNumber
        LAR     AR4,SignalSampleNumber  ; & Signal[i-k]
	SAR	AR2,SignalSampleNumber
        LAR     AR5,SignalSampleNumber 	; & Signal[i-k-DIFF_BASIS]
	SAR	AR3,SignalSampleNumber
        LAR     AR6,SignalSampleNumber 	; & Signal[i-k-DIFF_BASIS*4/3]

;	{
;	  DiffSignal = DiffSignal + Signal[i-k]))*Win_blackman[k] -
;	  		4*Signal[i-k-DIFF_BASIS]))*Win_blackman[k] +
;	  		3*Signal[i-k-DIFF_BASIS*4/3]))*Win_blackman[k];
;	}

        MAC  	WIN_BL_025,*-,AR4
	LACC 	#0
	RPT  	#6
	MAC 	WIN_BL_025+1,*-,AR4
	MAR	*,AR5
	RPT  	#3
	MAC 	WIN_BL_MINUS,*-,AR5
	MAR	*,AR6
	RPT  	#7
	MAC 	WIN_BL_075,*-,AR6
	MAR	*,AR5
	RPT  	#3
	MAC 	WIN_BL_MINUS+4,*-,AR5
	APAC
	SACH 	DiffSignal,2

;	if ( DiffSignalMax < DiffSignal )

	LACC	DiffSignal,0
	SUB	DiffSignalMax,0
	BCND	ADC_v_for_i4,LEQ

;	{
;	  DiffSignalMax = DiffSignal;
;	  Diff2MaxAdress[MaxNumber] = i;

	LACC	DiffSignal,0
	SACL    DiffSignalMax,0
	SAR	AR1,NumberOfMaxSample

;	}

ADC_v_for_i4
	MAR	*,AR1
	MAR	*-,AR2
	MAR	*-,AR3
	MAR	*-,AR0
	BANZ	ADC_v_for_i3,*-,AR4

;      }
;	  Diff2MaxAdress[MaxNumber] = i (NumberOfMaxSample);

	LAR	AR0,MaxNumber
	LAR	AR4,#Diff2MaxAdress
	MAR	*0+,AR4			; в AR4 & Diff2MaxAdress[MaxNumber]
	LACC	NumberOfMaxSample,0     ; сохpанение значения
	SUB	#Signal
	SACL    *                       ; Diff2MaxAdress[MaxNumber]

;      Diff2Max[MaxNumber] = DiffSignalMax;

	LAR	AR4,#Diff2Max
	MAR	*0+,AR4                 ; в AR4 & Diff2Max[MaxNumber]
	LACC	DiffSignalMax,0         ; сохpанение значения
	SACL    *                       ; Diff2Max[MaxNumber]

	 .if SIM != 0
        OUT     DiffSignalMax,0
	NOP
	NOP
	NOP
        OUT     DiffSignalMax,1
	.endif

;      DiffSignalMax = MIN_NUMBER;

	SPLK	#MIN_NUMBER,DiffSignalMax

;      for ( i=Diff2MaxAdress[MaxNumber] - DIFF_BASIS + 4;
;            i >= ( Diff2MaxAdress[MaxNumber] - DIFF_BASIS - 4); i-- )

	LAR	AR0,#7
	LAR	AR4,NumberOfMaxSample
	SBRK	#DIFF_BASIS - 4
	MAR	*,AR5
	LAR	AR5,NumberOfMaxSample
	SBRK	#DIFF_BASIS*3/2 - 4
	MAR	*,AR6
	LAR	AR6,NumberOfMaxSample
	SBRK	#DIFF_BASIS*2 - 4
	MAR	*,AR4

;      {
;      	DiffSignal = Signal[i] - 2*Signal[i-DIFF_BASIS/2] + Signal[i-DIFF_BASIS];

ADC_v_for_i5
					; & Signal[i]
	LACC	*-,0,AR5     		; & Signal[i-DIFF_BASIS/2]
	SUB	*-,1,AR6                ; & Signal[i-DIFF_BASIS]
	ADD	*-,0,AR0                ; в AR0 счетчик цикла
	SACL	DiffSignal,0

;	if ( DiffSignalMax < DiffSignal )

	SUB	DiffSignalMax,0
	BCND	ADC_v_for_i6,LEQ

;	{
;	  DiffSignalMax = DiffSignal;
;	  SignalSampleNumber = i;

	LACC	DiffSignal,0
	SACL    DiffSignalMax,0
	SAR	AR4,SignalSampleNumber

;	}

ADC_v_for_i6

	BANZ	ADC_v_for_i5,*-,AR4

;      }
;	  Max2DiffAdress[0] = SignalSampleNumber - DIFF_BASIS/2 - 2;

	LAR	AR4,#Max2DiffAdress
	LACC	SignalSampleNumber
	SUB	#Signal+DIFF_BASIS/2 + 2 ; в AR4 & Max2DiffAdress[0]
	SACL	*,0,AR1

;	i = Diff2MaxAdress[MaxNumber];

	LAR	AR1,NumberOfMaxSample	; Diff2MaxAdress[MaxNumber]
	LAR	AR2,#MaxAvrPress

;        MaxAvrPress[0] = (Signal[i] + Signal[i+1] + Signal[i+2] + Signal[i+3])/4;

	LACC	*+,14,AR1  	; в AR1 & Signal[Diff2MaxAdress[MaxNumber]]
	ADD	*+,14,AR1
	ADD	*+,14,AR1
	ADD	*+,14,AR2       ; в AR2 & MaxAvrPress
	SACH    *,0,AR4

;	i = Max2DiffAdress[0] + 2;

	LACC	*               ; в AR4 & Max2DiffAdress[0]
	ADD	#Signal+2
	SACL    SignalSampleNumber
	LAR	AR4,SignalSampleNumber
	LAR	AR2,#MinAvrPress

;        MinAvrPress[0] = (Signal[i] + Signal[i+1] + Signal[i+2] + Signal[i+3])/4;

	LACC	*+,14,AR4       ; & Signal[Max2DiffAdress[0] + 2]
	ADD	*+,14,AR4
	ADD	*+,14,AR4
	ADD	*+,14,AR2     	; & MinAvrPress
	SACH    *,0,AR4

;       if ( MaxNumber > 0)
;       {

        LACC    MaxNumber,0
        BCND    ADC_v_MaxNum_zero,EQ

;        TempPeriod = Diff2MaxAdress[MaxNumber] - Diff2MaxAdress[MaxNumber-1];

	LAR	AR0,MaxNumber
	LAR	AR4,#Diff2MaxAdress
	MAR	*0+,AR4
        LACC    *-,16,AR4                ;В AR4 находится & Diff2MaxAdress[MaxNumber]
        SUB     *,16,AR1
        SACH    TempPeriod,0

;        TempPeriodDiff = TempPeriod - AveragePeriodEvaluation;

        SUB     AveragePeriodEvaluation,14
        SACH    TempPeriodDiff,0

;        Temp2PeriodDiff = TempPeriod - 2*AveragePeriodEvaluation;

        SUB     AveragePeriodEvaluation,14
        SACH    Temp2PeriodDiff,0

;        TempAmplitudeDiff = abs( Diff2Max[MaxNumber] - Diff2Max[MaxNumber-1]);

        LAR     AR1,#Diff2Max
        MAR     *0+,AR1
        LACC    *-,0,AR1
        SUB     *,0,AR1
        ABS
        SACL    TempAmplitudeDiff

;      }

ADC_v_MaxNum_zero

;      if ( MaxNumber == 0)

        LACC    MaxNumber
        BCND    ADC_v_MaxNum_not_zero,NEQ

;      {
;	if ( MaxNumberShift > 0)

        LACC    MaxNumberShift
        BCND    ADC_v_MaxNumShift_zero,EQ

;	{

        MAR     *,AR1
        LAR     AR0,MaxNumberShift
        LAR     AR1,#Diff2MaxAdressFinish - 1
        MAR     *0+,AR2
        LAR     AR0,MaxNumber
        LAR     AR2,#Diff2MaxAdress
        MAR     *0+,AR2

;	  TempPeriod = Diff2MaxAdress[MaxNumber] + SampleNumberShift -
;	  	       Diff2MaxAdressFinish[MaxNumberShift-1];

        LACC    *,0,AR1
        ADD     SampleNumberShift
        SUB     *
        SACL    TempPeriod

;	}

ADC_v_MaxNum_not_zero

;      }

ADC_v_MaxNumShift_zero

;    }

ADC_MaxNotCenter

;  } // условие if ( SampleNumber > AnalysisStart )

ADC_v_end_p

;}
	RET
