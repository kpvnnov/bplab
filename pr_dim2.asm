;&D
;***********************************************************************
; $Id: pr_dim2.asm,v 1.4 2001-10-22 13:38:19 peter Exp $
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
; Preturn = B4mm;
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
;static int  	DP,Perror,Tdimstart,Tclosing,Tedge;
;int         	Pclose;
;int		DimSignal[3];

Pnew                  	.equ	NewPressure
DimSignal		.equ	SR30	; Первая ячейка сдвигового регистра ФНЧ

DIM_PAUSE		.set	28 	; it was 24 to 05.10.2001

Pressure_diminition_2:

	MAR	*,AR1
	SAR	AR0,*+,AR2
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

Dim_case_0:
;   case 0:
; 	  Pclose = Pnew - Preturn - DimSignal[DimModeSampleCounter]/256
;	         - 4000h/128 + B100mm/256 - Perror*3/4;
;	  if( Pclose > DimSignal[DimModeSampleCounter] )

	LACC	Pnew,16
	SUB     Preturn,16
	SUB	*,8,AR2
	SUB	#4000h,9       ; Приведение DimSignal к виду Unsigned
	ADD	#B10mm*10,8
	SUB	Perror,14
	SUB	Perror,15
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
;   case 1:

Dim_case_1:

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
;   case 2:

Dim_case_2:

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
;   case 3:

Dim_case_3:

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
	BCND    Dim_case_3_Preturn_32,NTC
	LACC	*+,10,AR2
	RPT	#6
	ADD	*+,10,AR2
	SACH    TMP+2,3
	SUB	Pclose,13
	SUB	Preturn,13
	ADD	Preturn,16
	SACH	Preturn,0
	B	Dim_case_3_Perror_culc

Dim_case_3_Preturn_32:
	LACC	*+,8,AR2
	RPT	#6
	ADD	*+,8,AR2
	SACH    TMP+2,5
	SUB	Pclose,11
	SUB	Preturn,11
	ADD	Preturn,16
	SACH	Preturn,0

Dim_case_3_Perror_culc:
	LACC	Perror,16
	ADD	TMP+2,14
	SUB	NewPressure,14
	SUB	Perror,14
	SACH	Perror,0

	LACC	TMP+2,0
        SUB     #EIGHT_MILL_OF_MERC-B0_2mm
	SACL	NewPressure

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
	LAR	AR0,*,AR2
	RET

**************************************************************************
