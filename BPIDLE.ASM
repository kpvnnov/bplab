* $Id: BPIDLE.ASM,v 1.6 2001-08-22 14:17:39 peter Exp $
        CLRC INTM               ;RS,NMI,INT1,INT2,TINT,TXRXINT.

IDLEST  NOP
        IDLE
        NOP
        ;последний раз использовали AR2 - если где-то ошибка в прерывании
        ;то сразу будет выясняться это

	BIT  	FLAGKEYB,15
	BCND 	NOTPRESSED,NTC  ;TC=0? (флаг равен 0?)
	LDP  	#0

CLEARINT1
	SETC 	INTM
	NOP
	SST  	#0,066h
	BIT  	066h,6   ;проверка INTM
			 ;INTM=0 - all interrupt enabled
			 ;INTM=1 - all disabled
	BCND 	CLEARINT1,NTC  ;все еще разрешены? INTM=0?
; прерывания запрещены
; можно работать
	LDP  	#4
	LACC 	FLAGKEYB,0
	AND  	#0FFFEh
	SACL 	FLAGKEYB
	LACC 	_MDSPL,1 ;вызываем процедуру в зависимости от режима
	ADD  	#KEY1
	CALA
	CLRC 	INTM
NOTPRESSED
*****

	BIT  	Jobs,9
	BCND 	NootBeeping,NTC

	LDP  	#0

CLEARINT2
	SETC 	INTM
	NOP
	SST  	#0,066h
	BIT  	066h,6   ;проверка INTM
			 ;INTM=0 - all interrupt enabled
			 ;INTM=1 - all disabled
	BCND 	CLEARINT2,NTC  ;все еще разрешены? INTM=0?
; прерывания запрещены
; можно работать
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

	LACC 	DPA0,0     ;инвертируем значение бипера
	XOR  	#01h
	SACL 	DPA0
	OUT  	DPA0,PA0   ;вывод состояние ячейки в порт

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
