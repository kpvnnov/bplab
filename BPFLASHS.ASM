;&D
* $Id: BPFLASHS.ASM,v 1.12 2002-04-23 17:31:00 peter Exp $
* ��᫥����⥫쭠� 䫥�
*****************************************************************************
* ���⪠ 䫥�
*****************************************************************************
* TMP - १���� ��ન
FLCLR
	RET
****************
* ���⪠ ��࠭��� 䫥�
* TMP - ����� 64 ����⭮� ��࠭���
****************
FlashPageClear
	RET
****************
* �஢�ઠ ����� ��࠭��� 䫥�
* TMP - ����� 64 ����⭮� ��࠭���
****************
* ACC - १���� (0 OK)
FlashPageCheck
	RET
*************************
*       �ணࠬ��஢���� 䫥�
*       ���� ��p�������
*       [_FLADR]      0-14bit
*       [_FLADR+1]   15-20bit
*       TMP    -  �室�� �����
*       �᫨ �p� ��室� �� ����p��p���� ACC=0 �� Ok.
* �ᯮ����
*************************
FLPROG
	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+

	LACC	_FLADR
	SACL	*+
	LACC	_FLADR+1
	SACL	*+
	LACC	TMP
	SACL	*+

	CALL	WriteToFifo

;�஢��塞, ᫥����� ������ ������� �� 墮��?
	MAR	*,AR7
	LAR	AR7,#FifoHeadTail
	LACC	*+			;����㦠�� 㪠��⥫� ������
	ADD	#1
	AND	#LengthFifo-1
	SUB	*		;�⭨���� �� 墮��
	BCND	SleepSpokoino,NEQ
	CALL	Clear_Fifo	;ᯨ娢��� �ਭ㤨⥫쭮 ���� 䫥�
SleepSpokoino:

	CALL	MayBeWriteFlash	;�᫨ �� ����� ������� �� 䫥�
				;� ����襬 � ����

	MAR	*,AR1
	MAR	*-,AR1
	LACC	*-
	SACL	TMP
	LACC	*-
	SACL	_FLADR+1
	LACC	*-
	SACL	_FLADR

;㢥��稢��� ���� �� �������
	LACC 	_FLADR
	AND	#07FFFh
	ADD  	#1
	AND  	#07FFFh
	SACL 	_FLADR
	BCND 	FLPR_NoOver,NEQ
	SACL	_FLADR
	LACC 	_FLADR+1
	ADD  	#1
	SACL 	_FLADR+1
FLPR_NoOver

	LAR     AR7,*-
	PSHD	*
	LACC	#0
	RET

MayBeWriteFlash:
	MAR     *,AR1
	POPD	*+

MayBeWriteAgain:
	CALL    ReadFromFifoNotInc

	CALL	Find_in_cache
	BCND	FLPR_2,EQ
	BCND 	WaitForReady,BIO
	CALL	Write_cache_to_flash
	BCND 	WaitForReady,BIO
	CALL	Read_flash_to_cache
FLPR_2
	CALL	Write_to_cache
	CALL	IncAddrFifo
	CALL	FifoIsEmpty
	BCND	MayBeWriteAgain,NEQ
WaitForReady:
	MAR	*,AR1
	MAR	*-,AR1
	PSHD	*
	RET

*************************
*       �⥭�� 䫥�
*       ���� ��p�������
*       AFLMSB     15-20bit
*       AFLLSB      0-14bit
*       ACC    -  ��室�� �����
*************************
	.globl	_flash_read
_flash_read:
FLREAD:
	MAR     *,AR1
	POPD	*+
 .if WARNINGLDP=1
	LDP	#4
 .endif

	CALL	Clear_Fifo

	CALL	Find_in_cache
	BCND	FLR_found_in_cache,EQ
	CALL	Write_cache_to_flash
	CALL	Read_flash_to_cache
