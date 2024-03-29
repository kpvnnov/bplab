;&D
* $Id: BPAVRPRG.ASM,v 1.17 2002-01-30 13:43:59 peter Exp $
 .copy bpavrprg.mac

	.globl	_clk_xf_avr
;        .globl	_three_imp_ssp_avr
;        .globl	_on_avr_spi

;_on_avr_spi:
;        LDP  	#4
;	mOnAVRSPI
;        RET
;_three_imp_ssp_avr:
;	mImp_SSPAVR
;	mImp_SSPAVR
;	mImp_SSPAVR
;	RET

CLKXFAVR:
;_clk_xf_avr:
	LACC	#16
NextCLKXFAVR:
	mImp_SSPAVR   ;1
	SUB	#1
	BCND	NextCLKXFAVR,NEQ

*	mImp_SSPAVR   ;2
*	mImp_SSPAVR   ;3
*	mImp_SSPAVR   ;4
*	mImp_SSPAVR   ;5
*	mImp_SSPAVR   ;6
*	mImp_SSPAVR   ;7
*	mImp_SSPAVR   ;8
*	mImp_SSPAVR   ;9
*	mImp_SSPAVR   ;10
*	mImp_SSPAVR   ;11
*	mImp_SSPAVR   ;12
*	mImp_SSPAVR   ;13
*	mImp_SSPAVR   ;14
*	mImp_SSPAVR   ;15
*	mImp_SSPAVR   ;16
	RET

*
* ��楤�� ��।�� (�뤠� ⠪⮢�� �����) �� SPI
* ��� AVR
* ���뫠�� ��� _����_ � ��㧮� ����� ���� 6 mks

CLKAVRSPI
	LACC	#8
NextCLKXFAVR1:
;	mImp_ssp
	mImp_SSPAVR
	SUB	#1
	BCND	NextCLKXFAVR1,NEQ

*	mOffPeriph
*	mOutDIOSR

	mWait6mks		;����� ���⠬� ����室��� ᤥ���� ����,
				;�⮡� AVR �ᯥ� ��ࠡ���� �ਭ���� �������

*	mOnAVRSPI

	LACC	#8
NextCLKXFAVR2:
;	mImp_ssp
        mImp_SSPAVR
	SUB	#1
	BCND	NextCLKXFAVR2,NEQ
	RET

* �室 � ᨭ�஭����� � AVR
* ��室 ACC=0 ��諨 � ᨭ��
* ACC=1 �� ��諨
* use AR7
AVRSinc
	MAR     *,AR1
	POPD	*+
	mWait1ms
	;ResetAVRClear
	mOffPeriph
	mOutDIOSR
	mWait1ms
	ResetAVRSet

	mWait40ms
	MAR	*,AR7
	LAR  	AR7,#AVRProg+3
	SPLK	#64,*,AR1	;����� ᤥ���� 64 横�� �室� � ᨭ��

AgainProgrammingEnaled
*����������������������������������������������������������������Ŀ
*�                   �  Byte 1   � Byte 2   � Byte 3   �Byte 4    �
*����������������������������������������������������������������Ĵ
*�Programming Enable � 1010 1100 �0101 0011 �xxxx xxxx �xxxx xxxx �
*������������������������������������������������������������������

	SendSSP	#0AC53h
	SendSSP #00000h
	mImp_SSPAVR
	mImp_SSPAVR
	mImp_SSPAVR

	CALL 	CLKXFAVR        ;��।��� ��� ����� ����
				;Programming Enable
	ReadSSP
	SendSSP	#03000h		;���뫠�� � �����
	SendSSP #00000h         ;���뫠�� � ����� (�⮡� ��।�� �� ��⠭�������)
	CALL 	CLKXFAVR        ;��।��� ��� ��᫥���� �������� ����
				;Programming Enable
	ReadSSP
	;� ���襬 ���� ������ ���� 53h, ����� �ணࠬ��஢���� ࠧ�襭�
	LACC	*
	XOR	#05300h^0FF00h
	AND	#0FF00h
	BCND	ProgrammEnabled,EQ
	;���� ������� ������⢮ �訡�� � ������� �� �������
	; ४��������� 32 ����⪨
	MAR	*,AR7
	LAR  	AR7,#AVRProg+3
	LACC	*
	SUB	#1
	SACL	*,0,AR1
	BCND    QPrgAVRNoSinc,EQ

