* $Id: BP206SEC.ASM,v 1.12 2001-04-11 10:03:40 peter Exp $
SIM			.set	0

*TMP                     .usect "bss1",8,1
SampleNumber            .usect "bss1",1
SampleNumberShift       .usect "bss1",1
MaxNumber               .usect "bss1",1
MaxNumberShift          .usect "bss1",1
AnalysisStart           .usect "bss1",1
AnalysisInterval        .usect "bss1",1
AveragePeriod           .usect "bss1",1
AveragePeriodEvaluation .usect "bss1",1
TempPeriod              .usect "bss1",1
TempPeriodDiff          .usect "bss1",1
Temp2PeriodDiff         .usect "bss1",1
TempAmplitudeDiff       .usect "bss1",1
SynchCount              .usect "bss1",1
PulseCounter            .equ   SynchCount

NextModeFlag            .usect "bss1",1
MeasurementFlags        .usect "bss1",1
DIFF_MAX_FLAG           .equ	0
FIRST_IMPULSE_FLAG      .equ	1
SYNCHRO_FLAG		.equ	2
FIRST_MEAS_FLAG         .equ	3
THREE_IMPULSE_FLAG      .equ	4
PRESS_MORE_SYSTOL_FLAG  .equ	5
DIM_PRESSURE_FLAG       .equ	6
;DiffMaxFlag             .usect "bss1",1
;FirstImpulseFlag
;SynchroFlag             .usect "bss1",1
;FirstMeasFlag           .usect "bss1",1
;ThreeImpulseFlag        .usect "bss1",1
;PressureMoreSystolFlag  .usect "bss1",1


StartMaxNumber          .usect "bss1",1
StepNumber              .usect "bss1",1
HigherCount             .usect "bss1",1
PressureTop             .usect "bss1",1
MaxDiffSignal           .usect "bss1",1
MaxAmplStepNumber       .usect "bss1",1
MaxAverageAmplitude     .usect "bss1",1
LastDiff2Max            .usect "bss1",1


PressPulseFrEv          .usect "bss1",1
NewPressure		.usect "bss1",1
SistolPressure		.usect "bss1",1
AveragePressure         .usect "bss1",1
DiastolPressure		.usect "bss1",1
SistolPressureAmplitude .usect "bss1",1
AugmentPressureNumber   .usect "bss1",1
ArtefactCount           .equ   PressPulseFrEv

Mode                    .usect "bss1",1
ModeCnt			.usect "bss1",1
SubroutMode		.usect "bss1",1

Max2DiffAdress          .usect "bss1",3
Duration                .usect "bss1",3
Max                     .usect "bss1",3
DTrend                  .usect "bss1",6
MaxAvrPress             .usect "bss1",3
MinAvrPress             .usect "bss1",3

DimModeSampleCounter  	.usect "bss1",1
DimMode               	.usect "bss1",1
Pline0                	.usect "bss1",1
Pline1                	.usect "bss1",1
Perror                	.usect "bss1",1
;Tclosing              	.usect "bss1",1
;Tedge                 	.usect "bss1",1
Tdimstart             	.usect "bss1",1
Preturn             	.usect "bss1",1
Pclose             	.usect "bss1",1


Diff2Max                .usect "MNArray0",32
Diff2MaxAdress          .usect "MNArray0",32
Diff2MaxAdressFinish    .usect "MNArray",256

Signal                  .usect "SigArray",1152        ; 1k+128 слов

StartMeasAdress         .usect "StepNum",32
FinishMeasAdress        .usect "StepNum",32
AvrPress                .usect "StepNum",32
AverageAmplitude        .usect "StepNum",32


DIFF_BASIS_OF_PR_AUG_1		.set   200
DIFF_BASIS_OF_PR_AUG_2		.set	30
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

ZERO_ZERO_FIVE_MM_PER_SAMPLE 	.equ 	B0_1mm*20    ;0,01мм.pт.ст/отсчет
ONE_MM_PER_SAMPLE               .equ    B0_5mm*30*2  ;1,00мм.pт.ст/отсчет

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
TWO_MINUTES		.set	11500

TIME_OUT               	.set    10
WHITE_VALVE_OFF		.set    15

MIN_STEP_NUMBER		.set	5
MIN_NUMBER		.set	0FFFFh

TRUE                    .set	1
FALSE                   .set	0


VALVE_CLOSE                     .set    10

	.if SIM == 0
SUPPLY_UP                       .set    0
START_SHIFT                     .set    1
PRESSURE_AUGMENT_40             .set    2
DAC_WORKING_CHECK               .set    3
PULSE_FREQUENCY_EVALUATION      .set    4
PRESSURE_AUGMENT                .set    5
PRESSURE_AUGMENT_STOP           .set    6
CHECK_HIGHER_SISTOL_PRESSURE    .set    7
PRESSURE_MEASUREMENT            .set    8
PRESSURE_DIMINUTION             .set    9
MEASUREMENT_FINISH              .set	10
 .if WriteDebug=0
  .if Sertificarion=1
PRESSURE_MEASUREMENT_MANUAL	.set	11
  .endif

 .elseif WriteDebug<3
  .if Sertificarion=1
PRESSURE_MEASUREMENT_MANUAL	.set	11
START_DEBUG_WRITE		.set	12
  .else
START_DEBUG_WRITE		.set	11
  .endif
 .endif
	.else
PULSE_FREQUENCY_EVALUATION      .set    0
PRESSURE_AUGMENT                .set    1
PRESSURE_AUGMENT_STOP           .set    2
CHECK_HIGHER_SISTOL_PRESSURE    .set    3
PRESSURE_MEASUREMENT            .set    4
PRESSURE_DIMINUTION             .set    5
MEASUREMENT_FINISH              .set    6

	.endif




