;       .sect "asp"
* $Id: BPSERIAL.ASM,v 1.23 2001-05-22 12:42:50 peter Exp $
*****************************************************************************
*       Асинхронный порт
* Протоколы обмена между BP и PC
* В основу обмена положены следующие принципы:
* · Скорость обмена выбирается из ряда 9,6/19,2/38,4/57,2 Кбит/с.
*   Слово содержит 8-мь информационных бит, один стоп бит.
*   Проверка на четность не используется. Большая скорость (до 1-го Мбита/с)
*   используется только при считывании  "результатов ЭКГ" и реализуется
*   через специальный интерфейс.
* · Обмен начинается на любой (из ряда) скорости посылкой символа "А",
*   необходимого для определения скорости обмена прибором.
*   При отсутствии ответа (" a , Ok") в течении 0.1с, повторить
*   попытку (до 4-х раз). Далее понижения скорость обмена и повторить
*   попытку.
*   При отсутствии ответа выдать сообщение "Нет связи с монитором ".
*   При наличии ответа, проводится проверка помехоустойчивости - (проба
*   скорости) - посылается 256 байт символов "A,U". При отсутствии ошибок
*   в ответ посылается  "A,U".  При наличии ошибок скорость понижается,
*   для этого надо выдержать время не менее 0.5 секунды и начать процедуру
*   с начала на меньшей скорости.
* · Инициатором любого обмена всегда является PC. BP только выполняет
*   команды.
* · Все команды содержат 4-а байта. Структура команды описана ниже.
* · Все команды выполняются после второго получения команды с
*   промежуточным подтверждением, т.е. возвратом кода команды в PC.
* · Если в команде два первых слова не совпали или команды нет в списке,
*   то возвращается код ошибки.
* · При ошибке, PC пробует повторить запрос - до 4-х раз, потом понижает
*   скорость и при  повторении ошибок или отсутствия ответа,
*   в течение 0.1 секунды выдает сообщение "Нет  связи".
* · Информация и данные передаются блоками объёмом 2 Кбайт
*   (оговаривается в конкретных протоколах). В конце блока
*   передается "контрольная сумма"  4-е байта (первый байт младший).
*   Контрольная сумма считается по формуле:
*
* Crc(32bit) = CrcTab ((Crc XOR Byte) AND 000000FFh) XOR (Crc SHR8bit)

* Начальное значение Crc=FFFFFFFFh

* ASPCR - FREE,SOFT,URST,0,0,0,DIM,TIM,RIM,STB,CAD,SETBRK,CIO3,CIO2,CIO1,CIO0
*  IOSR - 0,ADC,BI,TEMP,THRE,FE,OE,DR,DIO3,DIO2,DIO1,DIO0,IO3,IO2,IO1,IO0

*****************************************************************************

AutoBaund
	LACC 	Jobs,0
	OR  	#04h
	SACL 	Jobs     	;порт заработал - взводим флаг
	LAR  	AR1,#iCNTASP

*	SPLK 	#CNSTASP,CNTASP	;и взводим счетчик
	SPLK 	#CNSTASP,*	;и взводим счетчик

********************************
* 	Был принят символ "А"
********************************
	LACC 	rDIOSR
	AND  	#0FFH
	OR   	#ASPResA
	SACL 	TMP
;        SPLK 	#ASPResA,TMP ;ADC надо сбросить(записать туда 1)
;040FFh
      ;0,ADC,BI,TEMP,THRE,FE,OE,DR,DIO3,DIO2,DIO1,DIO0,IO3,IO2,IO1,IO0
*      0  1   0   0    0   0  0  0   1    1    1    1   1   1   1   1
	OUT  	TMP,IOSR   	;I/O status register

********************************
;здесь надо приостановить все действия, связанные с измерениями
********************************
	mOff_Interval		;если было мониторирование, стопим

	IN   	TMP,ADTR   	;если что-то есть во входном буфере - читаем

	IN  	TMP,BRD
	;При CLK   Fuart
	;При 3,6864мГц. 9,6kdit/c  BRD=000Ch
	;При 3,6864мГц. 19,2kdit/c BRD=0006h
	;При 3,6864мГц. 38,4kdit/c BRD=0003h
	;При 3,6864мГц. 57,6kdit/c BRD=0002h
*                           1 1 1
*	0 1 2 3 4 5 6 7 8 9 0 1 2
*         * !			   	57600
*             ! *                       38400
*                 * ! * *		19200
*                         * * * !	 9600
	LACC	TMP
	SUB	#2
	BCND	Correction_1,GT		;проверяем 57600
*	BCND	End_Correction,EQ
*************
* обработка скорости 115200
	LACC	TMP
	BCND	Save_Correction,NEQ
	SPLK	#1,TMP

*	SPLK	#2,TMP
	B	Save_Correction
Correction_1	;из BRD уже 2 отняли
	SUB	#2
	BCND    Correction_2,GT		;проверяем 38400
	;здесь в BRD либо 3 либо 4, принудительно записываем 3
	SPLK	#3,TMP
	B	Save_Correction
Correction_2	;из BRD 4 уже отняли
	SUB	#4
	BCND    Correction_3,GT		;проверяем 19200
	;здесь в BRD 5-8, принудительно задаем 6
	SPLK	#6,TMP
	B	Save_Correction
Correction_3
	;ниже 9600 скоростей пока нет, поэтому задаем BRD=12
	SPLK	#12,TMP
Save_Correction
	OUT	TMP,BRD
*End_Correction
;AnswerInit
;а в ответ надо выслать 041h,00h
	LAR  	AR1,#DATART
	SAR  	AR1,PosTransmit ;начало буфера передачи

 .if DebugSerial=1		;включена оталка com порта
*отладка
	SPLK 	#58h,*+         ;заполняем буфер данными
	SPLK 	#00h,*		;ответ на прием символа "A" или "a"
*** конец отладки

 .elseif DebugSerial=0          ;выключена
	SPLK 	#41h,*+         ;заполняем буфер данными
	SPLK 	#00h,*		;ответ на прием символа "A" или "a"
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

	SPLK 	#2,CNTASPTR     ;в буфере два символа

 .if DisableDisplay=1
 .elseif DisableDisplay=0
	LAR  	AR1,#iCntReceve
				;пока будем определять скорость обмена
	SPLK 	#01h,*+		;количество принятых символов - один
	SPLK 	#00h,*		;количсетво переданных символов - нуль
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

	SPLK 	#7h,MDSPL       ;вывод на экран количества принятых
				;и переданных символов
	SPLK 	#00h,Flags      ;мы пока еще ничего не сделали !!!

 .if ShowSpeedASP=1
; ну хотя бы выводить на экран скорость обмена ?

	LACC 	MDSPL,1
	ADD  	#MDSPLV,0
	CALA
	CALL 	MODIFSB
	CALL 	DISPLAY    	;вывод ячеек памяти индикатора на дисплей
				;восстановление счетчика

 .elseif ShowSpeedASP=0
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif



***********
EnableAndBeginTr
*отладка
*	SPLK	#2,DelayTransmit
*	B	RETASPINT
***конец отладки

	SPLK 	#00h,WhatDoingReceve
	SPLK 	#ASPST,TMP
;0E10F
;FREE,SOFT,URST,0,0,0,DIM,TIM,RIM,STB,CAD,SETBRK,CIO3,CIO2,CIO1,CIO0
;   1,   1,   1,0,0,0,  0,  1,  0,  0,  0,     0,   1,   1,   1,   1
;пишем в CAD "0",разрешаем прерывания передачи
	OUT  	TMP,ASPCR 	;Параметры ASP. Enable transmit


RETASPINT
	mPop_stack		;восстановление вычислительных регистров
				;из стека
	CLRC INTM   ;разрешение прерываний при выходе из
		    ;прерывания
	RET

*****************************************************************************
* обработка прерывания передачи
*****************************************************************************
; смотрим в буфер передачи и потихоньку выталкиваем оттуда данные
ASPTRANSMIT

 .if DisableDisplay=1
 .elseif DisableDisplay=0
	LAR	AR1,#iCntReceve+1

	LACC 	*,0
	ADD  	#1
	SACL 	*		;следующий байт приняли

	LACC 	*,0
	SUB  	#100
	BCND 	CountTrNotOver,LT	; еще не перешел через 100
	SACL 	*
CountTrNotOver
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif


	LAR  	AR1,PosTransmit ;загружаем указатель на начало буфера
	OUT  	*+,ADTR
	SAR  	AR1,PosTransmit ;запоминаем начало буфера передачи
********************************
*pending flag interrupts
********************************
	LAR  	AR1,#IFR   	;загружаем указатель на
				;Interrupt Flag Register
	SPLK 	#20h,*     	;pending TXRXINT
* Transmit/receive interrupt flag. Bit 5 is tied to the transmit/receive
* interrupt for the asynchronous serial port. To avoid double interrupts,
* write a 1 to this bit in the interrupt service routine.
********************************
	LACC 	CNTASPTR,0      ;считаем передаваемые символы
	SUB  	#1
	SACL 	CNTASPTR,0
	BCND 	RETASPINT,GT    ;пока больше нуля, значит не все передали

 .if DebugSerial=1		;включена отладка com порта
*отладка
*** отладжка
	LAR  	AR1,#DATART
	SAR  	AR1,PosTransmit ;начало буфера передачи
	SPLK 	#1,CNTASPTR     ;в буфере один символ
	B	RETASPINT
** конец отладки

 .elseif DebugSerial=0          ;выключена
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif


***********
* теперь все передали, надо очистить входной буфер
* сбросить все флаги (переполнения,frame error и т.д.)
	IN   	TMP,ADTR     ;если что-то есть во входном буфере - читаем
	BIT  	Flags,14
	BCND 	FromTrtoReceve,NTC ;флаг не стоит, надо перейти на прием

***********
	SPLK 	#ASPSRA,TMP	;Enable receiver A и прием символов вообще
	OUT  	TMP,ASPCR  	;ASPSRA -> ASPCR(IS@0FFF5h)
				;asynchronous serial-port
				;control register(ASPCR)
	LACC 	rDIOSR
	AND  	#0FFH
	OR   	#CIOSR
	SACL 	TMP
