;&D
* $Id: BPFLASH.ASM,v 1.24 2002-05-28 11:47:44 peter Exp $
****�⫠���
WriteEnd:
;����室��� �ந����� ������ ������⢠ ����७�� � ⠡���
;����७�� (���)
	BIT	_Jobs,15-WeCountingFlash
        BCND    AlreadyMaked,TC
	CALL	MakeValue		;���� ������ ⠡����
AlreadyMaked:
	mEnd_write_flash

	CLRC 	SXM
	LACC 	IZNUMREC
	SUB 	#256
	BCND 	NeChet1,EQ ;�� ��襬, �᫨ �� �뫮 ࠧ�襭��

	;���� ��������� ��砫�� ����
	LACC 	CountWrite	;�᫨ ��䨪� �� �뫮 ����ᠭ�
	BCND 	NoMaxInfo,EQ      ;� � ⠡��� ���ᨬ㬮� �� �㦭�

 .if OutputSectoring=1
	CALL	MakeSectoring	;⠡��� ���ᨬ㬮� �� ��㯥�쪠�
 .elseif OutputSectoring=0
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

NoMaxInfo:
	SPLK 	#0,_FLADR+1
	SPLK 	#0,_FLADR
	LACC 	IZNUMREC
	BCND 	NotFirst,NEQ	;�� �� ��ࢮ� ����७��
;ᠬ�� ��ࢮ� ����७��
;���� ������� ���� ��砫� �㫥���� ����७��

 .if Mem=20	;���� �����奬� �� 2 Mbyte
	SPLK 	#080h,TMP  ;����७�� ��稭����� � ���� 0x001000h
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
	SPLK 	#040h,TMP  ;����७�� ��稭����� � ���� 0x001000h
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
	SPLK 	#020h,TMP  ;����७�� ��稭����� � ���� 0x001000h
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	CALL 	FLPROG     ;����訩 ���� ����ᠫ�
	SPLK 	#000h,TMP  ;����७�� ��稭����� � ���� 0x001000h
	CALL 	FLPROG     ;���訩 ���� ����ᠫ�
	B FirstCompiled
NotFirst:
	LACC 	IZNUMREC,1
	ADD	#1,1
	SACL 	_FLADR     ;���� ������� ���� ����砭�� ����७��
FirstCompiled:

	LACC 	CountWrite
	BCND 	NoDataWrited,EQ
 .if Mem=20	;���� �����奬� �� 2 Mbyte
	LACC 	IZFLLSB,11
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
	LACC 	IZFLLSB,10
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
	LACC 	IZFLLSB,9
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	SACH 	TMP
	LACC 	TMP
 .if Mem=20	;���� �����奬� �� 2 Mbyte
	ADD  	IZFLMSB,11
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
	ADD  	IZFLMSB,10
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
	ADD  	IZFLMSB,9
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	XOR  	#0FFFEh
	BCND 	NoDataWrited,EQ 	;�� ����� ���᭮�� ����࠭�⢠

 .if Mem=20	;���� �����奬� �� 2 Mbyte
	LACC 	IZFLLSB,11
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
	LACC 	IZFLLSB,10
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
	LACC 	IZFLLSB,9
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

	SACH 	TMP
	LACC 	TMP
 .if Mem=20	;���� �����奬� �� 2 Mbyte
	ADD  	IZFLMSB,11
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
	ADD  	IZFLMSB,10
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
	ADD  	IZFLMSB,9
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	ADD  	#1         ;�ਡ���塞 �������,
			;�⮡� �࠭��� �� ��४�뢠����
	SACL 	TMP
	B 	PresentDataWrited
NoDataWrited:
 .if Mem=20	;���� �����奬� �� 2 Mbyte
	LACC 	IZFLLSB,11
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
	LACC 	IZFLLSB,10
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
	LACC 	IZFLLSB,9
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

	SACH 	TMP
	LACC 	TMP

 .if Mem=20
	ADD  	IZFLMSB,11
 .elseif Mem=40
	ADD  	IZFLMSB,10
 .elseif Mem=44
	ADD  	IZFLMSB,9
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	;������� �ਡ������ �� �㤥�, ��⮬� �� ��� ������
	SACL 	TMP
PresentDataWrited
;	LACC	NoWritePlace	;���� ���� �� 䫥� ?
;	BCND	Yes_It_Is,EQ	;��, ���� ����!
	BIT	_Jobs,15-NoPlaceInFlash	;;���� ���� �� 䫥� ?
        BCND	Yes_It_Is,NTC   ;��, ���� ����!
	SPLK	#0FFFEh,TMP
Yes_It_Is:
	CALL 	FLPROG     ;����訩 ���� ����ᠫ�
	LACC 	TMP,8
	SACH 	TMP

	CALL 	FLPROG     ;���訩 ���� ����ᠫ�
;���� ������� १����� ����७��
	LACC 	IZNUMREC,3 ;� ⠡��� 8 ������⮢
	ADD  	#0800h     ;ᬥ饭�� �� flash
	SACL 	_FLADR

	MAR  	*,AR2      	;modify auxiliary register
				;������ ������� �� ���������⢠ LARP 1
				;�.�. �� ���쭥�襩 ����� �����ᮬ AR2
	LAR  	AR2,#TimeOfBeginMeas

	LACC	*
        AND	#03Fh
        BIT	_Jobs,15-Manual_Meas
        BCND	ItIsNotManualMeas,NTC
        OR	#040H		;�⠢�� ��� ��筮�� 
