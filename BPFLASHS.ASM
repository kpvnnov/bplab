* $Id: BPFLASHS.ASM,v 1.6 2001-04-26 16:11:01 peter Exp $
* последовательная флеш
*****************************************************************************
* очистка флеш
*****************************************************************************
* TMP - результат стерки
FLCLR
	RET
****************
* очистка страницы флеш
* TMP - номер 64 кбайтной страницы
****************
FlashPageClear
	RET
****************
* проверка чистоты страницы флеш
* TMP - номер 64 кбайтной страницы
****************
* ACC - результат (0 OK)
FlashPageCheck
	RET
*************************
*       программирование флеш
*       Надо опpеделить
*       [FLADR]      0-14bit
*       [FLADR+1]   15-20bit
*       TMP    -  Входные данные
*       Если пpи выходе из подпpогpаммы ACC=0 все Ok.
* использует
*************************
FLPROG
	MAR	*,AR7
	POPD	*-
	SAR     AR6,*-
	LACC	FLADR
	SACL	*-
	LACC	FLADR+1
	SACL	*-
	LACC	TMP
	SACL	*-

	CALL	WriteToFifo

;проверяем, следующая запись набежит на хвост?
	MAR	*,AR6
	LAR	AR6,#FifoHeadTail
	LACC	*+			;загружаем указатель головы
	ADD	#1
	AND	#LengthFifo-1
	SUB	*		;отнимаем от хвоста
	BCND	SleepSpokoino,NEQ
	CALL	Clear_Fifo	;спихиваем принудительно весь флеш
SleepSpokoino:

	CALL	MayBeWriteFlash	;если не можем записать во флеш
				;то запишем в фифошку

	MAR	*,AR7
	MAR	*+,AR7
	LACC	*+
	SACL	TMP
	LACC	*+
	SACL	FLADR+1
	LACC	*+
	SACL	FLADR

;увеличиваем адрес на единицу
	LACC 	FLADR
	AND	#07FFFh
	ADD  	#1
	SACL 	FLADR
	AND  	#07FFFh
	BCND 	FLPR_NoOver,NEQ
	SACL	FLADR
	LACC 	FLADR+1
	ADD  	#1
	SACL 	FLADR+1
FLPR_NoOver

	LAR     AR6,*+
	PSHD	*
	LACC	#0
	RET

MayBeWriteFlash:
	MAR     *,AR7
	POPD	*-

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
	MAR	*,AR7
	MAR	*+,AR7
	PSHD	*
	RET

*************************
*       чтение флеш
*       Надо опpеделить
*       AFLMSB     15-20bit
*       AFLLSB      0-14bit
*       ACC    -  Выходные данные
*************************
FLREAD
	MAR     *,AR7
	POPD	*-

	CALL	Clear_Fifo

	CALL	Find_in_cache
	BCND	FLR_found_in_cache,EQ
	CALL	Write_cache_to_flash
	CALL	Read_flash_to_cache
FLR_found_in_cache
	CALL	Read_from_cache
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
	MAR	*,AR7
	MAR	*+,AR7
	PSHD	*
	RET
*************************
* ищем страницу AFLMSB/AFLLSB в кэше
* Выход:
* ACC=0 	- страницу в кеше нашли, TMPCASHE номер страницы
* ACC!=0        - страницу в кеше не нашли
*************************
Find_in_cache
	MAR     *,AR7
	POPD	*-
	SAR     AR6,*-

	LAR	AR6,#PageCache
	LACC	FLADR,7
 .if Mem=20	;одна микросхема на 2 Mbyte
	AND     #03FH,16
 .elseif Mem=40	;одна микросхема на 4 Mbyte
	AND     #07FH,16
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	SACH	*
	LACC	FLADR+1,6
	OR	*,AR6
	XOR	*
	BCND	NotFoundPage,NEQ
	LACC	*
	SACL    TMPCASHE
	LACC	#0
NotFoundPage
	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR6,*+
	PSHD	*
	RET
*************************
* пишем в кеш TMP
*************************
Write_to_cache
	MAR	*,AR7
	POPD	*-
	SAR     AR6,*-

	LACC	FLADR,15
	SACH	*
	LACC	*
	AND	#0FFH
	ADD	#FlashData
	SACL	*
	LAR	AR6,*
	MAR	*,AR6