;        SPLK 	#CIOSR,TMP
;CIOSR  06600h
      ;0,ADC,BI,TEMP,THRE,FE,OE,DR,DIO3,DIO2,DIO1,DIO0,IO3,IO2,IO1,IO0
*      0  1   1   0    0   1  1  0   1    1    1    1   1   1   1   1
	OUT  	TMP,IOSR	; I/O status register
				;IOSR is used for detecting current
				;levels and (changes when inputs) on
				;pins IO0-IO3 and status of UART
 .if Reset_BRD=1
	SPLK 	#CBRDR,TMP  	;baud rate generator
	OUT  	TMP,BRD    	;При CLK   Fuart
				;При 3,6864мГц. 9,6kdit/c  BRD=000Ch
				;При 3,6864мГц. 19,2kdit/c BRD=0006h
				;При 3,6864мГц. 38,4kdit/c BRD=0003h
				;При 3,6864мГц. 57,6kdit/c BRD=0002h
 .endif
	SPLK 	#0h,MDSPL  	;выводим на экран время
	LACC 	Jobs,0
	AND  	#0FFFBh
	SACL 	Jobs     	;порт на "автопилоте" ;)
	B 	QuitFromASPInt
***********

FromTrtoReceve
**********
	LACC 	rDIOSR
	AND  	#0FFH
	OR   	#ASPResF
	SACL 	TMP
;        SPLK 	#ASPResF,TMP 	;сбрасываем все ненужные флаги
;02600h
      ;0,ADC,BI,TEMP,THRE,FE,OE,DR,DIO3,DIO2,DIO1,DIO0,IO3,IO2,IO1,IO0
*      0  0   1   0    0   1  1  0   1    1    1    1   1   1   1   1
	OUT  	TMP,IOSR   ; I/O status register
**********
	SPLK 	#ASPSR,TMP	;переходим на прием
;0E08Fh
;FREE,SOFT,URST,0,0,0,DIM,TIM,RIM,STB,CAD,SETBRK,CIO3,CIO2,CIO1,CIO0
;   1,   1,   1,0,0,0,  0,  0,  1,  0,  0,     0,   1,   1,   1,   1
;разрешаем прерывания приема
	OUT  	TMP,ASPCR	;Параметры ASP. Enable receve
**********
;буфер одинаково (сначала) использутся и для приема и для передачи
;!!        LAR  AR1,#DATART
;!!        SAR  AR1,PosTransmit ;начало буфера передачи
QuitFromASPInt
*****************************
*pending flag interrupts
****************************
	LAR  	AR1,#IFR	;загружаем указатель на Interrupt Flag Register
	SPLK 	#20h,*     	;pending TXRXINT
*Transmit/receive interrupt flag. Bit 5 is tied to the transmit/receive
*interrupt for the asynchronous serial port. To avoid double interrupts,
*write a 1 to this bit in the interrupt service routine.

	B 	RETASPINT 	;возрат из прерывания
ASPAutoBaundFalse

**отладка

*	B	AutoBaund
****конец отладки
;бит автоподстройки стоит, а по логике работы прерывание передачи
;возникнуть не могло, поэтому это произошло прерывание приема
;автоподстройка не сработала и пришел фальш байт
	LACC 	rDIOSR
	AND  	#0FFH
	OR   	#ASPResF
	SACL 	TMP
;        SPLK #ASPResF,TMP     ;сбрасываем все ненужные флаги
;02600h
      ;0,ADC,BI,TEMP,THRE,FE,OE,DR,DIO3,DIO2,DIO1,DIO0,IO3,IO2,IO1,IO0
*      0  0   1   0    0   1  1  0   1    1    1    1   1   1   1   1
	OUT  	TMP,IOSR	; I/O status register
	IN   	TMP,ADTR   	;если что-то есть во входном буфере - читаем
	IN   	TMP,ADTR   	;если что-то есть во входном буфере - читаем

 .if Reset_BRD=1
	SPLK 	#CBRDR,TMP  	;baud rate generator
	OUT  	TMP,BRD    	;При CLK   Fuart
				;При 3,6864мГц. 9,6kdit/c  BRD=000Ch
				;При 3,6864мГц. 19,2kdit/c BRD=0006h
				;При 3,6864мГц. 38,4kdit/c BRD=0003h
				;При 3,6864мГц. 57,6kdit/c BRD=0002h
 .endif

;pending flag interrupts
	LAR  	AR1,#IFR   	;загружаем указатель на
				;Interrupt Flag Register
	SPLK #20h,*     	;pending TXRXINT
;Transmit/receive interrupt flag. Bit 5 is tied to the transmit/receive
;interrupt for the asynchronous serial port. To avoid double interrupts,
;write a 1 to this bit in the interrupt service routine.

	B 	RETASPINT 	;возрат из прерывания

*****************************************************************************
* обработка прерывания приема
*****************************************************************************
; складываем приходящие символы в буфер приема, декодируем команды
INTASP
***** сохранение регистров при вызове прерывания
	mPush_stack		;сохранение вычислительных
				;регистров в стеке
	LDP  	#4
**********
	MAR  	*,AR1

* проба
*	LAR  	AR1,#IFR   	;загружаем указатель на Interrupt Flag Register
*	SPLK 	#20h,*     	;pending TXRXINT
* конец пробы


	IN   	TMP,IOSR
	BIT  	TMP,1
; Bit 14 ADC  A detect complete bit. If the CAD bit of the ASPCR is 1
;             and the character A or a is received in the ADTR, ADC is
;             set to 1. The character A or a remains in the ADTR after
;             it has been detected. To avoid an overrun er-ror when the
;             next character arrives, the ADTR should be read immediately
;             after ADC is set.

	;A or a has been detected. If the CAD bit of the ASPCR is also
	;1, a receive interrupt (TXRXINT) will be generated, regardless
	;of the values of the DIM, TIM, and RIM bits of the ASPCR. For
	;as long as ADC = 1 and CAD = 1, a receive interrupt will occur.
	BCND 	AutoBaund,TC	;Если символа "А" не обнаpужено то
				;смотрим прием
	IN   	TMP,ASPCR
	BIT  	TMP,10	;а стоит ли бит автоподстройки?
	BCND 	ASPAutoBaundFalse,TC	;бит автоподстройки стоит
	LAR	AR1,#iCNTASP
*	SPLK 	#CNSTASP,CNTASP	;взводим счетчик заново,
				;так как прерывание произошло
	SPLK 	#CNSTASP,*	;взводим счетчик заново,
				;так как прерывание произошло
	BIT  	TMP,7	;разрешены прерывания передачи ?
	BCND 	ASPTRANSMIT,TC 	;Слово передано

ASPRECEVE
	IN   	TMP,IOSR
	BIT  	TMP,2
	BCND 	OUTFFErr,TC	;Пауза? (Break?)
;        BCND PAUSE,TC          ;Пауза? (Break?)
	BIT  	TMP,5
	BCND 	OUTFF,TC        ;Ошибка кадра?
	BIT  	TMP,6
	BCND 	OverFlow,TC        ;Переполнение?
;а так значит все приняли :)
	SPLK 	#7h,MDSPL       ;вывод на экран количества принятых
				;и переданных символов
 .if DisableDisplay=1
 .elseif DisableDisplay=0
	LAR	AR1,#iCntReceve

	LACC 	*,0
	ADD  	#1
	SACL 	*	      	;следующий байт приняли

	SUB  	#100
	BCND 	CountRecNotOver,LT	; еще не перешел через 100
	SACL 	*
CountRecNotOver
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif


	IN   	ByteReceve,ADTR ;если что-то есть во входном буфере - читаем

********************************
*	pending flag interrupts
********************************
	LAR  AR1,#IFR   ;загружаем указатель на Interrupt Flag Register
	SPLK #20h,*     ;pending TXRXINT
* Transmit/receive interrupt flag. Bit 5 is tied to the transmit/receive
* interrupt for the asynchronous serial port. To avoid double interrupts,
* write a 1 to this bit in the interrupt service routine.

	LACC 	WhatDoingReceve,1	;вызываем процедуру
					;в зависимости от режима
	ADD  	#ReceveWork
	BACC

*
PAUSE   B    INIT ;???
*
* выслать "взад" эфефины (0xFFFF)
OUTFFErr
	LACC 	rDIOSR
	AND  	#0FFH
	OR   	#ASPResF
	SACL 	TMP
;        SPLK 	#ASPResF,TMP     ;сбрасываем все ненужные флаги
;026FFh
      ;0,ADC,BI,TEMP,THRE,FE,OE,DR,DIO3,DIO2,DIO1,DIO0,IO3,IO2,IO1,IO0
*      0  0   1   0    0   1  1  0   1    1    1    1   1   1   1   1
	OUT  	TMP,IOSR	; I/O status register
	IN   	TMP,ADTR   	;если что-то есть во входном буфере - читаем
	IN   	TMP,ADTR   	;если что-то есть во входном буфере - читаем
********************************
* 	pending flag interrupts
********************************
	LAR  	AR1,#IFR   	;загружаем указатель на Interrupt Flag Register
	SPLK 	#20h,*     	;pending TXRXINT
;Transmit/receive interrupt flag. Bit 5 is tied to the transmit/receive
;interrupt for the asynchronous serial port. To avoid double interrupts,
;write a 1 to this bit in the interrupt service routine.
OUTFF
;а в ответ надо выслать 0FFh,0FFh,0FFh,0FFh
	LAR  	AR1,#DATART
	SAR  	AR1,PosTransmit	;начало буфера передачи
	SPLK 	#0FFh,*		;заполняем буфер данными
	RPT 	#2
	DMOV 	*+
	SPLK 	#4,CNTASPTR     ;в буфере четыре символа
	LACC 	Flags,0
	AND  	#0FFFEH         ;сбрасываем бит приема команды
	SACL 	Flags
	B 	EnableAndBeginTr
	;переходим на разрешение прерываний
	;передачи
OverFlow
	B	OUTFF
ReceveWork
;!!! строго следить за нумерацией
*********************************
Rec1 	.set 0  		;0 этот байт - команда (первый байт)
	B 	CommandReceve
*********************************
Rec2 	.set 1  		;1 этот байт - команда (второй байт)
	B 	CommandRecSec
*********************************
Rec3 	.set 2  		;2 этот байт - команда/данные (третий байт)
	B 	CommandRecThird