ItIsNotManualMeas:
	SACL 	TMP
	CALL 	FLPROG     ;������⢮ ᥪ㭤 ����ᠫ�
        mManual_MeasOff		;���뢠�� ��� ��筮�� ����७��

	MAR  	*,AR2      	;modify auxiliary register
				;������ ������� �� ���������⢠ LARP 1
				;�.�. �� ���쭥�襩 ����� �����ᮬ AR2
	LAR  	AR2,#TimeOfBeginMeas+1

	LACC	*
	SACL 	TMP
	CALL 	FLPROG     ;������⢮ ����� ����ᠫ�

	MAR  	*,AR2      	;modify auxiliary register
				;������ ������� �� ���������⢠ LARP 1
				;�.�. �� ���쭥�襩 ����� �����ᮬ AR2
	LAR  	AR2,#TimeOfBeginMeas+2

	LACC 	*+		;������⢮ �ᮢ


	CALL	ConvertBCD2BIN_

	MAR  	*,AR2


	SPM  	#0              ;Set P Register Output Shift Mode
				;multiplier output is left-shifted one place
	LT      *
	MPY     #24
	APAC			;᪫��뢠�� १���� � ᮤ�ন�� ��������

	CALL	ConvertBIN2BCD
	SACL	TMP


	CALL 	FLPROG     	;������⢮ �ᮢ ����ᠫ�
****************************

	SPM	#0
	LACC	SistolPressure
	ADD	#4000h,1
	SACL	TMP
	SPLK	#320,TMP+1

	LT      TMP
	MPYU    TMP+1
	PAC

	SACH 	TMP 		;��⮫��᪮� ��������
	LACC	TMP
	SUB	#48		;��⨭��� ���祭�� ����� 48
	SACL	TMP
	CALL FLPROG
*****************************

	SPM	#0
	LACC	AveragePressure		;�।��� ��������
	ADD	#4000h,1
	SACL	TMP
	SPLK	#320,TMP+1

	LT      TMP
	MPYU    TMP+1
	PAC

	SACH 	TMP 			;�।��� ��������
	LACC	TMP
	SUB	#48			;��⨭��� ���祭�� ����� 48
	SACL	TMP
	CALL 	FLPROG

*	SPLK #70,TMP ;�।��� ��������
*	CALL FLPROG
*****************************



	SPM	#0
	LACC	DiastolPressure
	ADD	#4000h,1
	SACL	TMP
	SPLK	#320,TMP+1

	LT      TMP
	MPYU    TMP+1
	PAC

	SACH 	TMP 		;����⮫��᪮� ��������
	CALL FLPROG
*****************************

* AveragePeriod (��ਮ� �थ��� ᮪�饭�� 㬭������ �� 16)
* ����塞 ����� f=60 ᥪ * 100 (��� ����) * 16 / AveragePeriod
	LAR	AR3,#TMP+3
	LAR	AR4,#_AveragePeriod
	MAR	*,AR3
	LACC	#6000
	SACL	*,AR4

*       ARP  = AR4
*       AR3  - ����뢠�� �� �᫨⥫�
*       AR4  - ����뢠�� �� �������⠫� (AR4 - "��⨢��")
*	AR3/AR4

	CALL	Division

*	SPLK #60,TMP ;���� �थ��� ᮪�饭��
	SACH	TMP,4
	CALL FLPROG

;        SPLK #0,TMP ;��� �訡�� (�� ��� �� ��� :)
	LACC 	ErrMeas
	ADD	#ERRORS_TABLE
	TBLR 	TMP
	CALL 	FLPROG
*****************************

 .if VersionFerrum=1		;��� �������

 .elseif VersionFerrum=2        ;� ������஬
*******
* ���뢠�� ��� �� 䫥�
*******
	CALL	Clear_cashe
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif


NeChet1
	SPLK 	#0,CountWrite ;
	mWeCountingFlashEnd	;����७�� ����ᠫ�
	RET
**** �⫠���

;HourTable .word 0,0024H,0048H,0072H,0096H


MakeValue

** ����塞 ����� ����� �� 䫥� �
** ᢮������ ���� ��� ����� १���⮢ ���᫥���
**
;	LACC MayToWrite
;	BCND YesWeWrite,NEQ
	BIT	_Jobs,15-WeCountingFlash
        BCND    YesWeWrite,TC

	CLRC 	SXM
;��ࢮ��砫쭮� ���㫥���
	SPLK 	#0,CountWrite ;���� ��祣� �� ����ᠫ�

	CALL	GetFlashCount
	SACL	IZNUMREC
	SUB  	#256      ;�� ��᫥���� ������ � ⠡���?
	BCND 	LastPlace,NEQ
NoPlace:
;��⠭����� �ਧ���� ��墠⪨ ����
	SPLK 	#0100h,IZNUMREC	;������⢮ ����ᥩ � ⠡��� ����७��
	mWeCountingFlash	;������⢮ ����ᥩ �����⠫�
	RET
NoPlaceFlash:
;	SPLK	#1,NoWritePlace	;��� ���� �� 䫥�
	mNoPlaceInFlash         ;��� ���� �� 䫥� ��� �䨭���ࠬ�
;	SPLK 	#1,MayToWrite  	;����� ����� �� 䫥� - �����
	mWeCountingFlash	;������⢮ ����ᥩ �����⠫�
	RET
LastPlace
	LACC 	TMP+2
	BCND FirstRec,EQ ;�� �����६���� � ��᫥���� � ��ࢠ� ������ :)
;᭠砫� ���� �஢����, ���� �� ���� �� flash
; #0FFFEh - �� �ਧ��� ��᫥���� ����� � TMP+1
	LACC 	TMP+1
	XOR 	#0FFFEh
	BCND 	NoPlaceFlash,EQ ;�᫨ ��� ���� �� flash
        
;	SPLK	#0,NoWritePlace
        mNoPlaceInFlashClear
 .if Mem=20	;���� �����奬� �� 2 Mbyte
	LACC 	TMP+1,5
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
	LACC 	TMP+1,6
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
	LACC 	TMP+1,7
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
ToRecBegin
	SACL 	IZFLLSB
	SACH 	IZFLMSB    ;���� ��������� (��᮫���)
			;����� ⥪�饩 ����� ���� � IZNUMREC
;	SPLK #1,MayToWrite  ;����� ����� �� 䫥�
        mWeCountingFlash
	RET
FirstRec
	LACC #01000h
	B ToRecBegin