*	LACC	TMP
*	AND	#0FFh
*	SACL	TMP

	BIT	FLADR,15
	BCND	Wr_Chetn,NTC	;четный байт
*	LACC	TMP,8
*	SACL	TMP
	LACC	*
	AND	#0FFh		;старшую половинку стираем
	ADD	TMP,8
	B	Wr_to_cashe_1

Wr_Chetn
	LACC	*
	AND	#0FF00H		;младшую половинку стираем
	SACL	*
	LACC	TMP
	AND	#0FFH

	OR	*		;пристыковываем новые данные
Wr_to_cashe_1
	SACL	*

	LAR	AR6,#PageWrite	;увеличиваем счетчик записей
	LACC	*
	ADD	#1
	BCND	Wr_to_cashe_2,EQ
	SACL	*
Wr_to_cashe_2

	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR6,*+
	PSHD	*
	RET

*************************
* читаем из кеш в ACC
*************************
Read_from_cache
	MAR	*,AR7
	POPD	*-
	SAR     AR6,*-

	LACC	FLADR,15
	SACH	*
	LACC	*
	AND	#0FFH
	ADD	#FlashData
	SACL	*
	LAR	AR6,*
	MAR	*,AR6

	BIT	FLADR,15
	BCND	Rd_Chetn,NTC	;четный байт
	LACC	*,8,AR7
	SACH	*
*	B	Rd_to_cashe_1

Rd_Chetn
	LACC	*
*	SACL	TMP

Rd_to_cashe_1

	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR6,*+
	PSHD	*
	RET
*************************
* освобождаем страницы кеш от незаписанных данных
* алгоритм освобождения следующий:
*  для каждой страницы счетчик записи,
*  находим страницу с максимальным количеством записи
*  и записываем ее во флеш, счетчик записей обнуляется,
*  номер записанной страницы сохраняется в TMPCASHE
*  ACC в этом случае не равно нулю
*  если все страницы записаны, TMPCASHE=0, ACC=0
Write_cache_to_flash
	MAR	*,AR7
	POPD	*-
	SAR     AR6,*-

	MAR	*,AR6
	LAR     AR6,#PageWrite
	LACC	*
	BCND	Wr_cache_to_f_1,EQ
	SPLK	#0,*
	LAR     AR6,#PageCache
	LACC	*
	SACL	TMPCASHE
	LAR	AR6,#FlashData
	CALL	Write_page
Wr_cache_to_f_1
	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR6,*+
	PSHD	*
	RET
**************
* загружаем страницу AFLMSB/AFLLSB в кэш
Read_flash_to_cache
	MAR	*,AR7
	POPD	*-
	SAR     AR6,*-

	LAR	AR6,#PageCache
	MAR	*,AR6

	LACC	FLADR,7
 .if Mem=20	;одна микросхема на 2 Mbyte
	AND	#03FH,16
 .elseif Mem=40	;одна микросхема на 4 Mbyte
	AND	#07FH,16
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	SACH	*
	LACC	FLADR+1,6
	OR	*
	SACL	*

	LAR	AR6,#FlashData
	CALL	Read_page

	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR6,*+
	PSHD	*
	RET

* освобождаем кеш от незаписанных данных
* путем их спихивания во флеш
Clear_cashe:
	MAR	*,AR7
	POPD	*-

	CALL	Clear_Fifo
	CALL	Write_cache_to_flash

	MAR	*,AR7
	MAR	*+,AR7
	PSHD	*
	RET

*спихиваем фифо в основной кеш или флеш
Clear_Fifo:
	MAR	*,AR7
	POPD	*-
	LACC	FLADR
	SACL	*-
	LACC	FLADR+1
	SACL	*-
	LACC	TMP
	SACL	*-


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
	MAR	*,AR7
	MAR	*+,AR7
	LACC	*+
	SACL	TMP
	LACC	*+
	SACL	FLADR+1
	LACC	*+
	SACL	FLADR
	PSHD	*
	RET


NumCache	.set	1			;пока одна страница кеша
PageCache	.usect "flbuf",NumCache,1       ;адреса кешируемых страниц
PageWrite	.usect "flbuf",NumCache,1       ;количество записей в страницу
FlashData   	.usect "flbuf",256*NumCache,1	;кеш страниц

