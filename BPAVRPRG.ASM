;&D
* $Id: BPAVRPRG.ASM,v 1.15 2001-10-22 13:38:11 peter Exp $
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
* процедура передачи (выдачи тактовой частоты) по SPI
* для AVR
* высылает два _байта_ с паузой между ними 6 mks

CLKAVRSPI
	LACC	#8
NextCLKXFAVR1:
;	mImp_ssp
	mImp_SSPAVR
	SUB	#1
	BCND	NextCLKXFAVR1,NEQ

*	mOffPeriph
*	mOutDIOSR

	mWait6mks		;между байтами необходимо сделать паузу,
				;чтобы AVR успел обработать принятую команду

*	mOnAVRSPI

	LACC	#8
NextCLKXFAVR2:
;	mImp_ssp
        mImp_SSPAVR
	SUB	#1
	BCND	NextCLKXFAVR2,NEQ
	RET

* вход в синхронизацию с AVR
* выход ACC=0 вошли в синхро
* ACC=1 не вошли
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
	SPLK	#64,*,AR1	;можно сделать 64 цикла входа в синхро

AgainProgrammingEnaled
*┌───────────────────┬───────────┬──────────┬──────────┬──────────┐
*│                   │  Byte 1   │ Byte 2   │ Byte 3   │Byte 4    │
*├───────────────────┼───────────┼──────────┼──────────┼──────────┤
*│Programming Enable │ 1010 1100 │0101 0011 │xxxx xxxx │xxxx xxxx │
*└───────────────────┴───────────┴──────────┴──────────┴──────────┘

	SendSSP	#0AC53h
	SendSSP #00000h
	mImp_SSPAVR
	mImp_SSPAVR
	mImp_SSPAVR

	CALL 	CLKXFAVR        ;передаем два первых байта
				;Programming Enable
	ReadSSP
	SendSSP	#03000h		;послылаем в запас
	SendSSP #00000h         ;послылаем в запас (чтобы передача не остановилась)
	CALL 	CLKXFAVR        ;передаем два последних незначащих байта
				;Programming Enable
	ReadSSP
	;в старшем байте должен быть 53h, значит программирование разрешено
	LACC	*
	XOR	#05300h^0FF00h
	AND	#0FF00h
	BCND	ProgrammEnabled,EQ
	;надо посчитать количество ошибок и повторить при желании
	; рекомендуется 32 попытки
	MAR	*,AR7
	LAR  	AR7,#AVRProg+3
	LACC	*
	SUB	#1
	SACL	*,0,AR1
	BCND    QPrgAVRNoSinc,EQ

* чтобы выйти на новую синхронизацию
* выталкиваем два лишних слова и начинаем заново
	CALL 	CLKXFAVR        ;передаем два первых байта
				;Programming Enable
	ReadSSP
	CALL 	CLKXFAVR        ;передаем два первых байта
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


* прогон одной комманды чтения в AVR

ReadByteAVR
*┌───────────────────────────────┬──────────┬──────────┬──────────┐
*│Read Program Memory  0010 H000 │xxxx aaaa │bbbb bbbb │oooo oooo │
*└───────────────────────────────┴──────────┴──────────┴──────────┘

	;в фифо добавляем еще два слова (команда чтения)
	;таким образом в фифо окажется четыре слова (две команды чтения)
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1

	LACC	*,7,AR1		;выделяем старшую часть адреса
	SACH	*,0,AR7		;сохраняем ее в стеке
	LACC	*,11,AR1	;выделяем младший бит (Hig/Low byte)
	AND	#00800H
	OR	#02000H		;добавляем код команды
	OR	*		;добавляем страшую часть адреса из стека
	SACL	*		;сохраняем все в стеке
	OUT  	*,SDTR,AR7	;отправляем в SPI

	LACC	*,7,AR1		;выделяем младшую часть адреса
				;переключаемся на стек
	SACL	*		;сохраняем ее в стеке
	OUT  	*,SDTR		;отправляем в SPI

	CALL 	CLKXFAVR	;отправляем команду чтения (которая в фифо)
	ReadSSP
	CALL 	CLKXFAVR
	ReadSSP
	RET
* прогон одной комманды чтения EEPROM в AVR

