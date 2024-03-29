;&D
* $Id: BPFLASHP.ASM,v 1.9 2001-10-22 13:38:12 peter Exp $
* ���।������ Flash ����� ������ ��������.

* ���ᨬ��쭮� ������⢮ ����७��  - 256.

* ����       ���ᠭ�� ������
* 00000h - 0001FFh      ��砫�� ���� ������ ����ᮢ ����७��
* 00200h - 0002FFh      ��ࠬ���� �ணࠬ��஢���� �ਡ��
* 00300h - 0007FFh      �஬������ १����� ����७��
* 00800h - 000FFFh      �������� ����७��
* 01000h - 1FFFFFh      ����� ����ᮢ ����७��


* �������� ����७��.
* �������� ����७�� ����� ᫥������ ��������:

*  ����
*  �����
* ��������  ���ᠭ�� ������        �ਬ�砭��
* 00h - 02h        �६�           ���� 00h - 0-5 ࠧ��� - ᥪ㭤�,
*              ��砫� ����७��    ���� 01h - 0-3 ࠧ��� - ������� �����,
*                                  ���� 01h - 4-7 ࠧ��� - ����⪨ �����,
*                                  ���� 02h - 0-3 ࠧ��� - ������� �ᮢ,
*                                  ���� 02h - 4-7 ࠧ��� - ����⪨ �ᮢ
* 03h            ���⮫��᪮�        �������� ����७�� ��⮫��᪮��
*                ��������          �������� �� 48 �� 300 ��.��.��.
*             (��⨭��� ���祭��
*                  ����� 48)
* 04h          �।��� ��������    �������� ����७�� �।���� ��������
*             (��⨭��� ���祭��       �� 48 �� 300 ��.��.��.
*                  ����� 48)
* 05h          ����⮫��᪮�      �������� ����७�� ����⮫��᪮��
*                ��������             �������� �� 0 �� 255 ��.��.��.
* 06h          ����� �थ���   �������� ����७�� ����� �थ���
*                 ᮪�饭��          ᮪�饭�� �� 0 �� 255 �/���.
* 07h           ��� �訡��
*
* 000-������ ���ணࠬ��஢�� � ��⮢ � ��᫥�������
* 080-�⬥�� ����७�� ��樥�⮬
* 081-����殮��� ���筨�� ��⠭�� ���� �����⨬��� ���祭��
* 082-��������� (��ᮥ������) ������
* 083-������ ��� ��������⥬� � ������ �ய�᪠�� ������
* 084-��०�� ��㡪� �������
* 085-���⮫��᪮� �� ��樥�� ����� 270 �� ��. ��.
* 086-������  �஢���  ᨣ���� (��� ������⢨�)
* 087-�६� ����७�� �� �ॢ�ᨫ� 2 ���
* 088, 089-��᮪�� �����⥫쭠� ��⨢����� ��樥��,
*     �९�������� �஢������ ����७��
* 090-�����㦥��� ����ࠢ���� ��᫥ ����祭�� ������
* 091-������ ��᫥ ������ ���३ �� �� ���ணࠬ��஢��
* 092-���誮� ����讥 �६� ����७�� (����� 2 ���)
* 093-��������� ��������� ࠧ�殮��
* 094-�� 㤠���� ��।����� ����⮫�
* 095-�� 㤠���� ��।����� ��⮫�
* 096-�� 㤠���� ��।����� ����� ����
* 097-���䠪�� �������� ��� ��⬨�
* 098-��� ����⨢��� ������ ������ ��������� १���⠬�.
*     ������⢮ ����७�� �ॢ�ᨫ� 150 (*)
* > 098-����७�� ��ࢠ�� ��-�� ����⭮�� ०��� ࠡ��� ������⨪�



*****************************************************************************
* ���⪠ 䫥�
*****************************************************************************
FLCLR   LAR     AR2,#0D555h  ; 05555h,02AAAh,05555h,05555h,02AAAh,05555h
        LAR     AR3,#0AAAAh  ;   0AAh,  055h,  080h,  0AAh,  055h,  010h Erase
        MAR     *,AR2

        LACC    _DPA0,0     ;�⥭�� ॣ���� ������ ����
        AND     #0001FH     ;���뢠�� ����� ��࠭��� � #CEF =0 (#CE)
                        ;ࠧ�襭�� ࠡ��� � 䫥�
        SACL    _DPA0       ;���������� ����� � �����
        OUT     _DPA0,PA0   ;� �뢮��� � ����
        SPLK    #0AAh,*,AR3   ;�ணࠬ���㥬 䫥� �� ��࠭��
        SPLK    #055h,*,AR2
        SPLK    #080h,*,AR2
        SPLK    #0AAh,*,AR3
        SPLK    #055h,*,AR2
        SPLK    #010h,*,AR2
        LACC    #07FFFh            ; T = 15 �.
	SPLK    #0800h,TMP+1
