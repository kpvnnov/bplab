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
//	OR	#07H		;�������
//	SACL 	_rDIOSR
 rDIOSR|=0x07;	//�몫�砥� �롮�� ���ன��
}
static inline void out_diosr()
{
//	OUT  	rDIOSR,IOSR      ;�����뢠�� � IO status register
 portIOSR=rDIOSR;
}

static inline void on_avr_spi()
{
//	LACC 	_rDIOSR
//	AND  	#08H  		;���뢠�� � ���� #RSAVD
//	OR	#04H		;�������
//	SACL 	_rDIOSR
 rDIOSR&=0x08;		//���뢠�� � ���� #RSAVD
 rDIOSR|=0x04;		//�������
}


void main(void)
{
//load_avr_state((unsigned short*)ResultADC);
//load_avr_time((unsigned short*)ResultADC);
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
 portSDTR;          		//������� ��譥�� �⥭��(!??)
				//��� �⠡��쭮��(���������) ࠡ��� � SSP
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
 out_diosr();		//��।��� �롮�� � ����
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
 out_diosr();		//��।��� �롮�� � ����

}




#define LOAD_ATEMPT	10

unsigned short load_avr_state(unsigned short* read_from_avr)
{
 unsigned char check_child;
 unsigned char counter;
 unsigned short send_to_avr[2];
// unsigned short read_from_avr[2];
 send_to_avr[0]=0x00FE;	//������� ��⮨� �� ����� ����(���� ᫮�)
 send_to_avr[1]=0xFEFE;	//00h - System State (��஥ ᫮�� - ������饥)
 counter=LOAD_ATEMPT;
 do
 {
  send_command_avr(&send_to_avr[0],read_from_avr,2);//�⠥� ��� ᫮�� �� ���ᨢ�
				//� �����뢠�� ��� ᫮�� � ���ᨢ
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
 send_to_avr[0]=0x22FE;	//������� ��⮨� �� ��� ����(��� ᫮�)
 send_to_avr[1]=0xFEFE;	//22h - Read Time (��஥,���� ᫮�� - ������饥)
 send_to_avr[2]=0xFEFE;
 counter=LOAD_ATEMPT;
 do
 {
  send_command_avr(&send_to_avr[0],read_from_avr,3);//�⠥� �� ᫮�� �� ���ᨢ�
				//� �����뢠�� �� ᫮�� � ���ᨢ
  check_correct=read_from_avr[2]&0x00FF;
  if (check_correct==0x0EE) break;
 } while ((--counter)!=0);
 return counter;
}
static inline void on_adc()
{
//	LACC 	rDIOSR
//	AND  	#0EH  		;���뢠�� � ���� IO0(#CS0)
//	SACL 	rDIOSR
 rDIOSR&=0x0e;	//���뢠�� � ���� IO0(#CS0)
}
void adc_power_down()
{
 asm("	SETC 	XF");
//	SPLK 	#SSPS,TMP    ;SSP start
//	OUT  	TMP,SSPCR    ;Synchronous Serial Port Control Register
 portSSPCR=SSPS;	//SSP start
//	IN   	TMP,SDTR     ;������� ��譥�� �⥭��
//				;��� �⠡��쭮��(���������) ࠡ��� � SSP
 portSDTR;	//������� ��譥�� �⥭��
 		//��� �⠡��쭮��(���������) ࠡ��� � SSP
//	SPLK 	#0EC00h,TMP  ;software power down
//	OUT  	TMP,SDTR
 portSDTR=0x0EC00;	//software power down

//	mImp_ssp              ;������塞 SSP � ��砫� ��।�� MSB
//	mImp_ssp
//	mImp_ssp
 three_imp_ssp();	//������塞 SSP � ��砫� ��।�� MSB
//	mOnADC
 on_adc();		//����砥� �롮�� ���
//	mOutDIOSR
 out_diosr();		//��।��� �롮�� ��� � ����

//	CALL 	CLKXF           ;1-��।��� ��ࢮ� ᫮��
 clk_xf();		//1-��।��� ��ࢮ� ᫮��
//	mOffPeriph
 off_periph();		//�⪫�砥� �롮��
//	mOutDIOSR
 out_diosr();		//��।��� �롮�� � ����
 
//	IN   	TMP,SDTR     ;������� ��譥�� �⥭��
//	IN   	TMP,SDTR     ;������� ��譥�� �⥭��
 portSDTR;	//������� ��譥�� �⥭��
 portSDTR;	//������� ��譥�� �⥭��

//	SPLK 	#SSPR,TMP    ;RESET SSP
//	OUT  	TMP,SSPCR
 portSSPCR=SSPR;	//RESET SSP

}

#define MONITOR_NOT_PROGRAM 0x0001&flags
#define BAD_TIME	1
//�஢�ઠ ���樠����樨 �६��� (��⠭���� �� �ணࠬ��஢����)
//*******************
//* �஢���� �६� �� ����������
//* �६� �� 㪠��⥫� AR7
//* �ଠ� ������� �����, ����⪨ �����, ������� �ᮢ, ����⪨ �ᮢ
//* ACC=0 �� OK
//extern unsigned short* WATCH;

unsigned short check_time() 
{
//	LACC	*+
//	SUB	#9
//	BCND	ErrorCheck,GT	;������⢮ ������ ����� >9
 if (WATCH[2]>9 ||

//        LACC	*+
//	SUB	#5
//	BCND	ErrorCheck,GT	;������⢮ ����⮪ ����� >5

     WATCH[3]>5 ||

//	LACC	*
//	SUB	#9
//	BCND	ErrorCheck,GT	;������⢮ ������ ����� >9
     WATCH[4]>9 ||
     WATCH[5]>2			//����⪨ ����� ������ ���� 0-2
    )
	return 1;
//�������⥫쭮 �஢��塞 ���������� 24 �ᮢ
    if ((WATCH[5]+WATCH[4]*10)>24)
     return 1;
    return 0;
//        switch(WATCH[5]) {	//����⪨ �����
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
//	;   !!!! !!!! !!!! !!!+ - �������� ��������?
//	;   !!!! !!!! !!!! !!+  - ����� ?
//	;   !!!! !!!! !!!! !+   - ��᫥����⥫�� ���� ࠡ�⠥�?
//	;   !!!! !!!! !!!! +    - �����뢠�� � ���?
//	;   !!!! !!!! !!!+     - ���� ������� � ��� ���祭��,�
//	;   !!!! !!!! !!!      - ��⠭����� ��� ���祭�� � �����
//	;   !!!! !!!! !!+      - ������� ���祭�� ��� � �祩�� ��� �����?
//	;   !!!! !!!! !+       	- ��᮪�� ⮭��쭮�� � ���⥫쭮�� ���
//	;   !!!! !!!! +	     - ��뢠�� ADCPRO ?
//	;   !!!! !!!+	     - ��襬 �� 䫥� ?
//	;   !!!! !!+		- ������஢���� ����祭�
//	;   !!!! !+		- ���� ����祭?
//	;   !!!! +		- ����� ����� ?
//	;   !!!+		- ����� �� �����뢠�� १����� ����७��
//	;   !!+ 		- ����७�� �뫮 "����"
//	;   !+			- �� �����⠫� ������⢮ ����७�� �� 䫥�
//	;   +			- ������⢨� ���� �� 䫥� ��� �䨭���ࠬ��

//;�������� �������� ?
#define CallMeasur_Flag	0	//�㫥��� ���

//;����� ?
#define BeepLittle_Flag 1	//���� ���

//;�����뢠�� � ���?
#define SendToDAC_Flag	3	//��⨩ ���

//;������� ���祭�� ��� � �祩�� ��� �����?
#define ReadDACVal_Flag	5	//;���� ���

#define BeepLong_Flag	6       //;��⮩ ���
//;���᫥��� ���祭�� ��� ����樨 BIT Flag,BeepLongPos
//;BeepLongPos	.set	(15-BeepLong_Flag)


#define CallADCPRO_Flag	7	//;ᥤ쬮� ���

#define BegWrFlash_Flag	8	//;���쬮� ���

#define OnInterval_Flag	9	//;������ ���

#define MotorIsOnn_Flag	10	//;������ ���

#define MayBeeping_Flag	11	//;��������� ���

#define MayShowRes_Flag	12	//;��������� ���

#define Manual_Meas	13 	//;�ਭ����� ���

#define WeCountingFlash 14	//;���ୠ���� ���
				//;�� �����⠫� ������⢮ ����७�� �� 䫥�
#define NoPlaceInFlash	15	//;��⭠���� ���
				//;������⢨� ���� �� 䫥� ��� �䨭���ࠬ��

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


// ��⠭���� ⥪�饣� �६��� � ���� :(
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


// �஢�ઠ ���ࢠ��� ����७�� �ਡ��
//������� ���ࢠ� ����� ����७�ﬨ 	+0
//��筮� ���ࢠ� ����� ����७�ﬨ  	+1
//ᯥ樠��� ���ࢠ� ����� ����७�ﬨ +2
// � ᥪ㭤��
 if (DayTimeInter[0]<3)	//������� ���ࢠ� ����� ����७�ﬨ
  result=BAD_RANGE_DAY;
 if (DayTimeInter[1]<3)	//��筮� ���ࢠ� ����� ����७�ﬨ
  result=BAD_RANGE_NIGHT;
 if (DayTimeInter[2]<3)	//ᯥ樠��� ���ࢠ� ����� ����७�ﬨ
  result=BAD_RANGE_SPECIAL;
// ����� �஢�ન ���ࢠ���

//************************************
//* �஢�ઠ �ணࠬ��஢���� ���᪮�� ०���
//;����砫쭮 ��⠥�, ��
//;������� �� ����� ���� �믮����� ��-�� ����饭���� ��⠭�� ��ࠬ��஢
//;�ணࠬ��஢����

//	SPLK	#0AAh,TMP+1
//	MAR  	*,AR7
//	LAR	AR7,#MayModify+1
//	SPLK	#05Ah,*		;�� 㬮�砭�� �� ���᪨� ०��


//;�� ������� ����� ��室���� Age
//* ������ ����� 14  ��� - ��⠥��� ॡ�����
//	SPLK	#0,FLADR+1
//	SPLK	#0200h+Age,FLADR
//	CALL	FLREAD
//	SACL	TMP+2
//;�� ������� ����� ��室���� ChildMode
//* ���᪨�/����� 5Ah - ���᪨� A5h - �����
//	SPLK	#0,FLADR+1
//	SPLK	#0200h+ChildMode,FLADR
	FLADR[0]=0x200+CHILDMODE;
	FLADR[1]=0;
//	CALL	FLREAD
	child_mode=flash_read();
//	SACL	TMP

//        XOR	#05Ah
//	BCND	Child_OK,EQ	;���᪨� ०�� �������
//	XOR	#0FFh
//	BCND	Child_OK,EQ	;����� ०�� �������
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
//	LACC	TMP+2		;�஢��塞 ������ ��樥��
//	SUB	#14
//	;�᫨ �� ����� 14, ���� �஢���� ���⮢��
//	;��⠭���� ���᪮�� ०���
	if (child_age>=14)
        {
//	BCND	CheckChildSet,LT
//	;���� �� ����� ०��

//	LACC	TMP
//	XOR	#0A5h
//	BCND	Age_False,NEQ
         if (child_mode!=0x0A5)
          result=BAD_CHILD_MODE;
        }

//	SPLK	#0h,TMP+1	;�ਡ�� ���ணࠬ��஢�� �� ����� ०��
//	MAR  	*,AR7
//	LAR	AR7,#MayModify+1
//	SPLK	#0A5h,*		;����� ०��
//	B	ChildAge_Check_OK
	else	//�஢��塞 ���⮢�� ��⠭���� ���᪮�� ०���
        {

//CheckChildSet:
//	;�஢��塞 ���⮢�� ��⠭���� ���᪮�� ०���
         if (child_mode!=0x05A)
          result=BAD_CHILD_MODE;
        }
//	LACC	TMP
//	XOR	#05Ah
//	BCND	Age_False,NEQ
//	SPLK	#066h,TMP+1	;�ਡ�� ���ணࠬ��஢�� �� ���᪨� ०��

//ChildAge_Check_OK:
//Child_Check_OK:
//* ����� �஢�ન �ணࠬ��஢���� ���᪮�� ०���

//* �஢��塞 ��� ࠧ�襭�� ��㪮���� ᨣ����
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
//*����� �஢�ન ��� ࠧ�襭��

//* �஢�ઠ ��� ࠧ�襭�� �뤠� १���⮢
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
//* ����� �஢�ન ��� ࠧ�襭�� �뤠� १���⮢

 if (result){
  reset_time(); 	//��⠭���� �६��� � ����
//	mOff_Interval
  off_scheduler();	//�몫�砥� 饤㫥�
  ShedulerReady=0;	//饤㫥� �� ��⮢ � ������
  DispErrMeas=rMONITOR_NOT_PROGRAMM;
  			//�뢮� ᮮ�饭�� �� ��������
  }
 return result;

}