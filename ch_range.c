enum error_range{
 eSampleNumber,
 eSampleNumberShift,
 eMaxNumber
};


void  quit_error_range(int eRange){
}

#define TEN_SECOND	1000
#define TWO_MINUTES	12000

extern unsigned int SampleNumber;
extern unsigned int SampleNumberShift;
extern unsigned int MaxNumber;

void check_range()
{
// * Список переменных и их возможные диапазоны значений


// SampleNumber            >=0, <=TEN_SECOND
 if (SampleNumber>TEN_SECOND){
  quit_error_range(eSampleNumber);
  return;
 }

// SampleNumberShift       >=0, <=TWO_MINUTES

 if (SampleNumberShift>TWO_MINUTES){
  quit_error_range(eSampleNumberShift);
  return;
 }

// MaxNumber               >=0, <=32
 if (MaxNumber>32){
  quit_error_range(eMaxNumber);
  return;
 }
// MaxNumberShift          >=0, <=325
// AnalysisStart           >=0, <=TEN_SECOND
// AnalysisInterval        >=MIN_ANALYSIS_INTERVAL, <=MAX_ANALYSIS_INTERVAL
// AveragePeriod           >=MIN_DURATION*16, <=MAX_DURATION*16
// AveragePeriodEvaluation >MIN_DURATION*4, <=MAX_DURATION*4
// TempPeriod              >MIN_DURATION/2, <=TEN_SECOND
// TempPeriodDiff          >=-MAX_DURATION, <=TEN_SECOND-MIN_DURATION/2
// TempAmplitudeDiff       >=0, <=B10mm*15
// PulseCounter            >=0, <=150

// MeasurementFlags        >0, < 1024

// StartMaxNumber          >0, <= 32
// StepNumber              >0, MAX_STEP_NUMBER
// HigherCount               Можно удалить.
// PressureTop             >=#LPRESS_40, <=LPRESS_270
// MaxDiffSignal           any
// MaxAverageAmplitude     any
// LastDiff2Max            any

// NewPressure		>=#LPRESS_20, <=LPRESS_280
// SistolPressure		>=#LPRESS_60, <=LPRESS_280
// AveragePressure         >=#LPRESS_30, <=LPRESS_260
// DiastolPressure		>=#LPRESS_30, <=LPRESS_240
// SistolPressureAmplitude >=B0_1mm, <=B4mm
// AugmentPressureNumber   >=0, <=3
// ArtefactCount           Пока не используетс

// Mode                    >=0, <=14
// ModeCnt			>=0, <=15000 or <=code
// SubroutMode		>=0, <=5

// DimModeSampleCounter    >=0, <=ONE_SECOND*4
// DimMode                 >=0, <=5
// Perror                  <+-PRESS_80
// Tdimstart               >=0, <=ONE_SECOND*4
// Preturn                 >=0, <=PRESS_80
// Pclose                  >=#PRESS_20, <=PRESS_280
// CodeError               >=0, <=1

// Max2DiffAdress[0]       >=0, <=TWO_MINUTES
// Max2DiffAdress[1]       >=0, <=TWO_MINUTES
// Max2DiffAdress[2]       >=0, <=TWO_MINUTES
// Duration[0]             >=0, <=TEN_SECOND
// Duration[1]             >=0, <=TEN_SECOND
// Duration[2]             >=0, <=TEN_SECOND

// * Остальное МОЖНО не проверять НА ДИАПАЗОН ЗНАЧЕНИЙ.
/*
Max                     .usect "bss1",3
DTrend                  .usect "bss1",6
MaxAvrPress             .usect "bss1",3
MinAvrPress             .usect "bss1",3


Diff2Max                .usect "MNArray0",32
Diff2MaxAdress          .usect "MNArray0",32
Diff2MaxAdressFinish    .usect "MNArray",325

Signal                  .usect "SigArray",1024        ; 1k
DiffSignal              .usect "SigArray",MAX_ANALYSIS_INTERVAL

MAX_STEP_NUMBER		.equ	48
StartMeasAdress         .usect "StepNum",MAX_STEP_NUMBER ;((280-30)/7)+2=40
FinishMeasAddress        .usect "StepNum",MAX_STEP_NUMBER
AvrPress                .usect "StepNum",MAX_STEP_NUMBER
AverageAmplitude        .usect "StepNum",MAX_STEP_NUMBER
*/
}