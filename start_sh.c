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
//;AVR тоже надо смещение высчитывать
//;поэтому "убыстрение" за счет памяти предыдущего смещения
//;убираем
// *	MAR  	*,AR2
// *	LAR  	AR2,#LastMeas
//	;в течении трех минут смещение действительно
// *	LACC	*
// *	BCND	Start_shift_without,NEQ	;поэтому считать его не будем

//	mNext_sub_mode
//	SPLK 	#3h,_MDSPL 	;переходим на уровень давления
// .if WriteDebug=0
//	mWait 1			;лишние 3 секунды нам ни к чему
// .else
//	mWait3sek		;3 секунды высвечиваем уровень давления
// .endif
//	RET

//Start_shift1_1:
//	mDec_counter		;CNTMOD--
//	RETC 	GT
//	mNext_sub_mode
//	LACC 	#0
//	SACL 	Preset0		;Ноль в начальное значение давления
//	SACL 	Preset0+1
//	SACL 	Preset0+2
  
//	SPLK 	#64,ModeCnt  ;пусть фильтр выровняется
//	RET
   Preset0=0;

//Start_shift2:
//	mDec_counter		;CNTMOD--
//	RETC 	GT

//	SendToDAC

//	mNext_sub_mode
   SubroutMode++;
//	SPLK 	#256,ModeCnt	;усреднение значения с канала
   ModeCnt=256;
//	RET
   break;
  case 1:
//Start_shift3:
//	CLRC 	SXM

//	MAR	*,AR6
//	LAR	AR6,#_ResultADC+6;AIN6 (PR0) значение на выходе датчика

// *	LACC 	Channel_one,8  	;Вычисление среднего по 3-м каналам
//	LACC 	*,8  	;Вычисление среднего по 3-м каналам
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
//	;в течении трех минут смещение действительно
//	SPLK	#3*60,*		;в секундах время

//	SPLK 	#PRESSURE_AUGMENT_40,Mode
//        mClear_subrout_mode_err_meas
//	SPLK 	#iCURRENT_PRESSURE,_MDSPL 	;переходим на уровень давления
//        RET
   Mode=PRESSURE_AUGMENT_40;
   MDSPL=iCURRENT_PRESSURE;
   break;
  default: error();
  }
}
