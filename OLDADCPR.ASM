;&D
* ������     	�⥭��
* 1.DAC1     	����
* 2.PR1      	DAC1 	(AIN8 - ��訩 PR2)
* 3.PR3      	PR1  	(AIN7 - �ᨫ���� ᨣ���)
* 4.PR0   	PR3     (AIN9 - ��ன �����,� ���쭥�襬 ��譨�)
* 5.Vref-    	PR0     (AIN6 - ���� ����� ��������)
* 6.Vref+    	Vref-
* 7.PowerDown  	Vref+
* 8.���      	१���� PowerDown

ADCPRO
	SPM  	#1              ;Set P Register Output Shift Mode
				;multiplier output is left-shifted one place

	SPLK 	#SSPS,TMP    ;SSP start
	OUT  	TMP,SSPCR    ;Synchronous Serial Port Control Register
	IN   	TMP,SDTR     ;������� ��譥�� �⥭��
				;��� �⠡��쭮��(���������) ࠡ��� � SSP

	SPLK 	#00D00h,TMP  ;AIN0(PL0),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.��ࢮ� ᫮�� ��� ��।��(PL0)

	SPLK 	#01D00h,TMP  ;AIN1(PL1),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.��ࢮ� ᫮�� ��� ��।��(PL1)

	SPLK 	#02D00h,TMP  ;AIN1(PL2),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.��ࢮ� ᫮�� ��� ��।��(PL1)

	SPLK 	#03D00h,TMP  ;AIN1(PL3),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.��ࢮ� ᫮�� ��� ��।��(PL1)

	SPLK 	#04D00h,TMP  ;AIN1(PL4),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.��ࢮ� ᫮�� ��� ��।��(PL1)

	SPLK 	#05D00h,TMP  ;AIN1(PL5),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.��ࢮ� ᫮�� ��� ��।��(PL1)

	SPLK 	#0AD00h,TMP  ;AIN10(VREF),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.��ࢮ� ᫮�� ��� ��।��(VREF)



	SPLK 	#08D00h,TMP  ;AIN8(DAC2),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.��ࢮ� ᫮�� ��� ��।��(PR0)

	mImp_ssp              ;������塞 SSP � ��砫� ��।�� MSB
	mImp_ssp
	mImp_ssp


	mOnADC			;����砥� �롮�� ���
	mOutDIOSR		;�����뢠�� �롮�� ���ன�� � ॣ���� �뢮��

	SPLK 	#07D00h,TMP  ;AIN7(PR1),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;2.��஥ ᫮�� ��� ��।�� (PR1)

	CALL 	CLKXF           ;1-��।��� ��ࢮ� ᫮��

	SETC 	SXM
	LAR  	AR3,#SR30  	;���� ��砫� ᤢ��.ॣ.���
	LAR  	AR4,#SR30+15    ;���� ���� ᤢ��.ॣ.���
	MAR     *,AR3

	SPLK 	#09D00h,TMP  ;AIN9(PR3),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;3.���� ᫮�� ��� ��।�� (PR3)

	RPT  	#30             ;����প� ��� A/D conversion
	NOP                     ;(N+2)*1542.5347(2)~~50mks

	CALL 	CLKXF           ;2-��।��� ��஥ ᫮��
	IN   	TMP,SDTR     ;(1)�⥭�� ��ࢮ�� १���� (����)

	SPLK 	#06D00h,TMP  ;AIN6(PR0),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;4.�⢥�⮥ ᫮�� ��� ��।�� (PR0)

	RPT  	#40             ;����প� ��� A/D conversion
	NOP

	CALL 	CLKXF           ;3-��।��� ���� ᫮��

	IN   	TMP,SDTR    	;(2)�⥭�� ��ண� १���� (DAC1)
	BIT  	Jobs,10   	;������� ���祭�� ��� � �祩�� ��� �����?
	BCND 	NotWriteFromDAC,NTC
	ClearReadDAC
	LACC 	TMP
	ADD  	#Ppa1_prog,0   	;DAC1n+Ppa1_prog
	SACL 	DAC2
NotWriteFromDAC

	SPLK 	#0CC00h,TMP  ;Vref-,16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;5.��⮥ ᫮�� ��� ��।��

	RPT  	#30             ;����প� ��� A/D conversion
	NOP

	CALL 	CLKXF           ;4-��।��� �⢥�⮥ ᫮�� (DAC1)
	IN   	TMP+1,SDTR   ;(3)�⥭�� ���쥣� १���� (PR1)

	;k1=100/3.9 �����樥�� �ᨫ���� ����樮����� �ᨫ�⥫�
	;Ppa1_prog=160/k1=32768/k1 - �������� ���祭�� 誠�� (5�� ��.��.)
	;                            ��᫥ �ᨫ�⥫�
	;Pr2n=(DAC1n+Ppa1_prog)*(k1/(1+k1))+Ppa1n/k1-Ppa1_prog
	;������ ���祭�� (16 ࠧ�冷�) ᨣ����, ���
	; DAC1n - ���祭�� �� ��室� ���
	; Ppa1n - ���祭�� �� ��室� �ᨫ�⥫�
	;
	MAC  	Const1,DAC2 	;Const1* DAC2= "(32768*k1/(1+k1))"*
				;* "(���祭�� �� ��室� ���+Ppa1_prog)"->P
	LACC 	#0
	MAC  	Const2,TMP+1 ;Const2*(TMP+1)= "1/k1=(3.9/100)*32768"*
				;*(���祭�� �ᨫ������ ������)
	APAC
	SUB 	#Ppa1_progMul2,15 ;�� 16 ᤢ����� �����
	SACH 	*,0,AR4
	CALL 	FILTER          ;FILTER

	SPLK 	#0DC00h,TMP	;Vref+,16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;6.��⮥ ᫮�� ��� ��।��


	RPT  	#30             ;����প� ��� A/D conversion
	NOP                     ;(N+2)*1542.5347(2)~~50mks

	CALL 	CLKXF           ;5-��।��� ��⮥ ᫮�� (Vref-)
	IN   	Channel_two,SDTR ;(4)�⥭�� �⢥�⮣� १���� (PR2)

	SPLK 	#0EC00h,TMP  ;software power down
	OUT  	TMP,SDTR     ;7.ᥤ쬮� ᫮�� ��� ��।��

* �뢮� ���祭�� � ���
	BIT  	Jobs,12    	;�㤥� ��������� ��� ?
	BCND 	DACC,TC    	; �㤥� ��易⥫쭮

	LACC 	TMP+1
	ADD  	#4000h,1
	SUB  	#0800h
	BCND 	DACC,LEQ
	SUB  	#0D0h,8
	BCND 	OUTDAC,LEQ
DACC
	SendToDAC
	LACC 	Jobs
	OR   	#10h     	;���� ������� � ��� ���祭��,�
				;��⠭����� ��� ���祭�� � �����
	SACL 	Jobs     	;��⠭�������� 䫠� ��� ���祭�� ��� � �����

	;�, �� �㦭� �������� � ���
	;Ppa0n/k1+Ppa0n-Ppa1_prog
	;k1=100/3.9, 1/k1=0.039~~ 1/32+1/128=0.03906

	SETC 	SXM
	LACC	Channel_one,16
*	SUB	#1333*2,15    	;(-32768-x)-(-32768-x)*0.03906=-32768
				;�⮡� �� �뫮 ��९������� ���
				;�� �������� ���� ���

*	BCND    VisheChemPorog,NOV	; ��९������� ���뫮
*	LACC 	#0
*	B	DostigliKrishi
VisheChemPorog
	LACC 	Channel_one,10
	ADD  	Channel_one,5   ;+Ppa0n*(1/32)
	ADD  	Channel_one,3	;+Ppa0n*(1/128)
	ADD  	#4000h,11
	SUB  	#Ppa1_prog,10
	SACH 	DAC,2
	LACC 	#0FFCh,0
	AND  	DAC
DostigliKrishi
	SACL 	DAC

OUTDAC  OUT  	DAC,SDTR   	;8.��।��� ���쬮� ᫮�� (��� ���)
*
	RPT  	#30             ;����প� ��� A/D conversion
	NOP                     ;(N+2)*1542.5347(2)~~50mks

	CALL 	CLKXF      	;6-��।��� ��⮥ ᫮��(Vref+)

	RPT  	#30             ;����প� ��� A/D conversion
	NOP

	CALL 	CLKXF		;7-��।��� ᥤ쬮� ᫮��
				;0EC00h ��� � ०�� Power Down

	IN   	Channel_one,SDTR ;PR0->[Channel_one]
				;(5)�⥭�� ��⮣� १���� (PR0)
	LACC    Channel_one
	ADD  	#4000h,1
	AND  	#0FFFFh
	SUB  	Preset0
	BCND 	No_minus,GEQ
	LACC 	#0
No_minus
	SACL 	CurrPressure



	mOffPeriph   		;�몫�砥� ��� ������

	BIT  	Jobs,12    	;�㤥� ��������� ��� ?
	BCND 	NotDAC,NTC 	;� ��� �� ���� ��������

	mOnDAC			;����砥� �롮�� ���

	ReadDAC
NotDAC
	mOutDIOSR		;�����뢠�� �롮�� ���ன�� � ॣ���� �뢮��

	LACC 	Jobs
	AND  	#0FFF7H
	SACL 	Jobs

	IN   	TMP,SDTR    	;(6)�⥭�� ��⮣� १���� (Vref-)
	CLRC 	SXM             ;�஢�ઠ ࠡ��� ���
	LACC 	TMP,0
	SETC 	SXM
	SUB  	#12,4
	BCND 	CONTA1,LT
	SPLK 	#rERROR_ADC,ErrMeas	;�訡�� � ���
	LACC 	_DPA0,0
	AND  	#0FFE3h
	SACL 	_DPA0
	OUT  	_DPA0,PA0
;//!!!        SPLK #8,MODEPR
*
CONTA1  RPT  	#30             ;����প� ��� A/D conversion
	NOP                     ;(N+2)*1542.5347(2)~~50mks

	CALL 	CLKXF           ;8-��।��� ���쬮� ᫮�� � ���
	IN   	TMP,SDTR     ;(7)�⥭�� ᥤ쬮�� १����
				;(Vref+)

	mOffPeriph   		;�몫�砥� ��� ������
	mOutDIOSR		;�����뢠�� �롮�� ���ன�� � ॣ���� �뢮��


	CLRC 	SXM             ;�஢�ઠ ࠡ��� ���
	LACC 	TMP,0
	SETC 	SXM
	SUB  	#0FEAh,4
*
	IN   	TMP,SDTR   	;(8)�⥭�� ���쬮�� १����
				;(���� � ����)
*
	SPLK 	#SSPR,TMP    ;RESET SSP
	OUT  	TMP,SSPCR
	RETC 	GT              ;������ �᫨ ACC>0 ?????
	SPLK 	#rERROR_ADC,ErrMeas	;�訡�� � ���
	LACC 	_DPA0,0
	AND  	#0FFE3h
	SACL 	_DPA0
	OUT  	_DPA0,PA0
;//!!!        SPLK #8,MODEPR
	RET

