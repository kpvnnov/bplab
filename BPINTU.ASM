;&D
****************************************************************************
*       ���� U ���२(INT1)
* $Id: BPINTU.ASM,v 1.8 2001-10-22 13:38:14 peter Exp $
****************************************************************************
*

INTU    mPush_stack		;��࠭���� ���᫨⥫���
				;ॣ���஢ � �⥪�
	LDP  	#4
	LAR  	AR2,#IFR	;����㦠�� 㪠��⥫� �� Interrupt Flag Register
	MAR  	*,AR2      	;modify auxiliary register
				;������ ������� �� ���������⢠ LARP 1
				;�.�. �� ���쭥�襩 ����� �����ᮬ AR2

	SPLK 	#01h,*     	;pending INT1
	LAR  	AR2,#IMR       	;load auxiliary reg #IMR -> AR2
				;interrupt mask register
	LACC 	*              	;load accumulator with shift
	AND  	#0FFFEh        	;��頥� ���� INT1(����頥� �� ���뢠���)
	SACL 	*              	;store mask interrupts
				;Interrupt mask register
				;0(15-6),TXRXINT,XINT,RINT,TINT,INT2(INT3),INT1
				;0      ,1      ,0    0    1   ,1         ,1
				;ࠧ�蠥� ���뢠��� ��
				; - ��᫥����⥫쭮�� �ᨭ�஭����
				; - ⠩���
				; - int2 (�����窠)
				; - int1 alarm!
	LAR	AR2,#iCNTKEYB+1

	SPLK 	#CNSTPOWER,*

	BIT     _Jobs,15			;����� ����७�� ����?
	BCND    IzmNeIdet,NTC
	mEnd_error_meas	rPowerLow
	B	OutFromErrorPower
IzmNeIdet
	SPLK	#rPowerLow,_DispErrMeas
OutFromErrorPower
	LACC	Flags
	OR	#8000H
	SACL	Flags
	mOff_Interval

	SPLK	#250,TMP
Beeping4khz_U
	mDelay250mks
	mBeepXOR

	LACC	TMP
	SUB	#1
	SACL	TMP
	BCND 	Beeping4khz_U,NEQ
	SPLK	#125,TMP
Beeping2khz_U
	mDelay250mks
	mDelay250mks
	mBeepXOR

	LACC	TMP
	SUB	#1
	SACL	TMP
	BCND 	Beeping2khz_U,NEQ


	mPop_stack		;����⠭������� ���᫨⥫��� ॣ���஢
				;�� �⥪�
	CLRC 	INTM   		;ࠧ�襭�� ���뢠��� �� ��室� ��
				;���뢠���
        RET


****************************************************************************
* ����⮢�� ��� ����饭�� ���뢠���
;CLEARINT
;        SETC   INTM
;        NOP
;        LST    #0,TMPKEYB
;        BIT    TMPKEYB,6    ;�஢�ઠ INTM
;                         ;INTM=0 - all interrupt enabled
;                         ;INTM=1 - all disabled
;        BCND CLEARINT,NTC  ;�� �� ࠧ�襭�? INTM=0?
; ���뢠��� ����饭�
; ����� ࠡ����
;        CLRC INTM
*����� ����⮢��
