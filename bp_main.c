// $Id: bp_main.c,v 1.2 2001-08-22 14:17:45 peter Exp $

#include "global.h"

extern s16 ResultADC[];
extern u8 WATCH[];
extern u8 MDSPL;
extern u8 iSYMBL[];
extern s16 OUTF;

void main(void)
{
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