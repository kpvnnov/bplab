;&D
*****************************************************************************
*       режимы дисплея
* $Id: BPDISPL.ASM,v 1.21 2001-10-22 13:38:12 peter Exp $
*****************************************************************************
	.globl	_compute

MDSPLV  B 	MDSPL0    ;вывод времени на дисплей

	B 	MDSPL1    ;вывод времени на дисплей с секундами
	B 	MDSPL2    ;Текущее давление Канал 0->на дисплей
 .if WriteDebug=0
	B 	MDSPL6    ;начало измерения давления
 .elseif WriteDebug<3

* .if PrintPreset=1
	B 	MDSPL3    ;Текущее давление Канал 1->на дисплей
* .elseif PrintPreset=0
*	B 	MDSPL6    ;начало измерения давления
 .endif
* .else
*  .emsg _ERROR __ MISSING PARAMETER_
* .endif

	B 	MDSPL4    ;Текущее давление Канал 2->на дисплей

	B 	MDSPL5    ;вывод кода ошибки на экран

	B 	MDSPL6    ;начало измерения давления
	B 	MDSPL7    ;количество принятых и переданных байт
	B 	MDSPL8    ;верхний предел измерения давления

iSYSTOL_PRESSURE	.set	9
	B 	MDSPL9    ; индикация систолического давления

iPULSE			.set	10
	B 	MDSPL11		;индикация пульса

iDIASTOL_PRESSURE	.set	11
	B 	MDSPL10		;индикация диастолического давления

iCURRENT_PRESSURE	.set	12
	B	MDSPL12		;индикация текущего давления (при накачке)

	B	MDSPL13		;сколько времени осталось

MDSPL0:
	MAR  	*,AR7      	;modify auxiliary register
	LAR  	AR7,#ProtectInterval	;защитный интервал?
	LACC	*
	BCND	MayShow,EQ
	LAR	AR7,#_iSYMBL

	SPLK 	#14h,*+
	SPLK 	#15h,*+
	SPLK 	#16h,*+
	SPLK 	#03h,*+
        RET

MayShow:
	LAR  	AR2,#_WATCH+2

DisplayCopy
	LAR	AR7,#_iSYMBL+3
	MAR  	*,AR2      	;modify auxiliary register
				;данная команда из подмножества LARP 1
				;т.е. при дальнейшей записи индексом AR2

	LACC 	*+,AR7		; Часы -> на дисплей
	SACL	*-,AR2

	LACC 	*+,AR7
	SACL	*-,AR2

	LACC 	*+,AR7
	SACL	*-,AR2

	LACC 	*+,AR7
	SACL	*-,AR2
	RET

MDSPL1
 .if Sertificarion=1
	LAR  	AR2,#TestTime   ;выводим на экран тестовое время
 .else
	LAR  	AR2,#_WATCH
 .endif
	B	DisplayCopy     ; Часы с секундами -> на дисплей


MDSPL2
	CLRC 	SXM        ;Текущее давление Канал 0->на дисплей

	LACC 	_OUTF
	ADD  	#4000h,1
	SACL 	TMP,0

;вывод на экран с учетом коээфициента температуры?
 .if DisplayCorrect=1
* unsigned short compute(unsigned short shift,unsigned short value)

        MAR	*,AR1		;выбираем стек
        LACC	TMP		;давление в канале 0
	SACL	*+
        LACC    Preset0		;смещение в канале 0
	SACL	*+
	CALL	_compute
	SBRK	2
	SACL	TMP
 .endif

	LACC 	TMP,9
	SUB  	TMP,7
	SUB  	TMP,6
	SACH 	TMP,0
	CALL	ConvBIN2DEC
	SPLK	#10,*		;пробел в 3 разряд
	RET

ConvBIN2DEC
	MAR  	*,AR7      	;modify auxiliary register
	LAR	AR7,#_iSYMBL+3
	LACC 	TMP,0
	ADD  	#TABL10,0
	TBLR 	TMP
	LACC 	TMP,0
	AND  	#000Fh
	SACL	*-		;младший разряд (0 позииця справа)

	LACC 	TMP,12
	AND  	#000Fh,16
	SACH	*-		;1 разряд

	LACC 	TMP,8
	AND  	#000Fh,16
	SACH	*-		;2 разряд
	RET

 .if WriteDebug=0
 .elseif WriteDebug<3

