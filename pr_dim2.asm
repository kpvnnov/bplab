;***********************************************************************
; $Id: pr_dim2.asm,v 1.3 2001-08-22 14:17:46 peter Exp $
;*       Pressure_diminution_2() - Процесс понижения давлени на 8 мм.рт.ст.
;*       Для запуска процесса вызвать макрос:  mDim_pressure_init
;***********************************************************************/
**************************************************************************
; Термины, Термины, Термины,...
**************************************************************************
; Pstart  - Давление начала стравливани
; Popen   - Клапан открылся, начинается стравливание.
; Pclose  - Давление при котором начинаем закрывать клапан.
; Plow    - Давление при котором клапан закрылся.
; Pnew    - Давление начала новой ступеньки
;
; Pnew = Pnew - 8мм.рт.ст.;
; Pline0 = Pstart - Popen
; Pline = Pline0 - DP*Tedge*2
; Pclosing = DP*Tclosing
; Pclose = Pnew - Preturn
;
; Pclosing = Pclose - Plow;
; Pline = Pnew - Plow;

**************************************************************************
; Данный алгоритм стравливания требует инициализации следующих переменных:
**************************************************************************
; перед измерением.
; Pnew = Pnew - 8;
; DimMode = 0;
; DimModeSampleCounter = 0;

; после включения питания.
; Tclosing = 8;
; Tedge = 4;
; Perror = 0;

