;&D
* $Id: PUL_F_E.ASM,v 1.11 2001-11-14 17:20:53 peter Exp $
;/***********************************************************
;*   Measurement_initialization
;***********************************************************/
;
; /* При инициализации процесса измерения */
; StartMeasAdress[StepNumber] = 0;
; SubroutMode = 0;
; MaxNumber = 0;                           // Номер максимума.
; StartMaxNumber = 0;
; MaxNumberShift = 0;
; StepNumber = 0;
; SampleNumber = 0;
; SampleNumberShift = 0;
; ErrMeas = 0;
; MaxAverageAmplitude = 0;
; SistolPressure = 0;
; DiastolPressure = 0;
; AnalysisInterval = 32*1.25;  // минимальный AnalysisInterval
; AnalysisStart = AnalysisInterval + 2*DIFF_BASIS;
; MeasurementFlags = MeasurementFlags &
;                 (~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)));
*
*   Макрос mMeasurement_init находится в файле BP206mac.asm
*
;
;/***********************************************************
;*   Pul_f_e.h
;***********************************************************/
;typedef	enum
;{
;  DIF_AMPLITUDE_10_COMPARISON,
;  DIF_AMPLITUDE_21_COMPARISON,
;  DIF_AMPLITUDE_20_COMPARISON,
;  INTERVALE_COMPARISON,
;  SYNCHRONIZATION_IS,
;  INTERVALE_IS_MORE_MAX
;} ENUM_FLAGS_WORD;

DIF_AMPLITUDE_10_COMPARISON	.set	0
DIF_AMPLITUDE_21_COMPARISON     .set	1
DIF_AMPLITUDE_20_COMPARISON     .set	2
INTERVALE_COMPARISON            .set	3
SYNCHRONIZATION_IS		.set	4
INTERVALE_IS_MORE_MAX           .set	5

;
;typedef	enum
;{
;  AMPLITUDE_10_COMPARISON,
;  AMPLITUDE_21_COMPARISON,
;  AMPLITUDE_20_COMPARISON
;} ENUM_FLAGS_WORD_2;

AMPLITUDE_10_COMPARISON         .set	0
AMPLITUDE_21_COMPARISON         .set	1
AMPLITUDE_20_COMPARISON         .set	2

;
;typedef	enum
;{
;  ALL_IMPULSE_IS_GOOD,
;  FIRST_IMPULSE_IS_BAD,
;  SECOND_IMPULSE_IS_BAD,
;  THIRD_IMPULSE_IS_BAD,
;  FIRST_IMPULSE_IS_GOOD,
;  SECOND_IMPULSE_IS_GOOD,
;  THIRD_IMPULSE_IS_GOOD,
;  ALL_IMPULSE_IS_BAD
;} ENUM_POINTER_TO_OPERATION;

ALL_IMPULSE_IS_GOOD             .set	0
FIRST_IMPULSE_IS_BAD            .set	1
SECOND_IMPULSE_IS_BAD           .set	2
THIRD_IMPULSE_IS_BAD            .set	3
FIRST_IMPULSE_IS_GOOD           .set	4
SECOND_IMPULSE_IS_GOOD          .set	5
THIRD_IMPULSE_IS_GOOD           .set	6
ALL_IMPULSE_IS_BAD              .set	7

;
;
;/***********************************************************
;*    Pulse frequency evaluation(AmplitudeThreshold)
;*    AmplitudeThreshold - параметр передаваемый в
;*                         аккомуляторе
;***********************************************************/
;void Pulse_frequency_evaluation(AmplitudeThreshold)
;{
;ENUM_POINTER_TO_OPERATION  	PointerToOperation;
;int 				FlagsWord
;int 				FlagsWord2

PointerToOperation	.equ	TMP+0
FlagsWord               .equ	TMP+1
FlagsWord2              .equ	TMP+2
AmplitudeThreshold	.equ	TMP+3
TmpAmplitude		.equ	TMP+4
NUMBER_IS_USED_TMP      .set	5

Pulse_frequency_evaluation:

	MAR	*,AR1
	POPD    *+,AR1
	SAR	AR0,*+,AR2
	SETC	SXM

	SACL	AmplitudeThreshold,0

; switch ( MaxNumber - StartMaxNumber )

	LACC	_MaxNumber,0
	SUB	_StartMaxNumber,0
	BCND    Pulse_MN_01,EQ
	SUB	#1
	BCND	Pulse_check_MN_2,NEQ

Pulse_MN_01:
;  {
;    case 0:
;    case 1:
;       mIncrement_max_number();
;       mArrays_are_shifted();
;       break;

	mIncrement_max_number
        mArrays_are_shifted
	B	Pulse_quit

Pulse_check_MN_2:
	SUB	#1
	BCND	Pulse_code_error,NEQ

;    case 2:
;       MeasurementFlags = MeasurementFlags &
;                       (~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)));
;       CodeError = 0;
;       FlagsWord = 0;
;       FlagsWord2 = 0;

	LACC    _MeasurementFlags
	AND	#(~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)))
	SACL	_MeasurementFlags
	LACL    #0
        SACL	_CodeError,0
	SACL    FlagsWord,0
	SACL    FlagsWord2,0
	LAR	AR0,_MaxNumber
	LAR	AR2,#Diff2Max-1
	MAR	*0+,AR2
;
;       if ( abs( Diff2Max[MaxNumber-1] - Diff2Max[MaxNumber-2]) <
;            AmplitudeThreshold*
;          ( Diff2Max[MaxNumber-1]+Diff2Max[MaxNumber-2])/2)
;          FlagsWord = FlagsWord |(1<<DIF_AMPLITUDE_10_COMPARISON);

	LACC	*-,15,AR2
	ADD	*+,15,AR2
	SACH	TmpAmplitude,0
	LACC	*-,13,AR2
	SUB	*+,13,AR2
	ABS
	LT	TmpAmplitude
	MPY	AmplitudeThreshold
	SPAC
	BCND    Pulse_1_comparison_end,GT
	LACC	FlagsWord,0
	OR	#1<<DIF_AMPLITUDE_10_COMPARISON
	SACL	FlagsWord,0
Pulse_1_comparison_end:

;       if ( abs( Diff2Max[MaxNumber] - Diff2Max[MaxNumber-1]) <
;            AmplitudeThreshold*
;          ( Diff2Max[MaxNumber] + Diff2Max[MaxNumber-1)/2)
;          FlagsWord = FlagsWord |(1<<DIF_AMPLITUDE_21_COMPARISON);

	LACC	*+,15,AR2
	ADD	*,15,AR2
	SACH	TmpAmplitude,0
	LACC	*-,13,AR2
	SUB	*-,13,AR2
	ABS
	LT	TmpAmplitude
	MPY	AmplitudeThreshold
	SPAC
	BCND    Pulse_2_comparison_end,GT
	LACC	FlagsWord,0
	OR	#1<<DIF_AMPLITUDE_21_COMPARISON
	SACL	FlagsWord,0
Pulse_2_comparison_end:

;       if ( abs( Diff2Max[MaxNumber] - Diff2Max[MaxNumber-2]) <
;            AmplitudeThreshold*
;          ( Diff2Max[MaxNumber] + Diff2Max[MaxNumber-2])/2)
;          FlagsWord = FlagsWord |(1<<DIF_AMPLITUDE_20_COMPARISON);

	LACC	*+,15,AR2
	MAR	*+,AR2
	ADD	*,15,AR2
	SACH	TmpAmplitude,0
	LACC	*-,13,AR2
	MAR	*-,AR2
	SUB	*,13,AR2
	ABS
	LT	TmpAmplitude
	MPY	AmplitudeThreshold
	SPAC
	BCND    Pulse_3_comparison_end,GT
	LACC	FlagsWord,0
	OR	#1<<DIF_AMPLITUDE_20_COMPARISON
	SACL	FlagsWord,0
Pulse_3_comparison_end:

;       if (abs(( Diff2MaxAdress[MaxNumber]-2*Diff2MaxAdress[MaxNumber-1]+
;                 Diff2MaxAdress[MaxNumber-2]))<
;               ( Diff2MaxAdress[MaxNumber]-Diff2MaxAdress[MaxNumber-2])*0.33/2)
;       {
;         FlagsWord = FlagsWord |(1<<INTERVALE_COMPARISON);
;       }
;       else
;       {
;         MeasurementFlags = MeasurementFlags & (~(1<<SYNCHRO_FLAG_WAS));
;       }

	LAR	AR2,#Diff2MaxAdress
	MAR	*0+,AR2
	LT	*,AR2                   ; Diff2MaxAdress[MaxNumber]
	MPY	#CONST_0_33
	LACC    *-,14,AR2         	; в сдвиге учтено *0.33/2
	SUB	*-,15,AR2               ; в сдвиге учтено *0.33/2
	ADD     *,14,AR2                ; в сдвиге учтено *0.33/2
	ABS
	SPAC
	LT  	*+,AR2                  ; Diff2MaxAdress[MaxNumber-2]
	MPY	#CONST_0_33
	APAC
	BCND    Pulse_4_comparison_bad,GT
	LACC	FlagsWord,0
	OR	#1<<INTERVALE_COMPARISON
	SACL	FlagsWord,0
	B	Pulse_4_comparison_end
Pulse_4_comparison_bad:
	LACC	_MeasurementFlags,0
	AND	#(~(1<<SYNCHRO_FLAG_WAS))
	SACL    _MeasurementFlags,0
Pulse_4_comparison_end:

;       if ( MeasurementFlags & (1<<SYNCHRO_FLAG_WAS))
;       {
;         if ( abs(( Diff2MaxAdress[MaxNumber]-Diff2MaxAdress[MaxNumber-2])*4/2 -
;              AveragePeriodEvaluation ) < 0.25*AveragePeriodEvaluation )
;            FlagsWord = FlagsWord |(1<<SYNCHRONIZATION_IS);
;       }

	BIT	_MeasurementFlags,15-SYNCHRO_FLAG_WAS
	BCND    Pulse_41_comparison_end,NTC
	LAR	AR2,#Diff2MaxAdress
	MAR	*0+,AR2
	LACC    *-,15,AR2
	MAR	*-,AR2
	SUB	*-,15,AR2
	SUB	_AveragePeriodEvaluation,14
	ABS
	LT  	_AveragePeriodEvaluation
	MPY	#CONST_0_249
	SPAC
	BCND	Pulse_41_comparison_end,GEQ
	LACC	FlagsWord,0
	OR	#1<<SYNCHRONIZATION_IS
	SACL	FlagsWord,0
Pulse_41_comparison_end:

;
;       if (( Diff2MaxAdress[MaxNumber-1]-Diff2MaxAdress[MaxNumber-2])> MAX_DURATION)
;       {
;          FlagsWord = FlagsWord |(1<<INTERVALE_IS_MORE_MAX);
;          MeasurementFlags = MeasurementFlags & (~(1<<SYNCHRO_FLAG_WAS));
;       }
;       if (( Diff2MaxAdress[MaxNumber]-Diff2MaxAdress[MaxNumber-1])> MAX_DURATION)
;       {
;      	   FlagsWord = FlagsWord |(1<<INTERVALE_IS_MORE_MAX);
;          MeasurementFlags = MeasurementFlags & (~(1<<SYNCHRO_FLAG_WAS));
;       }

	LACC	*-,0,AR2                ; Diff2MaxAdress[MaxNumber-1]
	SUB	*+,0,AR2                ; Diff2MaxAdress[MaxNumber-2]
	SUB	#MAX_DURATION
	BCND    Pulse_5_comparison_end,LEQ
	LACC	FlagsWord,0
	OR	#1<<INTERVALE_IS_MORE_MAX
	SACL	FlagsWord,0
	LACC	_MeasurementFlags,0
	AND	#(~(1<<SYNCHRO_FLAG_WAS))
	SACL    _MeasurementFlags,0
Pulse_5_comparison_end:
	MAR	*+,AR2
	LACC	*-,0,AR2                ; Diff2MaxAdress[MaxNumber]
	SUB	*,0,AR2                 ; Diff2MaxAdress[MaxNumber-1]
	SUB	#MAX_DURATION
	BCND    Pulse_6_comparison_end,LEQ
	LACC	FlagsWord,0
	OR	#1<<INTERVALE_IS_MORE_MAX
	SACL	FlagsWord,0
	LACC	_MeasurementFlags,0
	AND	#(~(1<<SYNCHRO_FLAG_WAS))
	SACL    _MeasurementFlags,0
Pulse_6_comparison_end:
;
;       if ( Diff2Max[MaxNumber-1] > Diff2Max[MaxNumber-2])
;      	   FlagsWord2 = FlagsWord2 |(1<<AMPLITUDE_10_COMPARISON);
;       if ( Diff2Max[MaxNumber] > Diff2Max[MaxNumber-1])
;      	   FlagsWord2 = FlagsWord2 |(1<<AMPLITUDE_21_COMPARISON);
;       if ( Diff2Max[MaxNumber] > Diff2Max[MaxNumber-2])
;      	   FlagsWord2 = FlagsWord2 |(1<<AMPLITUDE_20_COMPARISON);

	LAR	AR2,#Diff2Max-2
	MAR	*0+,AR2
	LACC	*+,0,AR2
	SUB	*,0,AR2
	BCND    Pulse_7_comparison_end,GT
	LACC	FlagsWord2,0
	OR	#1<<AMPLITUDE_10_COMPARISON
	SACL	FlagsWord2,0
Pulse_7_comparison_end:
	LACC	*+,0,AR2
	SUB	*-,0,AR2
	BCND    Pulse_8_comparison_end,GT
	LACC	FlagsWord2,0
	OR	#1<<AMPLITUDE_21_COMPARISON
	SACL	FlagsWord2,0
Pulse_8_comparison_end:
	MAR	*-,AR2
	LACC	*+,0,AR2
	MAR	*+,AR2
	SUB	*,0,AR2
	BCND    Pulse_9_comparison_end,GT
	LACC	FlagsWord2,0
	OR	#1<<AMPLITUDE_20_COMPARISON
	SACL	FlagsWord2,0
Pulse_9_comparison_end:
;
;       if ( FlagsWord&(1<<INTERVALE_IS_MORE_MAX) ==0 )
;       {
;      	switch ( FlagsWord & 0x01F )

	BIT	FlagsWord,15-INTERVALE_IS_MORE_MAX
	BCND	Pulse_flags_word_switch_def,TC
	LACC	FlagsWord,1
	AND	#0Fh,1
	ADD	#Pulse_flags_word_switch
	BACC
Pulse_flags_word_switch:
	B	Pulse_flags_word_switch_00
	B	Pulse_flags_word_switch_01
	B	Pulse_flags_word_switch_02
	B	Pulse_flags_word_switch_03
	B	Pulse_flags_word_switch_04
	B	Pulse_flags_word_switch_05
	B	Pulse_flags_word_switch_06
	B	Pulse_flags_word_switch_07
	B	Pulse_flags_word_switch_08
	B	Pulse_flags_word_switch_09
	B	Pulse_flags_word_switch_0A
	B	Pulse_flags_word_switch_0B
	B	Pulse_flags_word_switch_0C
	B	Pulse_flags_word_switch_0D
	B	Pulse_flags_word_switch_0E
	B	Pulse_flags_word_switch_0F

;      	 {

Pulse_flags_word_switch_00:
Pulse_flags_word_switch_08:
;      	   case  0x00:  // Intervale is bad,comparisons is bad
;      	   case  0x08:  // All amplitude comparisons is bad
;      		 switch ( FlagsWord2 )

	LACC	#Pulse_flags_word2_switch1
	ADD	FlagsWord2,1
	BACC
Pulse_flags_word2_switch1:
	B	Pulse_flags_word2_switch1_00
	B	Pulse_flags_word2_switch1_01
	B	Pulse_flags_word2_switch1_02
	B	Pulse_flags_word2_switch1_03
	B	Pulse_flags_word2_switch1_04
	B	Pulse_flags_word2_switch1_05
	B	Pulse_flags_word2_switch1_06
	B	Pulse_flags_word2_switch1_07

;      		  {

Pulse_flags_word2_switch1_00:
Pulse_flags_word2_switch1_02:
;      		    case 0x00:      // Impulse 1>2, 2>3, 1>3.
;      		    case 0x02:      // Impulse 1>2, 2<3, 1>3.
;                        if (( FlagsWord&(1<<SYNCHRONIZATION_IS))== 0)
	BIT	FlagsWord,15-SYNCHRONIZATION_IS
	BCND    Pulse_flags_word_switch_08_1,TC

;                        {
;      		    	   PointerToOperation = FIRST_IMPULSE_IS_GOOD;
;                        }
	SPLK	#FIRST_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_08_1:
;                        else
;                        {
;      		    	   PointerToOperation = THIRD_IMPULSE_IS_GOOD;
;                        }
;      		    	 break;
	SPLK	#THIRD_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word2_switch1_01:
Pulse_flags_word2_switch1_05:
;      		    case 0x01:      // Impulse 1<2, 2>3, 1>3.
;      		    case 0x05:      // Impulse 1<2, 2>3, 1<3.
;                        if (( FlagsWord&(1<<SYNCHRONIZATION_IS))== 0)
	BIT	FlagsWord,15-SYNCHRONIZATION_IS
	BCND    Pulse_flags_word_switch_08_2,TC
;                        {
;      		    	    PointerToOperation = SECOND_IMPULSE_IS_GOOD;
;                        }
	SPLK	#SECOND_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_08_2:
;                        else
;                        {
;      		    	   PointerToOperation = THIRD_IMPULSE_IS_GOOD;
;                        }
;      		    	 break;
	SPLK	#THIRD_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word2_switch1_06:
Pulse_flags_word2_switch1_07:
;      		    case 0x07:      // Impulse 1<2, 2<3, 1<3.
;      		    case 0x06:      // Impulse 1>2, 2<3, 1<3.
;      		    	 PointerToOperation = THIRD_IMPULSE_IS_GOOD;
;      		    	 break;
	SPLK	#THIRD_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word2_switch1_03:
Pulse_flags_word2_switch1_04:
;      		    case 0x03:      // Impulse 1<2, 2<3, 1>3.impossible event
;      		    case 0x04:      // Impulse 1>2, 2>3, 1<3.impossible event
;      		    	 CodeError = SW_FLAGS_WORD2_ERROR;
	SPLK	#SW_FLAGS_WORD2_ERROR,_CodeError
	B	Pulse_poin_to_oper_switch

;      		  }
;      		 break;

Pulse_flags_word_switch_01:
;      	   case  0x01:  // Intervale is bad,first comparison is good
;      		 if (( FlagsWord2&(1<<AMPLITUDE_21_COMPARISON))== 0)
	BIT	FlagsWord2,15-AMPLITUDE_21_COMPARISON
	BCND    Pulse_flags_word_switch_01_,TC

;      		  {         // Impulse 1 > 2
;      		    PointerToOperation = THIRD_IMPULSE_IS_BAD;
;      		  }
	SPLK	#THIRD_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_01_:
;      		  else
;      		  {         // Impulse 2 > 1
;      		    PointerToOperation = THIRD_IMPULSE_IS_GOOD;
;      		  }
;      		 break;
	SPLK	#THIRD_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_02:
;      	   case  0x02:  // Intervale is bad,second comparison is good
;      		 if (( FlagsWord2&(1<<AMPLITUDE_10_COMPARISON))== 0)
	BIT	FlagsWord2,15-AMPLITUDE_10_COMPARISON
	BCND    Pulse_flags_word_switch_02_,TC

;      		  {         // Impulse 0 > 1
;      		    PointerToOperation = FIRST_IMPULSE_IS_GOOD;
;      		  }
	SPLK	#FIRST_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_02_:
;      		  else
;      		  {         // Impulse 1 > 0
;      		    PointerToOperation = FIRST_IMPULSE_IS_BAD;
;      		  }
;      		 break;
	SPLK	#FIRST_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_03:
;      	   case  0x03:  // Intervale is bad,first and second comparisons is good
;      		 if (( FlagsWord2&(1<<AMPLITUDE_20_COMPARISON))== 0)
	BIT	FlagsWord2,15-AMPLITUDE_20_COMPARISON
	BCND    Pulse_flags_word_switch_03_,TC

;      		  {         // Impulse 0 > 2
;      		    PointerToOperation = THIRD_IMPULSE_IS_BAD;
;      		  }
	SPLK	#THIRD_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_03_:
;      		  else
;      		  {         // Impulse 2 > 0
;      		    PointerToOperation = FIRST_IMPULSE_IS_BAD;
;      		  }
;      		 break;
	SPLK	#FIRST_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_04:
;      	   case  0x04:  // Intervale is bad,third comparison is good
;      		 if (( FlagsWord2&(1<<AMPLITUDE_21_COMPARISON))== 0)
	BIT	FlagsWord2,15-AMPLITUDE_21_COMPARISON
	BCND    Pulse_flags_word_switch_04_,TC

;      		  {         // Impulse 1 > 2
;      		    PointerToOperation = SECOND_IMPULSE_IS_GOOD;
;      		  }
	SPLK	#SECOND_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_04_:
;      		  else
;      		  {         // Impulse 2 > 1
;      		    PointerToOperation = SECOND_IMPULSE_IS_BAD;
;      		  }
;      		 break;
	SPLK	#SECOND_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_05:
;      	   case  0x05:  // Intervale is bad,first and third comparisons is good
;      		 if (( FlagsWord2&(1<<AMPLITUDE_21_COMPARISON))== 0)
	BIT	FlagsWord2,15-AMPLITUDE_21_COMPARISON
	BCND    Pulse_flags_word_switch_05_,TC

;      		  {         // Impulse 1 > 2
;      		    PointerToOperation = THIRD_IMPULSE_IS_BAD;
;      		  }
	SPLK	#THIRD_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_05_:
;      		  else
;      		  {         // Impulse 2 > 1
;      		    PointerToOperation = SECOND_IMPULSE_IS_BAD;
;      		  }
;      	 	 break;
	SPLK	#SECOND_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_06:
;      	   case  0x06:  // Intervale is bad,second and third comparisons is good
;      		 if (( FlagsWord2&(1<<AMPLITUDE_10_COMPARISON))== 0)
	BIT	FlagsWord2,15-AMPLITUDE_10_COMPARISON
	BCND    Pulse_flags_word_switch_06_,TC

;      		  {         // Impulse 0 > 1
;      		    PointerToOperation = SECOND_IMPULSE_IS_BAD;
;      		  }
	SPLK	#SECOND_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_06_:
;      		  else
;      		  {         // Impulse 1 > 0
;      		    PointerToOperation = FIRST_IMPULSE_IS_BAD;
;      		  }
;      		 break;
	SPLK	#FIRST_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_07:
;      	   case  0x07:  // Intervale is bad,all comparisons is good
;      		 PointerToOperation = FIRST_IMPULSE_IS_BAD;
;      	 	 break;
	SPLK	#FIRST_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_09:
;      	   case  0x09:      // First amplitude comparison is good
;                if (( FlagsWord&(1<<SYNCHRONIZATION_IS))== 0)
;                {
;      		   if (( FlagsWord2&(1<<AMPLITUDE_21_COMPARISON))== 0)
	BIT	FlagsWord,15-SYNCHRONIZATION_IS
	BCND    Pulse_flags_word_switch_09_2,TC
	BIT	FlagsWord2,15-AMPLITUDE_21_COMPARISON
	BCND    Pulse_flags_word_switch_09_1,TC

;      		   {         // Impulse 1 > 2
;      		     PointerToOperation = THIRD_IMPULSE_IS_BAD;
;      		   }
	SPLK	#THIRD_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_09_1:
;      		   else
;      		   {         // Impulse 2 > 1
;      		     PointerToOperation = THIRD_IMPULSE_IS_GOOD;
;      		   }
;      		 }
;      		 break;
Pulse_flags_word_switch_09_2:
;                else
;      		 {
;      		   PointerToOperation = THIRD_IMPULSE_IS_GOOD;
;      		 }
;      		 break;
	SPLK	#THIRD_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_0A:
;      	   case  0x0A:      // Second amplitude comparison is good
;                if (( FlagsWord&(1<<SYNCHRONIZATION_IS))== 0)
;                {
;      		   if (( FlagsWord2&(1<<AMPLITUDE_10_COMPARISON))== 0)
	BIT	FlagsWord,15-SYNCHRONIZATION_IS
	BCND    Pulse_flags_word_switch_0A_2,TC
	BIT	FlagsWord2,15-AMPLITUDE_10_COMPARISON
	BCND    Pulse_flags_word_switch_0A_1,TC

;      		   {         // Impulse 0 > 1
;      		     PointerToOperation = FIRST_IMPULSE_IS_GOOD;
;      		   }
	SPLK	#FIRST_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_0A_1:
;      		   else
;      		   {         // Impulse 1 > 0
;      		     PointerToOperation = FIRST_IMPULSE_IS_BAD;
;      		   }
Pulse_flags_word_switch_0A_2:
;                else
;      		 {
;      		   PointerToOperation = FIRST_IMPULSE_IS_BAD;
;      		 }
;      		 break;
	SPLK	#FIRST_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_0B:
;      	   case  0x0B:      // Third amplitude comparison is bad
;     	   	 PointerToOperation = ALL_IMPULSE_IS_GOOD;
;      	 	 break;
	SPLK	#ALL_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_0C:
;      	   case  0x0C:      // Third amplitude comparison is good
;                if (( FlagsWord&(1<<SYNCHRONIZATION_IS))== 0)
;                {
;      		   if (( FlagsWord2&(1<<AMPLITUDE_21_COMPARISON))== 0)
	BIT	FlagsWord,15-SYNCHRONIZATION_IS
	BCND    Pulse_flags_word_switch_0C_2,TC
	BIT	FlagsWord2,15-AMPLITUDE_21_COMPARISON
	BCND    Pulse_flags_word_switch_0C_1,TC

;      		   {         // Impulse 1 > 2
;      		     PointerToOperation = SECOND_IMPULSE_IS_GOOD;
;      		   }
	SPLK	#SECOND_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_0C_1:
;      		   else
;      		   {         // Impulse 2 > 1
;      		     PointerToOperation = SECOND_IMPULSE_IS_BAD;
;      		   }
;      		 }
	SPLK	#SECOND_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_0C_2:
;      		 else
;      		 {
;      		   PointerToOperation = THIRD_IMPULSE_IS_GOOD;
;      		 }
;      		 break;
	SPLK	#THIRD_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_0D:
;      	   case  0x0D:      // Second amplitude comparison is bad
;                if (( FlagsWord&(1<<SYNCHRONIZATION_IS))== 0)
;                {
;      		   if (( FlagsWord2&(1<<AMPLITUDE_21_COMPARISON))== 0)
	BIT	FlagsWord,15-SYNCHRONIZATION_IS
	BCND    Pulse_flags_word_switch_0D_2,TC
	BIT	FlagsWord2,15-AMPLITUDE_21_COMPARISON
	BCND    Pulse_flags_word_switch_0D_1,TC

;      		   {         // Impulse 1 > 2
;      		     PointerToOperation = THIRD_IMPULSE_IS_BAD;
;      		   }
	SPLK	#THIRD_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_0D_1:
;      		   else
;      		   {         // Impulse 2 > 1
;      		     PointerToOperation = SECOND_IMPULSE_IS_BAD;
;      		   }
;      		 }
	SPLK	#SECOND_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_0D_2:
;      		 else
;      		 {
;      		   PointerToOperation = THIRD_IMPULSE_IS_GOOD;
;      		 }
;      		 break;
	SPLK	#THIRD_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_0E:
;      	   case  0x0E:      // First amplitude comparison is bad
;                if (( FlagsWord&(1<<SYNCHRONIZATION_IS))== 0)
;                {
;      		   if (( FlagsWord2&(1<<AMPLITUDE_10_COMPARISON))== 0)
	BIT	FlagsWord,15-SYNCHRONIZATION_IS
	BCND    Pulse_flags_word_switch_0E_2,TC
	BIT	FlagsWord2,15-AMPLITUDE_10_COMPARISON
	BCND    Pulse_flags_word_switch_0E_1,TC

;      		   {         // Impulse 0 > 1
;      		     PointerToOperation = SECOND_IMPULSE_IS_BAD;
;      		   }
	SPLK	#SECOND_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_0E_1:
;      		   else
;      		   {         // Impulse 1 > 0
;      		     PointerToOperation = FIRST_IMPULSE_IS_BAD;
;      		   }
;      		 }
Pulse_flags_word_switch_0E_2:
;                else
;      		 {
;      		   PointerToOperation = FIRST_IMPULSE_IS_BAD;
;      		 }
;      		 break;
	SPLK	#FIRST_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_0F:
;      	   case  0x0F:      // all is good
;     	   	 PointerToOperation = ALL_IMPULSE_IS_GOOD;
;      	 	 break;
	SPLK	#ALL_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

;      	  }
;      	}

Pulse_flags_word_switch_def:
;      	else
;      	{	            // Intervale is more max.
;      	  if (( Diff2MaxAdress[MaxNumber-1]-
;               Diff2MaxAdress[MaxNumber-2])>= MAX_DURATION)
	LAR	AR2,#Diff2MaxAdress-1
	MAR	*0+,AR2
	LACC	*-,0,AR2                ; Diff2MaxAdress[MaxNumber-1]
	SUB	*,0,AR2                 ; Diff2MaxAdress[MaxNumber-2]
	SUB	#MAX_DURATION
	BCND    Pulse_flags_word_switch_def_if,LT

;      	  { // Intervale 1 is more max.
;      	    PointerToOperation = FIRST_IMPULSE_IS_BAD;
;      	  }
	SPLK	#FIRST_IMPULSE_IS_BAD,PointerToOperation
	B	Pulse_poin_to_oper_switch

Pulse_flags_word_switch_def_if:
;      	  else
;      	  { // Intervale 2 is more max.
;      	    // Intervale 1 and 2 is more max.
;     	    PointerToOperation = THIRD_IMPULSE_IS_GOOD;
;         }
	SPLK	#THIRD_IMPULSE_IS_GOOD,PointerToOperation
	B	Pulse_poin_to_oper_switch

;      	}
;

Pulse_poin_to_oper_switch:
;       if ( CodeError == 0 )
;       {
	LACC	_CodeError,0
	BCND	Pulse_quit,NEQ

;         switch ( PointerToOperation )

	LACC	#Pulse_poin_to_oper_switch_case
	ADD	PointerToOperation,1
	BACC
Pulse_poin_to_oper_switch_case:
	B       Pulse_ALL_IMPULSE_IS_GOOD
	B       Pulse_FIRST_IMPULSE_IS_BAD
	B       Pulse_SECOND_IMPULSE_IS_BAD
	B       Pulse_THIRD_IMPULSE_IS_BAD
	B       Pulse_FIRST_IMPULSE_IS_GOOD
	B       Pulse_SECOND_IMPULSE_IS_GOOD
	B       Pulse_THIRD_IMPULSE_IS_GOOD
	B       Pulse_ALL_IMPULSE_IS_BAD

;          {

Pulse_ALL_IMPULSE_IS_GOOD:
;           case  ALL_IMPULSE_IS_GOOD:          // all is good
;                 AveragePeriodEvaluation = (Diff2MaxAdress[MaxNumber] -
;                              Diff2MaxAdress[MaxNumber-2])*4/2;
;                 LastDiff2Max = Diff2Max[MaxNumber];
;                 mIncrement_max_number();
;                 MeasurementFlags = MeasurementFlags |(1<<SYNCHRO_FLAG);
;                 break;
	LAR	AR2,#Diff2MaxAdress
	MAR	*0+,AR2
	LACC	*-,1,AR2
	MAR	*-,AR2
	SUB	*,1,AR2
	SACL	_AveragePeriodEvaluation,0
	LAR	AR2,#Diff2Max
	MAR	*0+,AR2
	LACC	*,0,AR2
	SACL	LastDiff2Max,0
	mIncrement_max_number
	LACC    _MeasurementFlags
	OR	#(1<<SYNCHRO_FLAG)
	SACL	_MeasurementFlags
	B	Pulse_quit

Pulse_FIRST_IMPULSE_IS_BAD:
;           case  FIRST_IMPULSE_IS_BAD:         // First impulse is bad
;                 Diff2Max[MaxNumber-2] = Diff2Max[MaxNumber-1];
;                 Diff2Max[MaxNumber-1] = Diff2Max[MaxNumber];
;                 Diff2MaxAdress[MaxNumber-2] = Diff2MaxAdress[MaxNumber-1];
;                 Diff2MaxAdress[MaxNumber-1] = Diff2MaxAdress[MaxNumber];
;                 mArrays_are_shifted();
;                 break;
	LAR	AR2,#Diff2Max-1
	MAR	*0+,AR2
	LACC	*-,0,AR2
	SACL    *+,0,AR2
	MAR	*+,AR2
	LACC	*-,0,AR2
	SACL    *,0,AR2
	LAR	AR2,#Diff2MaxAdress-1
	MAR	*0+,AR2
	LACC	*-,0,AR2
	SACL    *+,0,AR2
	MAR	*+,AR2
	LACC	*-,0,AR2
	SACL    *,0,AR2
	mArrays_are_shifted
	B	Pulse_quit

Pulse_SECOND_IMPULSE_IS_BAD:
;           case  SECOND_IMPULSE_IS_BAD:        // Second impulse is bad
;                 Diff2Max[MaxNumber-1] = Diff2Max[MaxNumber];
;                 Diff2MaxAdress[MaxNumber-1] = Diff2MaxAdress[MaxNumber];
;                 Max2DiffAdress[1] = Max2DiffAdress[0];
;                 MaxAvrPress[1] = MaxAvrPress[0];
;                 MinAvrPress[1] = MinAvrPress[0];
;                 break;
	LAR	AR2,#Diff2Max
	MAR	*0+,AR2
	LACC	*-,0,AR2
	SACL    *,0,AR2
	LAR	AR2,#Diff2MaxAdress
	MAR	*0+,AR2
	LACC	*-,0,AR2
	SACL    *,0,AR2
	LAR	AR2,#_Max2DiffAdress
	DMOV	*,AR2
	LAR	AR2,#MaxAvrPress
	DMOV	*,AR2
	LAR	AR2,#MinAvrPress
	DMOV	*,AR2
	B	Pulse_quit

Pulse_THIRD_IMPULSE_IS_BAD:
;           case  THIRD_IMPULSE_IS_BAD:         // Third impulse is bad
;                 break;
	B	Pulse_quit

Pulse_FIRST_IMPULSE_IS_GOOD:
;           case  FIRST_IMPULSE_IS_GOOD:        // First impulse is good
;                 MaxNumber = MaxNumber-1;
;                 Max2DiffAdress[1] = Max2DiffAdress[2];
;                 MaxAvrPress[1] = MaxAvrPress[2];
;                 MinAvrPress[1] = MinAvrPress[2];
;                 break;
	LACC    _MaxNumber
	SUB	#1
	SACL    _MaxNumber
	LAR	AR2,#_Max2DiffAdress+2
	LACC	*-,0,AR2
	SACL	*,0,AR2
	LAR	AR2,#MaxAvrPress+2
	LACC	*-,0,AR2
	SACL	*,0,AR2
	LAR	AR2,#MinAvrPress+2
	LACC	*-,0,AR2
	SACL	*,0,AR2
	B	Pulse_quit

Pulse_SECOND_IMPULSE_IS_GOOD:
;           case  SECOND_IMPULSE_IS_GOOD:       // Second impulse is good
;                 Diff2Max[MaxNumber-2] = Diff2Max[MaxNumber-1];
;                 Diff2MaxAdress[MaxNumber-2] = Diff2MaxAdress[MaxNumber-1];
;                 MaxNumber = MaxNumber-1;
;                 break;
	LAR	AR2,#Diff2Max-1
	MAR	*0+,AR2
	LACC	*-,0,AR2
	SACL    *,0,AR2
	LAR	AR2,#Diff2MaxAdress-1
	MAR	*0+,AR2
	LACC	*-,0,AR2
	SACL    *,0,AR2
	LACC    _MaxNumber
	SUB	#1
	SACL    _MaxNumber
	B	Pulse_quit

Pulse_THIRD_IMPULSE_IS_GOOD:
;           case  THIRD_IMPULSE_IS_GOOD:        // Third impulse is good
;                 Diff2Max[MaxNumber-2] = Diff2Max[MaxNumber];
;                 Diff2MaxAdress[MaxNumber-2] = Diff2MaxAdress[MaxNumber];
;                 MaxNumber = MaxNumber-1;
;                 Max2DiffAdress[1] = Max2DiffAdress[0];
;                 MaxAvrPress[1] = MaxAvrPress[0];
;                 MinAvrPress[1] = MinAvrPress[0];
;                 break;
	LAR	AR2,#Diff2Max
	MAR	*0+,AR2
	LACC	*-,0,AR2
	MAR	*-,AR2
	SACL    *,0,AR2
	LAR	AR2,#Diff2MaxAdress
	MAR	*0+,AR2
	LACC	*-,0,AR2
	MAR	*-,AR2
	SACL    *,0,AR2
	LACC    _MaxNumber
	SUB	#1
	SACL    _MaxNumber
	LAR	AR2,#_Max2DiffAdress
	DMOV	*,AR2
	LAR	AR2,#MaxAvrPress
	DMOV	*,AR2
	LAR	AR2,#MinAvrPress
	DMOV	*,AR2
	B	Pulse_quit

Pulse_ALL_IMPULSE_IS_BAD:
;           case  ALL_IMPULSE_IS_BAD:     		// all is bad
;                 MaxNumber = MaxNumber - 2;
;                 break;
	LACC    _MaxNumber
	SUB	#2
	SACL    _MaxNumber
	B	Pulse_quit
;          }
;       }
;       break;


Pulse_code_error:
;    default:
;       MeasurementFlags = MeasurementFlags &
;                       (~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)));
;       CodeError=PUL_F_E_CODE_ERROR;
	LACC    _MeasurementFlags
	AND	#(~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)))
	SACL	_MeasurementFlags
        SPLK	#PUL_F_E_CODE_ERROR,_CodeError
	B	Pulse_quit

