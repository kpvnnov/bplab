;&D
* $Id: BP206DEF.ASM,v 1.19 2001-10-22 13:38:11 peter Exp $
MAX_PRESS 	.set 08000h

PRESS_280 	.set 0E000h
PRESS_260 	.set 0D000h
PRESS_250 	.set 0C800h
PRESS_240 	.set 0C000h
PRESS_220 	.set 0B000h
PRESS_200 	.set 0A000h
PRESS_190 	.set 09800h
PRESS_180 	.set 09000h
PRESS_160 	.set 08000h
PRESS_145 	.set 07400h
PRESS_140 	.set 07000h
PRESS_130 	.set 06800h
PRESS_120 	.set 06000h
PRESS_100 	.set 05000h
PRESS_95  	.set 04C00h
PRESS_90  	.set 04800h
PRESS_80  	.set 04000h
PRESS_60  	.set 03000h
PRESS_50  	.set 02800h
PRESS_40  	.set 02000h
PRESS_30  	.set 01800h
PRESS_20  	.set 01000h
PRESS_10  	.set 00800h
PRESS_05  	.set 00400h
PRESS_02_5  	.set 00200h
PRESS_01_25 	.set 00100h
STEP_PRESS 	.set 0733h

LPRESS_310 	.set 07800h
LPRESS_300 	.set 07000h
LPRESS_280 	.set 06000h
PRESS_275_MILL_OF_MER	.set	05C00h
LPRESS_260 	.set 05000h
LPRESS_250 	.set 04800h
LPRESS_240 	.set 04000h
LPRESS_220 	.set 03000h
LPRESS_200 	.set 02000h
LPRESS_190 	.set 01800h
LPRESS_180 	.set 01000h
LPRESS_170 	.set 00800h
LPRESS_160 	.set 00000h
LPRESS_145 	.set 0F400h
LPRESS_140 	.set 0F000h
LPRESS_130 	.set 0E800h
LPRESS_120 	.set 0E000h
LPRESS_100 	.set 0D000h
LPRESS_80  	.set 0C000h
LPRESS_60  	.set 0B000h
LPRESS_50  	.set 0A800h
LPRESS_40  	.set 0A000h
LPRESS_30  	.set 09800h
LPRESS_20  	.set 09000h
LPRESS_10  	.set 08800h

; �������� �� ���஥ "���᪠������"

PRESS_PRESET 	.set PRESS_10

; �������� "��४�窨"

PRESS_OVER   	.set 0

* �६� ��宦����� �� ��㯥�쪥 40 ��. ��. ��.

TimeOn40mm 	.set 2000 ;20 ᥪ㭤

* �६� ��宦����� �� ��㯥�쪥 �� ����७�� �������

TimeOnStep 	.set 400 ; ���� ᥪ㭤�

*************************************************
* ��⮤ ��ન flash
*************************************************
;1 ��ࠥ� 楫����
;2 ��ࠥ� ��࠭�栬�

MetodFlashClear .set 2

FirstAdressInRam .set 08000h ; ����, ��� ࠧ��頥��� ��楤��

 .if TwoChanel=1
ModeOutput 	.set 3h
 .else
ModeOutput 	.set 1h
 .endif

 .if TwoChanel=1
;�뢮���� �� ��࠭ ᪮�४�஢����� ���祭��
; � ��⮬ ����樥� ⥬�������
DisplayCorrect	.set 1
 .else
DisplayCorrect	.set 0
 .endif

OutputSectoring	.set 1

************
* "�����᪮� �᫮" ��� ࠧ�襭�� �ணࠬ��஢���
************
MagicPass	.set 03162h

*************************************************
* ��� �뢮������ �ଠ� 2
*************************************************
* ���� �����:
* �뢮� ���� �ਥ��஢������ �ଠ� (���饭�� � 12 ��⭮�� ���)
* �ଠ� �뢮�� ��ࢮ�� ������ (1)
* ����ଠ� 0 (10)
*  - ��祣� �� �뢮���
* ����ଠ� 1 (11)
*  - �뢮��� ���� � ��ࢮ�� ������ � ���
* ����ଠ� 2 (12)
*  - �뢮��� ���� � ��ࢮ�� ������ ��᫥ 䨫���
*********************
* ��ன �����
*********************
* �뢮� ᫮�� (��᮫�⭮� 12 ��⮢�� (16) �᫮)
* �ଠ� �뢮�� ��ண� ������ (2)
* ����ଠ� 0 (20)
*  - ��祣� �� �뢮���
* ����ଠ� 1 (21)
*  - �뢮��� ᫮�� � ��ண� ������ � ���
* ����ଠ� 2 (22)
*  - �뢮��� ᫮�� � ��ண� ������ ��᫥ 䨫���
*********************
* �ᨫ���� ���� �����
*********************
* �뢮� ᫮�� (��᮫�⭮� 12 ��⮢�� (16) �᫮)
* �ଠ� �뢮�� �ᨫ������ ������ (3)
* ����ଠ� 0 (30)
*  - ��祣� �� �뢮���
* ����ଠ� 1 (31)
*  - �뢮��� ᫮�� � �ᨫ������ ������ � ���
* ����ଠ� 2 (32)
*  - �뢮��� ᫮�� � �ᨫ������ ������ ��᫥ 䨫���


