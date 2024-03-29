;&D
*************************************************************
* $Id: ADC_V_P5.ASM,v 1.7 2001-11-14 17:20:49 peter Exp $
*  ����� ��ࠡ�⪨ ���祭�� ADC -
*
*  void ADC_value_processing(){
*
*  �������� ��p������ � ���p� ��p�頥��� �㭪��.
*
*  � p����� �pאַ� ��p��樨
*
*     SampleNumber
*     MaxNumber
*     AnalysisStart
*     AnalysisInterval
*     AveragePeriodEvaluation
*     TempPeriod
*     TempPeriodDiff
*     TempAmplitudeDiff
*     Temporary1_L
*     Temporary1_H
*     Temporary2_L
*     Temporary2_H
*
*  � p����� ��ᢥ���� ��p��樨
*
*     Signal[]
*     DiffSignal[MAX_ANALYSIS_INTERVAL]
*     Diff2Max[MAX_NUMBER]
*     Diff2MaxAdress[MAX_NUMBER]
*     MaxAvrPress[3]
*     MinAvrPress[3]
*     Max2DiffAdress[0]
*
*
*  ����p ��pᨨ   ��� ���������   �p�稭�
*
*     1.0.0.        26.01.2000.
*     1.0.1.        21.04.2000.    ��������� ����p�⬠ ����p㦥��
*                                  � �業�� �������� �����ᮢ.
*     1.0.2.        25.04.2001.    ��������� ����p�⬠ ����p㦥��
*
****************************************************************
;
;#define	MAX_ANALYSIS_INTERVAL 200;
;
;void ADC_value_processing()
;{
;static int DiffSignal[MAX_ANALYSIS_INTERVAL];
;long int Win_blackman[8]={417,4233,16655,30465,30465,16655,4233,417};
;int DiffSignalMax,Diff2Signal;
;int i,k;
;long int Temp0;

;MAX_ANALYSIS_INTERVAL 	.set	200

;  �ᯮ�짮����� �祥� ����� TMP � ���㫥 ADC_value_processing

Diff2Signal             .equ   TMP
DiffSignalMax           .equ   TMP+1
SignalSampleNumber      .equ   TMP+2	; & SignalSampleNumber
NumberOfMaxSample       .equ   TMP+3
DiffMaxNumber           .equ   TMP+4
MaxSampleNumber         .equ   TMP+5

MIN_INTERVAL_TO_VERGE			.equ	25
FIRST_THRESHOLD_OF_INTERVAL        	.equ    65*4
SECOND_THRESHOLD_OF_INTERVAL        	.equ    80*4

        .text

*              ;����樥��� ����

WIN_BL  	.word	417, 4233, 16655, 30465, 30465, 16655, 4233, 417
WIN_BL_MINUS  	.word  -417,-4233,-16655,-30465,-30465,-16655,-4233,-417
WIN_BL_075  	.word	313, 3175, 12491, 22849, 22849, 12491, 3175, 313
WIN_BL_025  	.word	104, 1058,  4164,  7616,  7616,  4164, 1058, 104

ADC_value_processing:

        SETC    SXM            ;!!!!!!!!!!!!!!!!!!!!!!!!!
        SPM     #0             ;!!!!!!!!!!!!!!!!!!!!!!!!!

;  DiffMaxFlag = False;

	LACC	_MeasurementFlags
	AND	#~(1<<DIFF_MAX_FLAG)
	SACL	_MeasurementFlags

;  if ( SampleNumber > DIFF_BASIS*2 )

        LACC    _SampleNumber,0
        SUB     #DIFF_BASIS*2
        BCND    ADC_v_end_p,LEQ

;  { /* ���� ���ᨬ㬠 �� ���ࢠ�� ANALYSIS_INTERVAL */ // DIFF_BASIS=12 �� Fs=100��
;    // ��।������ ����� ���ᨬ��쭮�� ����� ( ��� �᪠�� Max )
;    if (( Mode == PRESSURE_MEASUREMENT )||( Mode == CHECK_HIGHER_SISTOL_PRESSURE))
;    {

	LACC	_Mode
	SUB	#PRESSURE_MEASUREMENT
	BCND	ADC_v_impulse_not_in_center,EQ
	LACC    _Mode
	SUB     #CHECK_HIGHER_SISTOL_PRESSURE
	BCND	ADC_v_impulse_in_center,NEQ

ADC_v_impulse_not_in_center:

;      if ((MeasurementFlags & (1<<FIRST_IMPULSE_FLAG)) == 0)

       	BIT	_MeasurementFlags,15-FIRST_IMPULSE_FLAG
	BCND	ADC_v_first_impulse,TC

;      {
;        if ( AveragePeriodEvaluation => FIRST_THRESHOLD_OF_INTERVAL )

	LACC	_AveragePeriodEvaluation
	SUB	#FIRST_THRESHOLD_OF_INTERVAL
	BCND	ADC_v_impulse_in_center,LT

;        {
;          if ( AveragePeriodEvaluation <= SECOND_THRESHOLD_OF_INTERVAL )

	LACC	_AveragePeriodEvaluation
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

	LACC    _AnalysisInterval,14
	ADD     _AnalysisInterval,12
      	SACH	MaxSampleNumber,0
	B	ADC_v_impulse_plase_finish

;          }
;        }
;        else
;        {
;          MaxSampleNumber = AnalysisInterval/2
;        }
;      }

ADC_v_first_impulse:

;      else
;      {
;        if (AveragePeriodEvaluation => FIRST_THRESHOLD_OF_INTERVAL)

	LACC	_AveragePeriodEvaluation
	SUB	#FIRST_THRESHOLD_OF_INTERVAL
	BCND	ADC_v_impulse_in_center,LT

;        {
;          if (AveragePeriodEvaluation <= SECOND_THRESHOLD_OF_INTERVAL)

	LACC	_AveragePeriodEvaluation
	SUB	#SECOND_THRESHOLD_OF_INTERVAL
	BCND	ADC_v_first_impl_30_to_end,GT

;          {
;            MaxSampleNumber = AnalysisInterval - MIN_INTERVAL_TO_VERGE

	LACC    _AnalysisInterval,0
	SUB     #MIN_INTERVAL_TO_VERGE
      	SACL	MaxSampleNumber,0
	B	ADC_v_impulse_plase_finish

;          }

ADC_v_first_impl_30_to_end:

;          else
;          {
;            MaxSampleNumber = AnalysisInterval * 0.69

	LACC    _AnalysisInterval,15
	ADD     _AnalysisInterval,14
	SUB     _AnalysisInterval,12
      	SACH	MaxSampleNumber,0
	B	ADC_v_impulse_plase_finish

;          }
;        }
;        else
;        {
;          MaxSampleNumber = AnalysisInterval/2
;        }
;      }
;    }

ADC_v_impulse_in_center:

;    else
;    {
;      MaxSampleNumber = AnalysisInterval/2

      	LACC	_AnalysisInterval,0
	SFR
      	SACL	MaxSampleNumber

;    }
ADC_v_impulse_plase_finish:

;    // ���᫥��� ������ ����� ᮣ��ᮢ������ 䨫���
;    for ( i=MAX_ANALYSIS_INTERVAL; i > 0; i-- )
;    {
;      DiffSignal[i] = DiffSignal[i-1];
;    }

	MAR	*,AR2
	LAR	AR2,#DiffSignal+MAX_ANALYSIS_INTERVAL-2
	RPT	#MAX_ANALYSIS_INTERVAL-2
	DMOV    *-,AR2

;    Temp0 = 0;
;    for ( k=0; k<8; k++ )
;    {
;      Temp0 = Temp0 +
;        ((long int)(Signal[SampleNumber-k]))*Win_blackman[k] -
;        ((long int)(Signal[SampleNumber-k-DIFF_BASIS]))*Win_blackman[k];
;    }
;    DiffSignal[0] = (int)(Temp0>>14);

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
	SACH 	*,2,AR2

	 .if SIM != 0
        OUT     *,0
	.endif

;    if ( SampleNumber > AnalysisStart )
;    {

        LACC    _SampleNumber,0
        SUB     _AnalysisStart,0
        BCND    ADC_v_SN_less_AS,LEQ

;      // ���� ���ᨬ㬠 � DiffSignal �� ���ࢠ�� AnalysisInterval
;      DiffSignalMax = MIN_NUMBER;
;      for ( i=AnalysisInterval; i > 0; i-- )
;      {
;        if ( DiffSignalMax < DiffSignal[i])
;        {
;      	   DiffSignalMax = DiffSignal[i];
;      	   DiffMaxNumber = i;
;        }
;      }

	SPLK	#MIN_NUMBER,DiffSignalMax
	LAR	AR0,_AnalysisInterval
ADC_v_for_i1:
	LACC	*,0,AR2
	SUB	DiffSignalMax,0
	BCND	ADC_v_for_i2,LEQ
	LACC	*,0,AR2
	SACL    DiffSignalMax,0
	SAR	AR0,DiffMaxNumber       ; ����� ����� ��
ADC_v_for_i2                           	; ��砫� ���ࢠ��
	MAR	*+,AR0
	BANZ	ADC_v_for_i1,*-,AR2

;      /*  DiffMaxNumber = i ( �p����� �p��� + HALF_OF_WIN) */

	LACC 	_AnalysisInterval,0
	SUB     DiffMaxNumber,0         ; ����� ����� ��
	SACL    DiffMaxNumber,0         ; ���� ���ࢠ��

;      if ( DiffMaxNumber == MaxSampleNumber )

	LACC    MaxSampleNumber,0
	SUB	DiffMaxNumber,0
        BCND    ADC_MaxNotCenter,NEQ

;      { // ���ᨬ� ����. ��稭��� ������
;        DiffMaxFlag = True;

	LACC	_MeasurementFlags
	OR	#(1<<DIFF_MAX_FLAG)
	SACL	_MeasurementFlags

;        DiffSignalMax = MIN_NUMBER;

	SPLK	#MIN_NUMBER,DiffSignalMax

;        for ( i=SampleNumber - DiffMaxNumber;
;              i >= ( SampleNumber - DiffMaxNumber - DIFF_BASIS - 2 ); i-- )

	LACC    #Signal
	ADD	_SampleNumber
	SUB     DiffMaxNumber
	SACL	SignalSampleNumber
	LAR	AR0,#DIFF_BASIS+1
        LAR     AR2,SignalSampleNumber	; AR2 = & Signal[i]
	SUB	#DIFF_BASIS
	SACL	SignalSampleNumber
        LAR     AR3,SignalSampleNumber  ; AR3 = & Signal[i-DIFF_BASIS]
	SUB	#DIFF_BASIS*1/3
	SACL	SignalSampleNumber
        LAR     AR4,SignalSampleNumber  ; AR4 = & Signal[i-DIFF_BASIS*4/3]
	MAR	*,AR5

;        {
;          Diff2Signal = 0;
;          for ( k=0; k<8; k++ )

ADC_v_for_i3

	SAR	AR2,SignalSampleNumber
        LAR     AR5,SignalSampleNumber  ; & Signal[i-k]
	SAR	AR3,SignalSampleNumber
        LAR     AR6,SignalSampleNumber 	; & Signal[i-k-DIFF_BASIS]
	SAR	AR4,SignalSampleNumber
        LAR     AR7,SignalSampleNumber 	; & Signal[i-k-DIFF_BASIS*4/3]

;          {
;            Diff2Signal = Diff2Signal + Signal[i-k]))*Win_blackman[k] -
;                          4*Signal[i-k-DIFF_BASIS]))*Win_blackman[k] +
;                          3*Signal[i-k-DIFF_BASIS*4/3]))*Win_blackman[k];
;          }

        MAC  	WIN_BL_025,*-,AR5
	LACC 	#0
	RPT  	#6
	MAC 	WIN_BL_025+1,*-,AR5
	MAR	*,AR6
	RPT  	#3
	MAC 	WIN_BL_MINUS,*-,AR6
	MAR	*,AR7
	RPT  	#7
	MAC 	WIN_BL_075,*-,AR7
	MAR	*,AR6
	RPT  	#3
	MAC 	WIN_BL_MINUS+4,*-,AR6
	APAC
	SACH 	Diff2Signal,2