;    }// End switch( MaxNumber - StartMaxNumber )
;}

Pulse_quit:

	MAR	*,AR1
	MAR	*-,AR1
	LAR	AR0,*-,AR1
	PSHD    *,AR2
	RET
;
;
;/***********************************************************
;*	Pulse_frequency_evaluation_40_80
;***********************************************************/
;void Pulse_frequency_evaluation_40_80()

TmpAmplitude_2		.equ	TMP+4

Pulse_frequency_evaluation_40_80:

	MAR	*,AR1
	POPD    *+,AR1
	SAR	AR0,*+,AR2

;{
;  if ( MaxNumber <= 2 )
;  {

	LACC    _MaxNumber,0
	SUB	#2
	BCND	Pulse_40_80_MN_more_2,GT

;    Pulse_frequency_evaluation(CONST_0_499);

	LACC	#CONST_0_499
	CALL 	Pulse_frequency_evaluation

;    if (( MeasurementFlags &(1<<SYNCHRO_FLAG)) != 0)
;    {
;      AnalysisInterval = AveragePeriodEvaluation*1.25/4;
;      AnalysisStart = SampleNumber + AnalysisInterval/2;
;    }
;  }
	BIT	_MeasurementFlags,15-SYNCHRO_FLAG
	BCND	Pulse_40_80_quit,NTC
	LACC	_AveragePeriodEvaluation,12
	ADD     _AveragePeriodEvaluation,14
	SACH    _AnalysisInterval,0
	LACC    _AnalysisInterval,15
	ADD     _SampleNumber,16
	SACH    _AnalysisStart,0
	B	Pulse_40_80_quit

Pulse_40_80_MN_more_2:
;  else
;  {
;    if (( abs( TempPeriodDiff*4 )) < 0.33*AveragePeriodEvaluation)

	LACC	_TempPeriodDiff,15
	ABS
	LT	_AveragePeriodEvaluation
	MPY	#CONST_0_33
	SPAC
	BCND	Pulse_40_80_temp_period_more_2,GT

;    {
;      if ( TempAmplitudeDiff < 0.499*
;         ( Diff2Max[MaxNumber-1]+Diff2Max[MaxNumber])/2)

	MAR	*,AR2
	LAR	AR0,_MaxNumber
	LAR	AR2,#Diff2Max-1
	MAR	*0+,AR2
	LACC	*+,15,AR2
	ADD	*,15,AR2
	SACH	TmpAmplitude_2,0
	LACC    _TempAmplitudeDiff,13
	LT	TmpAmplitude_2
	MPY	#CONST_0_499
	SPAC
	BCND	Pulse_40_80_quit,GT

;      {
;        AveragePeriod=AveragePeriodEvaluation*4;
;        Average();
;        mIncrement_max_number();
;        MeasurementFlags = ( MeasurementFlags |(1<<NEXT_MODE_FLAG))
;                                 & (~(1<<BAD_SYNCHRO_FLAG));
;      }
;    }

	LACC	_AveragePeriodEvaluation,2
	SACL	_AveragePeriod
	CALL   	Average
	mIncrement_max_number
	LACC    _MeasurementFlags,0
	OR	#1<<NEXT_MODE_FLAG
        AND     #(~(1<<BAD_SYNCHRO_FLAG))
	SACL    _MeasurementFlags,0
	B	Pulse_40_80_quit

Pulse_40_80_temp_period_more_2:
;    else
;    {
;      if (( abs( TempPeriod*4 - 2*AveragePeriodEvaluation)) <
;         	 0.33*AveragePeriodEvaluation)

	LACC    _TempPeriod,15
	SUB     _AveragePeriodEvaluation,14
	ABS
	LT      _AveragePeriodEvaluation
	MPY	#CONST_0_33
	SPAC
	BCND	Pulse_40_80_bad_period,GT

;      {
;        if ( TempAmplitudeDiff < 0.499*
;           ( Diff2Max[MaxNumber-1]+Diff2Max[MaxNumber])/2)

	MAR	*,AR2
	LAR	AR0,_MaxNumber
	LAR	AR2,#Diff2Max-1
	MAR	*0+,AR2
	LACC	*+,15,AR2
	ADD	*,15,AR2
	SACH	TmpAmplitude_2,0
	LACC    _TempAmplitudeDiff,13
	LT	TmpAmplitude_2
	MPY	#CONST_0_499
	SPAC
	BCND	Pulse_40_80_bad_amplitude,GT

;        {
;          AveragePeriod=AveragePeriodEvaluation*4;
;          Average_2();

	LACC	_AveragePeriodEvaluation,2
	SACL	_AveragePeriod
	CALL   	Average_2

;          if ( MeasurementFlags&(1<<BAD_SYNCHRO_FLAG) != 0 );
;          {
;            MeasurementFlags = MeasurementFlags &
;                (~((1<<BAD_SYNCHRO_FLAG)|(1<<SYNCHRO_FLAG)));
;            Diff2MaxAdress[0] = Diff2MaxAdress[MaxNumber-1];
;            Diff2MaxAdress[1] = Diff2MaxAdress[MaxNumber];
;            Diff2Max[0] =  Diff2Max[MaxNumber-1];
;            Diff2Max[1] =  Diff2Max[MaxNumber];
;            MaxNumber = 2;
;          }

	BIT	_MeasurementFlags,15-BAD_SYNCHRO_FLAG
	BCND    Pulse_40_80_bad_synchro_1,NTC
	LACC	_MeasurementFlags
	AND     #(~((1<<BAD_SYNCHRO_FLAG)|(1<<SYNCHRO_FLAG)))
	SACL    _MeasurementFlags
	MAR	*,AR2
	LAR	AR0,_MaxNumber
	LAR	AR2,#Diff2MaxAdress-1
	LAR	AR3,#Diff2MaxAdress
	MAR	*0+,AR2
	LACL	*+,AR3
	SACL	*+,AR2
	LACL	*,AR3
	SACL	*,AR2
	LAR	AR2,#Diff2Max-1
	LAR	AR3,#Diff2Max
	MAR	*0+,AR2
	LACL	*+,AR3
	SACL	*+,AR2
	LACL	*,AR3
	SACL	*,AR2
	SPLK	#2,_MaxNumber
	B	Pulse_40_80_quit

Pulse_40_80_bad_synchro_1:
;          else
;          {
;            MeasurementFlags = MeasurementFlags |(1<<BAD_SYNCHRO_FLAG);
;            mIncrement_max_number();
;          }
;        }

	LACC	_MeasurementFlags
	OR      #(1<<BAD_SYNCHRO_FLAG)
	SACL    _MeasurementFlags
	mIncrement_max_number
	B	Pulse_40_80_quit

Pulse_40_80_bad_amplitude:
;        else
;        {
;          MaxNumber = 0;
;          MeasurementFlags = MeasurementFlags &
;          (~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)|(1<<BAD_SYNCHRO_FLAG)));
;        }
;      }
Pulse_40_80_bad_period:
;      else
;      {
;        MaxNumber = 0;
;        MeasurementFlags = MeasurementFlags &
;          (~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)|(1<<BAD_SYNCHRO_FLAG)));
;      }

	SPLK	#0,_MaxNumber
	LACC    _MeasurementFlags
	AND	#(~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)|(1<<BAD_SYNCHRO_FLAG)))
	SACL	_MeasurementFlags
	B	Pulse_40_80_quit

