#if (WriteDebug>0)&&(WriteDebug<3)

void start_debug_write()
{
//pStart_Debug_Write
//	LACC    SubroutMode,1
//	ADD     #Start_Debug_Write_branch
//	BACC

//Start_Debug_Write_branch
//	B	Write_branch0
//	B	Write_branch1
//	B	Write_branch2
//	B	Write_branch3
//	B	Write_branch4
 switch(SubroutMode){
  case 0:
//Write_branch0
//	mNext_sub_mode
   SubroutMode++;
//	SPLK 	#3h,_MDSPL
   MDSPL=3;
//	LACC 	#0
//	SACL 	Preset0		;Ноль в начальное значение давления
//	SACL 	Preset0+1
//	SACL 	Preset0+2
//	SACL 	Preset1		;Ноль в начальное значение давления
//	SACL 	Preset1+1
//	SACL 	Preset1+2
   Preset0=0;
   Preset1=0;

//	SPLK 	#64,ModeCnt  ;пусть фильтр выровняется
//	RET
   ModeCnt=256;
   break;

//Write_branch1
//	mDec_counter		;CNTMOD--
//	RETC 	GT

//	SendToDAC
//
//	mNext_sub_mode
//	SPLK 	#256,ModeCnt	;усреднение значения с канала
//	RET

//Write_branch2
  case 1:
//	CLRC 	SXM

//	MAR	*,AR6
//	LAR	AR6,#_ResultADC+6;AIN6 (PR0) значение на выходе датчика

//	LACC 	*,8  	;Вычисление среднего по 3-м каналам
//	ADD  	#4000h,9
//	AND 	#0FFFFh,8
//	ADD  	Preset0+1,16
//	ADDS 	Preset0+2
//	SACH 	Preset0+1,0
//	SACL 	Preset0+2,0
   Preset0+=ResultADC[6];

//	LAR	AR6,#_ResultADC+9;AIN9 (аварийный) значение на выходе датчика

//	LACC 	*,8  	;Вычисление среднего по 3-м каналам
//	ADD  	#4000h,9
//	AND 	#0FFFFh,8
//	ADD  	Preset1+1,16
//	ADDS 	Preset1+2
//	SACH 	Preset1+1,0
//	SACL 	Preset1+2,0
   Preset1+=ResultADC[9];

//	mDec_counter		;CNTMOD--
//	RETC GT
   ModeCnt--;
   if (ModeCnt>0) return;

//	LACC 	Preset0+1
//	SACL	Preset0

//	LACC 	Preset1+1
//	SACL	Preset1
   Preset0>>=16;
   Preset1>>=16;
//	mClear_sample_number
!!!!!!!

//	mValve_on
   valve_on();
//	mWait_valve_hold
   wait_valve_hold();
//	mNext_sub_mode
   SubroutMode++;
	RET
   break;
//Write_branch3
  case 2:
//	mDec_counter		;CNTMOD--
//	RETC 	GT
   ModeCnt--;
   if (ModeCnt>0) return;
//	mNext_sub_mode
   SubroutMode++;
//	mValve_hold
   valve_hold();
//	mBegin_write_flash
   begin_wtite_flash();
//	Beep
   beep();
//	SPLK 	#3,_MDSPL 	;переходим на уровень давления
   MDSPL=3;
//	LACC	StartCode+1
//	BCND	largeTime,NEQ
//	SPLK 	#10500,ModeCnt
//	RET
//largeTime:
//	SPLK 	#15000,ModeCnt
//	RET
   if (StartCode[1]) ModeCnt=15000;
   else ModeCnt=10500;
   break;

//Write_branch4
  case 3:
//	mClear_sample_number
!!!!!!!
//	mDec_counter		;CNTMOD--
//	RETC 	GT
   ModeCnt--;
   if (ModeCnt>0) return;

//	mEnd_error_meas	rCancelByUser
//	RET
   end_error_meas(rCancelByUser);
   break;
  default: error();
 }
}
// .endif
#endif
