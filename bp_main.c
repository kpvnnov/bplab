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
enum MDSPLV{SHOW_TIME,		//�뢮� �६��� �� ��ᯫ��
	SHOW_TIME_SECOND,	//�뢮� �६��� �� ��ᯫ��,� ᥪ㭤���
        SHOW_CHANNEL0,          //�������� �� ������ 0
        SHOW_CHANNEL1,		//�������� �� ������ 1
        SHOW_CHANNEL2,		//�������� �� ������ 2
	SHOW_BEGINMEASS,	//��砫� ����७�� ��������
	SHOW_ERROR,		//�뢮� ���� �訡�� �� �࠭
	SHOW_SPEED,		//᪮���� �� ������
	SHOW_UPPRESSURE,	//���孨� �।�� ����७�� ��������
	SHOW_SISTOL,		//�������� ��⮫��᪮�� ��������
	SHOW_DIASTOL,		//�������� ����⮫��᪮�� ��������
	SHOW_PULSE,		//�������� ����
	SHOW_CURRENT_PRESSURE,	//�������� ⥪�饣� �������� (�� ����窥)
	SHOW_2_NEXT		//᪮�쪮 �६��� ��⠫��� �� ᫥���饣� ����७��
       };

void display_copy(u8* symbol)
{
u8 i;
for (i=0;i<4;i++)
 iSYMBL[3-i]=*symbol++;
}
void display_pressure(s16 davl)
{
u16 davlenie= ((s32)davl+32768L)/204.8; //65536 - ������ 誠�� ࠢ�� 320 ��.��.��.
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
 case SHOW_TIME: 		//�뢮� �६��� �� ��ᯫ��
  display_copy(&WATCH[2]);
  break;
 case SHOW_TIME_SECOND:         //�뢮� �६��� �� ��ᯫ�� � ᥪ㭤���
  #if Sertificarion==1
   display_copy(TestTime);
  #else
   display_copy(WATCH);
  #endif
  break;
 case SHOW_CHANNEL0:		//�������� �� ������ 0
  display_pressure(OUTF);
  break;
 case SHOW_CHANNEL1:            //����饥 �������� ����� 1->�� ��ᯫ��
  break;
 case SHOW_CHANNEL2:            //����饥 �������� ����� 2->�� ��ᯫ��
  display_pressure(ResultADC[9]);
  break;
 case SHOW_BEGINMEASS:		//��砫� ����७�� ��������
  break;
 case SHOW_ERROR:		//�뢮� ���� �訡�� �� �࠭
  break;
 case SHOW_SPEED:		//᪮���� �� ������
  break;
 case SHOW_UPPRESSURE:		//���孨� �।�� ����७�� ��������
  break;
 case SHOW_SISTOL:		//�������� ��⮫��᪮�� ��������
  break;
 case SHOW_DIASTOL:		//�������� ����⮫��᪮�� ��������
  break;
 case SHOW_PULSE:		//�������� ����
  break;
 case SHOW_CURRENT_PRESSURE:	//�������� ⥪�饣� �������� (�� ����窥)
  break;
 case SHOW_2_NEXT:		//᪮�쪮 �६��� ��⠫��� �� ᫥���饣� ����७��
  break;
 delault:
  break;
 }
}


unsigned short compute(unsigned short shift,unsigned short value)
{
// K= 270(��.��.��) / (262+ᬥ饭��)
// 320 ��.��.��. = 65536
// 270 ��.��.��. = 55296.0
// 262 ��.��.��. = 53657.6


return value*55296L/(53658+shift);
}