* �⮡� ��� �� ����� ᨭ�஭�����
* ��⠫������ ��� ��譨� ᫮�� � ��稭��� ������
	CALL 	CLKXFAVR        ;��।��� ��� ����� ����
				;Programming Enable
	ReadSSP
	CALL 	CLKXFAVR        ;��।��� ��� ����� ����
				;Programming Enable
	ReadSSP

	B	AgainProgrammingEnaled
QPrgAVRNoSinc:
	LACC	#1
ProgrammEnabled
	MAR	*,AR1
	MAR	*-,AR1
	PSHD	*
	RET


* �ண�� ����� �������� �⥭�� � AVR

ReadByteAVR
*����������������������������������������������������������������Ŀ
*�Read Program Memory  0010 H000 �xxxx aaaa �bbbb bbbb �oooo oooo �
*������������������������������������������������������������������

	;� �� ������塞 �� ��� ᫮�� (������� �⥭��)
	;⠪�� ��ࠧ�� � �� �������� ���� ᫮�� (��� ������� �⥭��)
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1

	LACC	*,7,AR1		;�뤥�塞 ������ ���� ����
	SACH	*,0,AR7		;��࠭塞 �� � �⥪�
	LACC	*,11,AR1	;�뤥�塞 ����訩 ��� (Hig/Low byte)
	AND	#00800H
	OR	#02000H		;������塞 ��� �������
	OR	*		;������塞 ������ ���� ���� �� �⥪�
	SACL	*		;��࠭塞 �� � �⥪�
	OUT  	*,SDTR,AR7	;��ࠢ�塞 � SPI

	LACC	*,7,AR1		;�뤥�塞 ������� ���� ����
				;��४��砥��� �� �⥪
	SACL	*		;��࠭塞 �� � �⥪�
	OUT  	*,SDTR		;��ࠢ�塞 � SPI

	CALL 	CLKXFAVR	;��ࠢ�塞 ������� �⥭�� (����� � ��)
	ReadSSP
	CALL 	CLKXFAVR
	ReadSSP
	RET
* �ண�� ����� �������� �⥭�� EEPROM � AVR

ReadByteEEPROM
*����������������������������������������������������������������Ŀ
*�Read Program Memory  1010 H000 �xxxx aaaa �bbbb bbbb �oooo oooo �
*������������������������������������������������������������������

	;� �� ������塞 �� ��� ᫮�� (������� �⥭��)
	;⠪�� ��ࠧ�� � �� �������� ���� ᫮�� (��� ������� �⥭��)
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1

	LACC	*,7,AR1		;�뤥�塞 ������ ���� ����
	SACH	*,0,AR7		;��࠭塞 �� � �⥪�
	LACC	*,11,AR1	;�뤥�塞 ����訩 ��� (Hig/Low byte)
	AND	#00800H
	OR	#02000H		;������塞 ��� �������
	OR	*		;������塞 ������ ���� ���� �� �⥪�
	SACL	*		;��࠭塞 �� � �⥪�
	OUT  	*,SDTR,AR7	;��ࠢ�塞 � SPI

	LACC	*,7,AR1		;�뤥�塞 ������� ���� ����
				;��४��砥��� �� �⥪
	SACL	*		;��࠭塞 �� � �⥪�
	OUT  	*,SDTR		;��ࠢ�塞 � SPI

	CALL 	CLKXFAVR	;��ࠢ�塞 ������� �⥭�� (����� � ��)
	ReadSSP
	CALL 	CLKXFAVR
	ReadSSP
	RET

* �ணࠬ��஢���� AVR
* ��室 � ACC
* =0 �ᯥ譮
* =1 �� ᨭ�����
* =2 �� �ணࠬ������� (���뢠���� ��㣨� �����)
* =3 �� �ணࠬ������� (���뢠���� 0FFh)

