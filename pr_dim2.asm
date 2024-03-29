;&D
;***********************************************************************
; $Id: pr_dim2.asm,v 1.5 2001-11-14 17:20:54 peter Exp $
;*       Pressure_diminution_2() - ����� ��������� ������� �� 8 ��.��.��.
;*       ��� ����᪠ ����� �맢��� �����:  mDim_pressure_init
;***********************************************************************/
**************************************************************************
; ��ନ��, ��ନ��, ��ନ��,...
**************************************************************************
; Pstart  - �������� ��砫� ��ࠢ������
; Popen   - ������ ������, ��稭����� ��ࠢ�������.
; Pclose  - �������� �� ���஬ ��稭��� ����뢠�� ������.
; Plow    - �������� �� ���஬ ������ �������.
; Pnew    - �������� ��砫� ����� ��㯥�쪨
;
; Pnew = Pnew - 8��.��.��.;
; Pline0 = Pstart - Popen
; Pline = Pline0 - DP*Tedge*2
; Pclosing = DP*Tclosing
; Pclose = Pnew - Preturn
;
; Pclosing = Pclose - Plow;
; Pline = Pnew - Plow;

**************************************************************************
**************************************************************************
; ����� ������ ��ࠢ������� �ॡ�� ���樠����樨 ᫥����� ��६�����:
**************************************************************************
; ��। ����७���.
; DimMode = 0;
; DimModeSampleCounter = 0;
; MeasurementFlags = (MeasurementFlags )|( 1<<DIM_PRESSURE_FLAG  );
;
;mDim_pressure_init	.macro
;

; ��᫥ ����祭�� ��⠭��.
; Perror = 0;
; Preturn = B4mm;
;
;mDim_pressure_supply_up_init	.macro
;

**************************************************************************
**************************************************************************
; �।����������, �� ����� PressureDiminition2 ��뢠���� �����
; ��ࠡ�⪨ ���뢠��� ���, ����� �ᯮ���� ��� �� ��࠭��� �����,
; �� �⮬ ��⠥���, �� �� ������� Tmp �祩�� � ARx ॣ�����
; ( �஬� AR1) ᢮�����.
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

Pnew                  	.equ	_NewPressure
DimSignal		.equ	SR30	; ��ࢠ� �祩�� ᤢ������� ॣ���� ���

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
	ADD 	_DimMode,1		; ����� �� "1" �㦥� �.�. �������
	BACC                    	; "Branch" �������� 2-� �祩�� �����.
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
	SUB     _Preturn,16
	SUB	*,8,AR2
	SUB	#4000h,9       ; �ਢ������ DimSignal � ���� Unsigned
	ADD	#B10mm*10,8
	SUB	_Perror,14
	SUB	_Perror,15
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
	SACL	_Pclose,0
	LACC	_DimModeSampleCounter
	SACL	_Tdimstart
	LACC    _DimMode,0
	ADD	#1
	SACL    _DimMode,0
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

	LACC	_DimModeSampleCounter
	SACL	_Tdimstart
	LACC    _DimMode
	ADD	#1
	SACL    _DimMode

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

	LACC	_DimModeSampleCounter,0
	SACL	_Tdimstart,0
	LACC    _DimMode
	ADD	#1
	SACL    _DimMode

;       }
;    	break;

	B	Dim_quit

;
;   case 3:

Dim_case_3:

;       if(( DimModeSampleCounter - Tdimstart ) > DIM_PAUSE)

	LACC	_DimModeSampleCounter,0
	SUB     _Tdimstart,0
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

	BIT	_MeasurementFlags,15-FIRST_MEAS_FLAG
	BCND    Dim_case_3_Preturn_32,NTC
	LACC	*+,10,AR2
	RPT	#6
	ADD	*+,10,AR2
	SACH    TMP+2,3
	SUB	_Pclose,13
	SUB	_Preturn,13
	ADD	_Preturn,16
	SACH	_Preturn,0
	B	Dim_case_3_Perror_culc

Dim_case_3_Preturn_32:
	LACC	*+,8,AR2
	RPT	#6
	ADD	*+,8,AR2
	SACH    TMP+2,5
	SUB	_Pclose,11
	SUB	_Preturn,11
	ADD	_Preturn,16
	SACH	_Preturn,0

Dim_case_3_Perror_culc:
	LACC	_Perror,16
	ADD	TMP+2,14
	SUB	_NewPressure,14
	SUB	_Perror,14
	SACH	_Perror,0

	LACC	TMP+2,0
        SUB     #EIGHT_MILL_OF_MERC-B0_2mm
	SACL	_NewPressure

	LACC	_MeasurementFlags,0
	AND	#~(1<<DIM_PRESSURE_FLAG)
	SACL	_MeasurementFlags,0

;       }
;
;    	break;

	B	Dim_quit

;     }

Dim_quit:

;       DimModeSampleCounter++;
;	return;

	LACC	_DimModeSampleCounter,0
	ADD	#1
	SACL	_DimModeSampleCounter,0

;	Stack is restore

	MAR	*,AR1
	MAR	*-,AR1
	LAR	AR0,*,AR2
	RET

**************************************************************************