FLCLR1  SUB     #1
	RPT     TMP+1
        NOP
	SPLK    #1,TMP
	BCND    ERRCLR,LEQ
        BCND    FLCLR1,BIO
*
CLRCHK  LAR     AR0,#7FFFh
        LAR     AR2,#8000h
CLRCON  LACC    *+,0,AR0           ;�⥭�� ������ � 䫥�
        AND     #0FFh              ;��᪨�㥬 ����訥 8 ���
        XOR     #0FFh              ;�ਢ���� � ���
        BCND    ERRCLR,NEQ         ;�᫨ �� ࠢ�� ���, � ��㤠���� �����
        BANZ    CLRCON,*-,AR2      ;Branch on Auxiliary Register Not Zero
        LACC    _DPA0
        ADD     #1,6       ;�ਡ���塞 1 � "������ ��࠭�窨"
        SACL    _DPA0
        OUT     _DPA0,PA0   ;�뢮��� ᮤ�ন��� ॣ���� � ����
        BIT     _DPA0,3     ;��襫 ����� ��࠭��� �� ��� D11 ?
        BCND    CLRCHK,NTC ;�த����� �஢��� ᫥���饩 "��࠭�窨"
	SPLK    #0,TMP        ; ���⪠ ����p訫��� �ᯥ譮
*
ERRCLR  LACC    _DPA0,0     ;�⠥� ᮤ�ন��� ॣ���� ������ ����
        OR      #0020H      ;�몫�砥� �롮�� 䫥� #CEF =1 (#CE)
        SACL    _DPA0       ;���������� ���ﭨ� ���� � �����
        OUT     _DPA0,PA0   ;�뢮��� �� � ����
        RET
****************
* ���⪠ ��࠭��� 䫥�
* TMP - ����� 64 ����⭮� ��࠭���
****************
FlashPageClear
        LAR     AR2,#0D555h  ; 05555h,02AAAh,05555h,05555h,02AAAh,SA (A20-16)
        LAR     AR3,#0AAAAh  ;   0AAh,  055h,  080h,  0AAh,  055h,  030h Sector Erase
        MAR     *,AR2

        LACC    _DPA0,0     ;�⥭�� ॣ���� ������ ����
        AND     #0001FH     ;���뢠�� ����� ��࠭��� � #CEF =0 (#CE)
                        ;ࠧ�襭�� ࠡ��� � 䫥�
	ADD     TMP,7 ; ᤢ�� ��� ���室� � D7 ᫮������� ����� ��࠭���
        SACL    _DPA0       ;���������� ����� � �����
        OUT     _DPA0,PA0   ;� �뢮��� � ����
        OR      #0020H      ;�몫�砥� �롮�� 䫥� #CEF =1 (#CE)
        SACL    _DPA0       ;���������� ���ﭨ� ���� � �����
        SPLK    #0AAh,*,AR3   ;�ணࠬ���㥬 䫥� �� ��࠭��
        SPLK    #055h,*,AR2
        SPLK    #080h,*,AR2
        SPLK    #0AAh,*,AR3
        SPLK    #055h,*,AR2
        SPLK    #030h,*,AR2
        LACC    #07FFFh            ; T = 15 �.
	SPLK    #0800h,TMP+1
FLCLR2  SUB     #1
	RPT     TMP+1
        NOP
;        SPLK #1,TMP
        BCND    ERRCLR1,LEQ
        BCND    FLCLR2,BIO
*
ERRCLR1
        OUT     _DPA0,PA0   ;�뢮��� �� � ����
        RET
****************
* �஢�ઠ ����� ��࠭��� 䫥�
* TMP - ����� 64 ����⭮� ��࠭���
****************
FlashPageCheck
        MAR     *,AR2
        LACC    _DPA0,0     ;�⥭�� ॣ���� ������ ����
        AND     #0001FH     ;���뢠�� ����� ��࠭��� � #CEF =0 (#CE)
                        ;ࠧ�襭�� ࠡ��� � 䫥�
	ADD     TMP,7 ; ᤢ�� ��� ���室� � D7 ᫮������� ����� ��࠭���
        SACL    _DPA0       ;���������� ����� � �����
        OUT     _DPA0,PA0   ;� �뢮��� � ����
	OR      #0020H      ;�몫�砥� �롮�� 䫥� #CEF =1 (#CE)
        SACL    _DPA0       ;���������� ���ﭨ� ���� � �����
;CLRCHK1
        LAR     AR0,#7FFFh
        LAR     AR2,#8000h
CLRCON1 LACC *+,0,AR0           ;�⥭�� ������ � 䫥�
        AND     #0FFh              ;��᪨�㥬 ����訥 8 ���
        XOR     #0FFh              ;�ਢ���� � ���
        BCND    ERRCheck,NEQ       ;�᫨ �� ࠢ�� ���, � �����
        BANZ    CLRCON1,*-,AR2      ;Branch on Auxiliary Register Not Zero
        ;�訡�� �� �뫮
