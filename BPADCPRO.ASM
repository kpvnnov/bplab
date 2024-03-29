;&D
*****************************************************************************
*       ��ࠡ�⪠ ADC
* $Id: BPADCPRO.ASM,v 1.14 2002-04-24 14:03:11 peter Exp $
****************************************************************************
*       ��� 誠�� ���(0-4,8�) ᮮ⢥����� 320 ��.��.��.
*       320*1.6=512; 512*(1-1/4-1/8)=512*0.625=320
*       Pmm=P-0.25*P-0.125*P - ���㫠 �८�ࠧ������ ���祭�� ��������
*                              � ��.��.��.
*       ��砫쭮� ᬥ饭�� �� �室� ��� <=200�� (������� 150��),
*       �� ᮮ⢥����� 0555h (������� 0400h)
****************************************************************************
*
FILTER: MAC  	CF30,*-            ;���-䨫��� 16-�� ���浪�
	LACC 	#0
	RPT  	#14
	MACD 	CF30+1,*-
	APAC
	SACH 	_OUTF,0
	RET

*              ;����樥��� 䨫��� Fs=30��.
CF30:   .word	348,  1007,428,-1205,-2159,389,6235,11335
	.word   11335,6235,389,-2159,-1205,428,1007,348
Const1  .word   07B32h  ;(32768*k1/(1+k1))
Const2  .word   004FEh 	; 1/k1=(3.9/100)*32768

 .if ChannelEKG==1
EKG_PORYADOK	.set 32

EKG_MASSIV1 .usect "ekg",EKG_PORYADOK
EKG_MASSIV2 .usect "ekg",EKG_PORYADOK

;�����樥��� ��� (Remez) 32-�� ���浪�
CF_EKG:
	.word   -18,  -186, -305,  -112,  325, 403
	.word  -219,  -793, -229,  1084, 1147,-951
	.word -2722,  -339, 6412, 12529,12529,6412
	.word  -339, -2722, -951,  1147, 1084,-229
	.word  -793,  -219,  403,   325, -112,-305
	.word  -186,   -18


FILTER_EKG:
	MAC  	CF_EKG,*-            ;���-䨫��� 28-�� ���浪�
	LACC 	#0
	RPT  	#(EKG_PORYADOK-2)
	MACD 	CF_EKG+1,*-
	APAC
	RET
 .endif
;	.globl	_clk_xf
* �뤠� ⠪⮢�� ����� ��� SSP
CLKXF:
;_clk_xf:
	mImp_ssp   ;1
	mImp_ssp   ;2
	mImp_ssp   ;3
	mImp_ssp   ;4
	mImp_ssp   ;5
	mImp_ssp   ;6
	mImp_ssp   ;7
	mImp_ssp   ;8
	mImp_ssp   ;9
	mImp_ssp   ;10
	mImp_ssp   ;11
	mImp_ssp   ;12
	mImp_ssp   ;13
	mImp_ssp   ;14
	mImp_ssp   ;15
	mImp_ssp   ;16
	RET
;	.globl	_three_imp_ssp
;_three_imp_ssp:
;	mImp_ssp              ;������塞 SSP � ��砫� ��।�� MSB
;	mImp_ssp
;	mImp_ssp
;	RET

mDelayConver	.macro
	RPT  	#30             ;����প� ��� A/D conversion
	NOP                     ;(N+2)*1542.5347(2)~~50mks
 .endm

* ������     	�⥭��

* 1.AIN0 (PL0)	����
* 2.AIN1 (PL1)  AIN0 (PL0)
* 3.AIN2 (PL2)  AIN1 (PL1)
* 4.AIN3 (PL3)  AIN2 (PL2)
* 5.AIN4 (PL4)  AIN3 (PL3)
* 6.AIN5 (PL5)  AIN4 (PL4)
* 7.AIN6 (PR0)  AIN5 (PL5)
* 8.AIN7 (PR1)  AIN6 (PR0)
* 9.AIN8 (DAC)  AIN7 (PR1)
*10.AIN9 (PR3)  AIN8 (DAC)
*11.AIN10(VREF) AIN9 (PR3)-⥯��� ��ன �����(���਩��)
*12.Vref-       AIN10(VREF)
*13.Vref+    	Vref-
*14.PowerDown  	Vref+
*15.���      	१���� PowerDown

ADCTABLE
 .word 04D00h	; 1.AIN4 (PL4) ,16 bit,MSB first,bipolar
 .word 05D00h	; 2.AIN5 (PL5) ,16 bit,MSB first,bipolar
 .word 06D00h	; 3.AIN6 (PR0) ,16 bit,MSB first,bipolar
 .word 07D00h	; 4.AIN7 (PR1) ,16 bit,MSB first,bipolar
 .word 08D00h	; 5.AIN8 (DAC) ,16 bit,MSB first,bipolar
 .word 09D00h	; 6.AIN9 (PR3) ,16 bit,MSB first,bipolar
 .word 0AD00h	; 7.AIN10(VREF),16 bit,MSB first,bipolar
 .word 0CC00h	; 8.Vref-      ,16 bit,MSB first,bipolar
 .word 0DC00h	; 9.Vref+      ,16 bit,MSB first,bipolar
 .word 0EC00h	;10.software power down

