;&D
* $Id: BP206SEC.ASM,v 1.17 2001-11-23 15:37:37 peter Exp $
SIM			.set	0

*TMP                     .usect "bss1",8,1
	.global	_SampleNumber
	.global	_SampleNumberShift
	.global	_MaxNumber
_MaxNumber               .usect "bss1",1

	.global _MaxNumberShift
_MaxNumberShift          .usect "bss1",1

	.global _AnalysisStart
_AnalysisStart           .usect "bss1",1

	.global	_AnalysisInterval
_AnalysisInterval        .usect "bss1",1

	.global	_AveragePeriod
_AveragePeriod           .usect "bss1",1

	.global	_AveragePeriodEvaluation
_AveragePeriodEvaluation .usect "bss1",1

	.global	_TempPeriod
_TempPeriod              .usect "bss1",1

	.global	_TempPeriodDiff
_TempPeriodDiff          .usect "bss1",1

	.global	_TempAmplitudeDiff
_TempAmplitudeDiff       .usect "bss1",1

	.global	_PulseCounter
_PulseCounter            .usect "bss1",1

	.global	_MeasurementFlags
_MeasurementFlags        .usect "bss1",1

DIFF_MAX_FLAG           .equ	0
FIRST_IMPULSE_FLAG      .equ	1
SYNCHRO_FLAG		.equ	2
SYNCHRO_FLAG_WAS	.equ	3
NEXT_MODE_FLAG		.equ	4
FIRST_MEAS_FLAG         .equ	5
THREE_IMPULSE_FLAG      .equ	6
PRESS_MORE_SYSTOL_FLAG  .equ	7
DIM_PRESSURE_FLAG       .equ	8
BAD_SYNCHRO_FLAG .equ	9

	.global	_StartMaxNumber
_StartMaxNumber          .usect "bss1",1

	.global	_StepNumber
_StepNumber              .usect "bss1",1
HigherCount             .usect "bss1",1

	.global	_PressureTop
_PressureTop             .usect "bss1",1
MaxDiffSignal           .usect "bss1",1
MaxAverageAmplitude     .usect "bss1",1
LastDiff2Max            .usect "bss1",1
	.global	_NewPressure
SistolPressure		.usect "bss1",1
AveragePressure         .usect "bss1",1
DiastolPressure		.usect "bss1",1
	.global	_SistolPressureAmplitude
_SistolPressureAmplitude .usect "bss1",1
	.global	_AugmentPressureNumber
_AugmentPressureNumber   .usect "bss1",1
ArtefactCount           .usect "bss1",1

	.global	_Mode
_Mode                    .usect "bss1",1
	.global	_ModeCnt
_ModeCnt			.usect "bss1",1
	.global	_SubroutMode
_SubroutMode		.usect "bss1",1

	.global	_Max2DiffAdress
_Max2DiffAdress          .usect "bss1",3
	.global	_Duration
_Duration                .usect "bss1",3
Max                     .usect "bss1",3
DTrend                  .usect "bss1",6
MaxAvrPress             .usect "bss1",3
MinAvrPress             .usect "bss1",3

	.global	_DimModeSampleCounter
_DimModeSampleCounter  	.usect "bss1",1
	.global	_DimMode
_DimMode               	.usect "bss1",1
;Pline0                	.usect "bss1",1
;Pline1                	.usect "bss1",1
	.global	_Perror
_Perror                	.usect "bss1",1
;Tclosing              	.usect "bss1",1
;Tedge                 	.usect "bss1",1
	.global	_Tdimstart
_Tdimstart             	.usect "bss1",1
	.global	_Preturn
_Preturn             	.usect "bss1",1
	.global	_Pclose
_Pclose             	.usect "bss1",1
	.global	_CodeError
_CodeError               .usect "bss1",1

	.if ( SIM == 1 )
TmpAddress              .usect "bss1",1
DimStopAddress          .usect "bss1",1
	.endif
Diff2Max                .usect "MNArray0",32
Diff2MaxAdress          .usect "MNArray0",32
Diff2MaxAdressFinish    .usect "MNArray",325

MAX_ANALYSIS_INTERVAL 	.set	200

Signal                  .usect "SigArray",1024        ; 1k
DiffSignal              .usect "SigArray",MAX_ANALYSIS_INTERVAL

MAX_STEP_NUMBER		.equ	48
StartMeasAdress         .usect "StepNum",MAX_STEP_NUMBER ;((280-30)/7)+2=40
FinishMeasAddress        .usect "StepNum",MAX_STEP_NUMBER
AvrPress                .usect "StepNum",MAX_STEP_NUMBER
AverageAmplitude        .usect "StepNum",MAX_STEP_NUMBER

DIFF_BASIS_OF_PR_AUG_1		.set   800
DIFF_BASIS_OF_PR_AUG_2		.set    30
DIFF_BASIS              	.set    12