MDSPL3
	SETC	SXM
	MAR	*,AR6
	LACC	StartCode+1
        BCND	SecondChannel,NEQ
	LAR	AR6,#_ResultADC+6;AIN6 (PR0) значение на выходе датчика
	LACC	*
	ADD  	#4000h,1
	AND	#0ffffh
	SUB  	Preset0
	B	ChannelSelected
SecondChannel:
 .if Sertificarion==0
	LAR	AR6,#_ResultADC+9;AIN9 (аварийный) значение на выходе датчика
 .else
  .if (WriteDebug!=0) 	;в отладочной версии показываем аварийный датчик
	LAR	AR6,#_ResultADC+9;AIN9 (аварийный) значение на выходе датчика
  .else 		;иначе показываем основное давление
        LAR	AR6,#_ResultADC+6;AIN6 (PR0) значение на выходе датчика
  .endif
 .endif
	LACC	*
	ADD  	#4000h,1
	AND	#0ffffh
	SUB  	Preset1
ChannelSelected
	BCND 	No_minus121,GEQ
	LACC 	#0h
No_minus121
	SACL    TMP
	CALL	OutputPressure

;	LACC	StartCode+1
;        ADD	#1
;	SACL 	*		;номер в 3 разряд
	SPLK	#10,*		;пробел в 3 разряд
	RET
 .endif

MDSPL4  CLRC 	SXM        ;Текущее давление Канал 2->на дисплей
	MAR	*,AR6
	LAR	AR6,#_ResultADC+9;AIN9 (PR3)

	LACC	*
	ADD	#4000,1
	SACL    TMP

	CALL	OutputPressure
	SPLK 	#2,*
	RET

OutputPressure
	CLRC 	SXM
	LACC 	TMP,9
	SUB  	TMP,7
	SUB  	TMP,6
	SACH 	TMP,0
*OutputPulse
	CALL	ConvBIN2DEC

	RET

MDSPL9  SETC	SXM
	LACC    SistolPressure
;	SUB  	Preset0
;	BCND 	No_minus9,GEQ
;	LACC 	#08000h
;No_minus9
	ADD  	#4000h,1
	SACL    TMP
	CALL	OutputPressure
	SPLK 	#11,*
	RET

MDSPL10 SETC	SXM
	SPM	#0
	LAR	AR3,#TMP+3
	LAR	AR4,#AveragePeriod
	MAR	*,AR3
	LACC	#6000
	SACL	*,AR4

*       ARP  = AR4
*       AR3  - Указывает на числитель
*       AR4  - Указывает на знаменаталь (AR4 - "Активан")
*	AR3/AR4

	CALL	Division

	SACH	TMP,4		;частота сердечных сокращений

	CALL	ConvBIN2DEC
	SPLK 	#12,*
	RET


MDSPL11  SETC	SXM
	LACC    DiastolPressure
;	SUB  	Preset0
;	BCND 	No_minus11,GEQ
;	LACC 	#08000h
;No_minus11
	ADD  	#4000h,1
	SACL    TMP
	CALL	OutputPressure
	SPLK 	#13,*
	RET


MDSPL12
	SETC	SXM
	MAR	*,AR6
	LAR	AR6,#_ResultADC+6;AIN6 (PR0) значение на выходе датчика

	LACC    *
	ADD  	#4000h,1
	AND	#0ffffh
	SUB  	Preset0
	BCND 	No_minus12,GEQ
	LACC 	#0h
No_minus12
	SACL    TMP
	CALL	OutputPressure
	SPLK 	#10,*
	RET


MDSPL5  		; вывод ошибки на экран
	MAR  	*,AR7      	;modify auxiliary register
	LAR	AR7,#_iSYMBL
        LACC	ZERROR
        AND	#0FFh
        XOR	#081H
        BCND	LowBattery,EQ
	LACC	ZERROR
	AND	#0FFh
	XOR	#050h
	BCND	SertificationMode,EQ

	SPLK 	#15,*+			; E

	SPLK 	#0,*+			; 0

	LACC	ZERROR,16-4
	AND	#0F0h,16-4
	SACH 	*+

	LACC	ZERROR
	AND	#0fh
	SACL 	*+

	RET
SertificationMode:
	SPLK 	#00Ah,*+		; ' '
	SPLK 	#00Eh,*+		; P
	SPLK 	#00Eh,*+		; P
	SPLK 	#00Eh,*			; P
	RET


LowBattery:
	SPLK 	#00Ah,*+		; ' '
	SPLK 	#013h,*+		; L
	SPLK 	#013h,*+		; L
	SPLK 	#013h,*			; L
	RET