LengthFifo	.set 32		;должно быть кратно степени двойки
FifoData	.usect "flbuf",LengthFifo	;данные в очереди фифошки
FifoAddr	.usect "flbuf",2*LengthFifo     ;адреса данных
FifoHeadTail	.usect "flbuf",2		;адрес "головы" и "хвоста"

* запись байта в фифошку
*       FLADR+1   15-20bit
*       FLADR      0-14bit
*       TMP  -  Входные данные

WriteToFifo:
	MAR	*,AR7
	POPD	*-
	SAR     AR6,*-

	MAR	*,AR6
	LAR	AR6,#FifoHeadTail
	LACC	*			;загружаем указатель головы
	ADD	#1
	AND	#LengthFifo-1
	SACL	*
	PUSH				;сохраняем указатель
	ADD	#FifoData
	MAR	*,AR7
	SACL	*
	LAR     AR6,*,AR6
	LACC	TMP
	SACL	*
	POP
	SFL
	ADD	#FifoAddr
	MAR	*,AR7
	SACL	*
	LAR     AR6,*,AR6
	LACC	FLADR
	SACL	*+
	LACC	FLADR+1
	SACL	*+

	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR6,*+
	PSHD	*
	RET

InitFifoAndCache:
	MAR	*,AR7
	POPD	*-
	SAR     AR6,*-

	MAR	*,AR6
	LAR	AR6,#FifoHeadTail
	LACC	#0
	SACL	*+
	SACL	*+

	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR6,*+
	PSHD	*
	RET

* чтение байта из фифошки
* адрес заносится сюда
* инкремент хвоста НЕ ДЕЛАЕМ
*       FLADR+1   15-20bit
*       FLADR      0-14bit
*       ACC    -  Выходные данные
*
ReadFromFifoNotInc:
	MAR	*,AR7
	POPD	*-
	SAR     AR6,*-

	MAR	*,AR6
	LAR	AR6,#FifoHeadTail+1
	LACC	*			;загружаем указатель головы
	ADD	#1
	AND	#LengthFifo-1
;записывать адрес пока не будем
;	SACL	*

	PUSH				;сохраняем указатель

	SFL
	ADD	#FifoAddr
	MAR	*,AR7
	SACL	*
	LAR     AR6,*,AR6
	LACC	*+
	SACL	FLADR
	LACC	*+
	SACL	FLADR+1

	POP

	ADD	#FifoData
	MAR	*,AR7
	SACL	*
	LAR     AR6,*,AR6
	LACC	*
        SACL	TMP

	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR6,*+
	PSHD	*
	RET
* в АСС возвращает разницу головы и хвоста
FifoIsEmpty:
	MAR	*,AR7
	POPD	*-
	SAR     AR6,*-

	MAR	*,AR6
	LAR	AR6,#FifoHeadTail
	LACC	*+			;загружаем указатель головы
	SUB	*

	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR6,*+
	PSHD	*
	RET
*делаем инкремент хвоста фифошки
IncAddrFifo:
	MAR	*,AR7
	POPD	*-
	SAR     AR6,*-

	MAR	*,AR6
	LAR	AR6,#FifoHeadTail+1
	LACC	*			;загружаем указатель головы
	ADD	#1
	AND	#LengthFifo-1
	SACL	*
	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR6,*+
	PSHD	*
	RET



*******
* чтение страницы
*  адрес для чтения, из него выбрать адрес страницы
*  ASFLMSB     15-20bit
*  AFLLSB      0-14bit
*	AR6 - куда загружать
* процедура берет байты из флеш и загружает парами в слова AR6
* то есть начальный адрес должен быть четным
******
Read_page
	LACC 	#07FFFh
Read_p_1
	SUB  	#1
	RPT  	#10
	NOP
	RETC	LEQ
	BCND 	Read_p_1,BIO
	mRead_512b

*******
* запись страницы