YesWeWrite
*** �⫠���
;//        BIT  CNTMOD,15
;//        BCND NeChet,TC
	CLRC SXM
	LACC IZNUMREC
	SUB #256
	BCND NeChet,EQ ;�� ��襬, �᫨ �� �뫮 ࠧ�襭��
;	LACC	NoWritePlace  ;���� �� ���� �� 䫥�?
;	BCND NeChet,NEQ		;��� ���� :(
        BIT	_Jobs,15-NoPlaceInFlash	;���� �� ���� �� 䫥�?
	BCND	NeChet,TC		;��� ���� :(
	LACC CountWrite ;᪮�쪮 ���⮢ ����ᠫ� �� 䫥�
 .if OutputSectoring=1
 .elseif OutputSectoring=0
	BCND AlreadyWrite,NEQ
	LACC IZFLLSB
	ADD  IZFLMSB,16
	ADD #0880h     ;�ਡ���塞 ��ࢮ��砫쭮� ᬥ饭�� ��� ��ࠬ��஢
	SACL IZFLLSB
	SACH IZFLMSB    ;���� ��������� (��᮫���)
AlreadyWrite
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

	SPLK	#1,CountWrite	;�� 䫥� �뫠 ������
	LACC IZFLLSB
        ADD  IZFLMSB,16
	SACH 	_FLADR+1,1  ;���������� ������ ���� ����
	AND   	#07FFFh
	SACL 	_FLADR    ;���������� ������� ���� ����

 .if Mem=20	;���� �����奬� �� 2 Mbyte
        LACC IZFLLSB,11
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
        LACC IZFLLSB,10
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
        LACC IZFLLSB,9
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	SACH TMP
	LACC TMP
 .if Mem=20	;���� �����奬� �� 2 Mbyte
        ADD  IZFLMSB,11
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
        ADD  IZFLMSB,10
 .elseif Mem=44	;���� �����奬� �� 4 Mbyte
        ADD  IZFLMSB,9
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
        XOR  #0FFFEh
        BCND NeChet,EQ ;�� ��襬, ���� ���稫���

 .if ModeOutput=3	;//��� ������ �������� - ��אַ� � ���਩��

	SETC	SXM
	MAR	*,AR2
	LAR	AR2,#_ResultADC+6;AIN6 (PR0)
        LACC	*		;//��室 ��אַ� ��ࢮ�� ���稪� ��������

	SUB	Preset0
	ADD	#4000h,1

	SACL 	TMP
	CALL 	FLPROG

	MAR	*,AR2
	LAR	AR2,#_ResultADC+6;AIN6 (PR0)
        LACC	*,8		;����� ����

	SUB	Preset0,8
	ADD	#4000h,9
	SACH 	TMP
	CALL 	FLPROG

	SETC	SXM
	MAR	*,AR2
	LAR	AR2,#_ResultADC+9;AIN6 (PR0)
        LACC	*		;//��室 ��אַ� ��ࢮ�� ���稪� ��������

	SUB	Preset0
	ADD	#4000h,1

	SACL 	TMP
	CALL 	FLPROG

	MAR	*,AR2
	LAR	AR2,#_ResultADC+9;AIN6 (PR0)
        LACC	*,8		;����� ����

	SUB	Preset0,8
	ADD	#4000h,9
	SACH 	TMP
	CALL 	FLPROG

 .if PsevdoEKG=1
	CALL	puttable
 .endif
 .if ChannelEKG=1
	WriteEKG	1
	WriteEKG	2
 .endif


	LACC  	IZFLMSB,16
	OR 	IZFLLSB
	ADD  	#4
 .if PsevdoEKG=1
	ADD	#4
 .endif
 .if ChannelEKG=1
	ADD	#4
 .endif
	SACL IZFLLSB
	SACH IZFLMSB
 .newblock
 .elseif ModeOutput=2

        BIT _Jobs,11
        BCND NormailWrite1,NTC
        LACC _Jobs
        AND  #0FFEFH
	SACL _Jobs      ;���뢠�� ��� ����� � ����� ���祭�� ���
        WriteParams 12 ;��襬 � ��ࢮ�� ������ ��᫥ 䨫��� (���� ����)
        WriteParams 00 ;��襬 0 (��������, �� � ᫥� ᫮�� - ��㯥�쪠)
        WriteParams 41 ;��襬 ���祭�� DAC2

        B NotNormalWrite1

NormailWrite1
	WriteParams 10
        WriteParams 12 ;��襬 � ��ࢮ�� ������ ��᫥ 䨫��� (���� ����)
	WriteParams 32 ;��襬 �㬠�� ᨣ���(��� ����)
*        WriteParams 31 ;��襬 � �ᨫ������ ������ � ��� (��� ����)
        WriteParams 42 ;��襬 ���祭�� �����ﭭ�� � ���

NotNormalWrite1

	LACC  	IZFLMSB,16
	OR 	IZFLLSB
	ADD  #5
        SACL IZFLLSB
        SACH IZFLMSB
 .elseif ModeOutput=1
        BIT _Jobs,11
        BCND NormailWrite2,NTC
        LACC _Jobs
        AND  #0FFEFH
        SACL _Jobs      ;���뢠�� ��� ����� � ����� ���祭�� ���
NormailWrite2:
 .if WriteDebug!=0

	SETC	SXM
	MAR	*,AR2
	LAR	AR2,#_ResultADC+6;AIN6 (PR0)
        LACC	*		;//��室 ��אַ� ��ࢮ�� ���稪� ��������

	SUB	Preset0
	ADD	#4000h,1

	SACL 	TMP
	CALL 	FLPROG

	MAR	*,AR2
	LAR	AR2,#_ResultADC+6;AIN6 (PR0)
        LACC	*,8		;����� ����

	SUB	Preset0,8
	ADD	#4000h,9
	SACH 	TMP
	CALL 	FLPROG

 .else
        WriteParams 32 ;��襬 � �ᨫ������ ������ � 䨫��� (��� ����)
 .endif


 .if PsevdoEKG=1
	CALL	puttable
 .endif
 .if ChannelEKG=1
	WriteEKG	1
	WriteEKG	2
 .endif


	LACC  	IZFLMSB,16
	OR 	IZFLLSB
	ADD  	#2
 .if PsevdoEKG=1
	ADD	#4
 .endif
 .if ChannelEKG=1
	ADD	#4
 .endif
	SACL IZFLLSB
	SACH IZFLMSB
 .newblock
 .elseif ModeOutput=0
        BIT _Jobs,11
        BCND NormailWrite3,NTC
        LACC _Jobs
        AND  #0FFEFH
        SACL _Jobs      ;���뢠�� ��� ����� � ����� ���祭�� ���
;        WriteParams 12 ;��襬 � ��ࢮ�� ������ ��᫥ 䨫��� (���� ����)
        WriteParams 00 ;��襬 0 (��������, �� ��� �����ந���)
        B NotNormailWrite3

NormailWrite3
;        WriteParams 12 ;��襬 � ��ࢮ�� ������ ��᫥ 䨫��� (���� ����)
        WriteParams 21 ;��襬 � ��ண� ������ � ��� (��� ����)
;        WriteParams 33 ;��襬 � �ᨫ������ ������ � ��� (��� ����)

NotNormailWrite3

        LACC IZFLLSB
        ADD  IZFLMSB,16
        ADD  #2
        SACL IZFLLSB
	SACH IZFLMSB
 .else
  .emsg _ERROR __ Wrong PARAMETER_
 .endif

NeChet
*****
	 RET
 .if PsevdoEKG=1
	.copy   ekgtable.asm


puttable
	CLRC 	SXM
	LACC	PositionEKG
	SUB	#LengthTableEkg
	BCND	NoOverEKG,LT
	SPLK	#0,PositionEKG
NoOverEKG
;//������ ��ࢮ� ⠡����
	LACC	#StartEKGTable1
	ADD     PositionEKG

	TBLR 	TMP
	CALL 	FLPROG

	LACC	#StartEKGTable1
	ADD     PositionEKG
	TBLR 	TMP
	LACC	TMP,8
	SACH	TMP
	CALL 	FLPROG

;//������ ��ன ⠡����
	LACC	#StartEKGTable2
	ADD     PositionEKG

	TBLR 	TMP
	CALL 	FLPROG

	LACC	#StartEKGTable2
	ADD     PositionEKG
	TBLR 	TMP
	LACC	TMP,8
	SACH	TMP
	CALL 	FLPROG

	LACC	PositionEKG
	ADD	#1
	SACL	PositionEKG
	RET

 .endif

MakeSectoring
	CLRC SXM

 .if Mem=20	;���� �����奬� �� 2 Mbyte
	LACC IZFLLSB,11
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
	LACC IZFLLSB,10
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
	LACC IZFLLSB,9
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	SACH TMP
	LACC TMP
 .if Mem=20	;���� �����奬� �� 2 Mbyte
	ADD  IZFLMSB,11
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
	ADD  IZFLMSB,10
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
	ADD  IZFLMSB,9
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	XOR  #0FFFEh
	BCND NeChetSectoring,EQ ;�� ��襬, ���� ���稫���

;	LACC CountWrite ;᪮�쪮 ���⮢ ����ᠫ� �� 䫥�
;	ADD #1
;	SACL CountWrite
	SPLK	#1,CountWrite	;�� 䫥� �뫠 ������

	;��ࠢ������� �� �࠭��� 32 ����
	;6 ���� � ���� (3 ᫮�� ����� ���ᨢ��)
	;���� ���ᨢ ������ StepNumber*8 ����
	;��ன ���ᨢ ������ (MaxNumber+MaxNumberShift)*2 ����
** �� ��直� ��砩 :)
	LACC	_StepNumber
	AND	#01Fh		;���ᨬ� 32 ����
	SACL	TMP+3

	LACC	_MaxNumber
	ADD	_MaxNumberShift
** �� ��直� ��砩 :)
	AND	#0FFh		;���ᨬ� 256 ����
	SACL	TMP+4

	LACC	TMP+3,3
	ADD	#001,3
	ADD	TMP+4,1
	ADD	#001,1
	ADD	#6

	NEG
 .if Mem=20	;���� �����奬� �� 2 Mbyte
	AND	#01Fh
	ADD	#020h
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
	AND	#03Fh
	ADD	#040h
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
	AND	#07Fh
	ADD	#080h
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	SACL	TMP

	LACC 	IZFLLSB
 .if Mem=20	;���� �����奬� �� 2 Mbyte
	AND	#0FFE0h
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
	AND	#0FFC0h
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
	AND	#0FF80h
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	ADD  	IZFLMSB,16

	ADD	TMP
	SACL	IZFLLSB
	SACH	IZFLMSB



	SACH 	_FLADR+1,1  ;���������� ������ ���� ����
	AND   	#07FFFh
	SACL 	_FLADR    ;���������� ������� ���� ����




	SPLK	#0,TMP+2		;��稭��� � ���

AgainSaveMassiv1
******
	LAR	AR0,TMP+2
	LAR	AR5,#StartMeasAdress
	MAR     *,AR5
	MAR     *0+			;AR5 = & StartMeasAdress[i]

	LACC	*
	SACL	TMP			;��࠭塞 ������� ����
	CALL 	FLPROG
	mIncAddressToFlash

	MAR	*,AR5
	LACC	*,8
	SACH	TMP			;��࠭塞 ������ ����
	CALL 	FLPROG
	mIncAddressToFlash
******
	LAR	AR0,TMP+2
	LAR	AR5,#FinishMeasAddress
	MAR     *,AR5
	MAR     *0+			;AR5 = & StartMeasAdress[i]

	LACC	*
	SACL	TMP			;��࠭塞 ������� ����
	CALL 	FLPROG
	mIncAddressToFlash

	MAR	*,AR5
	LACC	*,8
	SACH	TMP			;��࠭塞 ������ ����
	CALL 	FLPROG
	mIncAddressToFlash
******
	LAR	AR0,TMP+2
	LAR	AR5,#AvrPress
	MAR     *,AR5
	MAR     *0+			;AR5 = & StartMeasAdress[i]

	LACC	*
	ADD	#4000h,1
	SACL	TMP			;��࠭塞 ������� ����
	CALL 	FLPROG
	mIncAddressToFlash

	MAR	*,AR5
	LACC	*,8
	ADD	#4000h,1+8
	SACH	TMP			;��࠭塞 ������ ����
	CALL 	FLPROG
	mIncAddressToFlash