;    }
;  }
;}

Pulse_40_80_quit:
	MAR	*,AR1
	MAR	*-,AR1
	LAR	AR0,*-,AR1
	PSHD    *,AR2
	RET

;/***********************************************************
;*	Pulse_f_e_next_mode
;***********************************************************/
;void Pulse_f_e_next_mode()
Pulse_f_e_next_mode:

	MAR	*,AR1
	POPD    *+,AR1
	SAR	AR0,*+,AR2

;{
;     MaxDiffSignal = 0;
;     mMotor_on();
;     Mode=PRESSURE_AUGMENT;
;     Completion_of_mode();

	SPLK	#0,MaxDiffSignal
	mMotor_on
	SPLK	#PRESSURE_AUGMENT,_Mode
	CALL	Completion_of_mode

;     PulseCounter = 0;
;     AugmentPressureNumber = 0;

	LACL	#0
	SACL    _PulseCounter,0
	SACL    _AugmentPressureNumber,0

;     MeasurementFlags = MeasurementFlags &
;     (~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)|(1<<PRESS_MORE_SYSTOL_FLAG)));

	LACC    _MeasurementFlags,0
	AND     #~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)|(1<<PRESS_MORE_SYSTOL_FLAG))
	SACL    _MeasurementFlags,0

;     AnalysisStart = TIME_OF_MAX_PRESSURE + 0,5*AnalysisInterval;

	LACC	_AnalysisInterval,14
	ADD	#TIME_OF_MAX_PRESSURE,15
	SACH	_AnalysisStart,1