*********************************
Rec4 	.set 3  		;3 этот байт - команда/данные (четвертый байт)
	B 	CommandRecFour
*********************************
Receve41h  	.set 4		;4 принимаем 41h из последовательности
				;256 байт в процедуре определения
				;скорости обмена
	B 	CommandRec5_41
*********************************
Receve55h  	.set 5		;5 принимаем 55h из последовательности
				;256 байт в процедуре определения
				;скорости обмена
	B 	CommandRec5_55
********************************
ReceveData52 	.set 6		;6 принимаем 52 байта данных,
				;для программирования прибора
      B 	CommandRecData52
********************************
ReceveData2k 	.set 7		;7 принимаем 2k байта данных,
				;для программирования данных во флеш
      B 	CommandRecData2k
********************************
RecUserCode1	.set 8
      B		ReceveUserCode1
********************************
RecUserCode2	.set 9
      B		ReceveUserCode2
********************************
RecUserCode3	.set 10
      B		ReceveUserCode3
********************************
RecUserCode4	.set 11
      B		ReceveUserCode4
********************************
RecUserCode5	.set 12
      B		ReceveUserCode5
********************************
RecUserCode6	.set 13
      B		ReceveUserCode6
********************************
RecUserCode7	.set 14
      B		ReceveUserCode7
********************************
RecUserCode8	.set 15
      B		ReceveUserCode8
********************************
RecUserCode9	.set 16
      B		ReceveUserCode9

CommandReceve
	LAR  	AR1,#DATART   	;загружаем указатель на буфер приема-передачи
	LACC 	ByteReceve,0  	;в акумулятор загружаем принятый байт
	SACL 	*,0           	;запоминаем его в буфере приема-передачи
	LACC 	ByteReceve,4  	;надо вычислить две цифры одинаковы?
	XOR  	*
	AND  	#00F0h        	;если после XOR не ноль
	BCND 	OUTFF,NEQ     	;то "взад" высылаем "известно-что"
	SPLK 	#Rec2,WhatDoingReceve   ;следующий принимаем второй байт
	B 	RETASPINT 	;возрат из прерывания

CommandRecSec
	LAR  	AR1,#DATART
	LACC 	*
	XOR  	ByteReceve
	BCND 	OUTFF,NEQ
	LACC 	*+,4
	XOR  	ByteReceve
	AND  	#00F0h
	BCND 	OUTFF,NEQ
	LACC 	ByteReceve,0	;в акумулятор загружаем принятый байт
	SACL 	*,0           	;запоминаем его в буфере приема-передачи
	SPLK 	#Rec3,WhatDoingReceve	;следующий принимаем второй байт
	B 	RETASPINT 	;возрат из прерывания

CommandRecThird
	LAR  	AR1,#DATART+2   ;загружаем указатель на буфер приема-передачи
	LACC 	ByteReceve,0  	;в акумулятор загружаем принятый байт
	SACL 	*,0           	;запоминаем его в буфере приема-передачи
	SPLK 	#Rec4,WhatDoingReceve   ;следующий принимаем четвертый байт
	B 	RETASPINT 	;возрат из прерывания

CommandRecFour
	LAR  	AR1,#DATART+3   ;загружаем указатель на буфер приема-передачи
	LACC 	ByteReceve,0  	;в акумулятор загружаем принятый байт
	SACL 	*,0           	;запоминаем его в буфере приема-передачи
	LAR  	AR1,#DATART+1 	;загружаем указатель на буфер приема-передачи
	LACC 	*,1  		;в акумулятор загружаем принятый байт комманды
	AND  	#01EH
	ADD  	#CodeRec
	BACC

CodeRec
	B    	COD0       	; Ok ( Завеpшение обмена )
	B    	COD1       	; Запpогpаммиpовать BP2000
	B    	COD2       	; Считать сигнатуру
	B    	COD3       	; Считать данные из Flash давления
	B    	COD4       	; Очистить Flash давления
	B    	COD5       	; Пpоба (тест) скоpости
	B    	COD6       	; Заpезеpвиpовано
	B    	COD7       	; Пpоконтpолиpовать Flash давления
	B    	COD8       	; Считать pезультаты ЭКГ
	B    	COD9       	; Очистить Flash ЭКГ
	B    	CODA       	; Пpоконтpолиpовать Flash ЭКГ
	B    	CODB       	; Записать блок данных в прибор
	B    	CODC       	; служебная команда
	B    	CODD       	; Считать Данные из AVR
	B    	CODE       	; Заpезеpвиpовано
	B    	CODF       	; Ошибка
COD0
	LACC 	Flags,0
	OR  	#02h    	;после высылки подтверждения переход в режим
				;ожидания символа A
	B 	SendBackAndFlag

COD1
********************************
* программирование BP
**********************************************************************
* Направление     Структура посылки        Примечание
*   обмена
**********************************************************************
* PC > BP         11h,11h,11h,11h
**********************************************************************
* PC < BP         11h,11h,11h,11h /        Прим. 1
*                 или FFh,FFh,FFh,FFh
**********************************************************************
* PC > BP         11h,11h,11h,11h,         Где xxh - массив парам-ов,
*                 xxh,_xxh,Crh(мл)_,        прим. 3
*                 Crh(ст.)
**********************************************************************
* PC < BP         11h,11h,00h,00h /        Прим. 2
*                 11h,11h,FFh,FFh /
*                 FFh,FFh,FFh,FF
**********************************************************************
* Примечание:
* 1. Если ответа BP нет, в течение 0.1 секунды, то процесс
*    прекратить и выдать сообщение "НЕТ СВЯЗИ С МОНИТОРОМ".
*    Если в ответе BP ошибка или (FFh,FFh), то процесс повторяется
*    снова, до 4-х раз. Если ошибки повторяются,
*    то - "НЕТ СВЯЗИ С МОНИТОРОМ".
* 2. Если программирование завершено успешно, то 11h,11h,00h,00h,
*    если нет, то 11h,11h,FFh,FFh.
* 3. Параметры (256 байт + 4 байта "контрольная сумма") передаются
*    в следующем порядке:
*
IDSh		.set	0
* 1  Идентификационный номер пациента
*    8 байт мл. байт, ... ст. байт(коды ASCII)
FIOSh		.set	IDSh+8
* 2  Фамилия И.О.
*    16 байт мл. байт,... ст. байт(коды ASCII)
Age		.set	FIOSh+16
*   Возраст пока один байт, плюс три в резерве
DataInitSh	.set	Age+4
* 3  Дата инициализации
*    4 байт.(коды ASCII)
TimeInitSh	.set	DataInitSh+4
* 4  Время инициализации
*    4 байта - Минуты - единицы, десятки
*              Часы   - единицы, десятки,
*              В двоичном коде
DayLightTimeSh	.set	TimeInitSh+4
* 5  Дневное время
*    4 байта (часы с  до  ) -
*     Начало - единицы, десятки
*     Конец  - единицы, десятки
*     В двоичном коде
SpecTimeSh	.set	DayLightTimeSh+4
* 6  Специальный интервал
*    4 байта (часы с  до  ) -
*     Начало - единицы, десятки
*     Конец  - единицы, десятки
*     В двоичном коде
IntervalDayLightSh	.set	SpecTimeSh+4
* 7  Интервал между измерениями (день)
*    2 байта  Единицы, десятки (минут) max 99 мин.
*    В двоичном коде.
IntervalDayNightSh	.set	IntervalDayLightSh+2
* 8  Интервал между измерениями (ночь)
*    2 байта. Единицы, десятки (минут) max 99 мин.
*    В двоичном коде
IntervalSpecSh	.set	IntervalDayNightSh+2
* 9  Интервал между измерениями (спец. интервал)
*    2 байта. Единицы, десятки (минут) max 99 мин.
*    В двоичном коде
ParametrsSh	.set	IntervalSpecSh+2
* 10 Признаки
*    1 байт (1- Y, 0-N)
*     0-й бит - признак звукового сигнала
*     1-й бит  - признак индикации результатов
*    В двоичном коде
PorogIzmerenia	.set ParametrsSh+1
* порог измерения результатов измерения
MaxPressure	.set PorogIzmerenia+1
* Максимальное давление в манжете
ChildMode	.set MaxPressure+1
* Детский/взрослый 5Ah - детский AAh - взрослый [2001-01-29]
ConfirmChildMode	.set ChildMode+1
* Подтверждение режима Детский/взрослый	1 байт
*FFh - не подтвержден
*5Ah - детский
*A5h - взрослый [2001-01-29]	Поле устанавливается прибором
* 11 Резерв - дополнение до 256 байтов

	;надо проверить все ли четыре байта совпадают между собой
	LACC 	*+,0  		;в акумулятор загружаем принятый
				;байт комманды (DATART+1)
	XOR  	*     		;сравниваем с DATART+2
	BCND 	OUTFF,NEQ	;если не совпадает, то назад 0FFh
	LACC 	*+,0  		;в акумулятор загружаем принятый байт
				;комманды (DATART+2)
	XOR  	*     		;сравниваем с DATART+3
	BCND 	OUTFF,NEQ 	;если не совпадает, то назад 0FFh
	BIT  	Flags,15       	;уже принимали до этого четыре кода NNh ?
	BCND 	CommAndData,TC 	;да, уже принимали, поэтому идет плюс данные
	SPLK 	#11h,Flags+1
	LACC 	Flags,0
	OR  	#0001h
	B 	SendBackAndFlag
CommAndData
	LACC 	Flags+1
	XOR  	#11h      	;а те четыре кода, принятых перед этим
				;совпадают с текущей коммандой?
	BCND 	OUTFF,NEQ 	;если не совпадает, то назад 0FFh
	LACC 	Flags,0
	AND  	#0FFFEh
	SACL 	Flags      	;мы сделали это!!!
				;(след раз программирование
				; прибора заново)
	;следующий принимаем 256+4 байта данных
	SPLK 	#ReceveData52,WhatDoingReceve
	LAR  	AR1,#DATART+4
	SAR  	AR1,PosTransmit ;чтобы сразу запоминать данные приема
	B 	RETASPINT 	;возрат из прерывания