Program_AVR
	MAR     *,AR1
	POPD	*+
	SAR     AR7,*+
	SAR     AR6,*+

	CLRC	SXM

	;���뢠�� ����� � 䫥� � ���� #DATART+4
	LACC    #1Fh,1		;#1F0000h ���� ��� ��訢��
	SACL	_FLADR+1		;��砫�� ���� �� 䫥�
	SPLK	#0,_FLADR

	LAR	AR7,#DATART+4
NextReadFlashAVR:
	CALL	FLREAD
	MAR	*,AR7
	BIT     _FLADR,15
	BCND    NechetAdrAvr,NTC	;�� �⮨� TC, ����� ���� ����� (⠪ ��� �।��騩)
	SFL
	SACL	*,7,AR7		;��� ���� �����뢠�� � ���襩 ���
	B	CheckEndAdr

NechetAdrAvr:
	OR	*		;����� ���� � ����襩 ���
	SACL	*+
CheckEndAdr:			;�஢��塞 ������ ����
	LACC	_FLADR
	SUB	#4096
	BCND	NextReadFlashAVR,LT
	;��, 䫥� ��⠫� #DATART+4 4k����

	ResetAVRSet
	SETC 	XF	; CLK = 0


	MAR	*,AR1
	SPLK 	#SSPS,*		;SSP start
	OUT  	*,SSPCR		;Synchronous Serial Port Control Register

	IN   	*,SDTR     	;������� ��譥�� �⥭��(!??)
				;��� �⠡��쭮��(���������) ࠡ��� � SSP

	CALL	AVRSinc

	BCND	EnterToSync,EQ
	B	QPrgAVR
EnterToSync

	MAR	*,AR7
	LAR  	AR7,#AVRProg+1
	SPLK	#0,*            ;�����뢠�� ��砫�� �����
				;�ணࠬ��஢����
	LAR	AR6,#DATART+4	;��㤠 �⠥� �����


*����������������������������������������������������������������Ŀ
*�Write Program �      0100 H000 �xxxx aaaa �bbbb bbbb �iiii iiii �
*�   Memory     �������������������������������������������������Ĵ
*����������������                                                 �
*� H = 0 - Low byte, 1 - High byte                                �
*� a = address high bits                                          �
*� b = address low  bits                                          �
*� i = data in                                                    �
*������������������������������������������������������������������
ProgrammNext:
	;ReadByte        ;�⥭�� ���� ��� �ணࠬ��஢����
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1
	BIT	*,15,AR6
	BCND    ReadNechetAdrAvr,TC ;�⮨� TC, ����� ���� �����
	LACC	*,8,AR1		;��� ���� � ���襩 ���
	SACH	*
	LACC	*
	B	ChetReaded
ReadNechetAdrAvr
	LACC	*+
ChetReaded:
	AND	#0FFH
	;�᫨ �ࠢ���� � 0FFh, � �ணࠬ��஢��� ��� ����室�����
	MAR	*,AR7
	LAR  	AR7,#AVRProg+2
	SACL	*-,0,AR7
	XOR	#0FFh
	BCND	NextByte,EQ

	BIT 	Flags,15-WriteEEPROM ;��襬 EEPROM ?
        BCND	IsProgramMemory,NTC
*����������������������������������������������������������������Ŀ
*�Write EEPROM  �      1100 0000 �xxxx aaaa �bbbb bbbb �iiii iiii �
*�   Memory     �������������������������������������������������Ĵ
*����������������                                                 �
*� H = 0 - Low byte, 1 - High byte                                �
*� a = address high bits                                          �
*� b = address low  bits                                          �
*� i = data in                                                    �
*������������������������������������������������������������������
	LACC	*,8,AR1		;�뤥�塞 ������ ���� ����
	SACH	*,0,AR1		;��࠭塞 �� � �⥪�
	OR	#0C000H		;������塞 ��� �������
        B	IsEEPROM
IsProgramMemory:
	LACC	*,7,AR1		;�뤥�塞 ������ ���� ����
	SACH	*,0,AR7		;��࠭塞 �� � �⥪�

	LACC	*,11,AR1	;�뤥�塞 ����訩 ��� (Hig/Low byte)
	AND	#00800H
	OR	#04000H		;������塞 ��� �������
IsEEPROM:
	OR	*		;������塞 ������ ���� ���� �� �⥪�
	SACL	*		;��࠭塞 �� � �⥪�
	OUT  	*,SDTR,AR7	;��ࠢ�塞 � SPI

	BIT 	Flags,15-WriteEEPROM ;��襬 EEPROM ?
        BCND	IsProgramLowAddress,NTC
*����������������������������������������������������������������Ŀ
*�Write EEPROM  �      1100 0000 �xxxx aaaa �bbbb bbbb �iiii iiii �
*�   Memory     �������������������������������������������������Ĵ
*����������������                                                 �
*� H = 0 - Low byte, 1 - High byte                                �
*� a = address high bits                                          �
*� b = address low  bits                                          �
*� i = data in                                                    �
*������������������������������������������������������������������
	LACC	*+,8		;�뤥�塞 ������� ���� ����
				;��४��砥��� �� �����
        B	IsEEPROMLowAddress
IsProgramLowAddress:
	LACC	*+,7		;�뤥�塞 ������� ���� ����
				;��४��砥��� �� �����
IsEEPROMLowAddress:
	AND	#0FF00h
	OR	*,AR1		;� ����襩 ��� ���� ������塞 �����
	SACL	*		;��࠭塞 �� � �⥪�
	OUT  	*,SDTR		;��ࠢ�塞 � SPI

	;�� ���뫠���� �������, ����� ᨤ�� � fifo
	;(���� ������� ᨭ�஭���樨, ���� �⥭��)
	CALL 	CLKXFAVR
	ReadSSP
	CALL 	CLKXFAVR
	ReadSSP

	;������塞 䨪⨢��� ������� �⥭��
	SendSSP	#02000h
	SendSSP #00000h
	CALL 	CLKXFAVR	;�� ���뫠���� ������� �����
	ReadSSP
	CALL 	CLKXFAVR
	ReadSSP
	;�� ����� ������ � ����� fifo ��⠥��� ������� �⥭��(䨪⨢���)
	MAR	*,AR7
	LAR  	AR7,#AVRProg+3
	SPLK	#15,*,AR1	;᪮�쪮 ����� �ணࠬ��஢���� (�㤥� 15ms)
	; 3.2V  3.6V 4.0V 5.0V
	; 9 ms  7 ms 6 ms 4 ms

	mWait10ms
	B	NextByte
	mWait1ms

	CALL	ReadByteAVR
CheckAgain:
*����������������������������������������������������������������Ŀ
*������� Poling Data                                            �
*� �᫨ ���� ����ﭭ� ⮫쪮 �� ���ணࠬ��஢����� �祩��    �
*� � ��� ⮫쪮 �祩�� ���ணࠬ�������, �� �⥭�� �������    �
*� �����  ���� ����ﭭ� ���� ������ 0xFFh                   �
*������������������������������������������������������������������
	mWait1ms

	CALL	ReadByteAVR
	;�� ����� ������ � �� ��⠥��� ���� ������� �⥭�� (��� ᫮��)
	;�஢��塞 ���� �� �६� �஢����� ?
	MAR	*,AR7
	LAR  	AR7,#AVRProg+3
	LACC	*
	SUB	#1
	SACL	*,0,AR1
	BCND    QPrgAVRNoWait,EQ

	;�ࠢ������ ����祭�� ���� � ����묨
	;�᫨ 0FFh, � �஢��塞 �� ࠧ

	LAR  	AR7,#AVRProg+2
	LACC	*
	AND	#000FFh
*	XOR	#000FFh		;����� �����⭮ ������� 㦥
				;���⮬� ������ ���� 0(� �� ᠬ�� ���� FF)
	BCND	CheckAgain,EQ
	LACC	*,0,AR7
	AND	#000FFh
	XOR	#000FFh
	XOR	*
	BCND	QPrgAVRErrprg,NEQ	;����� ��⠭��
					;�⫨����� �� ������
NextByte:
	;㢥��稢��� ���� ��� �ணࠬ��஢����
	;� �ணࠬ���㥬 ᫥���騩 ����
	;AddAdress
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1
	LACC	*
	ADD	#1
	SACL	*
	BIT 	Flags,15-WriteEEPROM ;��襬 EEPROM ?
        BCND	IsIncAddressPM,NTC
	SUB	#2048
	BCND    ProgrammNext,LT	;�᫨ �� ���⨣��� ��᫥���� ����
        B	QPrgAVROK