;          if ( DiffSignalMax < Diff2Signal )

	LACC	Diff2Signal,0
	SUB	DiffSignalMax,0
	BCND	ADC_v_for_i4,LEQ

;          {
;            DiffSignalMax = Diff2Signal;
;            Diff2MaxAdress[MaxNumber] = i;

	LACC	Diff2Signal,0
	SACL    DiffSignalMax,0
	SAR	AR2,NumberOfMaxSample

;          }

ADC_v_for_i4
	MAR	*,AR2
	MAR	*-,AR3
	MAR	*-,AR4
	MAR	*-,AR0
	BANZ	ADC_v_for_i3,*-,AR5

;        }
;        Diff2MaxAdress[MaxNumber] = i (NumberOfMaxSample);

	LAR	AR0,_MaxNumber
	LAR	AR5,#Diff2MaxAdress
	MAR	*0+,AR5			; � AR5 & Diff2MaxAdress[MaxNumber]
	LACC	NumberOfMaxSample,0     ; ��p������ ���祭�
	SUB	#Signal
	SACL    *                       ; Diff2MaxAdress[MaxNumber]

;        Diff2Max[MaxNumber] = DiffSignalMax;

	LAR	AR5,#Diff2Max
	MAR	*0+,AR5                 ; � AR5 & Diff2Max[MaxNumber]
	LACC	DiffSignalMax,0         ; ��p������ ���祭�
	SACL    *                       ; Diff2Max[MaxNumber]

	 .if SIM != 0
        OUT     DiffSignalMax,1         ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	.endif