CommandRecData52
	;принимаем 256+4 байта данных
	LAR  	AR1,PosTransmit
	LACC 	ByteReceve,0  	;в акумулятор загружаем принятый байт
	SACL 	*+              ;сдвигаем буфер на единичку
	SAR  	AR1,PosTransmit ;чтобы сразу запоминать данные приема

	LACC 	PosTransmit
	SUB  	#DATART
	SUB  	#264      	;256+4+4 байта данных и четыре - код комманды + CRC
	BCND 	OutBuffer52,GEQ ;остаток от вычитания больше или равен 0
	;принимаем пока следующий байт (еще не все приняли)
	B 	RETASPINT 	;возрат из прерывания

OutBuffer52
****отладка заполнение в params
*//        CLRC SXM
*//        LAR  AR1,#DATART+4
*//        SPLK #03fh,TMP
*//        RPT  TMP
*//        BLDD *+,#Params
****
	SPLK 	#0FFFFh,CRC 	;надо посчитать контрольную сумму
	DMOV 	CRC
	LAR  	AR1,#DATART+4
	LAR  	AR0,#255     ;256 байт данных
	CLRC 	SXM
	CALL 	CRCCALC
	LAR  	AR1,#DATART+260 ;по этому смещению находится CRC
	LACC 	*+
	ADD  	*+,8
	XOR  	CRC
	BCND 	OUTFF,NEQ
	LACC 	*+
	ADD  	*+,8
	XOR  	CRC+1
	BCND 	OUTFF,NEQ

********************************
*   Пpогpаммиpование пpибоpа
*
	LAR  	AR0,#255        ;256 байт данных
	LAR  	AR6,#DATART+4

	SPLK 	#0,FLADR+1	;по адресу 000200h
	SPLK 	#200h,FLADR     ;параметры программирования прибора

	MAR  	*,AR6
NEXTWD  BLDD 	*+,#TMP
	CALL 	FLPROG
	BCND 	NOPROG,NEQ     	;если ACC!=0, то произошла ошибка записи
	MAR  	*,AR0
	BANZ 	NEXTWD,*-,AR6
*
 .if VersionFerrum=1		;без дешифратора

 .elseif VersionFerrum=2        ;с дешифратором
*******
* сбрасываем кэш во флеш
*******
	CALL	Clear_cashe
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

	BeepLong
	mSetWatchToInit

	CALL	InitScheduler
        mCheckBabyLevel

 .if AVRProcessor=1
        mSendBabyModeToAVR
 .endif

	MAR  	*,AR1
	LAR  	AR1,#DATART+2
	LACC	TMP+1
	SACL 	*
	DMOV 	*
	B 	SendBack

NOPROG  MAR  	*,AR1
	LAR  	AR1,#DATART+2
	SPLK 	#0FFh,*  	;записываем код ошибки
	DMOV 	*
	B    	SendBack       	;и высылаем его в PC


COD2
*******************************
* считывание сигнатуры
**********************************************************
* Направление   Структура посылки           Примечание
*   обмена
**********************************************************
* PC > BP       22h,22h,22h,22h,.
**********************************************************
* PC < BP       22h,22h,22h,22h /
*               FFh,FFh,FFh,FFh             Прим. 1
**********************************************************
* PC > BP       22h,22h,22h,22h
**********************************************************
* PC < BP       22h,22h,22h,22h.,           Прим. 2
*               xxh(мл),_ xxh(ст.),
*               Crh(мл),_Crh(ст.)/
*               FFh,FFh,FFh,FFh.
**********************************************************
* Примечание:
* 1. При ошибке - стандартная процедура с повторами.
* 2. xxh - массив (6-ть байт номер прибора, 2-а байта номер версии,
*                  1 байт - номер версии данных давления,
*                  1 байт - номер версии данных ЭКГ
*    Crh - "контрольная сумма" массива (4-е байта).

	;надо проверить все ли четыре байта совпадают между собой
	LACC 	*+,0  		;в акумулятор загружаем принятый
				;байт комманды (DATART+1)
	XOR  	*  		;сравниваем с DATART+2
	BCND 	OUTFF,NEQ 	;если не совпадает, то назад 0FFh
	LACC 	*+,0  		;в акумулятор загружаем принятый
				;байт комманды (DATART+2)
	XOR  	*     		;сравниваем с DATART+3
	BCND 	OUTFF,NEQ 	;если не совпадает, то назад 0FFh
	BIT  	Flags,15      	;уже принимали до этого четыре кода NNh ?
	BCND 	CommAndCrc,TC 	;да, уже принимали, поэтому идет плюс
	SPLK 	#22h,Flags+1
	LACC 	Flags,0
	OR  	#0001h
	B 	SendBackAndFlag
CommAndCrc
	LACC 	Flags+1
	XOR  	#22h		;а те четыре кода, принятых перед этим
				;совпадают с текущей коммандой?
	BCND 	OUTFF,NEQ	;если не совпадает, то назад 0FFh
	LACC 	Flags,0
	AND  	#0FFFEh
	SACL 	Flags      	;мы сделали это!!! (след раз определение
				;сигнатуры заново)
	LAR  AR1,#DATART+4  	;Считывание сигнатуpы в буфер
				;для передачи в компьютер
	LACC 	#SIGNT
	RPT  	#LengthSignat-1 ;LengthSignat байт данных
	TBLR 	*+
	CLRC 	SXM
	SPLK 	#0FFFFh,CRC 	; Подсчет контрольной суммы
	DMOV 	CRC

	LAR	AR1,#MayModify+1
	LACC	*
	LAR	AR1,#DATART+4+11
	SACL	*

	LAR  	AR1,#DATART+4
	LAR  	AR0,#LengthSignat-1   ;LengthSignat байт данных
	CALL 	CRCCALC
	LACC 	CRC
	AND  	#0FFh
	SACL 	*+
	LACC 	CRC,8
	SACH 	*+
	LACC 	CRC+1
	AND  	#0FFh
	SACL 	*+
	LACC 	CRC+1,8
	SACH 	*+
	SPLK 	#LengthSignat+8,CNTASPTR
				;в буфере LengthSignat+8 символов
				; LengthSignat байт сигнатура
				; 4 байта команда
				; 4 байта CRC
	B 	SendBackC
********************************
* вычисление контрольной суммы
*	AR1 - указатель на массив
*	AR0 - (длина-1) байт
*	CRC
********************************
CRCCALC LACC 	CRC
	XOR  	*+,AR0
	AND  	#0FFh
	SACL 	TMP
	LACC 	TMP,1
	ADD  	#CRCTBL
	TBLR 	TMP+1	;Старшая часть
	ADD  	#1
	TBLR 	TMP         ;Младшая часть
	LACC 	CRC,8
	SACH 	TMP+2
	LACC 	CRC+1,8
	OR   	TMP+2
	SACH 	TMP+2
	XOR  	TMP
	SACL 	CRC
	LACC 	TMP+2
	XOR  	TMP+1
	SACL 	CRC+1
	BANZ 	CRCCALC,*-,AR1
	RET


COD3    ;считывание данных из flash давления
* Направление Структура посылки              Примечание
*   обмена
* PC > BP     33h,33h,NNh(мл),NNhh(ст).
* PC < BP     33h,33h,NNh(мл),NNhh(ст)./     Прим. 1
*             FFh,FFh,FFh,FFh.
* PC > BP     33h,33h,NNh(мл),NNhh(ст).
* PC < BP     33h,33h,NNh(мл),NNhh(ст).      Прим. 2
*             xxh(мл),_ xxh(ст.),
*             Crh(мл),_Crh(ст.),  /
*             FFh,FFh,FFh,FFh.
* Примечание:
* 1. При ошибке - стандартная процедура с повторами.
* 2. NNh(ст.), NNh(мл) - номер блока дынных (определяет начальные
*    адреса с дискретностью 256 байт), xxh - элементы блока данных
*    объемом 2 Кбайт, Crh - "контрольная сумма" массива данных
*    (4-е байта).


        BIT  Flags,15      ;уже принимали до этого четыре кода NNh ?
        BCND CommAndBlood,TC ;да, уже принимали, поэтому высылаем назад
                           ;еще 2 Кбайт данных и контр.сумму впридачу
        ;а так, надо просто выслать назад те же самые коды
        ;и установить флаг, что это мы сделали :)
        LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+1)
        SACL Flags+1
        LACC *+,0  ;первый байт данных комманды (DATART+2)
        SACL Flags+2
	LACC *,0  ;второй байт данных комманды (DATART+3)
	SACL Flags+3
	LACC Flags,0
	OR  #0001h
	B SendBackAndFlag
CommAndBlood
	LACC Flags+1
	XOR  *+        ;а  код, принятых перед этим
		       ;совпадают с текущей коммандой?
	BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
	LACC Flags+2
	XOR  *+        ;а  первый байт данных, принятых перед этим
		       ;совпадают с текущим?
	BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
	LACC Flags+3
	XOR  *         ;а  второй байт данных, принятых перед этим
		       ;совпадают с текущим?
	BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
	LACC Flags,0
	AND  #0FFFEh
        SACL Flags      ;мы сделали это!!! (след раз чтение данных
                        ;давления заново)
        ;в DATART+2(мл) и DATART+3(ст) находится номер блока данных

*        CLRC SXM
*        LACC Flags+2,5  ;читаем младший байт
*        ADD  Flags+3,13
*        SACH AFLMSB,1
*        OR   #8000h
*        SACL AFLLSB
*        LACC DPA0
*        AND  #01Fh
*        ADD  AFLMSB,6
*        SACL DPA0
*        OUT  DPA0,PA0
*	OR   #20h
*        SACL DPA0

*        LAR  AR1,AFLLSB
*	SPLK #07ffh,TMP
*	RPT  TMP
*        BLDD *+,#DATART+4

*        OUT  DPA0,PA0

	CLRC SXM
 .if Mem=20	;одна микросхема на 2 Mbyte
	LACC Flags+2,5  ;читаем младший байт
	ADD  Flags+3,13
 .elseif Mem=40	;одна микросхема на 4 Mbyte
	LACC Flags+2,6  ;читаем младший байт
	ADD  Flags+3,14
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	SACH FLADR+1,1
	AND   #7FFFh
	SACL FLADR
	LAR	AR1,#DATART+4
	CALL	Read2K
	Beep


	SPLK #0FFFFh,CRC    ; Подсчет контрольной суммы
	DMOV CRC
	LAR  AR1,#DATART+4
	LAR  AR0,#07FFh
	MAR	*,AR1
        CALL CRCCALC
        LACC CRC
        AND  #0FFh
        SACL *+
        LACC CRC,8
        SACH *+
        LACC CRC+1
        AND  #0FFh
        SACL *+
        LACC CRC+1,8
        SACH *+
        SPLK #0808h,CNTASPTR     ;в буфере 2048+4+4 символов
        B SendBackC