ReadByteEEPROM
*┌───────────────────────────────┬──────────┬──────────┬──────────┐
*│Read Program Memory  1010 H000 │xxxx aaaa │bbbb bbbb │oooo oooo │
*└───────────────────────────────┴──────────┴──────────┴──────────┘

	;в фифо добавляем еще два слова (команда чтения)
	;таким образом в фифо окажется четыре слова (две команды чтения)
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1

	LACC	*,7,AR1		;выделяем старшую часть адреса
	SACH	*,0,AR7		;сохраняем ее в стеке
	LACC	*,11,AR1	;выделяем младший бит (Hig/Low byte)
	AND	#00800H
	OR	#02000H		;добавляем код команды
	OR	*		;добавляем страшую часть адреса из стека
	SACL	*		;сохраняем все в стеке
	OUT  	*,SDTR,AR7	;отправляем в SPI

	LACC	*,7,AR1		;выделяем младшую часть адреса
				;переключаемся на стек
	SACL	*		;сохраняем ее в стеке
	OUT  	*,SDTR		;отправляем в SPI

	CALL 	CLKXFAVR	;отправляем команду чтения (которая в фифо)
	ReadSSP
	CALL 	CLKXFAVR
	ReadSSP
	RET

* программирование AVR
* выход в ACC
* =0 успешно
* =1 не синхрится
* =2 не программируется (считываются другие данные)
* =3 не программируется (считывается 0FFh)

Program_AVR
	MAR     *,AR1
	POPD	*+
	SAR     AR7,*+
	SAR     AR6,*+

	CLRC	SXM

	;считываем данные с флеш в буфер #DATART+4
	LACC    #1Fh,1		;#1F0000h адрес для зашивки
	SACL	_FLADR+1		;начальный адрес во флеш
	SPLK	#0,_FLADR

	LAR	AR7,#DATART+4
NextReadFlashAVR:
	CALL	FLREAD
	MAR	*,AR7
	BIT     _FLADR,15
	BCND    NechetAdrAvr,NTC	;не стоит TC, значит адрес нечетный (так как предыдущий)
	SFL
	SACL	*,7,AR7		;четные адреса записываем в старшей части
	B	CheckEndAdr

NechetAdrAvr:
	OR	*		;нечетные адреса в младшей части
	SACL	*+
CheckEndAdr:			;проверяем конечный адрес
	LACC	_FLADR
	SUB	#4096
	BCND	NextReadFlashAVR,LT
	;все, флеш считали #DATART+4 4kбайт

	ResetAVRSet
	SETC 	XF	; CLK = 0


	MAR	*,AR1
	SPLK 	#SSPS,*		;SSP start
	OUT  	*,SSPCR		;Synchronous Serial Port Control Register

	IN   	*,SDTR     	;команда лишнего чтения(!??)
				;для стабильности(надежности) работы с SSP

	CALL	AVRSinc

	BCND	EnterToSync,EQ
	B	QPrgAVR
EnterToSync

	MAR	*,AR7
	LAR  	AR7,#AVRProg+1
	SPLK	#0,*            ;записываем начальный адресс
				;программирования
	LAR	AR6,#DATART+4	;откуда читаем данные


*┌──────────────┬────────────────┬──────────┬──────────┬──────────┐
*│Write Program │      0100 H000 │xxxx aaaa │bbbb bbbb │iiii iiii │
*│   Memory     ├────────────────┴──────────┴──────────┴──────────┤
*├──────────────┘                                                 │
*│ H = 0 - Low byte, 1 - High byte                                │
*│ a = address high bits                                          │
*│ b = address low  bits                                          │
*│ i = data in                                                    │
*└────────────────────────────────────────────────────────────────┘
ProgrammNext:
	;ReadByte        ;чтение байта для программирования
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1
	BIT	*,15,AR6
	BCND    ReadNechetAdrAvr,TC ;стоит TC, значит адрес нечетный
	LACC	*,8,AR1		;четные адреса в старшей части
	SACH	*
	LACC	*
	B	ChetReaded
ReadNechetAdrAvr
	LACC	*+
