// $Id: bp_main.c,v 1.3 2001-10-11 12:39:51 peter Exp $

#include "global.h"

#include <ioports.h>

extern s16 ResultADC[];
extern u8 * WATCH;
extern u8 MDSPL;
extern u8 iSYMBL[];
extern s16 OUTF;

unsigned short flags;

extern unsigned short rDIOSR;

#define portIOSR	portFFF6
volatile ioport unsigned portIOSR;



static inline void off_periph()
{
//	LACC 	_rDIOSR
//	OR	#07H		;дешифратор
//	SACL 	_rDIOSR
 rDIOSR|=0x07;	//выключаем выборку устройств
}
static inline void out_diosr()
{
//	OUT  	rDIOSR,IOSR      ;записываем в IO status register
 portIOSR=rDIOSR;
}

static inline void on_avr_spi()
{
//	LACC 	_rDIOSR
//	AND  	#08H  		;сбрасываем в ноль #RSAVD
//	OR	#04H		;дешифратор
//	SACL 	_rDIOSR
 rDIOSR&=0x08;		//сбрасываем в ноль #RSAVD
 rDIOSR|=0x04;		//дешифратор
}


void main(void)
{
//load_avr_state((unsigned short*)ResultADC);
//load_avr_time((unsigned short*)ResultADC);
}
enum MDSPLV{SHOW_TIME,		//вывод времени на дисплей
	SHOW_TIME_SECOND,	//вывод времени на дисплей,с секундами
        SHOW_CHANNEL0,          //давление на канале 0
        SHOW_CHANNEL1,		//давление на канале 1
        SHOW_CHANNEL2,		//давление на канале 2
	SHOW_BEGINMEASS,	//начало измерения давления
	SHOW_ERROR,		//вывод кода ошибки на экран
	SHOW_SPEED,		//скорость по обмену
	SHOW_UPPRESSURE,	//верхний предел измерения давления
	SHOW_SISTOL,		//индикация систолического давления
	SHOW_DIASTOL,		//индикация диастолического давления
	SHOW_PULSE,		//индикация пульса
	SHOW_CURRENT_PRESSURE,	//индикация текущего давления (при накачке)
	SHOW_2_NEXT		//сколько времени осталось до следующего измерения
       };

void display_copy(u8* symbol)
{
u8 i;
for (i=0;i<4;i++)
 iSYMBL[3-i]=*symbol++;
}
void display_pressure(s16 davl)
{
u16 davlenie= ((s32)davl+32768L)/204.8; //65536 - полная шкала равна 320 мм.рт.ст.
  iSYMBL[3]=davlenie%10;
  davlenie/=10;
  iSYMBL[2]=davlenie%10;
  davlenie/=10;
  iSYMBL[1]=davlenie%10;
  iSYMBL[0]=S_SPACE;
}
enum FLASH_ACTION {FLASH_CLEAR,FLASH_ERASE,FLASH_PROGRAM};


void display_persent(u8 cod,u8 perc)
{
  iSYMBL[3]=(perc&0x0FF);
  iSYMBL[2]=(perc&0x0FF00)>>8;
  iSYMBL[1]=S_SPACE;
  switch(cod){
   case FLASH_CLEAR:
    iSYMBL[0]=S_C;
    break;
   case FLASH_ERASE:
    iSYMBL[0]=S_E;
    break;
   case FLASH_PROGRAM:
    iSYMBL[0]=S_P;
    break;
  }
}