ERRCheck
        ; �ந��諠 �訡��
        OUT     _DPA0,PA0   ;�뢮��� �� � ����
        RET
*************************
*       �ணࠬ��஢���� 䫥�
*       ���� ��p�������
*       AFLMSB     15-20bit
*       AFLLSB      0-14bit,15bit=1
*       TMP    -  �室�� �����
*       �᫨ �p� ��室� �� ����p��p���� ACC=0 �� Ok.
* �ᯮ���� AR2,AR3,AR4
*************************
FLPROG  LACC 	_DPA0         ; 05555h,02AAAh,05555h, PA
	AND  	#001Fh       ;   0AAh,  055h,  0A0h, PD  Program
*	ADD  	AFLMSB,6
	ADD  	_FLADR+1,6
	SACL 	_DPA0
	OUT  	_DPA0,PA0
	OR   	#20h
	SACL 	_DPA0
*	LACC 	AFLLSB
	LACC 	_FLADR
	OR   	#8000h
	SACL 	TMP+1

	LACC 	_FLADR
        AND	#07FFFh
	ADD  	#1
	SACL 	_FLADR
	AND  	#07FFFh
	BCND 	FL_NoOver,NEQ
	SACL	_FLADR
	LACC 	_FLADR+1
	ADD  	#1
	SACL 	FLADR+1
FL_NoOver
	LAR  	AR2,#0D555h
	LAR  	AR3,#0AAAAh
	LAR  	AR4,TMP+1      ; PA
	MAR  	*,AR2
	SPLK 	#0AAh,*,AR3
	SPLK 	#055h,*,AR2
	SPLK 	#0A0h,*,AR4
	BLDD 	#TMP,*,AR2     ; PD �� TMP �� FLASH
	LACC 	#0FFh
FLPRG1  SUB  	#1
	RPT  	#1
	NOP
	BCND 	ERRPRG,LEQ
	BCND 	FLPRG1,BIO
	SPLK 	#0AAh,*,AR3
	SPLK 	#055h,*,AR2
	SPLK 	#0F0h,*,AR4
	BLDD 	*,#TMP+1,AR2   ; PD �� FLASH �
	OUT  	_DPA0,PA0
;        SPLK 	#0,TMP+3
	LACC 	TMP
	XOR  	TMP+1
	AND  	#0FFh
	RETC 	EQ
*
ERRPRG  OR 	#0FFh
;       SPLK 	#1,TMP+3
	OUT  	_DPA0,PA0
	RET
*

*******
* �⥭�� ��࠭���
*  ���� ��� �⥭��, �� ���� ����� ���� ��࠭���
*  ASFLMSB     15-20bit
*  AFLLSB      0-14bit
*	AR7 - �㤠 ����㦠��
* ��楤�� ���� ����� �� 䫥� � ����㦠�� ��ࠬ� � ᫮�� AR7
* � ���� ��砫�� ���� ������ ���� ���
******

	mRead_512b


***********
* �⥭�� �� ����� FLADR 2 kb ������ � AR2
***********
Read2K

	LACC 	_DPA0
	AND  	#01Fh
	ADD  	FLADR+1,6
	SACL 	_DPA0
	OUT  	_DPA0,PA0
	OR   	#20h
	SACL 	_DPA0

	LACC    FLADR
	OR	#08000H
	SACL	TMP
	LAR  	AR7,TMP
	LAR	AR0,#07FFH
	MAR	*,AR7
Read2K_1
	LACC	*+,0,AR2
	SACL	*+,0,AR0
	BANZ    Read2K_1,*-,AR7
	OUT  	_DPA0,PA0
	RET

*************************
*       �⥭�� 䫥�
*       ���� ��p�������
*       AFLMSB     15-20bit
*       AFLLSB      0-14bit
*       ACC    -  ��室�� �����
*************************
FLREAD
	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+

	LACC 	_DPA0
	AND  	#01Fh
	ADD  	FLADR+1,6
	SACL 	_DPA0
	OUT  	_DPA0,PA0
	OR   	#20h
	SACL 	_DPA0

	LACC    FLADR
	OR	#08000H
	SACL	*
	LAR  	AR7,*
	MAR	*,AR7

	LACC	*,0,AR1
	SACL	*

	LACC 	FLADR
	AND	#07FFFh
	ADD  	#1
	SACL 	FLADR
	AND  	#07FFFh
	BCND 	FLR_NoOver,NEQ
	SACL	FLADR
	LACC 	FLADR+1
	ADD  	#1
	SACL 	FLADR+1
FLR_NoOver

	LACC	*
	AND	#0FFH

	OUT  	_DPA0,PA0

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR7,*-
	PSHD	*

	RET
