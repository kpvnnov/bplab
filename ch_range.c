enum error_range{
 eSampleNumber=1,		//1   0x01
 eSampleNumberShift,    	//2   0x02
 eMaxNumber,            	//3   0x03
 eMaxNumberShift,               //4   0x04
 eAnalysisStart,                //5   0x05
 eAnalysisInterval,             //6   0x06
 eAveragePeriod,                //7   0x07
 eAveragePeriodEvaluation,      //8   0x08
 eTempPeriod,                   //9   0x09
 eTempAmplitudeDiff,            //10  0x0A
 ePulseCounter,                 //11  0x0B
 eMeasurementFlags,             //12  0x0C
 eStartMaxNumber,               //13  0x0D
 eStepNumber,                   //14  0x0E
 eSistolPressureAmplitude,      //15  0x0F
 eAugmentPressureNumber,        //16  0x10
 eMode,                         //17  0x11
 eModeCnt,                      //18  0x12
 eSubroutMode,                  //19  0x13
 eDimModeSampleCounter,         //20  0x14
 eDimMode,                      //21  0x15
 eTdimstart,                    //22  0x16
 ePreturn,                      //23  0x17
 eCodeError,                    //24  0x18
 eMax2DiffAdress_0,             //25  0x19
 eMax2DiffAdress_1,             //26  0x1A
 eMax2DiffAdress_2,             //27  0x1B
 eDuration_0,                   //28  0x1C
 eDuration_1,                   //29  0x1D
 eDuration_2,                   //30  0x1E

 eTempPeriodDiff,               //31  0x1F
 ePressureTop,                  //32  0x20
 eNewPressure,                  //33  0x21
 ePerror,                       //34  0x22
 ePclose                        //35  0x23
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
extern int Pclose;
extern unsigned int CodeError;
extern unsigned int Max2DiffAdress[];
extern unsigned int Duration[];

extern int TempPeriodDiff;
extern int PressureTop,NewPressure;
extern int Perror;


const unsigned varib_down_const[]={0,	// 1 SampleNumber            >=0, <=TEN_SECOND
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
	0,			// 12 MeasurementFlags        >0, < 1024
	0,			// 13 StartMaxNumber          >0, <= 32
	0,			// 14 StepNumber              >0, MAX_STEP_NUMBER
	B0_1mm,			// 15 SistolPressureAmplitude >=B0_1mm, <=B4mm
	0,			// 16 AugmentPressureNumber   >=0, <=3
	0,			// 17 Mode                    >=0, <=14
	0,			// 18 ModeCnt			>=0, <=15000 or <=code
	0,			// 19 SubroutMode		>=0, <=5
	0,			// 20 DimModeSampleCounter    >=0, <=ONE_SECOND*4
	0,			// 21 DimMode                 >=0, <=5
	0,			// 22 Tdimstart               >=0, <=ONE_SECOND*4
	0,			// 23 Preturn                 >=0, <=PRESS_80
	0,			// 24 CodeError               >=0, <=1
	0,			// 25 Max2DiffAdress[0]       >=0, <=TWO_MINUTES
	0,			// 26 Max2DiffAdress[1]       >=0, <=TWO_MINUTES
	0,			// 27 Max2DiffAdress[2]       >=0, <=TWO_MINUTES
	0,			// 28 Duration[0]             >=0, <=TEN_SECOND
	0,			// 29 Duration[1]             >=0, <=TEN_SECOND
	0			// 30 Duration[2]             >=0, <=TEN_SECOND

	};

const unsigned varib_up_const[]={TEN_SECOND+1,// 1  SampleNumber            >=0, <=TEN_SECOND+1
	TWO_MINUTES,		// 2  SampleNumberShift       >=0, <=TWO_MINUTES
	32,			// 3  MaxNumber               >=0, <=32
	325,			// 4  MaxNumberShift          >=0, <=325
	TEN_SECOND,		// 5  AnalysisStart           >=0, <=TEN_SECOND
	MAX_ANALYSIS_INTERVAL,	// 6  AnalysisInterval        >=MIN_ANALYSIS_INTERVAL, <=MAX_ANALYSIS_INTERVAL
	MAX_DURATION*16,	// 7  AveragePeriod           >=MIN_DURATION*16, <=MAX_DURATION*16
	MAX_DURATION*4,		// 8  AveragePeriodEvaluation >MIN_DURATION*4, <=MAX_DURATION*4
	TEN_SECOND,		// 9  TempPeriod              >MIN_DURATION/2, <=TEN_SECOND
	B10mm*15,		// 10 TempAmplitudeDiff       >=0, <=B10mm*15
	150,			// 11 PulseCounter            >=0, <=150
	1024,			// 12 MeasurementFlags        >0, < 1024
	32,			// 13 StartMaxNumber          >0, <= 32
	MAX_STEP_NUMBER,	// 14 StepNumber              >0, MAX_STEP_NUMBER
	B4mm,			// 15 SistolPressureAmplitude >=B0_1mm, <=B4mm
	3,			// 16 AugmentPressureNumber   >=0, <=3
	14,			// 17 Mode                    >=0, <=14
	15000,			// 18 ModeCnt			>=0, <=15000 or <=code
	5,			// 19 SubroutMode		>=0, <=5
	ONE_SECOND*4,		// 20 DimModeSampleCounter    >=0, <=ONE_SECOND*4
	5,			// 21 DimMode                 >=0, <=5
	ONE_SECOND*4,		// 22 Tdimstart               >=0, <=ONE_SECOND*4
	PRESS_80,		// 23 Preturn                 >=0, <=PRESS_80
	1,			// 24 CodeError               >=0, <=1
	TWO_MINUTES,		// 25 Max2DiffAdress[0]       >=0, <=TWO_MINUTES
	TWO_MINUTES,		// 26 Max2DiffAdress[1]       >=0, <=TWO_MINUTES
	TWO_MINUTES,		// 27 Max2DiffAdress[2]       >=0, <=TWO_MINUTES
	TEN_SECOND,		// 28 Duration[0]             >=0, <=TEN_SECOND
	TEN_SECOND,		// 29 Duration[1]             >=0, <=TEN_SECOND
	TEN_SECOND		// 30 Duration[2]             >=0, <=TEN_SECOND

	};


const unsigned * const varibs_const[]={&SampleNumber,	//1
	&SampleNumberShift,             //2
	&MaxNumber,                     //3
	&MaxNumberShift,                //4
	&AnalysisStart,                 //5
	&AnalysisInterval,              //6
	&AveragePeriod,                 //7
	&AveragePeriodEvaluation,       //8
	&TempPeriod,                    //9
	&TempAmplitudeDiff,             //10
	&PulseCounter,                  //11
	&MeasurementFlags,              //12
 	&StartMaxNumber,          	//13
	&StepNumber,              	//14
 	&SistolPressureAmplitude, 	//15
 	&AugmentPressureNumber,   	//16
 	&Mode,                    	//17
 	&ModeCnt,			//18
 	&SubroutMode,		 	//19
 	&DimModeSampleCounter,    	//20
 	&DimMode,                 	//21
 	&Tdimstart,               	//22
 	&Preturn,                 	//23
 	&CodeError,               	//24
 	&Max2DiffAdress[0],       	//25
 	&Max2DiffAdress[1],       	//26
 	&Max2DiffAdress[2],       	//27
 	&Duration[0],             	//28
 	&Duration[1],             	//29
 	&Duration[2]             	//30

	} ;

void prg2mem(void *target,void * source, unsigned count);

unsigned check_range()
{
// * Список переменных и их возможные диапазоны значений
unsigned short code_error=0;



unsigned varib_up[31];
unsigned varib_down[31];
unsigned * varibs[31];
int x;
prg2mem((void *)varib_up,(void *)varib_up_const,31);
prg2mem((void *)varib_down,(void *)varib_down_const,31);
prg2mem((void *)varibs,(void *)varibs_const,31);
 for (x=0;x<30;x++)
  if ( (*varibs[x]<varib_down[x])||
       (*varibs[x]>varib_up[x])
     )
  code_error=x+1;




// HigherCount               Можно удалить.


// MaxDiffSignal           any
// MaxAverageAmplitude     any
// LastDiff2Max            any


// SistolPressure		>=#LPRESS_60, <=LPRESS_280
// AveragePressure         >=#LPRESS_30, <=LPRESS_260
// DiastolPressure		>=#LPRESS_30, <=LPRESS_240



// ArtefactCount           Пока не используетс




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

//Pclose                  >=#LPRESS_20, <=LPRESS_280
 if ( (Pclose<LPRESS_20)||(Pclose>(LPRESS_280)) )
  code_error=ePclose;

 return code_error;

}