void mdsplv()
{
u16 davlenie;
display_persent(1,2);
switch(MDSPL){
 case SHOW_TIME: 		//вывод времени на дисплей
  display_copy(&WATCH[2]);
  break;
 case SHOW_TIME_SECOND:         //вывод времени на дисплей с секундами
  #if Sertificarion==1
   display_copy(TestTime);
  #else
   display_copy(WATCH);
  #endif
  break;
 case SHOW_CHANNEL0:		//давление на канале 0
  display_pressure(OUTF);
  break;
 case SHOW_CHANNEL1:            //Текущее давление Канал 1->на дисплей
  break;
 case SHOW_CHANNEL2:            //Текущее давление Канал 2->на дисплей
  display_pressure(ResultADC[9]);
  break;
 case SHOW_BEGINMEASS:		//начало измерения давления
  break;
 case SHOW_ERROR:		//вывод кода ошибки на экран
  break;
 case SHOW_SPEED:		//скорость по обмену
  break;
 case SHOW_UPPRESSURE:		//верхний предел измерения давления
  break;
 case SHOW_SISTOL:		//индикация систолического давления
  break;
 case SHOW_DIASTOL:		//индикация диастолического давления
  break;
 case SHOW_PULSE:		//индикация пульса
  break;
 case SHOW_CURRENT_PRESSURE:	//индикация текущего давления (при накачке)
  break;
 case SHOW_2_NEXT:		//сколько времени осталось до следующего измерения
  break;
 delault:
  break;
 }
}


unsigned short compute(unsigned short shift,unsigned short value)
{
// K= 270(мм.рт.ст) / (262+смещение)
// 320 мм.рт.ст. = 65536
// 270 мм.рт.ст. = 55296.0
// 262 мм.рт.ст. = 53657.6


return value*55296L/(53658+shift);
}


//void three_imp_ssp_avr();
//void three_imp_ssp();
//void clk_xf_avr();
//void clk_xf();

void clk_xf_avr()
{
unsigned short x;
 for (x=0;x<8;x++){
  asm("	CLRC 	XF");
  asm("	SETC 	XF");
 }
 asm("	RPT	#12");
 asm("	NOP");
 for (x=0;x<8;x++){
  asm("	CLRC 	XF");
  asm("	SETC 	XF");
 }
}



static inline void clk_xf()
{
unsigned short x;
 for (x=0;x<16;x++){
  asm("	CLRC 	XF");
  asm("	SETC 	XF");
 }
}

static inline void three_imp_ssp()	
{
unsigned short x;
 for (x=0;x<3;x++){
  asm("	CLRC 	XF");
  asm("	SETC 	XF");
 }
}

//#define	SSPCR	0xFFF1
//#define	SDTR	0xFFF0
#define	portSDTR	portFFF0
#define	portSSPCR	portFFF1

//SSPS - FREE,SOFT,TCOMP,RFNE,FT1,FT0,FR1,FR0,OVM,IN0,XRST,RRST,TXM,MCM,FSM,DLB
#define	SSPS    0xCC38   	//SSP start
#define SSPR	0xCC08   	//reset SSP

volatile ioport unsigned portSDTR;
volatile ioport unsigned portSSPCR;

void send_command_avr(unsigned short* to_avr,unsigned short* from_avr,unsigned char count)
{
unsigned char counter_out;
 portSSPCR=SSPS;		//SSP start
// counter_out=portSDTR; 				
 portSDTR;          		//команда лишнего чтения(!??)
				//для стабильности(надежности) работы с SSP
 counter_out=count;
 portSDTR=*to_avr++;
 counter_out--;
 if (counter_out)
 {
  portSDTR=*to_avr++;
  counter_out--;
 }
// three_imp_ssp_avr();
 three_imp_ssp();
 on_avr_spi();
 out_diosr();		//передаем выборку в порт
 while(counter_out)
 {
  portSDTR=*to_avr++;
  clk_xf_avr();
  *from_avr=portSDTR;
  *from_avr++^=0xFFFF;
  counter_out--;
  count--;
 }
 clk_xf_avr();
 *from_avr=portSDTR;
 *from_avr++^=0xFFFF;
 count--;
 if (count)
 {
  clk_xf_avr();
  *from_avr=portSDTR;
  *from_avr^=0xFFFF;
 }
 off_periph();
 out_diosr();		//передаем выборку в порт

}




#define LOAD_ATEMPT	10

unsigned short load_avr_state(unsigned short* read_from_avr)
{
 unsigned char check_child;
 unsigned char counter;
 unsigned short send_to_avr[2];
// unsigned short read_from_avr[2];
 send_to_avr[0]=0x00FE;	//команда состоит из четырех байт(двух слов)
 send_to_avr[1]=0xFEFE;	//00h - System State (второе слово - незначещее)
 counter=LOAD_ATEMPT;
 do
 {
  send_command_avr(&send_to_avr[0],read_from_avr,2);//читает два слова из массива
				//и записывает два слова в массив
  check_child=read_from_avr[1]>>8;
  if (check_child==0x0A5 ||check_child==0x05A) break;
 } while ((--counter)!=0);
 return counter;
}

