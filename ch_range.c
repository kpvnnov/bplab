enum error_range{
 eSampleNumber=1,		//1
 eSampleNumberShift,    	//2
 eMaxNumber,            	//3
 eMaxNumberShift,               //4
 eAnalysisStart,                //5
 eAnalysisInterval,             //6
 eAveragePeriod,                //7
 eAveragePeriodEvaluation,      //8
 eTempPeriod,                   //9
 eTempAmplitudeDiff,            //10
 ePulseCounter,                 //11
 eMeasurementFlags,             //12
 eStartMaxNumber,               //13
 eStepNumber,                   //14
 eSistolPressureAmplitude,      //15
 eAugmentPressureNumber,        //16
 eMode,                         //17
 eModeCnt,                      //18
 eSubroutMode,                  //19
 eDimModeSampleCounter,         //20
 eDimMode,                      //21
 eTdimstart,                    //22
 ePreturn,                      //23
 ePclose,                       //24
 eCodeError,                    //25
 eMax2DiffAdress_0,             //26
 eMax2DiffAdress_1,             //27
 eMax2DiffAdress_2,             //28
 eDuration_0,                   //29
 eDuration_1,                   //30
 eDuration_2,                   //31

 eTempPeriodDiff,               //32
 ePressureTop,                  //33
 eNewPressure,                  //34
 ePerror                        //35
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


#define LPRESS_0	-32768
#define LPRESS_10	-30720
#define LPRESS_20	-28672
#define LPRESS_30	-26624
#define LPRESS_40	-24576
#define LPRESS_80	-16384
#define LPRESS_270	22528
#define LPRESS_280	24576


#define PRESS_280 	 0xE000
#define PRESS_260 	 0xD000
#define PRESS_250 	 0xC800
#define PRESS_240 	 0xC000
#define PRESS_220 	 0xB000
#define PRESS_200 	 0xA000
#define PRESS_190 	 0x9800
#define PRESS_180 	 0x9000
#define PRESS_160 	 0x8000
#define PRESS_145 	 0x7400
#define PRESS_140 	 0x7000
#define PRESS_130 	 0x6800
#define PRESS_120 	 0x6000
#define PRESS_100 	 0x5000
#define PRESS_95  	 0x4C00
#define PRESS_90  	 0x4800
#define PRESS_80  	 0x4000
#define PRESS_60  	 0x3000
#define PRESS_50  	 0x2800
#define PRESS_40  	 0x2000
#define PRESS_30  	 0x1800
#define PRESS_20  	 0x1000
#define PRESS_10  	 0x0800
#define PRESS_05  	 0x0400
#define PRESS_02_5  	 0x0200
#define PRESS_01_25 	 0x0100
#define STEP_PRESS 	 0x0733


//#pragma DATA_SECTION(SampleNumber, "bss1")
//#pragma DATA_SECTION(SampleNumberShift, "bss1")
extern unsigned int SampleNumber,SampleNumberShift;
extern unsigned int MaxNumber,MaxNumberShift;
extern unsigned int AnalysisStart,AnalysisInterval;
extern unsigned int AveragePeriod,AveragePeriodEvaluation;
extern unsigned int TempPeriod;
extern unsigned int TempAmplitudeDiff;
extern unsigned int PulseCounter;
extern unsigned int MeasurementFlags;
extern unsigned int StartMaxNumber;
extern unsigned int StepNumber;
extern unsigned int SistolPressureAmplitude;
extern unsigned int AugmentPressureNumber;
extern unsigned int Mode,ModeCnt,SubroutMode,DimModeSampleCounter,DimMode;
extern unsigned int Tdimstart;
extern unsigned int Preturn;
extern unsigned int Pclose;
extern unsigned int CodeError;
extern unsigned int Max2DiffAdress[];
extern unsigned int Duration[];

extern int TempPeriodDiff;
extern int PressureTop,NewPressure;
extern int Perror;

unsigned check_range()
{
// * Список переменных и их возможные диапазоны значений
unsigned short code_error=0;

unsigned varib_down[]={0,	// 1 SampleNumber            >=0, <=TEN_SECOND
	0,			// 2 SampleNumberShift       >=0, <=TWO_MINUTES
	0,			// 3 MaxNumber               >=0, <=32
	0,			// 4 MaxNumberShift          >=0, <=325
	0,			// 5 AnalysisStart           >=0, <=TEN_SECOND
	MIN_ANALYSIS_INTERVAL,	// 6 AnalysisInterval        >=MIN_ANALYSIS_INTERVAL, <=MAX_ANALYSIS_INTERVAL
	MIN_DURATION*16,	// 7 AveragePeriod           >=MIN_DURATION*16, <=MAX_DURATION*16
	MIN_DURATION*4,		// 8 AveragePeriodEvaluation >MIN_DURATION*4, <=MAX_DURATION*4
	MIN_DURATION/2,		// 9 TempPeriod              >MIN_DURATION/2, <=TEN_SECOND
	0,			// 10 TempAmplitudeDiff       >=0, <=B10mm*15
	0,			// 11 PulseCounter            >=0, <=150
	0			// 12 MeasurementFlags        >0, < 1024
	};
unsigned varib_up[]={TEN_SECOND,// 1 SampleNumber            >=0, <=TEN_SECOND
	TWO_MINUTES,		// 2 SampleNumberShift       >=0, <=TWO_MINUTES
	32,			// 3 MaxNumber               >=0, <=32
	325,			// 4 MaxNumberShift          >=0, <=325
	TEN_SECOND,		// 5 AnalysisStart           >=0, <=TEN_SECOND
	MAX_ANALYSIS_INTERVAL,	// 6 AnalysisInterval        >=MIN_ANALYSIS_INTERVAL, <=MAX_ANALYSIS_INTERVAL
	MAX_DURATION*16,	// 7 AveragePeriod           >=MIN_DURATION*16, <=MAX_DURATION*16
	MAX_DURATION*4,		// 8 AveragePeriodEvaluation >MIN_DURATION*4, <=MAX_DURATION*4
	TEN_SECOND,		// 9 TempPeriod              >MIN_DURATION/2, <=TEN_SECOND
	B10mm*15,		// 10 TempAmplitudeDiff       >=0, <=B10mm*15
	150,			// 11 PulseCounter            >=0, <=150
	1024			// 12 MeasurementFlags        >0, < 1024

	};

unsigned *varibs[]={&SampleNumber,
	&SampleNumberShift,
	&MaxNumber,
	&MaxNumberShift,
	&AnalysisStart,
	&AnalysisInterval,
	&AveragePeriod,
	&AveragePeriodEvaluation,
	&TempPeriod,
	&TempAmplitudeDiff,
	&PulseCounter,
	&MeasurementFlags
	};
int x;
 for (x=0;x<11;x++)
  if ( (*varibs[x]<varib_down[x])||
       (*varibs[x]>varib_up[x])
     )
  code_error=x;





 if (MeasurementFlags>1024)
  code_error=eMeasurementFlags;


// StartMaxNumber          >0, <= 32
 if (StartMaxNumber>32)
  code_error=eStartMaxNumber;


// StepNumber              >0, MAX_STEP_NUMBER
 if (StepNumber>MAX_STEP_NUMBER)
  code_error=eStepNumber;

// HigherCount               Можно удалить.


// MaxDiffSignal           any
// MaxAverageAmplitude     any
// LastDiff2Max            any


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



// TempPeriodDiff          >=-MAX_DURATION, <=TEN_SECOND-MIN_DURATION/2
 if ( ((TempPeriodDiff+MAX_DURATION)<0)||(TempPeriodDiff>(TEN_SECOND-MIN_DURATION/2)) )
  code_error=eTempPeriodDiff;

// PressureTop             >=#LPRESS_40, <=LPRESS_270
 if ( (PressureTop<LPRESS_40)||(PressureTop>(LPRESS_270)) )
  code_error=ePressureTop;

// NewPressure		>=#LPRESS_20, <=LPRESS_280
 if ( (NewPressure<LPRESS_20)||(NewPressure>(LPRESS_280)) )
  code_error=eNewPressure;

// Perror                  <+-PRESS_80
 if (abs(Perror)>PRESS_80)
  code_error=ePerror;

 if (code_error) return code_error;
 else return 0;

}