FLR_found_in_cache
	CALL	Read_from_cache
	SACL	*

	LACC 	_FLADR
	AND	#07FFFh
	ADD  	#1
	AND  	#07FFFh
	SACL 	_FLADR
	BCND 	FLR_NoOver,NEQ
	SACL	_FLADR
	LACC 	_FLADR+1
	ADD  	#1
	SACL 	_FLADR+1
FLR_NoOver

	LACC	*
	AND	#0FFH
	MAR	*,AR1
	MAR	*-,AR1
	PSHD	*
	RET
*************************
* �饬 ��࠭��� AFLMSB/AFLLSB � ���
* ��室:
* ACC=0 	- ��࠭��� � ��� ��諨, TMPCASHE ����� ��࠭���
* ACC!=0        - ��࠭��� � ��� �� ��諨
*************************
Find_in_cache
	MAR     *,AR1
	POPD	*+
	SAR     AR7,*+

	LAR	AR7,#PageCache
	LACC	_FLADR,7
	AND     #03FH,16
	SACH	*
	LACC	_FLADR+1,6
	OR	*,AR7
	XOR	*
	BCND	NotFoundPage,NEQ
	LACC	*
	SACL    TMPCASHE
	LACC	#0
NotFoundPage
	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR7,*-
	PSHD	*
	RET
*************************
* ��襬 � ��� TMP
*************************
Write_to_cache
	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+

	LACC	_FLADR,15
	SACH	*
	LACC	*
	AND	#0FFH
	ADD	#FlashData
	SACL	*
	LAR	AR7,*
	MAR	*,AR7

*	LACC	TMP
*	AND	#0FFh
*	SACL	TMP

	BIT	_FLADR,15
	BCND	Wr_Chetn,NTC	;��� ����
*	LACC	TMP,8
*	SACL	TMP
	LACC	*
	AND	#0FFh		;������ ��������� ��ࠥ�
	ADD	TMP,8
	B	Wr_to_cashe_1

Wr_Chetn
	LACC	*
	AND	#0FF00H		;������� ��������� ��ࠥ�
	SACL	*
	LACC	TMP
	AND	#0FFH

	OR	*		;����몮�뢠�� ���� �����
Wr_to_cashe_1
	SACL	*

	LAR	AR7,#PageWrite	;㢥��稢��� ���稪 ����ᥩ
	LACC	*
	ADD	#1
	BCND	Wr_to_cashe_2,EQ
	SACL	*
Wr_to_cashe_2

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR7,*-
	PSHD	*
	RET

*************************
* �⠥� �� ��� � ACC
*************************
Read_from_cache
	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+

	LACC	_FLADR,15
	SACH	*
	LACC	*
	AND	#0FFH
	ADD	#FlashData
	SACL	*
	LAR	AR7,*
	MAR	*,AR7

	BIT	_FLADR,15
	BCND	Rd_Chetn,NTC	;��� ����
	LACC	*,8,AR1
	SACH	*
*	B	Rd_to_cashe_1

Rd_Chetn
	LACC	*
*	SACL	TMP

Rd_to_cashe_1

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR7,*-
	PSHD	*
	RET
*************************
* �᢮������� ��࠭��� ��� �� ������ᠭ��� ������
* ������ �᢮�������� ᫥���騩:
*  ��� ������ ��࠭��� ���稪 �����,
*  ��室�� ��࠭��� � ���ᨬ���� ������⢮� �����
*  � �����뢠�� �� �� 䫥�, ���稪 ����ᥩ ��������,
*  ����� ����ᠭ��� ��࠭��� ��࠭���� � TMPCASHE
*  ACC � �⮬ ��砥 �� ࠢ�� ���
*  �᫨ �� ��࠭��� ����ᠭ�, TMPCASHE=0, ACC=0
Write_cache_to_flash
	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+

	MAR	*,AR7
	LAR     AR7,#PageWrite
	LACC	*
	BCND	Wr_cache_to_f_1,EQ
	SPLK	#0,*
	LAR     AR7,#PageCache
	LACC	*
	SACL	TMPCASHE
	LAR	AR7,#FlashData
	CALL	Write_page
Wr_cache_to_f_1
	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR7,*-
	PSHD	*
	RET