unsigned short load_avr_time(unsigned short* read_from_avr)
{
 unsigned char check_correct;
 unsigned char counter;
 unsigned short send_to_avr[3];
// unsigned short read_from_avr[3];
 send_to_avr[0]=0x22FE;	//команда состоит из шести байт(трех слов)
 send_to_avr[1]=0xFEFE;	//22h - Read Time (второе,третье слово - незначещее)
 send_to_avr[2]=0xFEFE;
 counter=LOAD_ATEMPT;
 do
 {
  send_command_avr(&send_to_avr[0],read_from_avr,3);//читает три слова из массива
				//и записывает три слова в массив
  check_correct=read_from_avr[2]&0x00FF;
  if (check_correct==0x0EE) break;
 } while ((--counter)!=0);
 return counter;
}
static inline void on_adc()
{
//	LACC 	rDIOSR
//	AND  	#0EH  		;сбрасываем в ноль IO0(#CS0)
//	SACL 	rDIOSR
 rDIOSR&=0x0e;	//сбрасываем в ноль IO0(#CS0)
}
void adc_power_down()
{
 asm("	SETC 	XF");
//	SPLK 	#SSPS,TMP    ;SSP start
//	OUT  	TMP,SSPCR    ;Synchronous Serial Port Control Register
 portSSPCR=SSPS;	//SSP start
//	IN   	TMP,SDTR     ;команда лишнего чтения
//				;для стабильности(надежности) работы с SSP
 portSDTR;	//команда лишнего чтения
 		//для стабильности(надежности) работы с SSP
//	SPLK 	#0EC00h,TMP  ;software power down
//	OUT  	TMP,SDTR
 portSDTR=0x0EC00;	//software power down

//	mImp_ssp              ;подгоняем SSP к началу передачи MSB
//	mImp_ssp
//	mImp_ssp
 three_imp_ssp();	//подгоняем SSP к началу передачи MSB
//	mOnADC
 on_adc();		//включаем выборку АЦП
//	mOutDIOSR
 out_diosr();		//передаем выборку АЦП в порт

//	CALL 	CLKXF           ;1-передаем первое слово
 clk_xf();		//1-передаем первое слово
//	mOffPeriph
 off_periph();		//отключаем выборку
//	mOutDIOSR
 out_diosr();		//передаем выборку в порт
 
//	IN   	TMP,SDTR     ;команда лишнего чтения
//	IN   	TMP,SDTR     ;команда лишнего чтения
 portSDTR;	//команда лишнего чтения
 portSDTR;	//команда лишнего чтения

//	SPLK 	#SSPR,TMP    ;RESET SSP
//	OUT  	TMP,SSPCR
 portSSPCR=SSPR;	//RESET SSP

}

#define MONITOR_NOT_PROGRAM 0x0001&flags
#define BAD_TIME	1
//проверка инициализации времени (установки при программировании)
//*******************
//* проверяет время на валидность
//* время по указателю AR7
//* формат единицы минут, десятки минут, единицы часов, десятки часов
//* ACC=0 все OK
//extern unsigned short* WATCH;

unsigned short check_time() 
{
//	LACC	*+
//	SUB	#9
//	BCND	ErrorCheck,GT	;количество единиц минут >9
 if (WATCH[2]>9 ||

//        LACC	*+
//	SUB	#5
//	BCND	ErrorCheck,GT	;количество десяток минут >5

     WATCH[3]>5 ||

//	LACC	*
//	SUB	#9
//	BCND	ErrorCheck,GT	;количество единиц минут >9
     WATCH[4]>9 ||
     WATCH[5]>2			//десятки минут должны быть 0-2
    )
	return 1;
//дополнительно проверяем валидность 24 часов
    if ((WATCH[5]+WATCH[4]*10)>24)
     return 1;
    return 0;
//        switch(WATCH[5]) {	//десятки минут
//	if (WATCH[4]>3)

}