ChetReaded:
	AND	#0FFH
	;если сравнить с 0FFh, то программировать нет необходимости
	MAR	*,AR7
	LAR  	AR7,#AVRProg+2
	SACL	*-,0,AR7
	XOR	#0FFh
	BCND	NextByte,EQ

	LACC	*,7,AR1		;выделяем старшую часть адреса
	SACH	*,0,AR7		;сохраняем ее в стеке
	LACC	*,11,AR1	;выделяем младший бит (Hig/Low byte)
	AND	#00800H
	OR	#04000H		;добавляем код команды
	OR	*		;добавляем страшую часть адреса из стека
	SACL	*		;сохраняем все в стеке
	OUT  	*,SDTR,AR7	;отправляем в SPI

	LACC	*+,7		;выделяем младшую часть адреса
				;переключаемся на данные
	AND	#0FF00h
	OR	*,AR1		;к младшей части адреса добавляем данные
	SACL	*		;сохраняем ее в стеке
	OUT  	*,SDTR		;отправляем в SPI

	;это высылается команда, которая сидит в fifo
	;(либо команда синхронизации, либо чтения)
	CALL 	CLKXFAVR
	ReadSSP
	CALL 	CLKXFAVR
	ReadSSP

	;добавляем фиктивную команду чтения
	SendSSP	#02000h
	SendSSP #00000h
	CALL 	CLKXFAVR	;это высылается команда записи
	ReadSSP
	CALL 	CLKXFAVR
	ReadSSP
	;на данный момент в памяти fifo остается команда чтения(фиктивная)
	MAR	*,AR7
	LAR  	AR7,#AVRProg+3
	SPLK	#15,*,AR1	;сколько ждать программирования (будем 15ms)
	; 3.2V  3.6V 4.0V 5.0V
	; 9 ms  7 ms 6 ms 4 ms

	mWait10ms
	B	NextByte
	mWait1ms

	CALL	ReadByteAVR
CheckAgain:
*┌────────────────────────────────────────────────────────────────┐
*│алгоритм Poling Data                                            │
*│ если читать постоянно только что запрограммированную ячейку    │
*│ то как только ячейка запрограммируется, при чтении появятся    │
*│ данные  иначе постоянно будут читаться 0xFFh                   │
*└────────────────────────────────────────────────────────────────┘
	mWait1ms

	CALL	ReadByteAVR
	;на данный момент в фифо остается одна команда чтения (два слова)
	;проверяем есть еще время проверять ?
	MAR	*,AR7
	LAR  	AR7,#AVRProg+3
	LACC	*
	SUB	#1
	SACL	*,0,AR1
	BCND    QPrgAVRNoWait,EQ

	;сравниваем полученный байт с данными
	;если 0FFh, то проверяем еще раз

	LAR  	AR7,#AVRProg+2
	LACC	*
	AND	#000FFh
*	XOR	#000FFh		;данные аппаратно инверсны уже
				;поэтому должен быть 0(а на самом деле FF)
	BCND	CheckAgain,EQ
	LACC	*,0,AR7
	AND	#000FFh
	XOR	#000FFh
	XOR	*
	BCND	QPrgAVRErrprg,NEQ	;данные считанные
					;отличаются от прошитых
NextByte:
	;увеличиваем адрес для программирования
	;и программируем следующий байт
	;AddAdress
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1
	LACC	*
	ADD	#1
	SACL	*
	SUB	#4096
	BCND    ProgrammNext,LT	;если не достигнут последний адрес
QPrgAVROK:
	LACC	#0		;нормальный конец
* внимание!!! - это выход используется и процедуре чтения
QPrgAVR:
	MAR	*,AR1
	SACL	*+		;заносим результат в стек

	CALL 	CLKXFAVR        ;передаем два первых байта
				;которые остались в фифошке
	ReadSSP
	CALL 	CLKXFAVR        ;передаем два последних байта
				;которые остались в фифошке
	ReadSSP

	;ResetAVRClear
	mOffPeriph
	mOutDIOSR
	MAR	*-,AR1		;достаем результат из стека
	LACC	*-		;автоматом стек на след ячейку

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
	SendSSP #0ACFFH	;зашиваем лок биты
	SendSSP	#00000h
	CALL 	CLKXFAVR
	ReadSSP
	CALL 	CLKXFAVR
	ReadSSP
	RET

* чтение программной памяти AVR
* AR2 - куда читать
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

	IN   	*,SDTR     	;команда лишнего чтения(!??)
				;для стабильности(надежности) работы с SSP

	CALL	AVRSinc

	BCND	EnterToSync1,EQ
	B	QPrgAVR		;будем использовать стандартный выход