COD4    ;очистка flash давления
* Направление Структура посылки            Примечание
*   обмена
* PC > BP     44h,44h,44h,44h.
* PC < BP     44h,44h,44h,44h./
*             FFh,FFh,FFh,FFh
* PC > BP     44h,44h,44h,44h..
* PC < BP     44h,44h,00h,00h /
*             44h,44h,FFh,FFh./
*             FFh,FFh,FFh,FFh.        Это конец очистки (через 1-15с.)
*
* Примечание: Если операция завершена успешно, то 44h,44h,00h,00h,
* если нет, то 44h,44h,FFh,FFh.

        ;надо проверить все ли четыре байта совпадают между собой
        LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+1)
        XOR  *     ;сравниваем с DATART+2
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+2)
        XOR  *     ;сравниваем с DATART+3
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        BIT  Flags,15      ;уже принимали до этого четыре кода NNh ?
        BCND CommAndClear,TC ;да, уже принимали, поэтому вычищаем flash
                           ;и говорим о результатах
        SPLK #44h,Flags+1
        LACC Flags,0
        OR  #0001h
        B   SendBackAndFlag
CommAndClear
        LACC Flags+1
        XOR  #44h      ;а те четыре кода, принятых перед этим
                       ;совпадают с текущей коммандой?
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC Flags,0
        AND  #0FFFEh
        SACL Flags      ;мы сделали это!!! (след раз очистка
                        ;flash заново)
        CLRC SXM
  .if VersionFerrum=1		;без дешифратора
 .if MetodFlashClear=1
	CALL FLCLR            ; Очистить Flash давления
 .elseif MetodFlashClear=2
	SPLK #31,TMP
NextPage
	CALL FlashPageCheck
	BCND AlreadyClear,EQ
	CALL FlashPageClear
	CALL FlashPageCheck
	BCND ByakaClear,NEQ
AlreadyClear
	LACC TMP
	BCND EndOkClear,EQ
	SUB #1
	SACL TMP
	B NextPage
ByakaClear
	SPLK #1,TMP
EndOkClear
 .else
 .emsg _ERROR __ Wrong PARAMETER_
 .endif

 .elseif VersionFerrum=2        ;с дешифратором

 .if MetodFlashClear=1
	CALL FLCLR            ; Очистить Flash давления
 .elseif MetodFlashClear=2
;в теории надо стереть 0x000000- 0x0002FF
	SPLK 	#02FFH,TMP+1
	SPLK    #0FFh,TMP
	SPLK	#0,FLADR
	SPLK	#0,FLADR+1
NextPage
	CALL FLPROG
	LACC TMP+1
	BCND EndOkClear,EQ
	SUB #1
	SACL TMP+1
	B NextPage
*ByakaClear
*	SPLK #1,TMP
EndOkClear
;в теории надо стереть 0x1F0000- 0x1FFFFF
	SPLK 	#0FFFFH,TMP+1
	SPLK    #0FFh,TMP
	SPLK	#0,FLADR
	SPLK	#1Fh,FLADR+1
NextPage1
	CALL FLPROG
	CLRC SXM
	LACC TMP+1
	BCND EndOkClear1,EQ
	SUB #1
	SACL TMP+1
	B NextPage1
EndOkClear1
	Beep
*******
* сбрасываем кэш во флеш
*******
	CALL	Clear_cashe
	SPLK	#0,TMP
 .else
 .emsg _ERROR __ Wrong PARAMETER_
 .endif

 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif


	MAR  *,AR1

	LAR  AR1,#DATART+2
	SPLK #00h,*
	DMOV *
	BIT  TMP,15
	BCND SendBack,NTC
	SPLK #0FFh,*
	DMOV *
	B SendBack

COD5    ;определение скорости обмена
*
* N   Направление обмена   Структура посылки      Примечание
* 1   PC > BP              41h                    символ "A" autobaunding
* 2   PC < BP              41h,00h
* 3   PC > BP              55h,55h,55h,55h
* 4   PC < BP              55h,55h,55h,55h
*                          или FFh,FFh,FFh,FFh
* 5   PC > BP              55h,55h,55h,55h,
*                          41h,55h,41h,55h,
*                          41h,55h,__.            Команда + 256 байт
* 6   PC < BP              55h,55h,55h,55h,
*                          41h,55h,_,41h,55h
*                          или FFh,FFh,FFh,FFh
* Примечание:  Если при обмене есть ошибки, то понизить скорость,
* но не менее чем до 9.6 Кбит/с.

	;надо проверить все ли четыре байта совпадают между собой
	LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+1)
	XOR  *     ;сравниваем с DATART+2
	BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
	LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+2)
	XOR  *     ;сравниваем с DATART+3
	BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
	BIT  Flags,15      ;уже принимали до этого четыре кода NNh ?
	BCND CommAnd256,TC ;да, уже принимали, поэтому идет плюс
                           ;еще 256 байт
        ;а так, надо просто выслать назад те же самые коды
        ;и установить флаг, что это мы сделали :)
        SPLK #55h,Flags+1
        LACC Flags,0
        OR  #0001h
SendBackAndFlag
        SACL Flags      ;мы сделали это!!!
SendBack
        SPLK #4,CNTASPTR     ;в буфере четыре символа
SendBackC
        LAR  AR1,#DATART
        SAR  AR1,PosTransmit ;начало буфера передачи
        B EnableAndBeginTr   ;переходим на разрешение прерываний
			     ;передачи
CommAnd256
        LACC Flags+1
        XOR  #55h      ;а те четыре кода, принятых перед этим
                       ;совпадают с текущей коммандой?
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        ;будем принимать 256 байт
        SPLK #Receve41h,WhatDoingReceve ;следующий принимаем 41h
        LAR  AR1,#DATART+4
        SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема
        B RETASPINT ;возрат из прерывания
CommandRec5_41
        LAR  AR1,PosTransmit
        LACC ByteReceve,0  ;в акумулятор загружаем принятый байт
        SACL *+              ;сдвигаем буфер на единичку
        SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема
	XOR  #041h          ;если это не 41h,
	BCND OUTFF,NEQ     ;то высылаем соответствующее
*	BCND Error41,NEQ     ;то высылаем соответствующее
			   ;"приему" :) "ругательство"
	;будем принимать 55h следующим
	SPLK #Receve55h,WhatDoingReceve ;следующий принимаем второй байт (41,55)
	B RETASPINT ;возрат из прерывания
*Error41
*	B	OUTFF
CommandRec5_55
	LAR  AR1,PosTransmit
	LACC ByteReceve,0  ;в акумулятор загружаем принятый байт
	SACL *+              ;сдвигаем буфер на единичку
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема
	XOR  #055h          ;если это не 55h,
	BCND OUTFF,NEQ     ;то высылаем соответствующее
*	BCND Error41,NEQ     ;то высылаем соответствующее
			   ;"приему" :) "ругательство"
	LACC PosTransmit
	SUB  #DATART
	SUB  #260
	BCND OutBuffer256,GEQ ;остаток от вычитания больше или равен 0
	;следующий принимаем первый байт (41,55)
	SPLK #Receve41h,WhatDoingReceve ;следующий принимаем 41h
	B RETASPINT ;возрат из прерывания
OutBuffer256
	LACC Flags,0
	AND  #0FFFEh
	SACL Flags      ;мы сделали это!!! (след раз определение
			;скорости заново)
	SPLK #260,CNTASPTR   ;в буфере четыре символа 55h и 256 байт 41,55
	B SendBackC     ;переходим на разрешение прерываний
			     ;передачи

COD6    B OUTFF ;отладка
COD7    ;проконтролировать Flash давления
* Направление Структура посылки            Примечание
*   обмена
* PC > BP     77h,77h,77h,77h.
* PC < BP     77h,77h,77h,77h /
*             FFh,FFh,FFh,FFh
* PC > BP     77h,77h,77h,77h
* PC < BP     77h,77h,00h,00h /      Это конец контроля и очистки
*             77h,77h,FFh,FFh /           (через 5-25с.)
*             FFh,FFh,FFh,FFh
*
* Примечание: Если операция завершена успешно, то 77h,77h,00h,00h,
* если нет, то 77h,77h,FFh,FFh.

        ;надо проверить все ли четыре байта совпадают между собой
        LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+1)
        XOR  *     ;сравниваем с DATART+2
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+2)
        XOR  *     ;сравниваем с DATART+3
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        BIT  Flags,15      ;уже принимали до этого четыре кода NNh ?
        BCND CommAndControl,TC ;да, уже принимали, поэтому контроллируем
			   ;flash давления и говорим о результатах
        SPLK #77h,Flags+1
        LACC Flags,0
        OR  #0001h
        B   SendBackAndFlag
CommAndControl
        LACC Flags+1
        XOR  #77h      ;а те четыре кода, принятых перед этим
                       ;совпадают с текущей коммандой?
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC Flags,0
        AND  #0FFFEh
        SACL Flags      ;мы сделали это!!! (след раз очистка
                        ;flash заново)
       ;здесь (потом !!!) надо проконтролировать flash давления

        LAR  AR1,#DATART+2
        SPLK #00h,*
        DMOV *
        B SendBack

COD8    ;считывание данных из flash ЭКГ
        BIT  Flags,15      ;уже принимали до этого четыре кода NNh ?
        BCND CommAndDataEKG,TC ;да, уже принимали, поэтому высылаем назад
                           ;еще 2 Кбайт данных и контр.сумму впридачу
        ;а так, надо просто выслать назад те же самые коды
        ;и установить флаг, что это мы сделали :)
        LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+1)
        SACL Flags+1
        LACC *+,0  ;первый байт данных комманды (DATART+2)
        SACL Flags+2
        LACC *,0  ;второй байт данных комманды (DATART+3)
        SACL Flags+3
        LACC Flags,0
        OR  #0001h
	B SendBackAndFlag