******
	LAR	AR0,TMP+2
	LAR	AR5,#AverageAmplitude
	MAR     *,AR5
	MAR     *0+			;AR5 = & StartMeasAdress[i]

	LACC	*
	SACL	TMP			;��࠭塞 ������� ����
	CALL 	FLPROG
	mIncAddressToFlash

	MAR	*,AR5
	LACC	*,8
	SACH	TMP			;��࠭塞 ������ ����
	CALL 	FLPROG
	mIncAddressToFlash


	LACC	TMP+3
	SUB	TMP+2
	BCND	FinishSaveMassiv1,EQ
	LACC	TMP+2
	ADD	#1
	SACL	TMP+2
	B	AgainSaveMassiv1

FinishSaveMassiv1

* ���� ���ᨢ ����ᠫ�
******************


	SPLK	#0,TMP+2		;��稭��� � ���

AgainSaveMassiv2
	LAR	AR0,TMP+2
	LAR	AR5,#Diff2MaxAdressFinish
	MAR     *,AR5
	MAR     *0+			;AR5 = & Diff2MaxAdressFinish[i]

	LACC	*
	SACL	TMP			;��࠭塞 ������� ����
	CALL 	FLPROG
	mIncAddressToFlash

	MAR	*,AR5
	LACC	*,8
	SACH	TMP			;��࠭塞 ������ ����
	CALL 	FLPROG
	mIncAddressToFlash
******
	LACC	TMP+4
	SUB	TMP+2
	BCND	FinishSaveMassiv2,EQ
	LACC	TMP+2
	ADD	#1
	SACL	TMP+2
	B	AgainSaveMassiv2

FinishSaveMassiv2

	LACC	TMP+3,3
	ADD	#1,3
	SACL	TMP		;1
	CALL 	FLPROG
	mIncAddressToFlash

	LACC	TMP+3,3+8
	ADD	#1,3+8
	SACH	TMP		;2
	CALL 	FLPROG
	mIncAddressToFlash

	LACC	TMP+4,1
	ADD	#1,1
	SACL	TMP		;3
	CALL 	FLPROG
	mIncAddressToFlash

	LACC	TMP+4,1+8
	ADD	#1,1+8
	SACH	TMP		;4
	CALL 	FLPROG
	mIncAddressToFlash


	SPLK	#0,TMP		;5
	CALL 	FLPROG
	mIncAddressToFlash

	SPLK	#0,TMP		;6
	CALL 	FLPROG
*	mIncAddressToFlash


NeChetSectoring
*****
	 RET



**************
* ᪮�쪮 ����७�� �� 䫥�?
* �����頥� १���� � ACC (� � TMP+2)
; ���� �� ���� �� flash
; #0FFFEh - �� �ਧ��� ��᫥���� ����� � TMP+1
* use tmp,tmp+1,tmp+2
**************
GetFlashCount
	LACC	#0		;�⠥� 䫥� �� ������� �����
	SACL	_FLADR
	SACL	_FLADR+1


	SACL 	TMP+2
	SACL	TMP


AgainFindZapis
	LACC TMP
	SACL TMP+1
	CALL	FLREAD
	SACL	TMP

	CALL	FLREAD
	SACL	*		;���������� � �⥪�
	LACC	TMP
	ADD	*,8
	SACL 	TMP
	XOR  	#0FFFFh
	BCND 	PoslednyaaZapis,EQ
	LACC 	TMP+2
	ADD  	#1
	SACL 	TMP+2
	SUB  	#256      ;�� ��᫥���� ������ � ⠡���?
	BCND 	AgainFindZapis,NEQ
;��, ����� ���� ���, ��᫥���� ������
*NoPlaceZapis
;��⠭����� �ਧ���� ��墠⪨ ����
	SPLK 	#0101h,TMP+2
*��諨 ��᫥���� ������
PoslednyaaZapis
	LACC	TMP+2
	BCND	PoslednyaaZapis1,EQ
	SUB	#1
	SACL	TMP+2
PoslednyaaZapis1
	RET
***********************
* ������� ������ �� 䫥�
* ACC - ����� �����
* ������ ���쬨 ���� � TMP
* use tmp,tmp+1,..,tmp+7
***********************

GetRecordFlash
	MAR     *,AR1
	POPD	*+
	SAR     AR7,*+
	SAR	AR0,*+


	SACL	_FLADR
	LACC	_FLADR,3
	ADD  	#0800h     ;ᬥ饭�� �� flash ⠡���� १���⮢
	SACL	_FLADR
	SPLK	#0,_FLADR+1

	LAR	AR0,#7
	LAR	AR2,#TMP
GetRec_1
	CALL    FLREAD
	MAR	*,AR2
	SACL	*+,0,AR0
	BANZ    GetRec_1,*-,AR2      ;Branch on Auxiliary Register Not Zero


	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR0,*-
	LAR     AR7,*-
	PSHD	*
	RET

*
;������� ��楤��� �ணࠬ��஢���� �१ ��᫥����⥫�� ����
 .if SerialProg=1
*************************************************************************
* ����஢���� ������ �ணࠬ�� �� �ணࠬ���� 䫥�, � �ணࠬ��� ������
*************************************************************************
AddressForRead .set 00d00h

        .ref Lenfl_clr
	.ref Lenfl_ers
	.ref Lenfl_wrt,Lenfl_prg
	.ref LenDLY,LenREGS,LenARRAY
