//Start_shift
void start_shift()
 switch(SubroutMode){
//	LACC    SubroutMode,1
//	ADD     #Start_shift_branch
//	BACC

//Start_shift_branch
//	B	Start_shift1
//	B	Start_shift1_1
//	B	Start_shift2
//	B	Start_shift3
  case 0:
//Start_shift1
//;AVR ⮦� ���� ᬥ饭�� �����뢠��
//;���⮬� "����७��" �� ��� ����� �।��饣� ᬥ饭��
//;㡨ࠥ�
// *	MAR  	*,AR2
// *	LAR  	AR2,#LastMeas
//	;� �祭�� ��� ����� ᬥ饭�� ����⢨⥫쭮
// *	LACC	*
// *	BCND	Start_shift_without,NEQ	;���⮬� ����� ��� �� �㤥�

//	mNext_sub_mode
//	SPLK 	#3h,_MDSPL 	;���室�� �� �஢��� ��������
// .if WriteDebug=0
//	mWait 1			;��譨� 3 ᥪ㭤� ��� �� � 祬�
// .else
//	mWait3sek		;3 ᥪ㭤� ��ᢥ稢��� �஢��� ��������
// .endif
//	RET

//Start_shift1_1:
//	mDec_counter		;CNTMOD--
//	RETC 	GT
//	mNext_sub_mode
//	LACC 	#0
//	SACL 	Preset0		;���� � ��砫쭮� ���祭�� ��������
//	SACL 	Preset0+1
//	SACL 	Preset0+2
  
//	SPLK 	#64,ModeCnt  ;����� 䨫��� ��஢�����
//	RET
   Preset0=0;

//Start_shift2:
//	mDec_counter		;CNTMOD--
//	RETC 	GT

//	SendToDAC

//	mNext_sub_mode
   SubroutMode++;
//	SPLK 	#256,ModeCnt	;��।����� ���祭�� � ������
   ModeCnt=256;
//	RET
   break;
  case 1:
//Start_shift3:
//	CLRC 	SXM

//	MAR	*,AR6
//	LAR	AR6,#_ResultADC+6;AIN6 (PR0) ���祭�� �� ��室� ���稪�

// *	LACC 	Channel_one,8  	;���᫥��� �।���� �� 3-� �������
//	LACC 	*,8  	;���᫥��� �।���� �� 3-� �������
//	ADD  	#4000h,9
//	AND  	#0FFFFh,8
//	ADD  	Preset0+1,16
//	ADDS 	Preset0+2
//	SACH 	Preset0+1,0
//	SACL 	Preset0+2,0
   Preset0+=ResultADC[6];
//	mDec_counter		;CNTMOD--
//	RETC GT
   ModeCnt--;
   if (ModeCnt>0) return;

//	LACC 	Preset0+1
//	SACL	Preset0
   Preset0>>=16;
//*Start_shift_without
//	MAR  	*,AR2
//	LAR  	AR2,#LastMeas
//	;� �祭�� ��� ����� ᬥ饭�� ����⢨⥫쭮
//	SPLK	#3*60,*		;� ᥪ㭤�� �६�

//	SPLK 	#PRESSURE_AUGMENT_40,Mode
//        mClear_subrout_mode_err_meas
//	SPLK 	#iCURRENT_PRESSURE,_MDSPL 	;���室�� �� �஢��� ��������
//        RET
   Mode=PRESSURE_AUGMENT_40;
   MDSPL=iCURRENT_PRESSURE;
   break;
  default: error();
  }
}