CommAndDataEKG
        LACC Flags+1
        XOR  *+        ;а  код, принятых перед этим
                       ;совпадают с текущей коммандой?
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC Flags+2
	XOR  *+        ;а  первый байт данных, принятых перед этим
                       ;совпадают с текущим?
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC Flags+3
        XOR  *         ;а  второй байт данных, принятых перед этим
                       ;совпадают с текущим?
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC Flags,0
        AND  #0FFFEh
        SACL Flags      ;мы сделали это!!! (след раз чтение данных
                        ;давления заново)
        ;в DATART+2 и DATART+3 находится номер блока данных
        ;надо будет (потом !!!) заполнить 2кбайта данных
        LAR  AR1,#DATART+4  ;Считывание флеш данных в компьютер
	SPLK #07FFh,TMP
        LACC #8000h
	RPT  TMP
        TBLR *+
        CLRC SXM
        SPLK #0FFFFh,CRC    ; Подсчет контрольной суммы
        DMOV CRC
        LAR  AR1,#DATART+4
        LAR  AR0,#07FFh
        CALL CRCCALC
        LACC CRC
        AND  #0FFh
        SACL *+
        LACC CRC,8
	SACH *+
        LACC CRC+1
        AND  #0FFh
        SACL *+
        LACC CRC+1,8
	SACH *+
        SPLK #0808h,CNTASPTR     ;в буфере 2048+4+4 символов
        B SendBackC

COD9    ;очистка flash ЭКГ
        ;надо проверить все ли четыре байта совпадают между собой
        LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+1)
        XOR  *     ;сравниваем с DATART+2
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+2)
        XOR  *     ;сравниваем с DATART+3
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        BIT  Flags,15      ;уже принимали до этого четыре кода NNh ?
        BCND CommAndClearEKG,TC ;да, уже принимали, поэтому вычищаем flash
                           ;ЭКГ и говорим о результатах
        SPLK #99h,Flags+1
        LACC Flags,0
        OR  #0001h
        B   SendBackAndFlag
CommAndClearEKG
        LACC Flags+1
        XOR  #99h      ;а те четыре кода, принятых перед этим
                       ;совпадают с текущей коммандой?
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC Flags,0
        AND  #0FFFEh
        SACL Flags      ;мы сделали это!!! (след раз очистка
                        ;flash заново)
       ;здесь (потом !!!) надо очистить flash ЭКГ

	LAR  AR1,#DATART+2
        SPLK #00h,*
        DMOV *
	B SendBack

CODA    ;проконтролировать Flash ЭКГ
        ;надо проверить все ли четыре байта совпадают между собой
        LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+1)
        XOR  *     ;сравниваем с DATART+2
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+2)
        XOR  *     ;сравниваем с DATART+3
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        BIT  Flags,15      ;уже принимали до этого четыре кода NNh ?
        BCND CommAndControlEKG,TC ;да, уже принимали, поэтому контроллируем
                           ;flash ЭКГ и говорим о результатах
        SPLK #0AAh,Flags+1
        LACC Flags,0
        OR  #0001h
        B   SendBackAndFlag
CommAndControlEKG
        LACC Flags+1
        XOR  #0AAh      ;а те четыре кода, принятых перед этим
                       ;совпадают с текущей коммандой?
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC Flags,0
        AND  #0FFFEh
        SACL Flags      ;мы сделали это!!! (след раз очистка
                        ;flash заново)
       ;здесь (потом !!!) надо проконтролировать flash давления

        LAR  AR1,#DATART+2
        SPLK #00h,*
        DMOV *
        B SendBack
CODB ;записать блок данных в прибор

* Направление     Структура посылки        Примечание
*   обмена
* PC > BP         BBh,BBh,NNh(мл),NNhh(ст).
* PC < BP         BBh,BBh,NNh(мл),NNhh(ст). /        Прим. 1
*                 или FFh,FFh,FFh,FFh
* PC > BP         BBh,BBh,NNh(мл),NNhh(ст).,         Где xxh - массив парам-ов,
*                 xxh,_xxh,Crh(мл)_,        прим. 3
*                 Crh(ст.)
* PC < BP         BBh,BBh,00h,00h /        Прим. 2
*                 BBh,BBh,FFh,FFh /
*                 FFh,FFh,FFh,FFh
* Примечание:
* 1. При ошибке - стандартная процедура с повторами.
* 2. NNh(ст.), NNh(мл) - номер блока дынных (определяет начальные
*    адреса с дискретностью 256 байт), xxh - элементы блока данных
*    объемом 2 Кбайт, Crh - "контрольная сумма" массива данных
*    (4-е байта).
        BIT  Flags,15      ;уже принимали до этого четыре кода NNh ?
        BCND CommAndBigData,TC ;да, уже принимали, поэтому идет плюс данные
        ;а так, надо просто выслать назад те же самые коды
        ;и установить флаг, что это мы сделали :)
        LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+1)
        SACL Flags+1
        LACC *+,0  ;первый байт данных комманды (DATART+2)
        SACL Flags+2
        LACC *,0  ;второй байт данных комманды (DATART+3)
        SACL Flags+3
        LACC Flags,0
        OR  #0001h
        B SendBackAndFlag
CommAndBigData
        LACC Flags+1
	XOR  *+        ;а  код, принятых перед этим
		       ;совпадают с текущей коммандой?
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC Flags+2
        XOR  *+        ;а  первый байт данных, принятых перед этим
                       ;совпадают с текущим?
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC Flags+3
        XOR  *         ;а  второй байт данных, принятых перед этим
                       ;совпадают с текущим?
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC Flags,0
        AND  #0FFFEh
        SACL Flags      ;мы сделали это!!! (след раз чтение данных
                        ;давления заново)
        ;в DATART+2(мл) и DATART+3(ст) находится номер блока данных
        ;следующий принимаем 2048+4 байта данных
        SPLK #ReceveData2k,WhatDoingReceve
        LAR  AR1,#DATART+4
        SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема
        B RETASPINT ;возрат из прерывания

CommandRecData2k
        ;принимаем 2k+4 байта данных + CRC
        LAR  AR1,PosTransmit
        LACC ByteReceve,0  ;в акумулятор загружаем принятый байт
        SACL *+              ;сдвигаем буфер на единичку
        SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема

        LACC PosTransmit
        SUB  #DATART
        SUB  #2048+4+4      ;2048+4 байта данных и четыре код комманды + CRC
        BCND OutBuffer2k,GEQ ;остаток от вычитания больше или равен 0
	;принимаем пока следующий байт (еще не все приняли)
        B RETASPINT ;возрат из прерывания

OutBuffer2k
        SPLK #0FFFFh,CRC ;надо посчитать контрольную сумму
        DMOV CRC
        LAR  AR1,#DATART+4
        LAR  AR0,#2047     ;2048 байт данных
        CLRC SXM
        CALL CRCCALC
        LAR  AR1,#DATART+2052 ;по этому смещению находится CRC
        LACC *+
        ADD  *+,8
        XOR  CRC
        BCND OUTFF,NEQ
        LACC *+
        ADD  *+,8
        XOR  CRC+1
        BCND OUTFF,NEQ
*
*                               Пpогpаммиpование пpибоpа
*
        LAR  AR0,#2047        ;2048 байт данных
	LAR  AR6,#DATART+4
	LAR  AR1,#DATART+2

 .if Mem=20	;одна микросхема на 2 Mbyte
	LACC *+,5
	ADD  *,13
 .elseif Mem=40	;одна микросхема на 4 Mbyte
	LACC *+,6
	ADD  *,14
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	SACH 	FLADR+1,1  ;запоминаем старшую часть адреса
*        OR   #8000h
	AND	#07FFFH
	SACL 	FLADR    ;запоминаем младшую часть адреса

	MAR  	*,AR6
NEXTWD1 BLDD 	*+,#TMP
	CALL FLPROG
	BCND NOPROG1,NEQ ;если ACC!=0, то произошла ошибка записи

	MAR  *,AR0
	BANZ NEXTWD1,*-,AR6
*
 .if VersionFerrum=1		;без дешифратора

 .elseif VersionFerrum=2        ;с дешифратором
*******
* сбрасываем кэш во флеш
*******
	CALL	Clear_cashe
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

	MAR  *,AR1
        LAR  AR1,#DATART+2
	SPLK #000h,*
*	SPLK #0FFh,*
	Beep
	DMOV *
        B SendBack

NOPROG1 MAR  *,AR1
        LAR  AR1,#DATART+2
        SPLK #0FFh,*         ;записываем код ошибки
        DMOV *
        B    SendBack        ;и высылаем его в PC
CODC ;служебная команда

* Направление     Структура посылки        Примечание
*   обмена
* PC > BP         ССh,ССh,NNh(мл),NNhh(ст).
* PC < BP         ССh,ССh,NNh(мл),NNhh(ст). /        Прим. 1
*                 или FFh,FFh,FFh,FFh
* PC > BP         ССh,ССh,NNh(мл),NNhh(ст).,         Где xxh - массив парам-ов,
*                 xxh,_xxh,Crh(мл)_,        прим. 3
*                 Crh(ст.)
* PC < BP         ССh,ССh,00h,00h /        Прим. 2
*                 ССh,ССh,FFh,FFh /
*                 FFh,FFh,FFh,FFh
* Примечание:
* 1. При ошибке - стандартная процедура с повторами.
* 2. NNh(ст.), NNh(мл) - номер выполняемой команды
*
        BIT  Flags,15      ;уже принимали до этого четыре кода NNh ?
        BCND CommAndUserData,TC ;да, уже принимали, поэтому идет плюс данные
        ;а так, надо просто выслать назад те же самые коды
        ;и установить флаг, что это мы сделали :)
        LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+1)
        SACL Flags+1
        LACC *+,0  ;первый байт данных комманды (DATART+2)
        SACL Flags+2
        LACC *,0  ;второй байт данных комманды (DATART+3)
        SACL Flags+3
        LACC Flags,0
        OR  #0001h
        B SendBackAndFlag