CopyCodeToRam
	LAR  	AR2,#00800h  	;��९��뢠��� �ணࠬ��
	MAR	*,AR2
	LACC    #LenPrgAlgor-1
	ADD	#Lenfl_clr
	ADD	#Lenfl_ers
	ADD	#Lenfl_wrt
	ADD	#Lenfl_prg
	ADD	#LenDLY
	ADD	#LenREGS
	ADD	#LenARRAY
;-1
	SACL	TMP
	LACC 	#BeginOfBlock
	RPT	TMP
	TBLR 	*+
	RET
* .asect "PrgAlgor",FirstAdressInRam

;**Variables included from flash algorithms.
	.include "flashprg\svar4.h"    ; Variable declarations
	.ref GCLR              ; References clear algo.
	.ref GPGMJ             ; References program algo.
	.ref GERS              ; References erase algo.
	.ref FLWS              ; References Flash-write algo.
*	.def BeginPrgAlgor
;**Parameters used by flash algorithms.
	.def PRG_bufaddr, PRG_paddr
	.def PRG_length, PARMS
	.def BeginOfBlock
	.def SEG_ST,SEG_END,PROTECT

*************************************************************************
*VARS:    .usect  "PRG_data",16  ;This is an uninitialized data section  *
VARS	.set	0300h
				;required by the standard flash algos   *
				;for temporary variables. Pointers to   *
				;this space are hardcoded in SVAR3X.H,  *
				;and variables are init'd at run-time.  *
*************************************************************************
*PARMS:   .usect  "PRG_parm",10  ;This is an uninitialized data section  *
PARMS	.set	0310h
				;which is used for temporary variables, *
				;and for passing parameters to the flash*
				;algorithms.                            *
SEG_PARMS	.set	6
*************************************************************************
PROTECT     .set    PARMS       ;Segment enable bits.                   *
*************************************************************************
*****        Parameters needed for Programming algorithm.           *****
*************************************************************************
PRG_bufaddr .set    PARMS+1     ;Address of buffer for program data.    *
PRG_paddr   .set    PARMS+2     ;First flash address to program.        *
PRG_length  .set    PARMS+3     ;Length of block to program.            *
*************************************************************************
*****    Parameters needed for CLEAR, ERASE, and FLW algorithms.    *****
*************************************************************************
SEG_ST      .set    PARMS+4     ;Segment start address.                 *
SEG_END     .set    PARMS+5     ;Segment end address.                   *
*************************************************************************
****                  Other misc variables.                         *****
*************************************************************************
ERS_COUNT   .set    PARMS+6     ;Used for erase fail count.             *
*************************************************************************

*        .text
;BeginOfBlock	.set	$
BeginOfBlock	.set	0110h
       .sect "PrgAlgor"
BeginPrgAlgor	.set	$
*	.include "flashprg\sclr4.asm"
*	.include "flashprg\sera4.asm"
*	.include "flashprg\sflw4.asm"
*	.include "flashprg\spgm4.asm"
*	.include "flashprg\sutils4.asm"

*******************************************************************
** First erase flash1 by invoking the clear and erase algorithms.**
** Note that three parameters must be initialized before calling **
** the algorithms.                                               **
*******************************************************************
	LDP     #SEG_PARMS
	SPLK    #0,ERS_COUNT    ;Set erase fail count to 0.
**********Put parameters where they belong.**********
	SPLK    #0ff00h,PROTECT
	SPLK    #00000h,SEG_ST
	SPLK    #03FFFh,SEG_END
	CALL	_erase

	SPLK    #0ff00h,PROTECT
	SPLK    #04000h,SEG_ST
	SPLK    #07FFFh,SEG_END
	CALL	_erase
	B	program_flash
***********First clear flash ************
_erase:
ers_loop:
        MAR	*,AR1
	LACK	0
	SACL	*+
	LACK	0
	SACL	*+
        call	_display_persent1
	SBRK	2

        LDP     #SEG_PARMS

	CALL    GCLR            ;Clear flash.
	LACL    ERROR           ;Check for CLEAR/ERASE error
	BCND    ers_error,neq   ;If error, then hard fail.
***********Next erase flash ************

        MAR	*,AR1
	LACK	0
	SACL	*+
	LACK	1
	SACL	*+
	CALL	_display_persent1
	SBRK	2
	LDP     #SEG_PARMS

	CALL    GERS            ;Erase flash.
	LACL    ERROR           ;Check for CLEAR/ERASE error
	BCND    depletion,neq   ;If error, then try Flash-write.
        B       ers_done        ;Else, no errors erasing.
depletion:

        MAR	*,AR1
	LACL    ERS_COUNT       ;Get erase fail count.
	SACL	*+
	LACK	1
	SACL	*+
	CALL	_display_persent1
	SBRK	2
	LDP     #SEG_PARMS


	LACL    ERS_COUNT       ;Get erase fail count.
        ADD     #1              ;Increment fail count.
        SACL    ERS_COUNT       ;Save new count.
        SUB     #10             ;CHECK for max of 10.
        BCND    ers_error,GT    ;If ers_cout>10 then hard fail.
        CALL    FLWS            ;Else, try to recover from depletion.
        LACL    ERROR           ;Check for FLASH-WRITE error.
        BCND    ers_error,neq   ;If couldn't recover, then hard fail.
        B       ers_loop        ;Else, Try erase again.


ers_done:
	RET
*******************************************************************
** If here then flash is erased and ready to be reprogrammed.    **
** This is a good place in the example to set a breakpoint so    **
** that erasure can be verified (i.e. all flash bits should be 1)**
*******************************************************************

*******************************************************************
** At this point, an actual application fills a buffer with      **
** the data to be programmed. To simulate this in the example,   **
** three SARAM locations are initialized.                        **
*******************************************************************
program_flash:
	LDP     #4		;� ��� ��㣠� ��࠭�� ����� :)
	LAR	AR2,#0		;��砫�� ���� �ணࠬ��஢����

	LACC    #1Fh,1		;#1F0000h ���� ��� ��訢��
	SACL	_FLADR+1		;��砫�� ���� �� 䫥�
	SPLK	#0,_FLADR