MDSPL6
	SETC 	SXM
	LACC 	IZNUMREC,0
	ADD  	#001
*ItIsNotNull
	SACL	TMP
	CALL	ConvBIN2DEC

	SPLK 	#12,*
	RET


 .if ShowSpeedASP=1
; ну хотя бы выводить на экран скорость обмена ?
MDSPL7
	CLRC 	SXM
	MAR  	*,AR7      	;modify auxiliary register
	LAR	AR7,#_iSYMBL

	IN  	TMP,BRD		;считываем скорость обмена

	LACC	TMP
	SUB	#1
	BCND	MDSPL7_4,GT		;проверяем 115200
	SPLK	#1,*+
	SPLK	#1,*+
	SPLK	#5,*+
	SPLK	#2,*+
	RET
MDSPL7_4	;из BRD уже 1 отняли
	SUB	#1
	BCND	MDSPL7_1,GT		;проверяем 57600
	SPLK	#10,*+
	SPLK	#5,*+
	SPLK	#7,*+
	SPLK	#6,*+
	RET
MDSPL7_1	;из BRD уже 2 отняли
	SUB	#2
	BCND    MDSPL7_2,GT		;проверяем 38400
	SPLK	#10,*+
	SPLK	#3,*+
	SPLK	#8,*+
	SPLK	#4,*+
	RET

MDSPL7_2	;из BRD 4 уже отняли
	SUB	#4
	BCND    MDSPL7_3,GT		;проверяем 19200
	SPLK	#10,*+
	SPLK	#1,*+
	SPLK	#9,*+
	SPLK	#2,*+

	RET
MDSPL7_3
	;ниже 9600 скоростей пока нет, поэтому задаем BRD=12
	SPLK	#10,*+
	SPLK	#10,*+
	SPLK	#9,*+
	SPLK	#6,*+
	RET

 .elseif ShowSpeedASP=0
MDSPL7
	CLRC 	SXM
 .if DisableDisplay=1
	MAR  	*,AR7
	LAR	AR7,#_iSYMBL
	SPLK	#10,*+
	SPLK	#10,*+
	SPLK	#10,*+
	SPLK	#10,*
 .elseif DisableDisplay=0
	MAR  	*,AR6      	;modify auxiliary register
	LAR	AR6,#iCntReceve
	LAR	AR7,#_iSYMBL+3

	LACC 	*+,0,AR7
	ADD  	#TABL10,0
	TBLR 	TMP
	LACC 	TMP,0
	AND  	#000Fh
	SACL 	*-

	LACC 	TMP,12
	AND  	#000Fh,16
	SACH 	*-,AR6

	LACC 	*,0,AR7
	ADD  	#TABL10,0
	TBLR 	TMP
	LACC 	TMP,0
	AND  	#000Fh
	SACL 	*-

	LACC 	TMP,12
	AND  	#000Fh,16
	SACH 	*-
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif


	RET

 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

MDSPL8
	LACC 	StartCode,1		;что сейчас выводим на дисплей
	ADD  	#StartCodeFunc,0
	BACC
StartCodeFunc
	B	MDSPL8_0
	B	MDSPL8_1
	B	MDSPL8_2
	B	MDSPL8_3
MDSPL8_0			;вывод давления до которого накачиваем
	SETC	SXM
	LACC	CurrPressureLevel
	ADD  	#4000h,1
	AND	#0ffffh
	SACL    TMP
	CALL	OutputPressure
	SPLK 	#10,*
	RET


 .if Sertificarion=0

MDSPL8_1			; 111 - запись давления на входе
	MAR  	*,AR7      	;modify auxiliary register
	LAR	AR7,#_iSYMBL

	SPLK 	#10,*+
	SPLK 	#1,*+
	SPLK 	#1,*+
	LACC	StartCode+1
	ADD	#1
	SACL 	*+
	RET
 .else
MDSPL8_1			; 111 - запись давления на входе
	MAR  	*,AR7      	;modify auxiliary register
	LAR	AR7,#_iSYMBL

	LACC    StartCode+1
	SUB	#1
	BCND	Error_111,GT
	LACC    StartCode+1,1
	ADD  	#StartCode111,0
	BACC

StartCode111:
	B	CodeDebugRegim1
	B	CodeDebugRegim2
CodeDebugRegim1:
Error_111:
	SPLK 	#10,*+
	SPLK 	#2,*+
	SPLK 	#2,*+
	SPLK 	#2,*+
	RET