CommAndUserData
        LACC Flags+1
        XOR  *+        ;а  код, принятых перед этим
                       ;совпадают с текущей коммандой?
        BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
        LACC Flags+2
	XOR  *+        ;а  первый байт данных, принятых перед этим
		       ;совпадают с текущим?
	BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
	LACC Flags+3
	XOR  *         ;а  второй байт данных, принятых перед этим
		       ;совпадают с текущим?
	BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
	LACC Flags,0
	AND  #0FFFEh
	SACL Flags      ;мы сделали это!!! (след раз чтение данных
			;давления заново)
	;в DATART+2(мл) и DATART+3(ст) находится номер команды
	LAR  AR1,#DATART+2
	LACC 	*
	SUB  	#9         ;пока обрабатываем всего девять команд
	BCND ERRCOMM,GT ;вышли за предел обрабатываемых комманд?
	LACC 	*,1        ;код команды Branch из двух слов состоит
	BCND	ERRCOMM,EQ
	SUB	#1,1
	ADD  	#UserCode
	BACC
UserCode:
	B UserCode1     ;Проконтролировать Flash давления
	B UserCode2     ;Проконтролировать Flash ЭКГ
	B UserCode3	;Разрешить модификацию памяти прибора
	B UserCode4	;Переписать область flash памяти
			;данных в память программ TMS
	B UserCode5	;Переписать область flash памяти
			;данных в память программ AVR
	B UserCode6	;стереть данные в памяти программ AVR
	B UserCode7	;запустить тестовый режим часов
	B UserCode8	;считать аварийный код процессора
	B UserCode9	;чтение версии прошивки TMS и другая служебная инфо
;если добавляем команды, то вверх несколько строчек в команде SUB #NN
;стоит ограничитель обрабатываемых комманд, его тоже подпарвить необходимо
;он равен числу обрабатываемых комманд

UserCode1
	SPLK #RecUserCode1,WhatDoingReceve
	LAR  AR1,#DATART+4
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема
	B RETASPINT ;возрат из прерывания
; на данный момент просто высылаем назад код OK
ReceveUserCode1
	LAR  AR1,PosTransmit
	LACC ByteReceve,0  ;в акумулятор загружаем принятый байт
	SACL *+              ;сдвигаем буфер на единичку
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема

	LACC PosTransmit
	SUB  #DATART
	SUB  #4+4      ;четыре код комманды + CRC
	BCND OutBufferUserCode1,GEQ ;остаток от вычитания больше или равен 0
	;принимаем пока следующий байт (еще не все приняли)
	B RETASPINT ;возрат из прерывания

OutBufferUserCode1
	SPLK #0FFFFh,CRC ;надо посчитать контрольную сумму
	DMOV CRC
*        LAR  AR1,#DATART+4
*        LAR  AR0,#2047     ;2048 байт данных
*        CLRC SXM
*        CALL CRCCALC
	LAR  AR1,#DATART+4 ;по этому смещению находится CRC
	LACC *+
	ADD  *+,8
	XOR  CRC
	BCND OUTFF,NEQ
	LACC *+
	ADD  *+,8
	XOR  CRC+1
	BCND OUTFF,NEQ
	MAR	*,AR1
	LAR  AR1,#DATART+2
	SPLK #00h,*
	DMOV *
	B SendBack
UserCode2
	SPLK #RecUserCode2,WhatDoingReceve	;пока ничего не делаем
	LAR  AR1,#DATART+4
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема
	B RETASPINT ;возрат из прерывания
; на данный момент просто высылаем назад код OK
ReceveUserCode2
	LAR  AR1,PosTransmit
	LACC ByteReceve,0  ;в акумулятор загружаем принятый байт
	SACL *+              ;сдвигаем буфер на единичку
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема

	LACC PosTransmit
	SUB  #DATART
	SUB  #4+4      ;четыре код комманды + CRC
	BCND OutBufferUserCode2,GEQ ;остаток от вычитания больше или равен 0
	;принимаем пока следующий байт (еще не все приняли)
	B RETASPINT ;возрат из прерывания

OutBufferUserCode2
	SPLK #0FFFFh,CRC ;надо посчитать контрольную сумму
	DMOV CRC
*        LAR  AR1,#DATART+4
*        LAR  AR0,#2047     ;2048 байт данных
*        CLRC SXM
*        CALL CRCCALC
	LAR  AR1,#DATART+4 ;по этому смещению находится CRC
	LACC *+
	ADD  *+,8
	XOR  CRC
	BCND OUTFF,NEQ
	LACC *+
	ADD  *+,8
	XOR  CRC+1
	BCND OUTFF,NEQ
	MAR	*,AR1
	LAR  AR1,#DATART+2
	SPLK #00h,*
	DMOV *
	B SendBack

UserCode3
	;разрешить модификацию прибора
	SPLK 	#RecUserCode3,WhatDoingReceve
	LAR  AR1,#DATART+4
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема
	B RETASPINT ;возрат из прерывания
ReceveUserCode3
	LAR  AR1,PosTransmit
	LACC ByteReceve,0  ;в акумулятор загружаем принятый байт
	SACL *+              ;сдвигаем буфер на единичку
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема

	LACC PosTransmit
	SUB  #DATART
	SUB  #4+8+4      ;четыре код комманды + восемь данных+ CRC
	BCND OutBufferUserCode3,GEQ ;остаток от вычитания больше или равен 0
	;принимаем пока следующий байт (еще не все приняли)
	B RETASPINT ;возрат из прерывания

OutBufferUserCode3
	SPLK #0FFFFh,CRC ;надо посчитать контрольную сумму
	DMOV CRC
	LAR  AR1,#DATART+4
	LAR  AR0,#7     ;8 байт данных
	CLRC SXM
	CALL CRCCALC
	LAR  AR1,#DATART+8+4 ;по этому смещению находится CRC
	LACC *+
	ADD  *+,8
	XOR  CRC
	BCND OUTFF,NEQ
	LACC *+
	ADD  *+,8
	XOR  CRC+1
	BCND OUTFF,NEQ

********
* проверяем пароль
********
	MAR	*,AR1
	LAR  	AR1,#DATART+4

	LACC	*+		;1 символ пароля
	AND	#0FFh
	XOR	#'p'
	BCND	PassFail,NEQ

	LACC	*+		;2 символ пароля
	AND	#0FFh
	XOR	#'e'
	BCND	PassFail,NEQ

	LACC	*+		;3 символ пароля
	AND	#0FFh
	XOR	#'t'
	BCND	PassFail,NEQ

	LACC	*+		;4 символ пароля
	AND	#0FFh
	XOR	#'e'
	BCND	PassFail,NEQ

	LACC	*+		;5 символ пароля
	AND	#0FFh
	XOR	#'r'
	BCND	PassFail,NEQ

	LACC	*+		;6 символ пароля
	AND	#0FFh
	XOR	#'l'
	BCND	PassFail,NEQ

	LACC	*+		;7 символ пароля
	AND	#0FFh
	XOR	#'t'
	BCND	PassFail,NEQ

	LACC	*+		;8 символ пароля
	AND	#0FFh
	XOR	#'d'
	BCND	PassFail,NEQ

	MAR  	*,AR1
	LAR  	AR1,#MayModify
	SPLK	#MagicPass,*


	MAR	*,AR1
	LAR  AR1,#DATART+2

	SPLK #00h,*
	DMOV *
	B SendBack
UserCode4
	SPLK #RecUserCode4,WhatDoingReceve
	LAR  AR1,#DATART+4
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема
	B RETASPINT ;возрат из прерывания
ReceveUserCode4
	LAR  AR1,PosTransmit
	LACC ByteReceve,0  ;в акумулятор загружаем принятый байт
	SACL *+              ;сдвигаем буфер на единичку
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема

	LACC PosTransmit
	SUB  #DATART
	SUB  #4+4      ;четыре код комманды + CRC
	BCND OutBufferUserCode4,GEQ ;остаток от вычитания больше или равен 0
	;принимаем пока следующий байт (еще не все приняли)
	B RETASPINT ;возрат из прерывания

OutBufferUserCode4
	SPLK #0FFFFh,CRC ;надо посчитать контрольную сумму
	DMOV CRC
*        LAR  AR1,#DATART+4
*        LAR  AR0,#2047     ;2048 байт данных
*        CLRC SXM
*        CALL CRCCALC
	LAR  AR1,#DATART+4 ;по этому смещению находится CRC
	LACC *+
	ADD  *+,8
	XOR  CRC
	BCND OUTFF,NEQ
	LACC *+
	ADD  *+,8
	XOR  CRC+1
	BCND OUTFF,NEQ

	MAR  	*,AR1
	LAR  	AR1,#MayModify
	LACC	*
	XOR	#MagicPass
	BCND	PassFail,NEQ
 .if SerialProg=1
	CALL 	CopyCodeToRam
	B 	BeginPrgAlgor
 .elseif SerialProg=0
*	B 	0
 .endif


*	MAR	*,AR1
*	LAR  AR1,#DATART+2
*	SPLK #00h,*
*	DMOV *
*	B SendBack
	B	PassFail

PassFail
	MAR  	*,AR1
	LAR  	AR1,#MayModify
	SPLK	#0,*
ERRCOMM MAR  *,AR1
	LAR  AR1,#DATART+2
	SPLK #0FFh,*         ;записываем код ошибки
	DMOV *
	B    SendBack        ;и высылаем его в PC


UserCode5
 .if AVRProcessor=1		;с AVR
	SPLK #RecUserCode5,WhatDoingReceve
	LAR  AR1,#DATART+4
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема
	B RETASPINT ;возрат из прерывания
ReceveUserCode5
	LAR  AR1,PosTransmit
	LACC ByteReceve,0  ;в акумулятор загружаем принятый байт
	SACL *+              ;сдвигаем буфер на единичку
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема

	LACC PosTransmit
	SUB  #DATART
	SUB  #4+4      ;четыре код комманды + CRC
	BCND OutBufferUserCode5,GEQ ;остаток от вычитания больше или равен 0
	;принимаем пока следующий байт (еще не все приняли)
	B RETASPINT ;возрат из прерывания

OutBufferUserCode5
	SPLK #0FFFFh,CRC ;надо посчитать контрольную сумму
	DMOV CRC