IsIncAddressPM:
	SUB	#4096
	BCND    ProgrammNext,LT	;�᫨ �� ���⨣��� ��᫥���� ����
QPrgAVROK:
	LACC	#0		;��ଠ��� �����
* ��������!!! - �� ��室 �ᯮ������ � ��楤�� �⥭��
QPrgAVR:
	MAR	*,AR1
	SACL	*+		;����ᨬ १���� � �⥪

	CALL 	CLKXFAVR        ;��।��� ��� ����� ����
				;����� ��⠫��� � ��誥
	ReadSSP
	CALL 	CLKXFAVR        ;��।��� ��� ��᫥���� ����
				;����� ��⠫��� � ��誥
	ReadSSP

	;ResetAVRClear
	mOffPeriph
	mOutDIOSR
	MAR	*-,AR1		;���⠥� १���� �� �⥪�
	LACC	*-		;��⮬�⮬ �⥪ �� ᫥� �祩��

*	MAR	*,AR1
*	MAR	*-,AR1

	LAR     AR6,*-
	LAR     AR7,*-
	PSHD	*
	RET
QPrgAVRErrprg:
	LACC	#2
	B	QPrgAVR
QPrgAVRNoWait
	LACC	#3
	B	QPrgAVR
;Write Lock Bits      1010 1100    111x x21x  xxxx xxxx   xxxx xxxx
; 1 = lock bit 1
; 2 = lock bit 2
	SendSSP #0ACFFH	;��訢��� ��� ����
	SendSSP	#00000h
	CALL 	CLKXFAVR
	ReadSSP
	CALL 	CLKXFAVR
	ReadSSP
	RET

* �⥭�� �ணࠬ���� ����� AVR
* AR2 - �㤠 ����
ReadAVRMem
	MAR     *,AR1
	POPD	*+
	SAR     AR7,*+
	SAR     AR6,*+
	CLRC	SXM
	LAR  	AR7,#AVRProg
	MAR	*,AR7
	SPLK	#0,*
	ResetAVRSet
	SETC 	XF	; CLK = 0


	MAR	*,AR1
	SPLK 	#SSPS,*		;SSP start
	OUT  	*,SSPCR		;Synchronous Serial Port Control Register

	IN   	*,SDTR     	;������� ��譥�� �⥭��(!??)
				;��� �⠡��쭮��(���������) ࠡ��� � SSP

	CALL	AVRSinc

	BCND	EnterToSync1,EQ
	B	QPrgAVR		;�㤥� �ᯮ�짮���� �⠭����� ��室
EnterToSync1
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1
	LACC	_FLADR
	SACL	*            	;�����뢠�� ��砫�� ����
				;�⥭��
	LAR  	AR7,#AVRProg+3
	SPLK	#2048,*		;������⢮ ���� ��� �⥭��

	CALL	ReadByteAVR	;�����塞 �������� �⥭�� -
				;�� ��室� ᨣ�����
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1	;㢥��稢��� ����� �� �������
	LACC	*
	ADD	#1
	SACL	*
ReadAVRNext
	CALL	ReadByteAVR	;�����塞 �������� �⥭�� -
				;�� ���� ������
	LACC	*,0,AR2		;����㦠�� ����� �� �⥪�
	XOR	#0FFh
	SACL	*+,0,AR7

	LAR  	AR7,#AVRProg+3
	LACC	*
	SUB	#1
	SACL	*
	BCND	AllReadAvr,EQ
	LAR  	AR7,#AVRProg+1
	LACC	*
	ADD	#1
	SACL	*
	SUB	#4097		;������ ���� �� ���� ���� �����
	BCND    ReadAVRNext,LT	;�᫨ �� ���⨣��� ��᫥���� ����
AllReadAvr
	B	QPrgAVROK