**************
* ����㦠�� ��࠭��� AFLMSB/AFLLSB � ���
Read_flash_to_cache
	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+

	LAR	AR7,#PageCache
	MAR	*,AR7

	LACC	_FLADR,7
	AND	#03FH,16
	SACH	*
	LACC	_FLADR+1,6
	OR	*
	SACL	*

	LAR	AR7,#FlashData
	CALL	Read_page

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR7,*-
	PSHD	*
	RET

* �᢮������� ��� �� ������ᠭ��� ������
* ��⥬ �� ᯨ娢���� �� 䫥�
Clear_cashe:
	MAR	*,AR1
	POPD	*+

	CALL	Clear_Fifo
	CALL	Write_cache_to_flash

	MAR	*,AR1
	MAR	*-,AR1
	PSHD	*
	RET

*ᯨ娢��� �� � �᭮���� ��� ��� 䫥�
Clear_Fifo:
	MAR	*,AR1
	POPD	*+
	LACC	_FLADR
	SACL	*+
	LACC	_FLADR+1
	SACL	*+
	LACC	TMP
	SACL	*+


	SPLK	#07FFFh,TMPFIFO
MayBeClearAgain:
	LACC	TMPFIFO
	SUB	#1
	SACL	TMPFIFO
	BCND	False_Clear,EQ
	CALL	FifoIsEmpty
	BCND	False_Clear,EQ
	CALL	MayBeWriteFlash
        B	MayBeClearAgain
False_Clear:
	MAR	*,AR1
	MAR	*-,AR1
	LACC	*-
	SACL	TMP
	LACC	*-
	SACL	_FLADR+1
	LACC	*-
	SACL	_FLADR
	PSHD	*
	RET


NumCache	.set	1			;���� ���� ��࠭�� ���
PageCache	.usect "flbuf",NumCache,1       ;���� ����㥬�� ��࠭��
PageWrite	.usect "flbuf",NumCache,1       ;������⢮ ����ᥩ � ��࠭���
FlashData   	.usect "flbuf",256*NumCache,1	;��� ��࠭��

LengthFifo	.set 256		;������ ���� ��⭮ �⥯��� ������
FifoData	.usect "flbuf",LengthFifo	;����� � ��।� ��誨
FifoAddr	.usect "flbuf",2*LengthFifo     ;���� ������
FifoHeadTail	.usect "flbuf",2		;���� "������" � "墮��"

* ������ ���� � ����
*       _FLADR+1   15-20bit
*       _FLADR      0-14bit
*       TMP  -  �室�� �����

WriteToFifo:
	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+

	MAR	*,AR7
	LAR	AR7,#FifoHeadTail
	LACC	*			;����㦠�� 㪠��⥫� ������
	ADD	#1
	AND	#LengthFifo-1
	SACL	*
	PUSH				;��࠭塞 㪠��⥫�
	ADD	#FifoData
	MAR	*,AR1
	SACL	*
	LAR     AR7,*,AR7
	LACC	TMP
	SACL	*
	POP
	SFL
	ADD	#FifoAddr
	MAR	*,AR1
	SACL	*
	LAR     AR7,*,AR7
	LACC	_FLADR
	SACL	*+
	LACC	_FLADR+1
	SACL	*+

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR7,*-
	PSHD	*
	RET

InitFifoAndCache:
	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+

	MAR	*,AR7
	LAR	AR7,#FifoHeadTail
	LACC	#0
	SACL	*+
	SACL	*+

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR7,*-
	PSHD	*
	RET

* �⥭�� ���� �� ��誨
* ���� �������� �
* ���६��� 墮�� �� ������
*       _FLADR+1   15-20bit
*       _FLADR      0-14bit
*       ACC    -  ��室�� �����
*
ReadFromFifoNotInc:
	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+

	MAR	*,AR7
	LAR	AR7,#FifoHeadTail+1
	LACC	*			;����㦠�� 㪠��⥫� ������
	ADD	#1
	AND	#LengthFifo-1
;�����뢠�� ���� ���� �� �㤥�
;	SACL	*

	PUSH				;��࠭塞 㪠��⥫�

	SFL
	ADD	#FifoAddr
	MAR	*,AR1
	SACL	*
	LAR     AR7,*,AR7
	LACC	*+
	SACL	_FLADR
	LACC	*+
	SACL	_FLADR+1

	POP

	ADD	#FifoData
	MAR	*,AR1
	SACL	*
	LAR     AR7,*,AR7
	LACC	*
        SACL	TMP

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR7,*-
	PSHD	*
	RET
* � ��� �����頥� ࠧ���� ������ � 墮��
FifoIsEmpty:
	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+

	MAR	*,AR7
	LAR	AR7,#FifoHeadTail
	LACC	*+			;����㦠�� 㪠��⥫� ������
	SUB	*

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR7,*-
	PSHD	*
	RET
*������ ���६��� 墮�� ��誨
IncAddrFifo:
	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+

	MAR	*,AR7
	LAR	AR7,#FifoHeadTail+1
	LACC	*			;����㦠�� 㪠��⥫� ������
	ADD	#1
	AND	#LengthFifo-1
	SACL	*
	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR7,*-
	PSHD	*
	RET



*******
* �⥭�� ��࠭���
*  ���� ��� �⥭��, �� ���� ����� ���� ��࠭���
*  ASFLMSB     15-20bit
*  AFLLSB      0-14bit
*	AR7 - �㤠 ����㦠��
* ��楤�� ���� ����� �� 䫥� � ����㦠�� ��ࠬ� � ᫮�� AR7
* � ���� ��砫�� ���� ������ ���� ���
******
Read_page
	LACC 	#07FFFh
Read_p_3:
	BCND 	Read_p_1,BIO
	B	Read_p_2
Read_p_1:
	SUB  	#1
	RPT  	#10
	NOP
	RETC	LEQ
        B	Read_p_3
Read_p_2:
	mRead_512b

*******
* ������ ��࠭���

* ���� ��࠭��� TMPCASHE
* ᠬ� ��࠭�� - AR7
***********  ���� ��� �����, �� ���� ����� ���� ��࠭���
*********  AFLMSB     15-20bit
***********  AFLLSB      0-14bit
*  PA11-0 - ���� ��࠭���
*  BA9-0  - ���� ���� ����� ��࠭���
*  X      - ������� ��
* 1.[87h],[X],        ������ �� ��ன ����
* 2.[X..X,BA9-8],[BA7-0],
* 3.[n],[n],
* n.[n],[n]
*
* 1.[86h],[r,r,PA11-6], 	��� 2 -> page with built erase
* 2.[PA5-0,X..X],[X],
******
Write_page
	LACC 	#07FFFh
Write_p_1
	SUB  	#1
	RPT  	#10
	NOP
	RETC	LEQ
	BCND 	Write_p_1,BIO

	MAR	*,AR1
	POPD	*+
	SAR     AR7,*+
	SAR     AR0,*+

	SPLK 	#SSPS,*    ;SSP start
	OUT  	*,SSPCR    ;Synchronous Serial Port Control Register

	IN   	*,SDTR     ;������� ��譥�� �⥭��
				;��� �⠡��쭮��(���������) ࠡ��� � SSP
	LACC	#8700h
	SACL	*
	OUT  	*,SDTR     	;1.��ࢮ� ᫮�� ��� ��।��
				;([code][X])

	mImp_ssp              	;������塞 SSP � ��砫� ��।�� MSB
	mImp_ssp
	mImp_ssp

	;������� �롮�� 䫥�
	LACC	TMPCASHE,10
	AND	#080H
        BCND	Second_Flash,NEQ
	mOnFlash0
        B	Flash_0_ON
Second_Flash:
	mOnFlash1