extern unsigned short * DayTimeInter;
extern unsigned short * FLADR;
extern unsigned short ShedulerReady;
extern unsigned short DispErrMeas;
extern unsigned short Jobs;

#define rMONITOR_NOT_PROGRAMM 031

#define BAD_RANGE_DAY		01
#define BAD_RANGE_NIGHT         02
#define BAD_RANGE_SPECIAL       03
#define BAD_CHILD_MODE		04

#define CHILDMODE	0x35
#define AGE		0x18
#define PARAMETRS_SH    0x32


//	;   5432 1098 7654 3210
//	;   !!!! !!!! !!!! !!!+ - измерять давление?
//	;   !!!! !!!! !!!! !!+  - пищать ?
//	;   !!!! !!!! !!!! !+   - последовательный порт работает?
//	;   !!!! !!!! !!!! +    - записываем в ЦАП?
//	;   !!!! !!!! !!!+     - надо загнать в ЦАП значение,и
//	;   !!!! !!!! !!!      - установить сброс значения в канал
//	;   !!!! !!!! !!+      - записать значение ЦАП в ячейку для обсчета?
//	;   !!!! !!!! !+       	- высокой тональности и длительности писк
//	;   !!!! !!!! +	     - вызывать ADCPRO ?
//	;   !!!! !!!+	     - пишем во флеш ?
//	;   !!!! !!+		- мониторирование включено
//	;   !!!! !+		- мотор включен?
//	;   !!!! +		- можно пищать ?
//	;   !!!+		- можно ли показывать результаты измерения
//	;   !!+ 		- измерение было "ручным"
//	;   !+			- мы подсчитали количество измерений во флеш
//	;   +			- отсутствие места во флеш для сфинмограммы

//;измерять давление ?
#define CallMeasur_Flag	0	//нулевой бит

//;пищать ?
#define BeepLittle_Flag 1	//первый бит

//;записываем в ЦАП?
#define SendToDAC_Flag	3	//третий бит

//;записать значение ЦАП в ячейку для обсчета?
#define ReadDACVal_Flag	5	//;пятый бит

#define BeepLong_Flag	6       //;шестой бит
//;вычисление значений для операции BIT Flag,BeepLongPos
//;BeepLongPos	.set	(15-BeepLong_Flag)


#define CallADCPRO_Flag	7	//;седьмой бит

#define BegWrFlash_Flag	8	//;восьмой бит

#define OnInterval_Flag	9	//;девятый бит

#define MotorIsOnn_Flag	10	//;десятый бит

#define MayBeeping_Flag	11	//;одинадцатый бит

#define MayShowRes_Flag	12	//;двенадцатый бит

#define Manual_Meas	13 	//;тринадцатый бит

#define WeCountingFlash 14	//;четырнадцатый бит
				//;мы подсчитали количество измерений во флеш
#define NoPlaceInFlash	15	//;пятнадцатый бит
				//;отсутствие места во флеш для сфинмограммы

static inline void on_result()
{
	Jobs|=(1<<MayShowRes_Flag);
}
static inline void off_result()
{
	Jobs&=~(1<<MayShowRes_Flag);
}

static inline void on_sound()
{
 	Jobs|=(1<<MayBeeping_Flag);
}
static inline void  off_sound()
{
	Jobs&=~(1<<MayBeeping_Flag);
}

static inline void off_scheduler()
{
	Jobs&=~(1<<OnInterval_Flag);
}


// установка текущего времени в ноль :(
static inline void reset_time()
{
unsigned short x;
 for (x=0;x<7;x++)
 {
	WATCH[x]=0;
 }
}