ADCPRO
	MAR     *,AR1
	POPD	*+
	SAR     AR7,*+
	SAR     AR6,*+

	SPM  	#1              ;Set P Register Output Shift Mode
				;multiplier output is left-shifted one place

	SPLK 	#SSPS,*		;SSP start
	OUT  	*,SSPCR		;Synchronous Serial Port Control Register

	IN   	*,SDTR     	;������� ��譥�� �⥭��(!??)
				;��� �⠡��쭮��(���������) ࠡ��� � SSP
***************************************************
* ��稭��� �����뢠�� ����� � fifo SSP
***************************************************
	SPLK 	#00D00h,*  	;AIN0(PL0),16 bit,MSB first,bipolar
	OUT  	*,SDTR     	;1.��ࢮ� ᫮�� ��� ��।��(PL0)

	SPLK 	#01D00h,*  	;AIN1(PL1),16 bit,MSB first,bipolar
	OUT  	*,SDTR     	;2.��஥ ᫮�� ��� ��।��(PL1)

	mImp_ssp              	;������塞 SSP � ��砫� ��।�� MSB
	mImp_ssp
	mImp_ssp

	mOnADC			;����砥� �롮�� ���
	mOutDIOSR		;�����뢠�� �롮�� ���ன�� � ॣ���� �뢮��

	SPLK 	#02D00h,*  	;AIN2(PL2),16 bit,MSB first,bipolar
	OUT  	*,SDTR     	;3.���� ᫮�� ��� ��।��(PL2)

	CALL 	CLKXF		;1-��।��� ��ࢮ� ᫮�� � ���
	IN	*,SDTR		;(1)�⥭�� ��ࢮ�� १���� (����)


	LAR	AR6,#10		;11 横���
	LAR	AR7,#_ResultADC	;����� �㤥� ���������� १�����
*******************
* � ⠡��� ADCTABLE ����ᠭ� ���祭��
* ����� ���� ��।������� � ���
********************
	LACC 	#ADCTABLE

	SPLK 	#03D00h,*  	;AIN3(PL3),16 bit,MSB first,bipolar
ReadNextInput

	OUT  	*,SDTR    	;4.(�⢥�⮥+0..N) ᫮�� ��� ��।��(AIN3..(3+0..N))
	TBLR 	*,AR7

	mDelayConver		;��㧠 ��� �८�ࠧ������ ADC
	CALL 	CLKXF		;2-��।��� ��஥+0..N ᫮�� � ���
	IN	*+,SDTR,AR6	;(1)�⥭�� ��ண�+0..N १���� (AIN0..(0..N))
	ADD	#1

	BANZ	ReadNextInput,*-,AR1

*************************************************
* ��� ����� ����� ����� ���� � �����ᨥ�
* ����� �㤥� ���� �������⥫�� 横� �����ᨨ ������
 .if NewFerrum=1

	LAR	AR6,#10		;11 横���
	LAR	AR7,#_ResultADC	;����� �㤥� ���������� १�����
	MAR	*,AR7
InverseNextInput
	LACC	#0FFFFh
	XOR	*
	SACL	*+,0,AR6

	BANZ	InverseNextInput,*-,AR7
 .endif
* ����� 横�� �����ᨨ ������ ��� ����� �����
*************************************************

*****************************************************
* �� �����ன�� ��� �� �।��饬 横��
* ���祭�� �� ��室� ����(AIN8) ⥯��� �㤥� �ᯮ�짮������
* � ����� �����

	BIT  	_Jobs,10   	;������� ���祭�� ��� � �祩�� ��� �����?
	BCND 	NotWriteFromDAC,NTC
	ClearReadDAC
	MAR	*,AR6
	LAR	AR6,#_ResultADC+8	;AIN8 (���祭�� �� ��室� ���)
	LACC 	*
	ADD  	#Ppa1_prog,0   	;DAC1n+Ppa1_prog
	SACL 	DAC2
