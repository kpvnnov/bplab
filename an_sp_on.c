void an_sp_up()
{
//	LACC    SubroutMode,1
//	ADD     #LevelZero_branch
//	BACC

//LevelZero_branch
//	B	LevelZero0
//	B	LevelZero1
//	B	LevelZero2

//Onn_Izmer
//	SPLK 	#0h,_MDSPL
//	mOn_Interval
//	Beep
//	End_measurement
//	RET
//Off_Izmer
//	SPLK 	#0h,_MDSPL
//	mOff_Interval
//	Beep
//	End_measurement
//
//;	MAR	*,AR2
//;	LAR	AR2,#AVRProg
//;	SPLK	#1,*+
//;	SPLK	#1101h,*		;SystemState
//;	CALL	SendCommandAVR

//	RET

 switch(SubroutMode){
  case 0:
//LevelZero0
//	mDec_counter		;CNTMOD--
   ModeCnt--;
//	RETC 	GT
   if (ModeCnt>0) return;
//	LACC 	StartCode,0
//	SUB 	#2
//	BCND	Onn_Izmer,EQ
   if (StartCode==2)
    on_izmer();
//	LACC 	StartCode,0
//	SUB 	#3
//	BCND	Off_Izmer,EQ
   else if (StartCode==3)
    off_izmer();
   else {
//	SPLK 	#6h,_MDSPL 	;���室�� �� ����� ����७��
    MDSPL=6;		//���室�� �� ����� ����७��
// .if WriteDebug=0
//	mWait 1			;��譥� �६� ����� �� � 祬�
// .else
//	mWait3sek		;3 ᥪ㭤� ��ᢥ稢��� ����� ����७��
// .endif
#if WriteDebug==0
    ModeCnt=1;		//��譥� �६� ����� �� � 祬�
#else
    ModeCnt=THREE_SECOND;	//3 ᥪ㭤� ��ᢥ稢��� ����� ����७��
#endif
//	mNext_sub_mode
    SubroutMode++;
// * ����砥� ��⠭��
//	CALL 	SuperBeep
    super_beep();
//	PowerAnalogOn
    power_analog_on();
//	mClear_sample_number
!!!!!!!!!!!
//	LAR	AR7,#TimeOfBeginMeas
//	CALL	SaveTimeOfBeginMeas
    save_time_of_begin_meas();
//	mResetInterval		;����㦠�� ���ࢠ� ᫥���饣� ����७��
    reset_interval();
//	mResetFastInterval	;���������� �� ������
    save_fast_interval();
//	CALL	MakeValue
    compute_number();
//	RET
    break;

//LevelZero1			;��ᢥ稢��� ����� ����७��
   case 1:
//	mDec_counter		;CNTMOD--
   ModeCnt--;
//	RETC 	GT
   if (ModeCnt>0) return;
//	mNext_sub_mode
    SubroutMode++;
// .if WriteDebug=0
//	mWait   250		; 2.5 ᥪ㭤� � ����祭�� ��������� ��⠭���
// .else
//	SPLK 	#64,ModeCnt	;
// .endif
#if WriteDebug==0
    ModeCnt=250;	//2.5 ᥪ㭤� � ����祭�� ��������� ��⠭���
#else
    ModeCnt=64;		//0.64 ᥪ㭤� � ����祭�� ��������� ��⠭���
#endif
//	mClear_sample_number
!!!
//	BeginADC       ;��稭��� �������� ADC
    begin_adc();
//       Beep
    beep();
//	RET
    break;

//LevelZero2
   case 2:
//	mDec_counter		;CNTMOD--
    ModeCnt--;
//	RETC 	GT
    if (ModeCnt>0) return;

// .if WriteDebug=0
// .elseif WriteDebug<3
//	LACC    StartCode,0
//	SUB	#1
//	BCND	NoWriteThis,NEQ
//	SPLK 	#START_DEBUG_WRITE,Mode
//	SPLK	#0,SubroutMode		;��� ��ࢮ��砫쭮�� case
//	mClear_sample_number
//	RET
//NoWriteThis
// .else
// .endif
#if (WriteDebug>0)&&(WriteDebug<3)
    if (StartCode==1){
     Mode=START_DEBUG_WRITE;
     SubroutMode=0;		//��� ��ࢮ��砫쭮�� case
     return;
    }
#endif


//	LACC	CurrPressureLevel
//	SACL	PrevPressureLevel
    PrevPressureLevel=CurrPressureLevel;
//	ADD	#PRESS_PRESET
//	SACL	PressureTop
    PressureTop+=PRESS_PRESET;
//	SPLK 	#START_SHIFT,Mode
    Mode=START_SHIFT;
//	SPLK	#0,SubroutMode		;��� ��ࢮ��砫쭮�� case
    SubroutMode=0;
//	mClear_sample_number
!!!!!!!!
//;�஢���� ��⠭�� �ਡ�� - �᫨ �祭� ������, � ����७�� ��⠭�����
//;#####################################

//	RET
    break;
   default: error();
  }
}