Flash_0_ON:
	mOutDIOSR

	SPLK	#0,*
	OUT  	*,SDTR,AR7     	;2.��஥ ᫮�� ��� ��।��
				;[X..X,BA9-8],[BA7-0]

	; * ᫮�� ��� ��।��
	OUT	*+,SDTR     	;3.���� ᫮�� ��� ��।��
				;([��ࢮ� ᫮��])

	CALL 	CLKXF           ;1-��।��� ��ࢮ� ᫮��
				;([code][X])
	; * ᫮�� ��� ��।��
	OUT	*+,SDTR,AR1    	;4.�⢥�⮥ ᫮�� ��� ��।��
				;([��஥ ᫮��])
	IN   	*,SDTR     	;(1)�⥭�� ��ࢮ�� १���� (����)
	CALL 	CLKXF           ;2-��।��� ��஥ ᫮��
				;[X..X,BA9-8],[BA7-0]
	IN   	*,SDTR     	;(2)�⥭�� ��ண� १���� (����)

	LAR	AR0,#255-2

Write_page_1
	CALL 	CLKXF           ;��।��� N ᫮�� (N=0..255)
	IN   	*,SDTR,AR7     	;�⥭�� (3+N) १���� (����)
	; * ᫮�� ��� ��।��
	OUT	*+,SDTR,AR0    	;3+N ᫮�� ��� ��।��
				;([3+N ᫮�� ������])
*	MAR	*,AR0
	BANZ    Write_page_1,*-,AR1

*	LACC    AFLMSB

;�� ��� �⥭��

	LACC	TMPCASHE,10
	SACH	*
	LACC	*
 .if Mem=20	;���� �����奬� �� 2 Mbyte
	AND	#003Fh		;��᪠ ��� 2 �����
 .elseif Mem=40	;���� �����奬� �� 4 Mbyte
	AND	#007Fh		;��᪠ ��� 4 �����
 .elseif Mem=44	;��� �����奬� �� 4 Mbyte
	AND	#007Fh		;��᪠ ��� 8 �����
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	OR	#8600h
	SACL 	*		;������ ��ண� ����


	OUT  	*,SDTR     	;1.��ࢮ� ᫮�� ��� ��।��
				;([code][page_msb])

	CALL 	CLKXF           ;�।��᫥���� ᫮��(N=254)
	IN   	*,SDTR     	;�⥭�� १����
				;(���� ᫮�� ������ N=254)

	LACC	TMPCASHE,10
*	LACC    AFLLSB,1
	AND     #0FC00h
	SACL 	*		;������ ���� ��� ����� ��࠭���
	OUT  	*,SDTR     	;2.��஥ ᫮�� ��� ��।��
				;([page_lsb][adress])
	CALL 	CLKXF           ;��᫥���� ᫮��(N=255)
	;�몫��7�� �롮�� 䫥�
	mOffPeriph
	mOutDIOSR

	IN   	*,SDTR     	;�⥭�� १����
				;(���� ᫮�� ������ N=255)

	NOP ;������ ����� ��㧠 ������ ���� ???!!!
	;������� �롮�� 䫥�

	mOnFlash0
	mOutDIOSR

	CALL 	CLKXF           ;������� �����
	IN   	*,SDTR     	;�⥭�� १����
				;(���� ᫮�� )

	CALL 	CLKXF           ;������� ����� ���� ��࠭���
	IN   	*,SDTR     	;�⥭�� १����
				;(���� ᫮�� )
	;�몫���� �롮�� 䫥�
	;������ ��諠
	mOffPeriph
	mOutDIOSR

	SPLK 	#SSPR,*    	;RESET SSP
	OUT  	*,SSPCR

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR0,*-
	LAR     AR7,*-
	PSHD	*
	RET


***********
* �⥭�� �� ����� _FLADR 2 kb ������ � AR2
***********
Read2K
	MAR	*,AR1
	POPD	*+
	SAR     AR0,*+

	LAR	AR0,#2047
Read2k_1
	CALL	FLREAD
	MAR	*,AR2
	SACL	*+,0,AR0
	BANZ    Read2k_1,*-,AR2

	MAR	*,AR1
	MAR	*-,AR1
	LAR     AR0,*-
	PSHD	*
	RET