* адрес страницы TMPCASHE
* сама страница - AR6
***********  адрес для записи, из него выбрать адрес страницы
*********  AFLMSB     15-20bit
***********  AFLLSB      0-14bit
*  PA11-0 - адрес страницы
*  BA9-0  - адрес байта внутри страницы
*  X      - неважно что
* 1.[87h],[X],        запись во второй буфер
* 2.[X..X,BA9-8],[BA7-0],
* 3.[n],[n],
* n.[n],[n]
*
* 1.[86h],[r,r,PA11-6], 	буф 2 -> page with built erase
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

	MAR	*,AR7
	POPD	*-
	SAR     AR6,*-
	SAR     AR0,*-

	SPLK 	#SSPS,*    ;SSP start
	OUT  	*,SSPCR    ;Synchronous Serial Port Control Register

	IN   	*,SDTR     ;команда лишнего чтения
				;для стабильности(надежности) работы с SSP
	LACC	#8700h
	SACL	*
	OUT  	*,SDTR     	;1.первое слово для передачи
				;([code][X])

	mImp_ssp              	;подгоняем SSP к началу передачи MSB
	mImp_ssp
	mImp_ssp

	;включить выборку флеш
	mOnFlash0
	mOutDIOSR

	SPLK	#0,*
	OUT  	*,SDTR,AR6     	;2.второе слово для передачи
				;[X..X,BA9-8],[BA7-0]

	; * слово для передачи
	OUT	*+,SDTR     	;3.третье слово для передачи
				;([первое слово])

	CALL 	CLKXF           ;1-передаем первое слово
				;([code][X])
	; * слово для передачи
	OUT	*+,SDTR,AR7    	;4.четвертое слово для передачи
				;([второе слово])
	IN   	*,SDTR     	;(1)чтение первого результата (мусор)
	CALL 	CLKXF           ;2-передаем второе слово
				;[X..X,BA9-8],[BA7-0]
	IN   	*,SDTR     	;(2)чтение второго результата (мусор)

	LAR	AR0,#255-2

Write_page_1
	CALL 	CLKXF           ;передаем N слово (N=0..255)
	IN   	*,SDTR,AR6     	;чтение (3+N) результата (мусор)
	; * слово для передачи
	OUT	*+,SDTR,AR0    	;3+N слово для передачи
				;([3+N слово данных])
*	MAR	*,AR0
	BANZ    Write_page_1,*-,AR7

*	LACC    AFLMSB

;еще два чтения

	LACC	TMPCASHE,10
	SACH	*
	LACC	*
 .if Mem=20	;одна микросхема на 2 Mbyte
	AND	#003Fh		;маска для 2 мбайта
 .elseif Mem=40	;одна микросхема на 4 Mbyte
	AND	#007Fh		;маска для 4 мбайта
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
	OR	#8600h
	SACL 	*		;запись второго буфера


	OUT  	*,SDTR     	;1.первое слово для передачи
				;([code][page_msb])

	CALL 	CLKXF           ;предпоследнее слово(N=254)
	IN   	*,SDTR     	;чтение результата
				;(мусор слово данных N=254)

	LACC	TMPCASHE,10
*	LACC    AFLLSB,1
	AND     #0FC00h
	SACL 	*		;запись адреса для записи страницы
	OUT  	*,SDTR     	;2.второе слово для передачи
				;([page_lsb][adress])
	CALL 	CLKXF           ;последнее слово(N=255)
	;выключить выборку флеш
	mOffPeriph
	mOutDIOSR

	IN   	*,SDTR     	;чтение результата
				;(мусор слово данных N=255)

	NOP ;незаню какая пауза должна быть ???!!!
	;включить выборку флеш

	mOnFlash0
	mOutDIOSR

	CALL 	CLKXF           ;команда записи
	IN   	*,SDTR     	;чтение результата
				;(мусор слово )

	CALL 	CLKXF           ;команда записи адреса страницы
	IN   	*,SDTR     	;чтение результата
				;(мусор слово )
	;выключить выборку флеш
	;запись пошла
	mOffPeriph
	mOutDIOSR

	SPLK 	#SSPR,*    	;RESET SSP
	OUT  	*,SSPCR

	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR0,*+
	LAR     AR6,*+
	PSHD	*
	RET


***********
* чтение по адресу FLADR 2 kb данных в AR1
***********
Read2K
	MAR	*,AR7
	POPD	*-
	SAR     AR0,*-

	LAR	AR0,#2047
Read2k_1
	CALL	FLREAD
	MAR	*,AR1
	SACL	*+,0,AR0
	BANZ    Read2k_1,*-,AR1

	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR0,*+
	PSHD	*
	RET