;        //���� �窨 ��� �७��.
;        DiffSignalMax = MIN_NUMBER;

	SPLK	#MIN_NUMBER,DiffSignalMax

;        for ( i=Diff2MaxAdress[MaxNumber] - DIFF_BASIS + 4;
;              i >= ( Diff2MaxAdress[MaxNumber] - DIFF_BASIS - 4); i-- )

	LAR	AR0,#7
	LAR	AR5,NumberOfMaxSample
	SBRK	#DIFF_BASIS - 4
	MAR	*,AR6
	LAR	AR6,NumberOfMaxSample
	SBRK	#DIFF_BASIS*3/2 - 4
	MAR	*,AR7
	LAR	AR7,NumberOfMaxSample
	SBRK	#DIFF_BASIS*2 - 4
	MAR	*,AR5

;        {
;          Diff2Signal = Signal[i] - 2*Signal[i-DIFF_BASIS/2] + Signal[i-DIFF_BASIS];

ADC_v_for_i5
					; & Signal[i]
	LACC	*-,0,AR6     		; & Signal[i-DIFF_BASIS/2]
	SUB	*-,1,AR7                ; & Signal[i-DIFF_BASIS]
	ADD	*-,0,AR0                ; � AR0 ���稪 横��
	SACL	Diff2Signal,0

;          if ( DiffSignalMax < Diff2Signal )

	SUB	DiffSignalMax,0
	BCND	ADC_v_for_i6,LEQ

;          {
;            DiffSignalMax = Diff2Signal;
;            SignalSampleNumber = i;

	LACC	Diff2Signal,0
	SACL    DiffSignalMax,0
	SAR	AR5,SignalSampleNumber

;          }

ADC_v_for_i6

	BANZ	ADC_v_for_i5,*-,AR5

;        }