;     mZeroToAverageAmplitude();
;     Finish_Meas_Address();

	mZeroToAverageAmplitude
	CALL	Finish_Meas_Address

;}
	MAR	*,AR1
	MAR	*-,AR1
	LAR	AR0,*-,AR1
	PSHD    *,AR2
	RET

;/***********************************************************
;*	Pulse_frequency_evaluation_40
;***********************************************************/
;void Pulse_frequency_evaluation_40()
Pulse_frequency_evaluation_40:

;{
;  if (( MeasurementFlags&(1<<DIFF_MAX_FLAG)) != 0 )

	BIT	_MeasurementFlags,15-DIFF_MAX_FLAG
        BCND    Pulse_f_e_40_quit,NTC

;  {
;    if ( Diff2Max[MaxNumber] > MIN_THRESHOLD_40MM )  // > 0.1 мм.рт.ст

	MAR	*,AR2
	LAR	AR0,_MaxNumber
	LAR	AR2,#Diff2Max
	MAR	*0+,AR2
	LACC	*,0
	SUB	#MIN_THRESHOLD_40MM,0
	BCND    Pulse_f_e_40_quit,LEQ

;    {
;      if ( Diff2Max[MaxNumber] < MAX_THRESHOLD_40MM )

	SUB	#MAX_THRESHOLD_40MM-MIN_THRESHOLD_40MM,0
	BCND    Pulse_f_e_40_implse_more_max,GEQ

;      {                         // < 4 или 8 мм.рт.ст
;        Pulse_frequency_evaluation_40_80();
;        if (( MeasurementFlags &(1<<NEXT_MODE_FLAG)) != 0)
;        { //подготовка следующего режима
;          Pulse_f_e_next_mode();
;        }

	CALL	Pulse_frequency_evaluation_40_80
	BIT	_MeasurementFlags,15-NEXT_MODE_FLAG
	BCND	Pulse_f_e_40_quit,NTC
	CALL	Pulse_f_e_next_mode
	B	Pulse_f_e_40_quit

;      }

Pulse_f_e_40_implse_more_max:
;      elso
;      {
;        MaxNumber = 0;
;          MeasurementFlags = MeasurementFlags &
;                          (~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)));

	SPLK	#0,_MaxNumber
	LACC    _MeasurementFlags
	AND	#(~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)))
	SACL	_MeasurementFlags

;      }
;    }
;  }