Save_Next_Block
	LAR     AR7, #AddressForRead     ;Using last 3K of SARAM as buffer.
	CALL	Read_512	;�⠥� 256 ᫮� (512 ����)


	CALL	PROGRAM_BLOCK	;�ணࠬ���㥬

        MAR	*,AR1
	SAR	AR2,*
        LACC	*+,8
        SACH	*+
	LACK	1
	SACL	*+
	CALL	_display_persent1
	SBRK	2
        MAR	*-,AR1
        LAR	AR2,*


        LDP     #4		;� ��� ��㣠� ��࠭�� ����� :)
	SAR	AR2,*
	LACC	*
	ADD	#100h
	SACL	*
	SUB	#8000h
	BCND	prg_done,GEQ
	LAR	AR2,*

	;㢥��稢��� ���� �⥭�� �� 䫥�
	LACC 	_FLADR
	AND	#07FFFh
	ADD  	#200H		;���� 512
	SACL 	_FLADR
	BIT	_FLADR,0
	BCND 	Progr_Flash_NoOver,NTC
	AND  	#07FFFh
	SACL	_FLADR
	LACC 	_FLADR+1
	ADD  	#1
	SACL 	_FLADR+1
Progr_Flash_NoOver:

	B	Save_Next_Block

*******************************************************************
** Now that the data to be programmed is ready, the programming  **
** algorithm is invoked. Note that four parameters must be       **
** initialized before calling the algorithm.                     **
*******************************************************************

PROGRAM_BLOCK
	MAR	*,AR1
	POPD	*+
	SAR     AR2,*+
	SAR     AR0,*+

	LDP     #SEG_PARMS
**********Put parameters where they belong.**********
	splk    #0ff00h,PROTECT
	splk    #AddressForRead,PRG_bufaddr
*	splk    #00000h,PRG_paddr
	SAR	AR2,PRG_paddr		;���� ��� �ணࠬ��஢���� �࠭����� �����

	splk    #00100h,PRG_length
***********Next program flash ************
	CALL    GPGMJ           ;Program flash from buffer.
	LACL    ERROR           ;Check for program error.
	BCND    prg_error,neq   ;If error then clear ACC.

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR0,*-
	LAR     AR2,*-
	PSHD	*
	RET
*	B       prg_done        ;Else, No errors programming.

ers_error:
*******************************************************************
** If here then an unrecoverable error has occured during erase. **
** In an actual application, the system takes some action to     **
** indicate that service is required.                            **
*******************************************************************
;        B       ers_error       ;Error while erasing.
prg_error:
*******************************************************************
** If here then an error has occured during programming. In an   **
** actual application, the system takes some action to indicate  **
** that service is required.                                     **
*******************************************************************
	LDP	#4
	SPLK	#500,TMP
Beeping4khz
	mDelay250mks
	mBeepXOR

	LACC	TMP
	SUB	#1
	SACL	TMP
	BCND 	Beeping4khz,NEQ
	SPLK	#250,TMP
Beeping2khz
	mDelay250mks
	mDelay250mks
	mBeepXOR

	LACC	TMP
	SUB	#1
	SACL	TMP
	BCND 	Beeping2khz,NEQ

	B       prg_error       ;Error while programming.

prg_done:
*******************************************************************
** If here then flash has been successfully programmed.           *
*******************************************************************
	LDP	#4
	SPLK	#500,TMP
Beeping4khz_1
	mDelay250mks
	mBeepXOR

	LACC	TMP
	SUB	#1
	SACL	TMP
	BCND 	Beeping4khz_1,NEQ

	SPLK	#250,TMP
Beeping2khz_1
	mDelay250mks
	mDelay250mks
*	mBeepXOR

	LACC	TMP
	SUB	#1
	SACL	TMP
	BCND 	Beeping2khz_1,NEQ
	B       prg_done        ;Done programming.
 .if VersionFerrum=1		;��� �������
*******
* �⥭�� ��࠭���
*  ���� ��� �⥭��, �� ���� ����� ���� ��࠭���
*  ASFLMSB     15-20bit
*  AFLLSB      0-14bit
*	AR7 - �㤠 ����㦠��
*
Read_512

	mRead_512b

 .elseif VersionFerrum=2        ;� ������஬
*******
* �⥭�� ��࠭���
*  ���� ��� �⥭��, �� ���� ����� ���� ��࠭���
*  ASFLMSB     15-20bit
*  AFLLSB      0-14bit
*	AR7 - �㤠 ����㦠��
*
*  PA11-0 - ���� ��࠭���
*  BA9-0  - ���� ���� ����� ��࠭���
*  X      - ������� ��
* 1.[52h],[r,r,PA11-6],
* 2.[PA5-0,BA9-8],[BA7-0],
* 3.[X],[X],
* 4.[X],[X]
******
Read_512

	mRead_512b
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

DISPL_REFRESH:
        MAR	*,AR2
	LAR	AR2,#iDISPL

        BIT	_Jobs,15-Manual_Meas
	BCND 	CurNoRefresh,NTC
	LACC 	*          	;�ந������ refresh
	CMPL
	SACL 	*+
	LACC 	*
	CMPL
	SACL    *
CurNoRefresh:
	LACC _Jobs
	XOR   #(1<<Manual_Meas)
	SACL _Jobs


        MAR	*,AR1
;�뢮� �祥� ����� �������� �� ��ᯫ��
	SPLK 	#SSPS,*    ;SSP start
	OUT  	*,SSPCR    ;Synchronous Serial Port Control Register
	MAR	*,AR2
	LAR	AR2,#iDISPL

	OUT  	*+,SDTR
	OUT  	*,SDTR

	mImp_ssp
	mImp_ssp
	mImp_ssp

      	mImp_ssp
	mImp_ssp
	mImp_ssp
	mImp_ssp
      	mImp_ssp
	mImp_ssp
	mImp_ssp
	mImp_ssp
      	mImp_ssp
	mImp_ssp
	mImp_ssp
	mImp_ssp
      	mImp_ssp
	mImp_ssp
	mImp_ssp
	mImp_ssp

      	mImp_ssp
	mImp_ssp
	mImp_ssp
	mImp_ssp
      	mImp_ssp
	mImp_ssp
	mImp_ssp
	mImp_ssp
      	mImp_ssp
	mImp_ssp
	mImp_ssp
	mImp_ssp
      	mImp_ssp
	mImp_ssp
	mImp_ssp
	mImp_ssp

        MAR	*,AR1
	SPLK 	#SSPR,*
	OUT  	*,SSPCR

	LACC 	_DPA0,0
	OR   	#02h
	SACL 	_DPA0
	OUT  	_DPA0,PA0
	AND  	#0FFFDh
	SACL 	_DPA0
	OUT  	_DPA0,PA0
	RET