;        // Calculate StartTrendPointer
;        Max2DiffAdress[0] = SignalSampleNumber - DIFF_BASIS/2 - 2;

	LAR	AR5,#_Max2DiffAdress
	LACC	SignalSampleNumber
	SUB	#Signal+DIFF_BASIS/2 + 2 ; � AR5 & Max2DiffAdress[0]
	SACL	*,0,AR2

;        // Calculate average pressure this MAX.
;        i = Diff2MaxAdress[MaxNumber];

	LAR	AR2,NumberOfMaxSample	; Diff2MaxAdress[MaxNumber]
	LAR	AR3,#MaxAvrPress

;        MaxAvrPress[0] = (Signal[i] + Signal[i+1] + Signal[i+2] + Signal[i+3])/4;

	LACC	*+,14,AR2  	; � AR2 & Signal[Diff2MaxAdress[MaxNumber]]
	ADD	*+,14,AR2
	ADD	*+,14,AR2
	ADD	*+,14,AR3       ; � AR3 & MaxAvrPress
	SACH    *,0,AR5

;        i = Max2DiffAdress[0] + 2;

	LACC	*               ; � AR5 & Max2DiffAdress[0]
	ADD	#Signal+2
	SACL    SignalSampleNumber
	LAR	AR5,SignalSampleNumber
	LAR	AR3,#MinAvrPress