Pulse_f_e_40_quit:
;  if (( MeasurementFlags&(1<<NEXT_MODE_FLAG)) == 0 )

	BIT	_MeasurementFlags,15-NEXT_MODE_FLAG
	BCND	Pulse_f_e_40_next_mode_is,TC
;  {
;    if ( SampleNumber > TEN_SECOND )

	LACC    _SampleNumber,0
	SUB     #TEN_SECOND
	BCND    Pulse_f_e_40_sn_less_10,LEQ

;    {
;      Mode = PRESSURE_AUGMENT_80;
;      Synchro_flag_is_reseted();
;      Completion_of_mode();
;      mZeroToAverageAmplitude();
;      Finish_Meas_Address();

	SPLK 	#PRESSURE_AUGMENT_80,_Mode
	CALL	Synchro_flag_is_reseted
	CALL	Completion_of_mode
	mZeroToAverageAmplitude
	CALL	Finish_Meas_Address

;    }
Pulse_f_e_40_sn_less_10:
;  }
Pulse_f_e_40_next_mode_is:

;  Analysis_of_end();
;  SampleNumber++;

	CALL	Analysis_of_end
	LACC    _SampleNumber,0
	ADD	#1
	SACL    _SampleNumber,0

	RET
;}
;
;/***********************************************************
;*	Pulse_frequency_evaluation_80
;***********************************************************/
;void Pulse_frequency_evaluation_80()
Pulse_frequency_evaluation_80:

;{
;  if (( MeasurementFlags&(1<<DIFF_MAX_FLAG)) != 0 )

	BIT	_MeasurementFlags,15-DIFF_MAX_FLAG
        BCND    Pulse_f_e_80_quit,NTC

;  {
;    if ( Diff2Max[MaxNumber] > MIN_THRESHOLD_40MM )  // > 0.1 мм.рт.ст

	MAR	*,AR2
	LAR	AR0,_MaxNumber
	LAR	AR2,#Diff2Max
	MAR	*0+,AR2
	LACC	*,0
	SUB	#MIN_THRESHOLD_40MM,0
	BCND    Pulse_f_e_80_quit,LEQ

;    {
;      if ( Diff2Max[MaxNumber] < MAX_THRESHOLD_SISTOL )

	SUB	#MAX_THRESHOLD_SISTOL-MIN_THRESHOLD_40MM,0
	BCND    Pulse_f_e_80_implse_more_max,GEQ

;      {                         // < 4 или 8 мм.рт.ст
;        Pulse_frequency_evaluation_40_80();
;        if (( MeasurementFlags &(1<<NEXT_MODE_FLAG)) != 0)
;        { //подготовка следующего режима
;          Pulse_f_e_next_mode();
;        }

	CALL	Pulse_frequency_evaluation_40_80
	BIT	_MeasurementFlags,15-NEXT_MODE_FLAG
	BCND	Pulse_f_e_80_quit,NTC
	CALL	Pulse_f_e_next_mode
	B	Pulse_f_e_80_quit

;      }

Pulse_f_e_80_implse_more_max:
;      elso
;      {
;        MaxNumber = 0;
;          MeasurementFlags = MeasurementFlags &
;                          (~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)));

	SPLK	#0,_MaxNumber
	LACC    _MeasurementFlags
	AND	#(~((1<<SYNCHRO_FLAG)|(1<<NEXT_MODE_FLAG)))
	SACL	_MeasurementFlags

;      }
;    }
;  }

Pulse_f_e_80_quit:
;  if (( MeasurementFlags&(1<<NEXT_MODE_FLAG)) == 0 )

	BIT	_MeasurementFlags,15-NEXT_MODE_FLAG
	BCND	Pulse_f_e_80_next_mode_is,TC
;  {
;    if ( SampleNumber > TEN_SECOND )

	LACC    _SampleNumber,0
	SUB     #TEN_SECOND
	BCND    Pulse_f_e_80_sn_less_10,LEQ

;    {
;      Completion_of_mode();
;      mZeroToAverageAmplitude();
;      Finish_Meas_Address();
;      mEnd_error_meas(rERROR_PULS_FREQ_EVAL);

	CALL	Completion_of_mode
	mZeroToAverageAmplitude
	CALL	Finish_Meas_Address
	mEnd_error_meas	rERROR_PULS_FREQ_EVAL

;    }
Pulse_f_e_80_sn_less_10:
;  }
Pulse_f_e_80_next_mode_is:

;  Analysis_of_end();
;  SampleNumber++;

	CALL	Analysis_of_end
	LACC    _SampleNumber,0
	ADD	#1
	SACL    _SampleNumber,0
	RET
;}