*        LAR  AR1,#DATART+4
*        LAR  AR0,#2047     ;2048 байт данных
*        CLRC SXM
*        CALL CRCCALC
	LAR  AR1,#DATART+4 ;по этому смещению находится CRC
	LACC *+
	ADD  *+,8
	XOR  CRC
	BCND OUTFF,NEQ
	LACC *+
	ADD  *+,8
	XOR  CRC+1
	BCND OUTFF,NEQ

	MAR  	*,AR1
	LAR  	AR1,#MayModify
	LACC	*
	XOR	#MagicPass
	BCND	PassFail,NEQ
	CALL    Program_AVR
	MAR	*,AR1
	LAR  	AR1,#DATART+2

	SACL 	*
	DMOV 	*
	Beep
 .else
ReceveUserCode5:
 .endif 		;AVRProcessor
	B SendBack
UserCode6
 .if AVRProcessor=1		;с AVR
	SPLK #RecUserCode6,WhatDoingReceve
	LAR  AR1,#DATART+4
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема
	B RETASPINT ;возрат из прерывания
ReceveUserCode6
	LAR  AR1,PosTransmit
	LACC ByteReceve,0  ;в акумулятор загружаем принятый байт
	SACL *+              ;сдвигаем буфер на единичку
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема

	LACC PosTransmit
	SUB  #DATART
	SUB  #4+4      ;четыре код комманды + CRC
	BCND OutBufferUserCode6,GEQ ;остаток от вычитания больше или равен 0
	;принимаем пока следующий байт (еще не все приняли)
	B RETASPINT ;возрат из прерывания

OutBufferUserCode6
	SPLK #0FFFFh,CRC ;надо посчитать контрольную сумму
	DMOV CRC
*        LAR  AR1,#DATART+4
*        LAR  AR0,#2047     ;2048 байт данных
*        CLRC SXM
*        CALL CRCCALC
	LAR  AR1,#DATART+4 ;по этому смещению находится CRC
	LACC *+
	ADD  *+,8
	XOR  CRC
	BCND OUTFF,NEQ
	LACC *+
	ADD  *+,8
	XOR  CRC+1
	BCND OUTFF,NEQ

	MAR  	*,AR1
	LAR  	AR1,#MayModify
	LACC	*
	XOR	#MagicPass
	BCND	PassFail,NEQ
	CALL    EraseAVRMem
	MAR	*,AR1
	LAR  	AR1,#DATART+2

	SACL 	*
	DMOV 	*
 .else
ReceveUserCode6:
 .endif 		;AVRProcessor
	B SendBack

UserCode7
 .if Sertificarion=1	;включение режима тестового времени
	SPLK #RecUserCode7,WhatDoingReceve
	LAR  AR1,#DATART+4
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема
	B RETASPINT ;возрат из прерывания
ReceveUserCode7
	LAR  AR1,PosTransmit
	LACC ByteReceve,0  ;в акумулятор загружаем принятый байт
	SACL *+              ;сдвигаем буфер на единичку
	SAR  AR1,PosTransmit ;чтобы сразу запоминать данные приема

	LACC PosTransmit
	SUB  #DATART
	SUB  #4+4      ;четыре код комманды + CRC
	BCND OutBufferUserCode7,GEQ ;остаток от вычитания больше или равен 0
	;принимаем пока следующий байт (еще не все приняли)
	B RETASPINT ;возрат из прерывания

OutBufferUserCode7
	SPLK #0FFFFh,CRC ;надо посчитать контрольную сумму
	DMOV CRC
*        LAR  AR1,#DATART+4
*        LAR  AR0,#2047     ;2048 байт данных
*        CLRC SXM
*        CALL CRCCALC
	LAR  AR1,#DATART+4 ;по этому смещению находится CRC
	LACC *+
	ADD  *+,8
	XOR  CRC
	BCND OUTFF,NEQ
	LACC *+
	ADD  *+,8
	XOR  CRC+1
	BCND OUTFF,NEQ

*	MAR  	*,AR1
*	LAR  	AR1,#MayModify
*	LACC	*
*	XOR	#MagicPass
*	BCND	PassFail,NEQ

	MAR	*,AR1
	LAR	AR1,#TestTime+4
	SPLK	#1,*

	LACC	#0
	LAR  	AR1,#DATART+2

	SACL 	*
	DMOV 	*
 .else
ReceveUserCode7:

 .endif 		;Sertificarion включение режима тестового времени
	B SendBack

UserCode8:
ReceveUserCode8:	;он как бы и не нужен, но для проформы стоит
 .if AVRProcessor=1
	MAR	*,AR1
	LAR	AR1,#AVRProg
	SPLK	#1,*+
	SPLK	#04401h,*		;Read Fatal Measurement Error
	CALL	SendCommandAVR
 .else
 .endif

	MAR	*,AR1
	LAR	AR1,#AVRProg+2
	LACC	*
	LAR	AR1,#DATART+4
	SACL	*

	SPLK 	#0FFFFh,CRC    ; Подсчет контрольной суммы
	DMOV 	CRC
	LAR  	AR1,#DATART+4
	LAR  	AR0,#07FFh
	MAR	*,AR1
	CALL 	CRCCALC
	LACC 	CRC
	AND  	#0FFh
	SACL 	*+
	LACC 	CRC,8
	SACH 	*+
	LACC 	CRC+1
	AND  	#0FFh
	SACL 	*+
	LACC 	CRC+1,8
	SACH 	*+
	SPLK 	#0808h,CNTASPTR     ;в буфере 2048+4+4 символов
	B 	SendBackC

UserCode9:
ReceveUserCode9:	;он как бы и не нужен, но для проформы стоит

        MAR	*,AR1
	LAR  	AR1,#DATART+4  	;Считывание номера версии и даты
				;для передачи в компьютер
	LACC 	#CurrentRevision

ReadAgainRevision:
        TBLR 	CRC		;CRC используем как промежуточную ячейку
        SACL	CRC+1
	LACC	CRC,8
        SACH	*
        LACC	*+
        AND	#0FFH
        BCND	RevisionReaded,EQ
        LACC	CRC
        SACL	*+
        AND	#0FFH
        BCND	RevisionReaded,EQ
        LACC	CRC+1
        ADD	#1
        B	ReadAgainRevision

RevisionReaded:

	SPLK 	#0FFFFh,CRC    ; Подсчет контрольной суммы
	DMOV 	CRC
	LAR  	AR1,#DATART+4
	LAR  	AR0,#07FFh
	MAR	*,AR1
	CALL 	CRCCALC
	LACC 	CRC
	AND  	#0FFh
	SACL 	*+
	LACC 	CRC,8
	SACH 	*+
	LACC 	CRC+1
	AND  	#0FFh
	SACL 	*+
	LACC 	CRC+1,8
	SACH 	*+
	SPLK 	#0808h,CNTASPTR     ;в буфере 2048+4+4 символов
	B 	SendBackC



CODD	;считывание данных из AVR
 .if AVRProcessor=1		;с AVR
* Направление Структура посылки              Примечание
*   обмена
* PC > BP     DDh,DDh,NNh(мл),NNhh(ст).
* PC < BP     DDh,DDh,NNh(мл),NNhh(ст)./     Прим. 1
*             FFh,FFh,FFh,FFh.
* PC > BP     DDh,DDh,NNh(мл),NNhh(ст).
* PC < BP     DDh,DDh,NNh(мл),NNhh(ст).      Прим. 2
*             xxh(мл),_ xxh(ст.),
*             Crh(мл),_Crh(ст.),  /
*             FFh,FFh,FFh,FFh.
* Примечание:
* 1. При ошибке - стандартная процедура с повторами.
* 2. NNh(ст.), NNh(мл) - номер блока дынных (определяет начальные
*    адреса с дискретностью 256 байт), xxh - элементы блока данных
*    объемом 2 Кбайт, Crh - "контрольная сумма" массива данных
*    (4-е байта).


        BIT  Flags,15      ;уже принимали до этого четыре кода NNh ?
	BCND CommAndAVR,TC ;да, уже принимали, поэтому высылаем назад
			   ;еще 2 Кбайт данных и контр.сумму впридачу
	;а так, надо просто выслать назад те же самые коды
	;и установить флаг, что это мы сделали :)
	LACC *+,0  ;в акумулятор загружаем принятый байт комманды (DATART+1)
	SACL Flags+1
	LACC *+,0  ;первый байт данных комманды (DATART+2)
	SACL Flags+2
	LACC *,0  ;второй байт данных комманды (DATART+3)
	SACL Flags+3
	LACC Flags,0
	OR  #0001h
	B SendBackAndFlag
CommAndAVR
	LACC Flags+1
	XOR  *+        ;а  код, принятых перед этим
		       ;совпадают с текущей коммандой?
	BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
	LACC Flags+2
	XOR  *+        ;а  первый байт данных, принятых перед этим
		       ;совпадают с текущим?
	BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
	LACC Flags+3
	XOR  *         ;а  второй байт данных, принятых перед этим
		       ;совпадают с текущим?
	BCND OUTFF,NEQ ;если не совпадает, то назад 0FFh
	LACC Flags,0
	AND  #0FFFEh
	SACL Flags      ;мы сделали это!!! (след раз чтение данных
			;давления заново)
	;в DATART+2(мл) и DATART+3(ст) находится номер блока данных


	CLRC SXM
	LACC Flags+2,5  ;читаем младший байт
	ADD  Flags+3,13
	SACH FLADR+1,1
	AND   #7FFFh
	SACL FLADR
	LAR	AR1,#DATART+4
	CALL	ReadAVRMem
	BCND	OUTFF,NEQ
*	LACC	#10
*	CALL	Sound
	Beep

	SPLK #0FFFFh,CRC    ; Подсчет контрольной суммы
	DMOV CRC
	LAR  AR1,#DATART+4
	LAR  AR0,#07FFh
	MAR	*,AR1
	CALL CRCCALC
	LACC CRC
	AND  #0FFh
	SACL *+
	LACC CRC,8
	SACH *+
	LACC CRC+1
	AND  #0FFh
	SACL *+
	LACC CRC+1,8
	SACH *+
	SPLK #0808h,CNTASPTR     ;в буфере 2048+4+4 символов
	B SendBackC
 .endif 		;AVRProcessor

CODE
CODF
	B 	OUTFF 		;отладка