unsigned short check_intervals()
{
unsigned short result=0;
unsigned short child_mode;
unsigned short child_age;
 if (check_time())
  result=BAD_TIME;


// проверка интервалов измерения прибора
//дневной интервал между измерениями 	+0
//ночной интервал между измерениями  	+1
//специальный интервал между измерениями +2
// в секундах
 if (DayTimeInter[0]<3)	//дневной интервал между измерениями
  result=BAD_RANGE_DAY;
 if (DayTimeInter[1]<3)	//ночной интервал между измерениями
  result=BAD_RANGE_NIGHT;
 if (DayTimeInter[2]<3)	//специальный интервал между измерениями
  result=BAD_RANGE_SPECIAL;
// конец проверки интервалов

//************************************
//* проверка программирования детского режима
//;изначально считаем, что
//;команда не может быть выполнена из-за запрещенного сочетания параметров
//;программирования

//	SPLK	#0AAh,TMP+1
//	MAR  	*,AR7
//	LAR	AR7,#MayModify+1
//	SPLK	#05Ah,*		;по умолчанию на детский режим


//;по данному адресу находится Age
//* Возраст Менее 14  лет - считается ребенком
//	SPLK	#0,FLADR+1
//	SPLK	#0200h+Age,FLADR
//	CALL	FLREAD
//	SACL	TMP+2
//;по данному адресу находится ChildMode
//* Детский/взрослый 5Ah - детский A5h - взрослый
//	SPLK	#0,FLADR+1
//	SPLK	#0200h+ChildMode,FLADR
	FLADR[0]=0x200+CHILDMODE;
	FLADR[1]=0;
//	CALL	FLREAD
	child_mode=flash_read();
//	SACL	TMP

//        XOR	#05Ah
//	BCND	Child_OK,EQ	;детский режим валиден
//	XOR	#0FFh
//	BCND	Child_OK,EQ	;взрослый режим валиден
//Age_False:
//	mOff_Interval
//	SPLK	#0,ShedulerReady
//	SPLK	DispErrMeas,rMONITOR_NOT_PROGRAMM
//	B	Child_Check_OK

        if ((child_mode!=0x5A)&&(child_mode!=0x0A5))
         result=BAD_CHILD_MODE;


//Child_OK:
	FLADR[0]=0x200+AGE;
	FLADR[1]=0;
	child_age=flash_read();
//	LACC	TMP+2		;проверяем возраст пациента
//	SUB	#14
//	;если он меньше 14, надо проверить байтовую
//	;установку детского режима
	if (child_age>=14)
        {
//	BCND	CheckChildSet,LT
//	;иначе это взрослый режим

//	LACC	TMP
//	XOR	#0A5h
//	BCND	Age_False,NEQ
         if (child_mode!=0x0A5)
          result=BAD_CHILD_MODE;
        }

//	SPLK	#0h,TMP+1	;прибор запрограммирован на взрослый режим
//	MAR  	*,AR7
//	LAR	AR7,#MayModify+1
//	SPLK	#0A5h,*		;взрослый режим
//	B	ChildAge_Check_OK
	else	//проверяем байтовую установку детского режима
        {

//CheckChildSet:
//	;проверяем байтовую установку детского режима
         if (child_mode!=0x05A)
          result=BAD_CHILD_MODE;
        }
//	LACC	TMP
//	XOR	#05Ah
//	BCND	Age_False,NEQ
//	SPLK	#066h,TMP+1	;прибор запрограммирован на детский режим

//ChildAge_Check_OK:
//Child_Check_OK:
//* конец проверки программирования детского режима

//* проверяем бит разрешения звукового сигнала
//	mOffSound

//	SPLK	#0,FLADR+1
//	SPLK	#0200h+ParametrsSh,FLADR
//	CALL	FLREAD
	FLADR[0]=0x200+PARAMETRS_SH;
	FLADR[1]=0;
	if ((child_mode=flash_read())&0x01)
         on_sound();
        else
         off_sound();
//        SACL	TMP
//	AND	#01h
//        BCND	NoEnableSound,EQ
//        mOnSound
//NoEnableSound:
//*конец проверки бита разрешения

//* проверка бита разрешения выдачи результатов
//	mOffResult

	if (child_mode&0x02)
         on_result();
        else 
         off_result();
//        LACC	TMP
//	AND	#02h
//        BCND	NoEnableResult,EQ
//        mOnResult
//NoEnableResult:
//* конец проверки бита разрешения выдачи результатов

 if (result){
  reset_time(); 	//установка времени в ноль
//	mOff_Interval
  off_scheduler();	//выключаем щедулер
  ShedulerReady=0;	//щедулер не готов к запуску
  DispErrMeas=rMONITOR_NOT_PROGRAMM;
  			//вывод сообщения на индикатор
  }
 return result;

}