CodeDebugRegim2:
	SPLK 	#10,*+
	SPLK 	#3,*+
	SPLK 	#3,*+
	SPLK 	#3,*+
	RET
 .endif

MDSPL8_2			;OH
	MAR  	*,AR7      	;modify auxiliary register
	LAR	AR7,#_iSYMBL

	SPLK 	#10,*+
	SPLK 	#16,*+
	SPLK 	#17,*+
	SPLK 	#10,*+
	RET
MDSPL8_3			;OFF
	MAR  	*,AR7      	;modify auxiliary register
	LAR	AR7,#_iSYMBL

	SPLK 	#10,*+
	SPLK 	#16,*+
	SPLK 	#18,*+
	SPLK 	#18,*+
	RET

MDSPL13                         ; сколько осталось до изм -> на дисплей

	LAR	AR3,#CounterToBegin
	LAR	AR4,#TMP+3
	MAR	*,AR3
	LACC	*,0,AR4
	SPLK	#60,*,AR4

*       ARP  = AR4
*       AR3  - Указывает на числитель
*       AR4  - Указывает на знаменаталь (AR4 - "Активан")
*	AR3/AR4

	CALL	Division

	SACH	TMP

	CALL	ConvBIN2DEC
	SPLK 	#10,*
	RET



MODIFSB
	MAR  	*,AR7
	LAR	AR7,#_iSYMBL

	LACC 	#DSIM0     	;преобразование символов дисплея
	      			;в слова выдаваемые на экран
	ADD	*+

	TBLR 	TMP
	LACC 	#DSIM0
	ADD	*+

	TBLR 	TMP+1
	LACC 	#DSIM0
	ADD	*+

	TBLR 	TMP+2
	LACC 	#DSIM0
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
*                                                         GFEDCBA
DSIM0   .word   003Fh   ; 0 Описание символа 0           00111111    A
DSIM1   .word   0006h   ; 1 Описание символа 1           00000110  F   B
DSIM2   .word   005Bh   ; 2 Описание символа 2           01011011    G
DSIM3   .word   004Fh   ; 3 Описание символа 3           01001111  E   C
DSIM4   .word   0066h   ; 4 Описание символа 4           01100110    D
DSIM5   .word   006Dh   ; 5 Описание символа 5           01101101
DSIM6   .word   007Dh   ; 6 Описание символа 6           01111101
DSIM7   .word   0007h   ; 7 Описание символа 7           00000111
DSIM8   .word   007Fh   ; 8 Описание символа 8           01111111
DSIM9   .word   006Fh   ; 9 Описание символа 9           01101111
DSIM    .word   0000h   ; A Описание символа "Пустота"   00000000
DSIM23  .word   0001h   ; B Описание символа (верх.тире) 00000001
DSIM22  .word   0040h   ; C Описание символа (сред.тире) 01000000
DSIM21  .word   0008h   ; D Описание символа (нижн.тире) 00001000
DSIMP   .word   0073h   ; E Описание символа P           01110011
DSIME   .word   0079h   ; F Описание символа E           01111001
DSIMO   .word   003Fh   ;10 Описание символа O           00111111
DSIMN   .word   0076h   ;11 Описание символа E           01110110
DSIMF   .word   0071h   ;12 Описание символа F           01110001
DSIML   .word   0038h   ;13 Описание символа F           00111000
        .word   0037h   ;14 Описание символа П           00110111
        .word   0077h   ;15 Описание символа А           01110111
        .word   006Eh   ;16 Описание символа У           01101110
*                                                         GFEDCBA
*

*****************************************************************************
*       Вывод на дисплей
*****************************************************************************
DISPLAY
	SPLK 	#SSPS,TMP    ;SSP start
	OUT  	TMP,SSPCR    ;Synchronous Serial Port Control Register
	MAR	*,AR7
	LAR	AR7,#iDISPL

	OUT  	*+,SDTR
	OUT  	*,SDTR

	mImp_ssp
	mImp_ssp
	mImp_ssp
	CALL 	CLKXF
	CALL 	CLKXF

	SPLK 	#SSPR,TMP
	OUT  	TMP,SSPCR

	LACC 	_DPA0,0
	OR   	#02h
	SACL 	_DPA0
	OUT  	_DPA0,PA0
	AND  	#0FFFDh
	SACL 	_DPA0
	OUT  	_DPA0,PA0
	RET