CONST_0_2                       .set    00CCDh   ;4  - shift 2
CONST_0_249                     .set    00FFFh   ;4  - shift 2
CONST_0_3                       .set    0099Ah   ;8  - shift 3
CONST_0_33                      .set    00AAAh   ;8  - shift 3
CONST_0_35                      .set    00B33h   ;8  - shift 3
CONST_0_375                     .set    00C00h   ;8  - shift 3
CONST_0_4                       .set    00CCDh   ;8  - shift 3
CONST_0_499                     .set    00FFFh   ;8  - shift 3
CONST_0_6                       .set    0099Ah   ;16 - shift 4
CONST_0_69		        .set	00B0Ah	 ;16 - shift 4
CONST_0_75		        .set	00C00h	 ;16 - shift 4
CONST_0_8			.set    00CCCh   ;16 - shift 4
CONST_1_25                      .set    00A00h   ;32 - shift 5
CONST_1_5                       .set    00BFFh   ;32 - shift 5
B0_1mm                          .set    21
B0_2mm                          .set    41
B0_5mm                          .set    102
B4mm                            .set    819
B8mm                            .set    1638  ;//посчитать точнее
B10mm                           .set    2048

THRESHOLD_OF_SISTOL            	.set    00851h   ;(0.55)16 - shift 4
THRESHOLD_OF_AVERAGE           	.set    00C00h   ;(0.77)16 - shift 4
THRESHOLD_OF_DIASTOL           	.set    00C51h   ;(0.77)16 - shift 4
;#define STARTE_SAMPLE_NUMBER    32    //
;#define ANALYSIS_INTERVAL       32    //
;#define MAX_MIN_THRESHOLD_40MM  32    //
;#define MIN_THRESHOLD_40MM
;#define MIN_THRESHOLD_SISTOL    B0_2mm
;#define MAX_THRESHOLD_SISTOL    B10mm
;#define MAX_MIN_HIGH_THRESHOLD  64    //

MIN_THRESHOLD_40MM      	.set    B0_1mm*3     ;//0.1 мм.рт.ст.
MAX_THRESHOLD_40MM      	.set    B4mm*3       ;//4 мм.рт.ст.
MIN_THRESHOLD_SISTOL    	.equ    B0_1mm*3
MAX_THRESHOLD_SISTOL    	.equ    B10mm*3

ZERO_ZERO_FIVE_MM_PER_SAMPLE 	.equ 	B0_1mm*DIFF_BASIS_OF_PR_AUG_1/10    ;0,01мм.pт.ст/отсчет
ONE_MM_PER_SAMPLE               .equ    B0_5mm*DIFF_BASIS_OF_PR_AUG_2*6  ;3,00мм.pт.ст/отсчет

RESERVE_MILL_OF_MERC    	.equ    B8mm
EIGHT_MILL_OF_MERC		.equ    B8mm

;#define Diskret 100
;//для 200 Гц
;// 40 уд/мин - 300 отсчетов
;// 180 уд/мин - 66 отсчетов
;//#define MIN_DURATION 66
;//#define MAX_DURATION 300
;//для 100 Гц
;// 40 уд/мин - 150 отсчетов
;// 180 уд/мин - 33 отсчетов
;// 200 уд/мин - 30 отсчетов

MIN_DURATION            .set    30
MAX_DURATION            .set    150

TIME_OF_MAX_PRESSURE  	.set	32
ONE_SECOND              .set    100
TWO_SECOND              .set    200
TEN_SECOND              .set    1000
TWO_MINUTES		.set	11000

TIME_OUT               	.set    10
WHITE_VALVE_OFF		.set    15

MIN_STEP_NUMBER		.set	7
MIN_NUMBER		.set	0F000h

TRUE                    .set	1
FALSE                   .set	0


VALVE_CLOSE                     .set    10

	.if SIM == 0
SUPPLY_UP                       .set    0
START_SHIFT                     .set    1
PRESSURE_AUGMENT_40             .set    2
DAC_WORKING_CHECK               .set    3
PULSE_FREQ_EVALUATION_40        .set    4
PRESSURE_AUGMENT_80             .set    5
PULSE_FREQ_EVALUATION_80        .set    6
PRESSURE_AUGMENT                .set    7
PRESSURE_AUGMENT_STOP           .set    8
CHECK_HIGHER_SISTOL_PRESSURE    .set    9
PRESSURE_MEASUREMENT            .set   10
PRESSURE_DIMINUTION             .set   11
MEASUREMENT_FINISH              .set   12
 .if WriteDebug=0
  .if Sertificarion=1
PRESSURE_MEASUREMENT_MANUAL	.set	13
  .endif

 .elseif WriteDebug<3
  .if Sertificarion=1
PRESSURE_MEASUREMENT_MANUAL	.set	13
START_DEBUG_WRITE		.set	14
  .else
START_DEBUG_WRITE		.set	13
  .endif
 .endif
	.else
DAC_WORKING_CHECK               .set    0
PULSE_FREQ_EVALUATION_40        .set    0
PRESSURE_AUGMENT_80             .set    1
PULSE_FREQ_EVALUATION_80        .set    2
PRESSURE_AUGMENT                .set    3
PRESSURE_AUGMENT_STOP           .set    4
CHECK_HIGHER_SISTOL_PRESSURE    .set    5
PRESSURE_MEASUREMENT            .set    6
PRESSURE_DIMINUTION             .set    7
MEASUREMENT_FINISH              .set    8

	.endif

PUL_F_E_CODE_ERROR              .set    0
SW_FLAGS_WORD2_ERROR            .set    1