* �⥭�� �ணࠬ���� ����� AVR
* AR2 - �㤠 ����
ReadAVREEprom
	MAR     *,AR1
	POPD	*+
	SAR     AR7,*+
	SAR     AR6,*+
	CLRC	SXM
	LAR  	AR7,#AVRProg
	MAR	*,AR7
	SPLK	#0,*
	ResetAVRSet
	SETC 	XF	; CLK = 0


	MAR	*,AR1
	SPLK 	#SSPS,*		;SSP start
	OUT  	*,SSPCR		;Synchronous Serial Port Control Register

	IN   	*,SDTR     	;������� ��譥�� �⥭��(!??)
				;��� �⠡��쭮��(���������) ࠡ��� � SSP

	CALL	AVRSinc

	BCND	EnterToSync3,EQ
	B	QPrgAVR		;�㤥� �ᯮ�짮���� �⠭����� ��室
EnterToSync3
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1
	LACC	_FLADR
	SACL	*            	;�����뢠�� ��砫�� ����
				;�⥭��
	LAR  	AR7,#AVRProg+3
	SPLK	#2048,*		;������⢮ ���� ��� �⥭��

	CALL	ReadByteEEPROM	;�����塞 �������� �⥭�� -
				;�� ��室� ᨣ�����
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1	;㢥��稢��� ����� �� �������
	LACC	*
	ADD	#1
	SACL	*
ReadAVRNext1
	CALL	ReadByteEEPROM	;�����塞 �������� �⥭�� -
				;�� ���� ������
	LACC	*,0,AR2		;����㦠�� ����� �� �⥪�
	XOR	#0FFh
	SACL	*+,0,AR7

	LAR  	AR7,#AVRProg+3
	LACC	*
	SUB	#1
	SACL	*
	BCND	AllReadAvr1,EQ
	LAR  	AR7,#AVRProg+1
	LACC	*
	ADD	#1
	SACL	*
	SUB	#4097		;������ ���� �� ���� ���� �����
	BCND    ReadAVRNext1,LT	;�᫨ �� ���⨣��� ��᫥���� ����
AllReadAvr1
	B	QPrgAVROK


* ��ઠ �ணࠬ���� ����� AVR
EraseAVRMem
	MAR     *,AR1
	POPD	*+
	SAR     AR7,*+
	SAR     AR6,*+
	CLRC	SXM
	ResetAVRSet
	SETC 	XF	; CLK = 0


	MAR	*,AR1
	SPLK 	#SSPS,*		;SSP start
	OUT  	*,SSPCR		;Synchronous Serial Port Control Register

	IN   	*,SDTR     	;������� ��譥�� �⥭��(!??)
				;��� �⠡��쭮��(���������) ࠡ��� � SSP

	CALL	AVRSinc

	BCND	EnterToSync2,EQ
	B	QPrgAVR		;�㤥� �ᯮ�짮���� �⠭����� ��室
EnterToSync2
*����������������������������������������������������������������Ŀ
*�Chip Erase       �   1010 1100 � 100x xxx �xxxx xxxx �xxxx xxxx �
*������������������������������������������������������������������
	MAR	*,AR1
	SendSSP	#0AC80h
	SendSSP	#00000h

*
	CALL 	CLKXFAVR           ;��।��� ��� ����� ����
				;Read Command
	ReadSSP
	CALL 	CLKXFAVR           ;��।��� ��� ��᫥���� �������� ����
				;Read Command
	ReadSSP
*

	CALL 	CLKXFAVR           ;��।��� ��� ����� ����
				;Chip Erase
	ReadSSP
	CALL 	CLKXFAVR
				;��।��� ��� ��᫥����  ����
				;Chip Erase
	ReadSSP
	mWait40ms
	B	QPrgAVROK
* ����뢠�� �ணࠬ���� ����� AVR
CloseAVRMem:
	MAR     *,AR1
	POPD	*+
	SAR     AR7,*+
	SAR     AR6,*+
	CLRC	SXM
	ResetAVRSet
	SETC 	XF	; CLK = 0


	MAR	*,AR1
	SPLK 	#SSPS,*		;SSP start
	OUT  	*,SSPCR		;Synchronous Serial Port Control Register

	IN   	*,SDTR     	;������� ��譥�� �⥭��(!??)
				;��� �⠡��쭮��(���������) ࠡ��� � SSP

	CALL	AVRSinc

	BCND	EnterToSync4,EQ
	B	QPrgAVR		;�㤥� �ᯮ�짮���� �⠭����� ��室