**************************************************************************
;
**************************************************************************
;int	DimModeSampleCounter;
;int	DimMode,Pnew;
;
;void PressureDiminition2()
;{
;static int  DP,Pline0,Perror,Tdimstart,Tclosing,Tedge;
;int         Pclose;
;
; DimSignal[DimModeSampleCounter]=Pressure0;
;
; switch ( DimMode )
;   case 0:
;       if( DimModeSampleCounter = 0 )
;       {
;         Pline0 = DimSignal[0];
;	}
;       if( DimModeSampleCounter = 2 )
;	  DimMode++;
;    	break;
;
;   case 1:
;       DP0=8*DimSignal[DimModeSampleCounter]-
;          9*DimSignal[DimModeSampleCounter-1]+
;          1*DimSignal[DimModeSampleCounter-3];
;       if(( DP0 >= 0 )||( DimModeSampleCounter >= 8 ))
;        {
;          Pline1 = DimSignal[DimModeSampleCounter-1];
;          if ( DimSignal[DimModeSampleCounter] < Pline1 )
;          {
;             Pline1 = DimSignal[DimModeSampleCounter];
;          }
;          Pline0 = Pline0 - Pline1;
;          Tdimstart = DimModeSampleCounter;
;          DimMode++;
;        }
;    	break;
;
;   case 2:
;	if (( DimModeSampleCounter - Tdimstart) >= 4 )
;	{
;         if ( Preturn == 0 )
;         {
;           Preturn = Pline0*0,7:
;         }
; 	  Pclose = Pnew - Preturn;
;	  if( Pclose > DimSignal[DimModeSampleCounter] )
;	  {
;	    Pclose = DimSignal[DimModeSampleCounter];
;           Tdimstart = DimModeSampleCounter;
;           Valve_is_closed();
;           DimMode++;
;         }
;	}
;    	break;
;
;   case 3:
;       if(( DimSignal[DimModeSampleCounter]-
;            DimSignal[DimModeSampleCounter-1]) > 0)
;       {
;         Tdimstart = DimModeSampleCounter;
;	  mValve_hold();
;         DimMode++;
;       }
;    	break;
;
;   case 4:
;       if( 2*( DimSignal[DimModeSampleCounter]-
;               DimSignal[DimModeSampleCounter-1]) <
;             ( DimSignal[DimModeSampleCounter-1]-
;               DimSignal[DimModeSampleCounter-2]))
;       {
;         Tdimstart = DimModeSampleCounter;
;         DimMode++;
;       }
;    	break;
;
;   case 5:
;       if(( DimModeSampleCounter - Tdimstart ) > DIM_PAUSE)
;       {
;	  for (i=0; i<8; i++)
;         {
;	    Pcurrent = 0;
;           Pcurrent = Pcurrent + (DimSignal[DimModeSampleCounter - i];
;         }
;         Preturn = Preturn + ( Pcurrent/8 - Pclose - Preturn )/16;
;	  MeasurementFlags = (MeasurementFlags )&(~( 1<<DIM_PRESSURE_FLAG  ));
;       }
;
;    	break;
;     }
;       DimModeSampleCounter++;
;	return;
**************************************************************************


**************************************************************************
; Данный алгоритм стравливания требует инициализации следующих переменных:
**************************************************************************
; перед измерением.
; DimMode = 0;
; DimModeSampleCounter = 0;
; MeasurementFlags = (MeasurementFlags )|( 1<<DIM_PRESSURE_FLAG  );
;
;mDim_pressure_init	.macro
;

; после включения питания.
; Perror = 0;
;
;mDim_pressure_supply_up_init	.macro
;

**************************************************************************
**************************************************************************
; Предпологается, что модуль PressureDiminition2 вызывается внутри
; обработки прерывания АЦП, модуль использует эту же страницу памяти,
; при этом считается, что все локальные Tmp ячейки и ARx регистры
; ( кроме AR1) свободны.
**************************************************************************
**************************************************************************
;int	DimModeSampleCounter;
;int	DimMode,Pnew;
;
;void PressureDiminition2()
;{
;static int  	DP,Pline0,Pline1,Perror,Tdimstart,Tclosing,Tedge;
;int         	Pclose;
;int		DimSignal[3];

;DimModeSampleCounter  	.usect "bss1",1
;DimMode               	.usect "bss1",1
;Pline0                	.usect "bss1",1
;Pline1                	.usect "bss1",1
;Perror                	.usect "bss1",1
;Tdimstart             	.usect "bss1",1

Pnew                  	.equ	NewPressure
DimSignal		.equ	SR30	; Первая ячейка сдвигового регистра ФНЧ

DIM_PAUSE		.set	24

Pressure_diminition_2:

	MAR	*,AR1
	SAR	AR0,*+,AR1
	SAR	AR2,*+,AR2
	SETC	SXM

; DimSignal[DimModeSampleCounter]=Pressure0;

	LAR	AR2,#DimSignal+1
;
; switch ( DimMode )

	LACC	#Dim_mode_case,0
	ADD 	DimMode,1		; Сдвиг на "1" нужен т.к. команда
	BACC                    	; "Branch" занимает 2-е ячейки памяти.
Dim_mode_case:
	B	Dim_case_0
	B	Dim_case_1
	B	Dim_case_2
	B	Dim_case_3
	B	Dim_case_4
	B	Dim_case_5

;   case 0:

Dim_case_0:

;         Pline0 = DimSignal[0];
;	  DimMode++;
;    	break;

	LACC	*,0,AR2
	SACL    Pline0,0
	LACC    DimMode
	ADD	#1
	SACL    DimMode

	;LAR	AR2,#IMR		;??????????????????????????????
	;LACC	*
	;AND	#001Fh
	;SACL	*
	;SPLK	#ASPST,TMP
	;OUT	TMP,ASPCR
	;NOP

	;LACC	Perror,12
	;SACH	TMP+2,0
	;OUT	TMP+2,ADTR                               ;?????????????????????????????

	B	Dim_quit

;
;   case 1:

Dim_case_1:

;       DP0=8*DimSignal[DimModeSampleCounter]-
;          9*DimSignal[DimModeSampleCounter-1]+
;          1*DimSignal[DimModeSampleCounter-3];
;       if(( DP0 >= 0 )||( DimModeSampleCounter >= 8 ))

	LACC	DimModeSampleCounter,0
	SUB     #8
	BCND	Dim_case_1_calculation,GEQ
	LACC	*+,3,AR2
	SUB	*,3,AR2
	SUB	*+,0,AR2
	MAR	*+,AR2
	ADD	*-,0,AR2
	BCND	Dim_quit,LT

;        {

Dim_case_1_calculation:

;          Pline1 = DimSignal[DimModeSampleCounter-1];
;          if ( DimSignal[DimModeSampleCounter] < Pline1 )
;          {
;             Pline1 = DimSignal[DimModeSampleCounter];
;          }
;          Pline0 = Pline0 - Pline1;
;          Tdimstart = DimModeSampleCounter;
;          DimMode++;

	MAR	*-,AR2
	LACC	*-,0
	SACL	Pline1,0
	SUB	*,0
	BCND	Dim_case_1_calc_Pline0,LEQ
	LACC	*,0
	SACL	Pline1,0
Dim_case_1_calc_Pline0:
	LACC	Pline0,0
	SUB     Pline1,0
	SACL	Pline0,0
	LACC	DimModeSampleCounter
	SACL	Tdimstart
	LACC    DimMode
	ADD	#1
	SACL    DimMode

;        }
;    	break;

	B	Dim_quit

Dim_case_2:
;   case 2:
;	if (( DimModeSampleCounter - Tdimstart) >= 4 )
;	{

	LACC	DimModeSampleCounter,0
	SUB     Tdimstart,0
	SUB	#4
	BCND	Dim_quit,LT

;         if ( Preturn == 0 )

	LACC	Preturn,0
	BCND	Dim_case_2_Pclose_calculation,NEQ

;         {
;           Preturn = Pline0*0,625:
;         }

	LACC	Pline0,15
	ADD	Pline0,13
	SACH	Preturn,0

Dim_case_2_Pclose_calculation:

; 	  Pclose = Pnew - Preturn - DimSignal[DimModeSampleCounter]/256 + B100mm/256;
;	  if( Pclose > DimSignal[DimModeSampleCounter] )

	LACC	Pnew,16
	SUB     Preturn,16
	SUB	*,8,AR2
	ADD	#B10mm*10,8
	SUB	*,16,AR2
	BCND	Dim_quit,LEQ

;	  {
;	    Pclose = DimSignal[DimModeSampleCounter];
;           Tdimstart = DimModeSampleCounter;
;           Valve_is_closed();
;           DimMode++;
;         }
;	}

	LACC	*,0,AR2
	SACL	Pclose,0
	LACC	DimModeSampleCounter
	SACL	Tdimstart
	LACC    DimMode,0
	ADD	#1
	SACL    DimMode,0
	mValve_on            ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;       }
;    	break;

	B	Dim_quit

;
;   case 3:

Dim_case_3:

;       if(( DimSignal[DimModeSampleCounter]-
;            DimSignal[DimModeSampleCounter-1]) > 0)

	LACC	*+,0,AR2
	SUB	*,0,AR2
	BCND	Dim_quit,LEQ

;       {
;         Tdimstart = DimModeSampleCounter;
;	  mValve_hold();
;         DimMode++;

	LACC	DimModeSampleCounter
	SACL	Tdimstart
	LACC    DimMode
	ADD	#1
	SACL    DimMode

  	mValve_hold                     ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;       }
;    	break;

	B	Dim_quit

;
;   case 4:

Dim_case_4:

;       if( 2*( DimSignal[DimModeSampleCounter]-
;               DimSignal[DimModeSampleCounter-1]) <
;             ( DimSignal[DimModeSampleCounter-1]-
;               DimSignal[DimModeSampleCounter-2]))

	LACC	*+,1,AR2
	SUB	*,1,AR2
	SUB	*+,0,AR2
	ADD	*,0,AR2
	BCND	Dim_quit,GT

;       {
;         Tdimstart = DimModeSampleCounter;
;         DimMode++;

	LACC	DimModeSampleCounter,0
	SACL	Tdimstart,0
	LACC    DimMode
	ADD	#1
	SACL    DimMode

;       }
;    	break;

	B	Dim_quit

;
;   case 5:

Dim_case_5:

;       if(( DimModeSampleCounter - Tdimstart ) > DIM_PAUSE)

	LACC	DimModeSampleCounter,0
	SUB     Tdimstart,0
	SUB	#DIM_PAUSE
	BCND	Dim_quit,LT

;       {
;	  Pcurrent = 0;
;	  for (i=0; i<8; i++)
;         {
;           Pcurrent = Pcurrent + (DimSignal[DimModeSampleCounter - i];
;         }
;         if ((MeasurementFlags & 1<<FIRST_MEAS_FLAG ) != 0)
;         {
;            Preturn = Preturn + ( Pcurrent/8 - Pclose - Preturn )/8;
;         }
;	  else
;         {
;            Preturn = Preturn + ( Pcurrent/8 - Pclose - Preturn )/32;
;         }
;	  MeasurementFlags = (MeasurementFlags )&(~( 1<<DIM_PRESSURE_FLAG  ));
;       }

	BIT	MeasurementFlags,15-FIRST_MEAS_FLAG
	BCND    Dim_case_5_Preturn_32,NTC
	LACC	*+,10,AR2
	RPT	#6
	ADD	*+,10,AR2
	SACH    TMP+2,3
	SUB	Pclose,13
	SUB	Preturn,13
	ADD	Preturn,16
	SACH	Preturn,0
	B	Dim_case_5_Perror_culc

Dim_case_5_Preturn_32:
	LACC	*+,8,AR2
	RPT	#6
	ADD	*+,8,AR2
	SACH    TMP+2,5
	SUB	Pclose,11
	SUB	Preturn,11
	ADD	Preturn,16
	SACH	Preturn,0

Dim_case_5_Perror_culc:
	LACC	TMP+2,0
	SUB	NewPressure,0
	SACL	Perror,0

	LACC	TMP+2,0
        SUB     #EIGHT_MILL_OF_MERC-B0_2mm
	SACL	NewPressure

	;LACC	Preturn,12
	;SACH	TMP+2,0
	;OUT	TMP+2,ADTR                               ;?????????????????????????????

	LACC	MeasurementFlags,0
	AND	#~(1<<DIM_PRESSURE_FLAG)
	SACL	MeasurementFlags,0

;       }
;
;    	break;

	B	Dim_quit

;     }

Dim_quit:

;       DimModeSampleCounter++;
;	return;

	LACC	DimModeSampleCounter,0
	ADD	#1
	SACL	DimModeSampleCounter,0

;	Stack is restore

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR2,*-,AR1
	LAR	AR0,*,AR1
	RET

**************************************************************************