;        MinAvrPress[0] = (Signal[i] + Signal[i+1] + Signal[i+2] + Signal[i+3])/4;

	LACC	*+,14,AR5       ; & Signal[Max2DiffAdress[0] + 2]
	ADD	*+,14,AR5
	ADD	*+,14,AR5
	ADD	*+,14,AR3     	; & MinAvrPress
	SACH    *,0,AR5

;        // Temporary calculation
;        if ( MaxNumber > 0)
;        {

        LACC    _MaxNumber,0
        BCND    ADC_v_MaxNum_zero,EQ

;          TempPeriod = Diff2MaxAdress[MaxNumber] - Diff2MaxAdress[MaxNumber-1];

	LAR	AR0,_MaxNumber
	LAR	AR5,#Diff2MaxAdress
	MAR	*0+,AR5
        LACC    *-,16,AR5                ;� AR5 ��室���� & Diff2MaxAdress[MaxNumber]
        SUB     *,16,AR2
        SACH    _TempPeriod,0

;          TempPeriodDiff = TempPeriod - AveragePeriodEvaluation/4;

        SUB     _AveragePeriodEvaluation,14
        SACH    _TempPeriodDiff,0

;          TempAmplitudeDiff = abs( Diff2Max[MaxNumber] - Diff2Max[MaxNumber-1]);

        LAR     AR2,#Diff2Max
        MAR     *0+,AR2
        LACC    *-,0,AR2
        SUB     *,0,AR2
        ABS
        SACL    _TempAmplitudeDiff

;        }

ADC_v_MaxNum_zero

;        if ( MaxNumber == 0)

        LACC    _MaxNumber
        BCND    ADC_v_MaxNum_not_zero,NEQ

;        {
;          if ( MaxNumberShift > 0)

        LACC    _MaxNumberShift
        BCND    ADC_v_MaxNumShift_zero,EQ

;          {

        MAR     *,AR2
        LAR     AR0,_MaxNumberShift
        LAR     AR2,#Diff2MaxAdressFinish - 1
        MAR     *0+,AR3
        LAR     AR0,_MaxNumber
        LAR     AR3,#Diff2MaxAdress
        MAR     *0+,AR3

;            TempPeriod = Diff2MaxAdress[MaxNumber] + SampleNumberShift -
;                         Diff2MaxAdressFinish[MaxNumberShift-1];

        LACC    *,0,AR2
        ADD     _SampleNumberShift
        SUB     *
        SACL    _TempPeriod

;            TempAmplitudeDiff = abs( Diff2Max[MaxNumber] - LastDiff2Max );

        LAR     AR2,#Diff2Max
        MAR     *0+,AR2
	LACC	*,0,AR2
	SUB	LastDiff2Max,0
	ABS
	SACL	_TempAmplitudeDiff

;          }

ADC_v_MaxNum_not_zero

;        }

ADC_v_MaxNumShift_zero

;      }

ADC_MaxNotCenter

;    } // �᫮��� if ( SampleNumber > AnalysisStart )
ADC_v_SN_less_AS:

;  } // �᫮��� if ( SampleNumber > DIFF_BASIS*2 )
ADC_v_end_p

;}
	RET