******************************************************
* FUNCTION DEF : _display_persent
******************************************************
_display_persent1:
LF2	.set	1
	SAR	AR0,*+
	SAR	AR1,*
	LAR	AR0,*+,AR2
*** 105	-----------------------    iSYMBL[3] = perc&0xfu;
;>>>> 	  iSYMBL[3]=(perc&0x0F);
	LACK	15
	LARK	AR2,-4+LF2
	MAR	*0+
	AND	* 
	LDPK	_iSYMBL+3
	SACL	_iSYMBL+3
*** 106	-----------------------    iSYMBL[2] = perc>>4&0xfu;
;>>>> 	  iSYMBL[2]=(perc&0x0F0)>>4;
	RSXM
	LAC	*+,11
	ANDK	15,15
	LDPK	_iSYMBL+2
	SACH	_iSYMBL+2,1
*** 107	-----------------------    iSYMBL[1] = 10u;
;>>>> 	  iSYMBL[1]=S_SPACE;
;>>>> 	  switch(cod){
;>>>> 	   case FLASH_CLEAR:
;>>>> 	    iSYMBL[0]=S_C;
;>>>> 	    break;
;>>>> 	   case FLASH_ERASE:
;>>>> 	    iSYMBL[0]=S_E;
;>>>> 	    break;
;>>>> 	   case FLASH_PROGRAM:
	LACK	10
	LDPK	_iSYMBL+1
	SACL	_iSYMBL+1
***  	-----------------------    switch ( cod ) {...};
	ZALS	* 
	BZ	L3
	SUBK	1
	BZ	L2
	SUBK	1
	BNZ	disp_pers_EPI0_2
***	-----------------------g1:
*** 116	-----------------------    iSYMBL[0] = 14u;
;>>>> 	    iSYMBL[0]=S_P;
	LACK	14
	LDPK	_iSYMBL
	SACL	_iSYMBL
*** 117	-----------------------    goto g4;
;>>>> 	    break;
	B	disp_pers_EPI0_2
L2:
***	-----------------------g2:
*** 113	-----------------------    iSYMBL[0] = 15u;
	LACK	15
	LDPK	_iSYMBL
	SACL	_iSYMBL
*** 114	-----------------------    goto g4;
	B	disp_pers_EPI0_2
L3:
***	-----------------------g3:
*** 110	-----------------------    iSYMBL[0] = 16u;
	LACK	16
	LDPK	_iSYMBL
	SACL	_iSYMBL
***	-----------------------g4:
***  	-----------------------    return;
disp_pers_EPI0_2:
	CALL	MODIFSB1
	LDP     #4		;� ��� ��㣠� ��࠭�� ����� :)
	CALL	DISPL_REFRESH,*,AR1
	MAR	* ,AR1
	SBRK	2
	LAR	AR0,* 
	RET

MODIFSB1:
	LDP     #4		;� ��� ��㣠� ��࠭�� ����� :)
	MAR  	*,AR7
	LAR	AR7,#_iSYMBL

	LACC 	#DSIM0_1     	;�८�ࠧ������ ᨬ����� ��ᯫ��
	      			;� ᫮�� �뤠����� �� ��࠭
	ADD	*+

	TBLR 	TMP
	LACC 	#DSIM0_1
	ADD	*+

	TBLR 	TMP+1
	LACC 	#DSIM0_1
	ADD	*+

	TBLR 	TMP+2
	LACC 	#DSIM0_1
	ADD	*
	LAR	AR7,#iDISPL

	TBLR 	TMP+3
	LACC 	TMP,8
	OR   	TMP+1
	SACL 	*+
	LACC 	TMP+2,8
	OR   	TMP+3
	SACL 	*
	RET
out_display:

*                                                         GFEDCBA
DSIM0_1 .word   003Fh   ; 0 ���ᠭ�� ᨬ���� 0           00111111    A
        .word   0006h   ; 1 ���ᠭ�� ᨬ���� 1           00000110  F   B
  	.word   005Bh   ; 2 ���ᠭ�� ᨬ���� 2           01011011    G
	.word   004Fh   ; 3 ���ᠭ�� ᨬ���� 3           01001111  E   C
	.word   0066h   ; 4 ���ᠭ�� ᨬ���� 4           01100110    D
	.word   006Dh   ; 5 ���ᠭ�� ᨬ���� 5           01101101
	.word   007Dh   ; 6 ���ᠭ�� ᨬ���� 6           01111101
	.word   0007h   ; 7 ���ᠭ�� ᨬ���� 7           00000111
	.word   007Fh   ; 8 ���ᠭ�� ᨬ���� 8           01111111
	.word   006Fh   ; 9 ���ᠭ�� ᨬ���� 9           01101111
	.word   0077h   ; A ���ᠭ�� ᨬ���� "�����"   01110111
	.word   007Fh   ; B ���ᠭ�� ᨬ���� (����.��) 01111111
	.word   0039h   ; C ���ᠭ�� ᨬ���� (�।.��) 00111001
	.word   003Fh   ; D ���ᠭ�� ᨬ���� (����.��) 00111111
	.word   0079h   ; E ���ᠭ�� ᨬ���� P           01111001
	.word   0071h   ; F ���ᠭ�� ᨬ���� E           01110001


LenPrgAlgor	.set	$-BeginPrgAlgor

 .elseif SerialProg=0
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