EnterToSync1
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1
	LACC	_FLADR
	SACL	*            	;записываем начальный адрес
				;чтения
	LAR  	AR7,#AVRProg+3
	SPLK	#2048,*		;количество байт для чтения

	CALL	ReadByteAVR	;загоняем комманду чтения -
				;на выходе сигнатура
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1	;увеличиваем адресс на единицу
	LACC	*
	ADD	#1
	SACL	*
ReadAVRNext
	CALL	ReadByteAVR	;загоняем комманду чтения -
				;на байт данных
	LACC	*,0,AR2		;загружаем данные из стека
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
	SUB	#4097		;должно быть на один адрес больше
	BCND    ReadAVRNext,LT	;если не достигнут последний адрес
AllReadAvr
	B	QPrgAVROK
* чтение программной памяти AVR
* AR2 - куда читать
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

	IN   	*,SDTR     	;команда лишнего чтения(!??)
				;для стабильности(надежности) работы с SSP

	CALL	AVRSinc

	BCND	EnterToSync3,EQ
	B	QPrgAVR		;будем использовать стандартный выход
EnterToSync3
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1
	LACC	_FLADR
	SACL	*            	;записываем начальный адрес
				;чтения
	LAR  	AR7,#AVRProg+3
	SPLK	#2048,*		;количество байт для чтения

	CALL	ReadByteEEPROM	;загоняем комманду чтения -
				;на выходе сигнатура
	MAR	*,AR7
	LAR  	AR7,#AVRProg+1	;увеличиваем адресс на единицу
	LACC	*
	ADD	#1
	SACL	*
ReadAVRNext1
	CALL	ReadByteEEPROM	;загоняем комманду чтения -
				;на байт данных
	LACC	*,0,AR2		;загружаем данные из стека
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
	SUB	#4097		;должно быть на один адрес больше
	BCND    ReadAVRNext1,LT	;если не достигнут последний адрес
AllReadAvr1
	B	QPrgAVROK


* стерка программной памяти AVR
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

	IN   	*,SDTR     	;команда лишнего чтения(!??)
				;для стабильности(надежности) работы с SSP

	CALL	AVRSinc

	BCND	EnterToSync2,EQ
	B	QPrgAVR		;будем использовать стандартный выход
EnterToSync2
*┌─────────────────┬─────────────┬──────────┬──────────┬──────────┐
*│Chip Erase       │   1010 1100 │ 100x xxx │xxxx xxxx │xxxx xxxx │
*└─────────────────┴─────────────┴──────────┴──────────┴──────────┘
	MAR	*,AR1
	SendSSP	#0AC80h
	SendSSP	#00000h

*
	CALL 	CLKXFAVR           ;передаем два первых байта
				;Read Command
	ReadSSP
	CALL 	CLKXFAVR           ;передаем два последних незначащих байта
				;Read Command
	ReadSSP
*

	CALL 	CLKXFAVR           ;передаем два первых байта
				;Chip Erase
	ReadSSP
	CALL 	CLKXFAVR
				;передаем два последних  байта
				;Chip Erase
	ReadSSP
	mWait40ms
	B	QPrgAVROK
* закрываем программную памяти AVR
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

	IN   	*,SDTR     	;команда лишнего чтения(!??)
				;для стабильности(надежности) работы с SSP

	CALL	AVRSinc

	BCND	EnterToSync4,EQ
	B	QPrgAVR		;будем использовать стандартный выход
EnterToSync4:
*┌─────────────────┬─────────────┬──────────┬──────────┬──────────┐
*│Write Lock Bits  │   1010 1100 │ 1111 1Ll1│xxxx xxxx │xxxx xxxx │
*└─────────────────┴─────────────┴──────────┴──────────┴──────────┘
* L - 1
* l - 2
* Set bits 1, 2 ='0' to program Lock bits.

        MAR	*,AR1
	SendSSP	#0ACF9h
	SendSSP	#00000h

*
	CALL 	CLKXFAVR           ;передаем два первых байта
				;Write Lock Bits
	ReadSSP
	CALL 	CLKXFAVR           ;передаем два последних незначащих байта
				;Write Lock Bits
	ReadSSP
*

	CALL 	CLKXFAVR           ;передаем два первых байта
				;Write Lock Bits
	ReadSSP
	CALL 	CLKXFAVR
				;передаем два последних  байта
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

	IN   	*,SDTR,AR7     	;команда лишнего чтения(!??)
				;для стабильности(надежности) работы с SSP

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