EnterToSync4:
*����������������������������������������������������������������Ŀ
*�Write Lock Bits  �   1010 1100 � 1111 1Ll1�xxxx xxxx �xxxx xxxx �
*������������������������������������������������������������������
* L - 1
* l - 2
* Set bits 1, 2 ='0' to program Lock bits.

        MAR	*,AR1
	SendSSP	#0ACF9h
	SendSSP	#00000h

*
	CALL 	CLKXFAVR           ;��।��� ��� ����� ����
				;Write Lock Bits
	ReadSSP
	CALL 	CLKXFAVR           ;��।��� ��� ��᫥���� �������� ����
				;Write Lock Bits
	ReadSSP
*

	CALL 	CLKXFAVR           ;��।��� ��� ����� ����
				;Write Lock Bits
	ReadSSP
	CALL 	CLKXFAVR
				;��।��� ��� ��᫥����  ����
				;Write Lock Bits
	ReadSSP
	mWait40ms
	B	QPrgAVROK


SendCommandAVR
	MAR     *,AR1
	POPD	*+
	SAR     AR7,*+
	SAR     AR6,*+
	CLRC	SXM

	MAR	*,AR1
	SPLK 	#SSPS,*		;SSP start
	OUT  	*,SSPCR		;Synchronous Serial Port Control Register

	IN   	*,SDTR,AR7     	;������� ��譥�� �⥭��(!??)
				;��� �⠡��쭮��(���������) ࠡ��� � SSP

	LAR  	AR7,#AVRProg
	LAR  	AR6,#AVRProg
	LACC	*+
NExtParmSPIAVR:
	OUT  	*+,SDTR
	SUB	#1
	BCND	NExtParmSPIAVR,GT

	mImp_SSPAVR
	mImp_SSPAVR
	mImp_SSPAVR

	mOnAVRSPI
NextWordSPIAVR
	mWait6mks
	CALL	CLKAVRSPI
	ReadSSP
	LACC	*,0,AR7
	XOR	#0FFFFh
	SACL	*+,0,AR6
	LACC	*
	SUB	#1
	SACL	*
	BCND	NextWordSPIAVR,GT
	mOffPeriph
	mOutDIOSR
	B	QPrgAVROK


;>>>> 	void prg2mem(unsigned *target,unsigned * source, unsigned count)
******************************************************
* FUNCTION DEF : _prg2mem
******************************************************
	.global _prg2mem
_prg2mem:
LF2	.set	1
	SAR	AR0,*+
	SAR	AR1,*
	LAR	AR0,*+
;	<save register vars>
	SAR	AR6,*+,AR2
*
* AR5	assigned to parameter target
* AR6	assigned to parameter source
*
	LARK	AR2,-3+LF2
	MAR	*0+
        ;ᥩ�� ����㦠�� target
	LAR	AR5,*-			;AR5(AR2) - address in data
        ;ᥩ�� ����㦠��  source
	LACL	*-                      ;ACC = address in program
        ;ᥩ�� ����㦠��  count
; ACC (count)
        LAR	AR3,*,AR3		;AR3 = length of section
        BANZ	cloop,*-,AR5
        B	EPI0_2

cloop:
	TBLR	*+,AR3			; copy from program to data
	ADDK	1			; increment program address
	BANZ	cloop,*-,AR5		; check for zero and decrement

EPI0_2:
	MAR	* ,AR1
;	<restore register vars>
	MAR	*-
	LAR	AR6,*
	SBRK	2
	LAR	AR0,* 
	RET


;        .if	.tms32025 | .tms3202xx
*	.global _prg2mem
;_prg2mem:
;	LARP	AR3
;	LRLK	AR3,#__const_length	; AR3 = length of section
;	BANZ	cont,*-,AR2		; Check for zero and decrement
;	B	quit			; if (zero) quit
;cont:
;	LRLK	AR2,#__const_run	; AR2 = const address in data
;	LALK	#__const_load		; ACC = const address in program
;cloop:
;	TBLR	*+,AR3			; copy from program to data
;	ADDK	1			; increment program address
;	BANZ	cloop,*-,AR2		; check for zero and decrement
;quit:
;	LARP	AR1			; restore ARP to SP
;	RET				; return
;	.endif ; .tms32025 | .tms3202xx	
