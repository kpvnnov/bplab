****************************************************************************
*       Мало U батареи(INT1)
* $Id: BPINTU.ASM,v 1.5 2000-12-15 16:42:29 peter Exp $
****************************************************************************
*

INTU    mPush_stack		;сохранение вычислительных
				;регистров в стеке
	LDP  	#4
	LAR  	AR1,#IFR	;загружаем указатель на Interrupt Flag Register
	MAR  	*,AR1      	;modify auxiliary register
				;данная команда из подмножества LARP 1
				;т.е. при дальнейшей записи индексом AR1

	SPLK 	#01h,*     	;pending INT1
	LAR  	AR1,#IMR       	;load auxiliary reg #IMR -> AR1
				;interrupt mask register
	LACC 	*              	;load accumulator with shift
	AND  	#0FFFEh        	;очищаем маску INT1(запрещаем эти прерывания)
	SACL 	*              	;store mask interrupts
				;Interrupt mask register
				;0(15-6),TXRXINT,XINT,RINT,TINT,INT2(INT3),INT1
				;0      ,1      ,0    0    1   ,1         ,1
				;разрешаем прерывания от
				; - последовательного асинхронного
				; - таймера
				; - int2 (кнопочка)
				; - int1 alarm!
	LAR	AR1,#iCNTKEYB+1

	SPLK 	#CNSTPOWER,*

	BIT     Jobs,15			;процесс измерения идет?
	BCND    IzmNeIdet,NTC
	mEnd_error_meas	rPowerLow
	B	OutFromErrorPower
IzmNeIdet
	SPLK	#rPowerLow,DispErrMeas
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


	mPop_stack		;восстановление вычислительных регистров
				;из стека
	CLRC 	INTM   		;разрешение прерываний при выходе из
				;прерывания
        RET


****************************************************************************
* заготовка для запрещения прерываний
;CLEARINT
;        SETC   INTM
;        NOP
;        LST    #0,TMPKEYB
;        BIT    TMPKEYB,6    ;проверка INTM
;                         ;INTM=0 - all interrupt enabled
;                         ;INTM=1 - all disabled
;        BCND CLEARINT,NTC  ;все еще разрешены? INTM=0?
; прерывания запрещены
; можно работать
;        CLRC INTM
*конец заготовки