NotWriteFromDAC
*******************************************
;k1=100/3.9 �����樥�� �ᨫ���� ����樮����� �ᨫ�⥫�
;Ppa1_prog=160/k1=32768/k1 - �������� ���祭�� 誠�� (5�� ��.��.)
;                            ��᫥ �ᨫ�⥫�
;Pr2n=(DAC1n+Ppa1_prog)*(k1/(1+k1))+Ppa1n/k1-Ppa1_prog
;������ ���祭�� (16 ࠧ�冷�) ᨣ����, ���
; DAC1n - ���祭�� �� ��室� ���
; Ppa1n - ���祭�� �� ��室� �ᨫ�⥫�
;
	MAR     *,AR6
	LAR	AR6,#_ResultADC+7;AIN7(PR1)

	MAC  	Const1,DAC2 	;Const1* DAC2= "(32768*k1/(1+k1))"*
				;* "(���祭�� �� ��室� ���+Ppa1_prog)"->P
	LACC 	#0
	MAC  	Const2,* 	;Const2*(PR1)= "1/k1(=3.9/100)*32768"*
				;*(���祭�� �ᨫ������ ������)
	APAC
	SUB 	#Ppa1_progMul2,15 ;�� 16 ᤢ����� �����
	LAR  	AR6,#SR30  	;���� ��砫� ᤢ��.ॣ.���
	SACH 	*
	LAR  	AR6,#SR30+15    ;���� ���� ᤢ��.ॣ.���
	CALL 	FILTER          ;FILTER

 .if ChannelEKG==1
        MAR	*,AR6
	LAR	AR6,#_ResultADC+1;AIN1(PL1)
        LACC	*
	LAR  	AR6,#EKG_MASSIV1	;���� ��砫� ᤢ��.ॣ.���
	SACL 	*
	LAR  	AR6,#EKG_MASSIV2+EKG_PORYADOK-1    ;���� ���� ᤢ��.ॣ.���
	CALL 	FILTER_EKG          ;FILTER
       	SACH 	_OUTF_EKG1,0

        MAR	*,AR6
	LAR	AR6,#_ResultADC+3;AIN3(PL3)
        LACC	*
	LAR  	AR6,#EKG_MASSIV2	;���� ��砫� ᤢ��.ॣ.���
	SACL 	*
	LAR  	AR6,#EKG_MASSIV2+EKG_PORYADOK-1    ;���� ���� ᤢ��.ॣ.���
	CALL 	FILTER_EKG          ;FILTER
       	SACH 	_OUTF_EKG2,0
 .endif
***********************************************
* ����塞 �������� � ��⮬ ᬥ饭��
	SETC 	SXM
	MAR	*,AR6
	LAR	AR6,#_ResultADC+6;AIN6 (PR0) ���祭�� �� ��室� ���稪�
	LACC    *
	ADD  	#4000h,1
	AND  	#0FFFFh
	SUB  	Preset0
	BCND 	No_minus,GEQ
	LACC 	#0
No_minus
	SACL 	CurrPressure

***********************************************
* � ��६����� DAC ��室���� ���祭�� ��� �뢮�� � ���
* �६� �� �६��� :) ���祭�� ��� ���� �����ࠨ����
* ᥩ�� ��� �����ࠨ������ ⠪, �⮡� ��室��� ᨣ���
* � �������⥫쭮�� �ᨫ�⥫� ����� � "�।���"
* �������� ���� ���ﬨ
* 1. �ਭ㤨⥫쭮 ��⠭����� ��� �����ன�� ���
* 2. ���祭�� ᨣ���� � �������⥫쭮�� �ᨫ�⥫�
*    ����諮 � �࠭�� (᫥��� ���뢠��, �� �� ����樮����
*    �ᨫ�⥫�� ࠧ��筮� ��室��� ����殮���(max))

	BIT  	_Jobs,12		;�㤥� ��������� ��� ?
************
* ����� ��� ��⠭���������� ��� �ਭ㤨⥫쭮�
* �����ன�� ���.
* ��� �������� �ࠢ����� ��⮢, �� ⠪�� �ᯮ������
* ��� �ਧ��� �����뢠��� � ��� ���祭��
* �᫨ ����� ��� �㤥� ��⠭����� (�ਭ㤨⥫쭮 ��� �
* ����� ���᫥���) � �롮ઠ ����, �� ���뫪� � ����
* ������, �㤥� ����祭�. � ��⨢��� ��砥 (�⮡� ��
* ������� ������ ࠡ��� � SSP) �롮ઠ ��� �� �६�
* "��।��"  ���祭�� � ���� �㤥� �⪫�祭�

	BCND 	DACC,TC    	; �㤥� ��易⥫쭮

	MAR	*,AR6
	LAR	AR6,#_ResultADC+7;AIN7(PR1) ���祭�� �� ��室� �ᨫ�⥫�

	LACC 	*
	ADD  	#4000h,1
	SUB  	#0800h
	BCND 	DACC,LEQ
	SUB  	#0D0h,8
	BCND 	EndComputeDAC,LEQ
DACC
	SendToDAC

*	LACC 	_Jobs
*	OR   	#10h     	;���� ������� � ��� ���祭��,�
				;��⠭����� ��� ���祭�� � �����
*	SACL 	_Jobs     	;��⠭�������� 䫠� ��� ���祭�� ��� � �����

*******************************
;�, �� �㦭� �������� � ���
;Ppa0n/k1+Ppa0n-Ppa1_prog
;k1=100/3.9, 1/k1=0.039~~ 1/32+1/128=0.03906
; Ppa0n - ��室 � ��אַ�� ������
*******************************
	SETC 	SXM

	MAR	*,AR6
	LAR	AR6,#_ResultADC+6;AIN6 (PR0) ���祭�� �� ��室� ���稪�

*****************************
* �⮡� �� "��४������" � ���᫥��ﬨ
* � �⮬ ���� �������� ��ண���� ���祭��
* � ����� ������ ��ࠡ���饥
	LACC	*,16
*	SUB	#1333*2,15    	;(-32768-x)-(-32768-x)*0.03906=-32768
				;�⮡� �� �뫮 ��९������� ���
				;�� �������� ���� ���

*	BCND    VisheChemPorog,NOV	; ��९������� ���뫮
*	LACC 	#0
*	B	DostigliKrishi
VisheChemPorog
*****************************
* ����塞 �� ��㫥 ���祭�� ��� ������� � ���
*****************************
	LACC 	*,10
	ADD  	*,5   		;+Ppa0n*(1/32)
	ADD  	*,3		;+Ppa0n*(1/128)
	ADD  	#4000h,11
	SUB  	#Ppa1_prog,10
	SACH 	DAC,2
	LACC 	#0FFCh,0
	AND  	DAC
DostigliKrishi
	SACL 	DAC		;� �⮩ �祩�� ��室���� ���祭��
				;���஥ ����室��� ��।��� � ���
EndComputeDAC
* ����� ���᫥��� ���祭�� ���
*********************************************

*********************************************
* �����뢠�� � fifo ᫮�� ��� ��।�� � ���
* �� �� �� �� �����, �� ��� � ���� ��������
* �롮ઠ ��� ��⨢�������� ⮫쪮 � ��砥
* �᫨ �� � �뫮 ࠧ�襭�� "����� ᨫ"
* (�뫮 ���᫥��� �����ன�� ���)
*********************************************
	OUT  	DAC,SDTR

****************************************
* �.�. ��। �⨬ �뫮 ���᫥��� ���祭�� ᨣ���� (FILTER)
* �� ������ � ��墮� ��㯨�� �� ����, ����� ����� �࠭�
* �� ����室��� ���뢠�� �� ᫥����� ����䨪���� ����
*	mDelayConver		;��㧠 ��� �८�ࠧ������ ADC
****************************************
	CALL 	CLKXF		;13 �맮� (��।��� ������� Vref+)
	MAR	*,AR7
	IN	*+,SDTR		;Vref-

	mDelayConver		;��㧠 ��� �८�ࠧ������ ADC
	CALL 	CLKXF		;14 �맮� (��।��� ������� PowerDown)
	MAR	*,AR7
	IN	*+,SDTR,AR1	;Vref+
*********
* ࠡ�� � ��� �����祭�, ����� ��� �� �� 祬...

	mOffPeriph   		;�몫�砥� ��� ������
	mOutDIOSR		;�����뢠�� �롮�� ���ன�� � ॣ���� �뢮��

********
* ����㯨�� ��।� ��।����� ������� ��� ���
* to be or not to be, ��� � 祬 �����
* �⥭�� १���� � SSP �� ��।�� �������
* �� ����⢥��� (��� ��� SSP ����⥫쭮, �⮡�
* ����� �� ��⠫��� � fifo) �.�. �� ���祭�� ࠡ���
* ������� Power Down ��� ���


	BIT  	_Jobs,12    	;�㤥� ��������� ��� ?
	BCND 	NotDAC,NTC 	;� ��� �� ���� ��������

	mOnDAC			;����砥� �롮�� ���
	mOutDIOSR		;�����뢠�� �롮�� ���ன�� � ॣ���� �뢮��
	ClearSendToDAC		;��� �����ந��, ��ᨬ 䫠�
	ReadDAC			;�� ᫥���饬 ��㣥 ���� �����
				;���祭�� �� ��室� ���
NotDAC
*************************************************

*****
* ��㧠 ��। ��।�祩 㦥 �� �㦭�
*****
	CALL 	CLKXF		;15-� �맮� (��।��� ���祭�� ���)
	IN	*,SDTR		;१���� ������� Power Down

************
* ࠡ�� ��楤��� �����祭�, �� ᢨ�����, ⮢���
	mOffPeriph   		;�몫�砥� ��� ������
	mOutDIOSR		;�����뢠�� �롮�� ���ன�� � ॣ���� �뢮��

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR6,*-
	LAR     AR7,*-
	PSHD	*

	RET
