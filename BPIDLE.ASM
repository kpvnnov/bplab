;&D
* $Id: BPIDLE.ASM,v 1.9 2001-10-22 13:38:13 peter Exp $
        CLRC INTM               ;RS,NMI,INT1,INT2,TINT,TXRXINT.

IDLEST  NOP
        IDLE
        NOP
        ;��᫥���� ࠧ �ᯮ�짮���� AR2 - �᫨ ���-� �訡�� � ���뢠���
        ;� �ࠧ� �㤥� ��������� ��

	BIT  	FLAGKEYB,15
	BCND 	NOTPRESSED,NTC  ;TC=0? (䫠� ࠢ�� 0?)
	LDP  	#0

CLEARINT1
	SETC 	INTM
	NOP
	SST  	#0,066h
	BIT  	066h,6   ;�஢�ઠ INTM
			 ;INTM=0 - all interrupt enabled
			 ;INTM=1 - all disabled
	BCND 	CLEARINT1,NTC  ;�� �� ࠧ�襭�? INTM=0?
; ���뢠��� ����饭�
; ����� ࠡ����
	LDP  	#4
	LACC 	FLAGKEYB,0
	AND  	#0FFFEh
	SACL 	FLAGKEYB
	LACC 	_MDSPL,1 ;��뢠�� ��楤��� � ����ᨬ��� �� ०���
	ADD  	#KEY1
	CALA
	CLRC 	INTM
NOTPRESSED
*****

	BIT  	_Jobs,9
	BCND 	NootBeeping,NTC

	LDP  	#0

CLEARINT2
	SETC 	INTM
	NOP
	SST  	#0,066h
	BIT  	066h,6   ;�஢�ઠ INTM
			 ;INTM=0 - all interrupt enabled
			 ;INTM=1 - all disabled
	BCND 	CLEARINT2,NTC  ;�� �� ࠧ�襭�? INTM=0?
; ���뢠��� ����饭�
; ����� ࠡ����
	LDP  	#4
	mBeepLongEnd
	CLRC 	INTM

	SPLK 	#200,CNTBEEP1
DELAY1_1
	LACC 	#120
DELAY1
	RPT 	#5          ;+12
	NOP
	SUB 	#1          ;+2
	BCND 	DELAY1,NEQ ;+3

	DisInt

	LACC 	_DPA0,0     ;�������㥬 ���祭�� �����
	XOR  	#01h
	SACL 	_DPA0
	OUT  	_DPA0,PA0   ;�뢮� ���ﭨ� �祩�� � ����

	CLRC 	INTM

	LACC 	CNTBEEP1
	BCND 	NootBeeping,EQ
	SUB  	#1
	SACL 	CNTBEEP1
	B 	DELAY1_1



NootBeeping
	NOP
	NOP
	NOP

*****

	B    	IDLEST
