enum error_range{
 eSampleNumber=1,		//1
 eSampleNumberShift,    	//2
 eMaxNumber,            	//3
 eMaxNumberShift,
 eAnalysisStart,
 eAnalysisInterval,
 eAveragePeriod,
 eAveragePeriodEvaluation,
 eTempPeriod,
 eTempPeriodDiff,
 eTempAmplitudeDiff,
 ePulseCounter,
 eMeasurementFlags,
 eStartMaxNumber,
 eStepNumber,
 ePressureTop,
 eNewPressure,
 eSistolPressureAmplitude,
 eAugmentPressureNumber,
 eMode,
 eModeCnt,
 eSubroutMode,
 eDimModeSampleCounter,
 eDimMode,
 ePerror,
 eTdimstart,
 ePreturn,
 ePclose,
 eCodeError,
 eMax2DiffAdress_0,
 eMax2DiffAdress_1,
 eMax2DiffAdress_2,
 eDuration_0,
 eDuration_1,
 eDuration_2
};


#define ONE_SECOND	100
#define TEN_SECOND	1000
#define TWO_MINUTES	12000
#define MIN_ANALYSIS_INTERVAL	40
#define MAX_ANALYSIS_INTERVAL	200
#define MIN_DURATION	30
#define MAX_DURATION	150
#define B0_1mm		21
#define B4mm		819
#define B10mm		2048
#define MAX_STEP_NUMBER	48


#define LPRESS_0		-32768
#define LPRESS_10	-30720
#define LPRESS_20	-28672
#define LPRESS_30	-26624
#define LPRESS_40	-24576
#define LPRESS_80	-16384
#define LPRESS_270	22528
#define LPRESS_280	24576


extern unsigned int SampleNumber,SampleNumberShift;
extern unsigned int MaxNumber,MaxNumberShift;
extern unsigned int AnalysisStart,AnalysisInterval;
extern unsigned int AveragePeriod,AveragePeriodEvaluation;
extern unsigned int TempPeriod;
extern int TempPeriodDiff;
extern unsigned int TempAmplitudeDiff;
extern unsigned int PulseCounter;
extern unsigned int MeasurementFlags;
extern unsigned int StartMaxNumber;
extern unsigned int StepNumber;
extern int PressureTop,NewPressure;
extern unsigned int SistolPressureAmplitude;
extern unsigned int AugmentPressureNumber;
extern unsigned int Mode,ModeCnt,SubroutMode,DimModeSampleCounter,DimMode;
extern unsigned int Perror; //?????
extern unsigned int Tdimstart;
extern unsigned int Preturn;//??????
extern int Pclose; //?????
extern unsigned int CodeError;
extern unsigned int Max2DiffAdress[];
extern unsigned int Duration[];


unsigned check_range()
{
// * Список переменных и их возможные диапазоны значений
unsigned short code_error=0;

// SampleNumber            >=0, <=TEN_SECOND
 if (SampleNumber>TEN_SECOND)
  code_error=eSampleNumber;


// SampleNumberShift       >=0, <=TWO_MINUTES

 if (SampleNumberShift>TWO_MINUTES)
  code_error=eSampleNumberShift;


// MaxNumber               >=0, <=32
 if (MaxNumber>32)
  code_error=eMaxNumber;

// MaxNumberShift          >=0, <=325
 if (MaxNumberShift>325)
  code_error=eMaxNumberShift;

// AnalysisStart           >=0, <=TEN_SECOND
 if (AnalysisStart>TEN_SECOND)
  code_error=eAnalysisStart;

// AnalysisInterval        >=MIN_ANALYSIS_INTERVAL, <=MAX_ANALYSIS_INTERVAL
 if ( (AnalysisInterval<MIN_ANALYSIS_INTERVAL)||(AnalysisInterval>MAX_ANALYSIS_INTERVAL) )
  code_error=eAnalysisInterval;


// AveragePeriod           >=MIN_DURATION*16, <=MAX_DURATION*16
 if ( (AveragePeriod<(MIN_DURATION*16))||(AveragePeriod>(MAX_DURATION*16)) )
  code_error=eAveragePeriod;

// AveragePeriodEvaluation >MIN_DURATION*4, <=MAX_DURATION*4
 if ( (AveragePeriodEvaluation<(MIN_DURATION*4))||(AveragePeriodEvaluation>(MAX_DURATION*4)) )
  code_error=eAveragePeriodEvaluation;

// TempPeriod              >MIN_DURATION/2, <=TEN_SECOND
 if ( (TempPeriod<(MIN_DURATION/2))||(TempPeriod>(TEN_SECOND)) )
  code_error=eTempPeriod;

// TempPeriodDiff          >=-MAX_DURATION, <=TEN_SECOND-MIN_DURATION/2
 if ( ((TempPeriodDiff+MAX_DURATION)<0)||(TempPeriodDiff>(TEN_SECOND-MIN_DURATION/2)) )
  code_error=eTempPeriodDiff;

// TempAmplitudeDiff       >=0, <=B10mm*15
 if (TempAmplitudeDiff>(B10mm*15))
  code_error=eTempAmplitudeDiff;


// PulseCounter            >=0, <=150
 if (PulseCounter>150)
  code_error=ePulseCounter;


// MeasurementFlags        >0, < 1024
 if (MeasurementFlags>1024)
  code_error=eMeasurementFlags;


// StartMaxNumber          >0, <= 32
 if (StartMaxNumber>32)
  code_error=eStartMaxNumber;


// StepNumber              >0, MAX_STEP_NUMBER
 if (StepNumber>MAX_STEP_NUMBER)
  code_error=eStepNumber;

// HigherCount               Можно удалить.
// PressureTop             >=#LPRESS_40, <=LPRESS_270
 if ( (PressureTop<LPRESS_40)||(PressureTop>(LPRESS_270)) )
  code_error=ePressureTop;


// MaxDiffSignal           any
// MaxAverageAmplitude     any
// LastDiff2Max            any

// NewPressure		>=#LPRESS_20, <=LPRESS_280
 if ( (NewPressure<LPRESS_20)||(NewPressure>(LPRESS_280)) )
  code_error=eNewPressure;

// SistolPressure		>=#LPRESS_60, <=LPRESS_280
// AveragePressure         >=#LPRESS_30, <=LPRESS_260
// DiastolPressure		>=#LPRESS_30, <=LPRESS_240
// SistolPressureAmplitude >=B0_1mm, <=B4mm
 if ( (SistolPressureAmplitude<B0_1mm)||(SistolPressureAmplitude>(B4mm)) )
  code_error=eSistolPressureAmplitude;


// AugmentPressureNumber   >=0, <=3
 if (AugmentPressureNumber>3)
  code_error=eAugmentPressureNumber;

// ArtefactCount           Пока не используетс

// Mode                    >=0, <=14
 if (Mode>14)
  code_error=eMode;

// ModeCnt			>=0, <=15000 or <=code
 if (ModeCnt>15000)
  code_error=eModeCnt;

// SubroutMode		>=0, <=5
 if (SubroutMode>5)
  code_error=eSubroutMode;


// DimModeSampleCounter    >=0, <=ONE_SECOND*4
 if (DimModeSampleCounter>(ONE_SECOND*4))
  code_error=eDimModeSampleCounter;


// DimMode                 >=0, <=5
 if (DimMode>5)
  code_error=eDimMode;

// Perror                  <+-PRESS_80
 if (abs(Perror)>PRESS_80)
  code_error=ePerror;

// Tdimstart               >=0, <=ONE_SECOND*4
 if (Tdimstart>(ONE_SECOND*4))
  code_error=eTdimstart;

// Preturn                 >=0, <=PRESS_80
 if (Preturn>PRESS_80)
  code_error=ePreturn;

// Pclose                  >=#PRESS_20, <=PRESS_280
 if ( (Pclose<PRESS_20)||(Pclose>PRESS_280) )
  code_error=ePclose;


// CodeError               >=0, <=1
 if (CodeError>2)
  code_error=eCodeError;


// Max2DiffAdress[0]       >=0, <=TWO_MINUTES
 if (Max2DiffAdress[0]>TWO_MINUTES)
  code_error=eMax2DiffAdress_0;

// Max2DiffAdress[1]       >=0, <=TWO_MINUTES
 if (Max2DiffAdress[1]>TWO_MINUTES)
  code_error=eMax2DiffAdress_1;

// Max2DiffAdress[2]       >=0, <=TWO_MINUTES
 if (Max2DiffAdress[2]>TWO_MINUTES)
  code_error=eMax2DiffAdress_2;

// Duration[0]             >=0, <=TEN_SECOND
 if (Duration[0]>TEN_SECOND)
  code_error=eDuration_0;

// Duration[1]             >=0, <=TEN_SECOND
 if (Duration[1]>TEN_SECOND)
  code_error=eDuration_1;

// Duration[2]             >=0, <=TEN_SECOND
 if (Duration[2]>TEN_SECOND)
  code_error=eDuration_2;


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

 if (code_error) return code_error;
 else return 0;

}