* $Id: BPFLASH.ASM,v 1.12 2001-02-23 09:48:23 peter Exp $
****отладка
WriteEnd
*	BIT     Jobs,7			;пишем во флеш ?
*	BCND	YesFlash,TC 		;пишем, так как было разрешение
*	CALL	MakeValue		;надо забить таблицу
*YesFlash
	LACC 	MayToWrite
	BCND 	AlreadyMaked,NEQ
	CALL	MakeValue		;надо забить таблицу
AlreadyMaked
	mEnd_write_flash
	CLRC 	SXM
	LACC 	IZNUMREC
	SUB 	#256
	BCND 	NeChet1,EQ ;не пишем, если не было разрешения
	;надо заполнить начальный адрес
*	LACC 	CountWrite
*	BCND NeChet1,EQ
 .if OutputSectoring=1
	CALL	MakeSectoring
 .elseif OutputSectoring=0
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

	SPLK 	#0,FLADR+1
	SPLK 	#0,FLADR
	LACC 	IZNUMREC
	BCND 	NotFirst,NEQ
	SACL 	FLADR	;надо записать адрес начала нулевого измерения

	SPLK 	#080h,TMP  ;измерения начинаются с адреса 0x001000h
	CALL 	FLPROG     ;младший байт записали
	SPLK 	#000h,TMP  ;измерения начинаются с адреса 0x001000h
	CALL 	FLPROG     ;старший байт записали
	B FirstCompiled
NotFirst
	LACC 	IZNUMREC,1
	ADD	#1,1
	SACL 	FLADR     ;надо записать адрес окончания измерения
FirstCompiled

	LACC 	CountWrite
	BCND 	NoDataWrited,EQ

	LACC 	IZFLLSB,11
	SACH 	TMP
	LACC 	TMP
	ADD  	IZFLMSB,11
	ADD  	#1         ;прибавляем единичку,
			;чтобы границы не перекрывались
	SACL 	TMP
	B 	PresentDataWrited
NoDataWrited
	LACC 	IZFLLSB,11
	SACH 	TMP
	LACC 	TMP
	ADD  	IZFLMSB,11
	;единичку прибавлять не будем, потому что нет данных
	SACL 	TMP
PresentDataWrited
	LACC	NoWritePlace	;есть место во флеш ?
	BCND	Yes_It_Is,EQ	;да, место есть!
	SPLK	#0FFFEh,TMP
Yes_It_Is:
	CALL 	FLPROG     ;младший байт записали
	LACC 	TMP,8
	SACH 	TMP

	CALL 	FLPROG     ;старший байт записали
;надо записать результаты измерения
	LACC 	IZNUMREC,3 ;в таблице 8 элементов
	ADD  	#0800h     ;смещение во flash
	SACL 	FLADR

	MAR  	*,AR1      	;modify auxiliary register
				;данная команда из подмножества LARP 1
				;т.е. при дальнейшей записи индексом AR1
	LAR  	AR1,#TimeOfBeginMeas

	LACC	*
	SACL 	TMP
	CALL 	FLPROG     ;количество секунд записали

	MAR  	*,AR1      	;modify auxiliary register
				;данная команда из подмножества LARP 1
				;т.е. при дальнейшей записи индексом AR1
	LAR  	AR1,#TimeOfBeginMeas+1

	LACC	*
	SACL 	TMP
	CALL 	FLPROG     ;количество минут записали

	MAR  	*,AR1      	;modify auxiliary register
				;данная команда из подмножества LARP 1
				;т.е. при дальнейшей записи индексом AR1
	LAR  	AR1,#TimeOfBeginMeas+2

	LACC 	*+		;количество часов

;	SACL 	TMP

	CALL	ConvertBCD2BIN_

	MAR  	*,AR1


	SPM  	#0              ;Set P Register Output Shift Mode
				;multiplier output is left-shifted one place
;	LAR	AR1,#TimeOfBeginMeas+3
	LT      *
	MPY     #24
	APAC			;складываем результат с содержимым аккумулятора

	CALL	ConvertBIN2BCD
	SACL	TMP


	CALL 	FLPROG     	;количество часов записали
****************************

	SPM	#0
	LACC	SistolPressure
	ADD	#4000h,1
	SACL	TMP
	SPLK	#320,TMP+1

	LT      TMP
	MPYU    TMP+1
	PAC

	SACH 	TMP 		;систолическое давление
	LACC	TMP
	SUB	#48		;истинное значение минус 48
	SACL	TMP
	CALL FLPROG
*****************************
*	LACC AFLLSB
*	ADD  #1
*	SACL AFLLSB     ;адрес увеличили на 1

	SPM	#0
	LACC	AveragePressure		;среднее давление
	ADD	#4000h,1
	SACL	TMP
	SPLK	#320,TMP+1

	LT      TMP
	MPYU    TMP+1
	PAC

	SACH 	TMP 			;среднее давление
	LACC	TMP
	SUB	#48			;истинное значение минус 48
	SACL	TMP
	CALL 	FLPROG

*	SPLK #70,TMP ;среднее давление
*	CALL FLPROG
*****************************


*	LACC AFLLSB
*	ADD  #1
*	SACL AFLLSB     ;адрес увеличили на 1

	SPM	#0
	LACC	DiastolPressure
	ADD	#4000h,1
	SACL	TMP
	SPLK	#320,TMP+1

	LT      TMP
	MPYU    TMP+1
	PAC

	SACH 	TMP 		;диастолическое давление
	CALL FLPROG
*****************************

*	LACC AFLLSB
*	ADD  #1
*	SACL AFLLSB     ;адрес увеличили на 1


**********************************************
* AveragePeriod (период сердечных сокращений умноженный на 16)
* вычисляем частоту f=60 сек * 100 (част дискр) * 16 / AveragePeriod
	LAR	AR2,#TMP+3
	LAR	AR3,#AveragePeriod
	MAR	*,AR2
	LACC	#6000
	SACL	*,AR3

*       ARP  = AR3
*       AR2  - Указывает на числитель
*       AR3  - Указывает на знаменаталь (AR3 - "Активан")
*	AR2/AR3

	CALL	Division

*	SPLK #60,TMP ;частота сердечных сокращений
	SACH	TMP,4
	CALL FLPROG
*	LACC AFLLSB
*	ADD  #1
*	SACL AFLLSB     ;адрес увеличили на 1

;        SPLK #0,TMP ;код ошибки (ее как бы нет :)
	LACC 	ErrMeas
	ADD	#ERRORS_TABLE
	TBLR 	TMP
	CALL 	FLPROG
*****************************

 .if VersionFerrum=1		;без дешифратора

 .elseif VersionFerrum=2        ;с дешифратором
*******
* сбрасываем кэш во флеш
*******
	CALL	Clear_cashe
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif


NeChet1
	SPLK 	#0,CountWrite ;
	SPLK 	#0,MayToWrite
	RET
**** отладка

;HourTable .word 0,0024H,0048H,0072H,0096H


MakeValue

** вычисляем номер записи во флеш и
** свободное место для записи результатов вычислений
**
	LACC MayToWrite
	BCND YesWeWrite,NEQ
	CLRC SXM
;первоначальное обнуление
	SPLK #0,CountWrite ;пока ничего не записали
*	SPLK #0,BeginLevel
*	SPLK #0,BeginLevel+1

	CALL	GetFlashCount
	SACL	IZNUMREC
	SUB  	#256      ;это последняя запись в таблице?
	BCND 	LastPlace,NEQ
NoPlace
;установить признаки нехватки места
	SPLK #0100h,IZNUMREC
	SPLK #1,MayToWrite  ;можно писать во флеш
	RET
NoPlaceFlash:
	SPLK	#1,NoWritePlace	;нет места во флеш
	SPLK 	#1,MayToWrite  ;можно писать во флеш - нельзя
	RET
LastPlace
	LACC 	TMP+2
	BCND FirstRec,EQ ;это одновременно и последняя и первая запись :)
;сначала надо проверить, есть ли место во flash
; #0FFFEh - это признак последней записи в TMP+1
	LACC 	TMP+1
	XOR 	#0FFFEh
	BCND 	NoPlaceFlash,EQ ;если нет места во flash
	SPLK	#0,NoWritePlace
	LACC 	TMP+1,5
ToRecBegin
	SACL 	IZFLLSB
	SACH 	IZFLMSB    ;адрес запомнили (абсолютный)
			;номер текущей записи есть в IZNUMREC
	SPLK #1,MayToWrite  ;можно писать во флеш
	RET
FirstRec
	LACC #01000h
	B ToRecBegin


YesWeWrite
*** отладка
;//        BIT  CNTMOD,15
;//        BCND NeChet,TC
	CLRC SXM
	LACC IZNUMREC
	SUB #256
	BCND NeChet,EQ ;не пишем, если не было разрешения
	LACC	NoWritePlace  ;есть ли место во флеш?
	BCND NeChet,NEQ		;нет места :(

	LACC CountWrite ;сколько байтов записали во флеш
 .if OutputSectoring=1
 .elseif OutputSectoring=0
	BCND AlreadyWrite,NEQ
	LACC IZFLLSB
	ADD  IZFLMSB,16
	ADD #0880h     ;прибавляем первоначальное смещение для параметров
	SACL IZFLLSB
	SACH IZFLMSB    ;адрес запомнили (абсолютный)
	LACC CountWrite ;сколько байтов записали во флеш
AlreadyWrite
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif

	ADD #1
	SACL CountWrite
	LACC IZFLLSB
        ADD  IZFLMSB,16
*        SACH AFLMSB,1  ;запоминаем старшую часть адреса
*        OR   #8000h
*        SACL AFLLSB    ;запоминаем младшую часть адреса
	SACH 	FLADR+1,1  ;запоминаем старшую часть адреса
	SACL 	FLADR    ;запоминаем младшую часть адреса

        LACC IZFLLSB,11
	SACH TMP
	LACC TMP
        ADD  IZFLMSB,11
        XOR  #0FFFEh
        BCND NeChet,EQ ;не пишем, место кончилось

 .if ModeOutput=2

        BIT Jobs,11
        BCND NormailWrite1,NTC
        LACC Jobs
        AND  #0FFEFH
	SACL Jobs      ;сбрасываем бит записи в канал значения ЦАП
        WriteParams 12 ;пишем с первого канала после фильтра (один байт)
        WriteParams 00 ;пишем 0 (индикатор, что в след слове - ступенька)
        WriteParams 41 ;пишем значение DAC2

        B NotNormalWrite1

NormailWrite1
	WriteParams 10
        WriteParams 12 ;пишем с первого канала после фильтра (один байт)
	WriteParams 32 ;пишем сумарный сигнал(два байта)
*        WriteParams 31 ;пишем с усиленного канала с АЦП (два байта)
        WriteParams 42 ;пишем значение обмерянное с ЦАП

NotNormalWrite1

	LACC  	IZFLMSB,16
	OR 	IZFLLSB
	ADD  #5
        SACL IZFLLSB
        SACH IZFLMSB
 .elseif ModeOutput=1
        BIT Jobs,11
        BCND NormailWrite2,NTC
        LACC Jobs
        AND  #0FFEFH
        SACL Jobs      ;сбрасываем бит записи в канал значения ЦАП
;        WriteParams 12 ;пишем с первого канала после фильтра (один байт)
        WriteParams 32 ;пишем с усиленного канала с фильтра (два байта)
;	WriteParams 21 ;пишем со второго канала с АЦП (два байта)
;	WriteParams 00 ;пишем 0 (индикатор, что ЦАП подстроился)
	B NotNormailWrite2

NormailWrite2
;        WriteParams 12 ;пишем с первого канала после фильтра (один байт)
	WriteParams 32 ;пишем с усиленного канала с фильтра (два байта)
;        WriteParams 21 ;пишем со второго канала с АЦП (два байта)

NotNormailWrite2
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
        BIT Jobs,11
        BCND NormailWrite3,NTC
        LACC Jobs
        AND  #0FFEFH
        SACL Jobs      ;сбрасываем бит записи в канал значения ЦАП
;        WriteParams 12 ;пишем с первого канала после фильтра (один байт)
        WriteParams 00 ;пишем 0 (индикатор, что ЦАП подстроился)
        B NotNormailWrite3

NormailWrite3
;        WriteParams 12 ;пишем с первого канала после фильтра (один байт)
        WriteParams 21 ;пишем со второго канала с АЦП (два байта)
;        WriteParams 33 ;пишем с усиленного канала с АЦП (два байта)

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
;//запись первой таблицы
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

;//запись второй таблицы
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

	LACC IZFLLSB,11
	SACH TMP
	LACC TMP
	ADD  IZFLMSB,11
	XOR  #0FFFEh
	BCND NeChetSectoring,EQ ;не пишем, место кончилось

	LACC CountWrite ;сколько байтов записали во флеш
	ADD #1
	SACL CountWrite

	;выравнивание на границу 32 байт
	;6 байт в конце (3 слова длины массивов)
	;первый массив длиной StepNumber*8 байт
	;второй массив длиной (MaxNumber+MaxNumberShift)*2 байта
** на всякий случай :)
	LACC	StepNumber
	AND	#01Fh		;максимум 32 байта
	SACL	TMP+3

	LACC	MaxNumber
	ADD	MaxNumberShift
** на всякий случай :)
	AND	#0FFh		;максимум 256 байт
	SACL	TMP+4

	LACC	TMP+3,3
	ADD	#001,3
	ADD	TMP+4,1
	ADD	#001,1
	ADD	#6

	NEG
	AND	#01Fh
	ADD	#020h
	SACL	TMP

	LACC 	IZFLLSB
	AND	#0FFE0h
	ADD  	IZFLMSB,16

	ADD	TMP
	SACL	IZFLLSB
	SACH	IZFLMSB



*	SACH AFLMSB,1  ;запоминаем старшую часть адреса
*	OR   #8000h
*	SACL AFLLSB    ;запоминаем младшую часть адреса
	SACH 	FLADR+1,1  ;запоминаем старшую часть адреса
	AND   	#07FFFh
	SACL 	FLADR    ;запоминаем младшую часть адреса




	SPLK	#0,TMP+2		;начинаем с нуля

AgainSaveMassiv1
******
	LAR	AR0,TMP+2
	LAR	AR4,#StartMeasAdress
	MAR     *,AR4
	MAR     *0+			;AR4 = & StartMeasAdress[i]

	LACC	*
	SACL	TMP			;сохраняем младшую часть
	CALL 	FLPROG
	mIncAddressToFlash

	MAR	*,AR4
	LACC	*,8
	SACH	TMP			;сохраняем старшую часть
	CALL 	FLPROG
	mIncAddressToFlash
******
	LAR	AR0,TMP+2
	LAR	AR4,#FinishMeasAdress
	MAR     *,AR4
	MAR     *0+			;AR4 = & StartMeasAdress[i]

	LACC	*
	SACL	TMP			;сохраняем младшую часть
	CALL 	FLPROG
	mIncAddressToFlash

	MAR	*,AR4
	LACC	*,8
	SACH	TMP			;сохраняем старшую часть
	CALL 	FLPROG
	mIncAddressToFlash
******
	LAR	AR0,TMP+2
	LAR	AR4,#AvrPress
	MAR     *,AR4
	MAR     *0+			;AR4 = & StartMeasAdress[i]

	LACC	*
	ADD	#4000h,1
	SACL	TMP			;сохраняем младшую часть
	CALL 	FLPROG
	mIncAddressToFlash

	MAR	*,AR4
	LACC	*,8
	ADD	#4000h,1+8
	SACH	TMP			;сохраняем старшую часть
	CALL 	FLPROG
	mIncAddressToFlash
******
	LAR	AR0,TMP+2
	LAR	AR4,#AverageAmplitude
	MAR     *,AR4
	MAR     *0+			;AR4 = & StartMeasAdress[i]

	LACC	*
	SACL	TMP			;сохраняем младшую часть
	CALL 	FLPROG
	mIncAddressToFlash

	MAR	*,AR4
	LACC	*,8
	SACH	TMP			;сохраняем старшую часть
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

* первый массив записали
******************


	SPLK	#0,TMP+2		;начинаем с нуля

AgainSaveMassiv2
	LAR	AR0,TMP+2
	LAR	AR4,#Diff2MaxAdressFinish
	MAR     *,AR4
	MAR     *0+			;AR4 = & Diff2MaxAdressFinish[i]

	LACC	*
	SACL	TMP			;сохраняем младшую часть
	CALL 	FLPROG
	mIncAddressToFlash

	MAR	*,AR4
	LACC	*,8
	SACH	TMP			;сохраняем старшую часть
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
* сколько измерений во флеш?
* возвращает результат в ACC (и в TMP+2)
; есть ли место во flash
; #0FFFEh - это признак последней записи в TMP+1
* use tmp,tmp+1,tmp+2
**************
GetFlashCount
	LACC	#0		;читаем флеш по данному адресу
	SACL	FLADR
	SACL	FLADR+1


	SACL 	TMP+2
	SACL	TMP


AgainFindZapis
	LACC TMP
	SACL TMP+1
	CALL	FLREAD
	SACL	TMP

	CALL	FLREAD
	SACL	*		;запоминаем в стеке
	LACC	TMP
	ADD	*,8
	SACL 	TMP
	XOR  	#0FFFFh
	BCND 	PoslednyaaZapis,EQ
	LACC 	TMP+2
	ADD  	#1
	SACL 	TMP+2
	SUB  	#256      ;это последняя запись в таблице?
	BCND 	AgainFindZapis,NEQ
;все, больше места нет, последняя запись
*NoPlaceZapis
;установить признаки нехватки места
	SPLK 	#0100h,TMP+2
*нашли последнюю запись
PoslednyaaZapis
	LACC	TMP+2
	BCND	PoslednyaaZapis1,EQ
	SUB	#1
	SACL	TMP+2
PoslednyaaZapis1
	RET
***********************
* получить запись из флеш
* ACC - номер записи
* возврат восьми байт в TMP
* use tmp,tmp+1,..,tmp+7
***********************

GetRecordFlash
	MAR     *,AR7
	POPD	*-
	SAR     AR6,*-
	SAR	AR0,*-


	SACL	FLADR
	LACC	FLADR,3
	ADD  	#0800h     ;смещение во flash таблицы результатов
	SACL	FLADR
	SPLK	#0,FLADR+1

	LAR	AR0,#7
	LAR	AR1,#TMP
GetRec_1
	CALL    FLREAD
	MAR	*,AR1
	SACL	*+,0,AR0
	BANZ    GetRec_1,*-,AR1      ;Branch on Auxiliary Register Not Zero


	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR0,*+
	LAR     AR6,*+
	PSHD	*
	RET

*
;включать процедуру программирования через последовательный порт
 .if SerialProg=1
*************************************************************************
* копирование области программы из программной флеш, в програмную память
*************************************************************************
	.ref Lenfl_clr
	.ref Lenfl_ers
	.ref Lenfl_wrt,Lenfl_prg
	.ref LenDLY,LenREGS,LenARRAY
CopyCodeToRam
	LAR  	AR1,#00800h  	;переписывание программы
	MAR	*,AR1
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
				;this space are hardcoded in SVAR2X.H,  *
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
BeginOfBlock	.set	$
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
***********First clear flash ************
ers_loop:
	CALL    GCLR            ;Clear flash.
	LACL    ERROR           ;Check for CLEAR/ERASE error
	BCND    ers_error,neq   ;If error, then hard fail.
***********Next erase flash ************
	CALL    GERS            ;Erase flash.
	LACL    ERROR           ;Check for CLEAR/ERASE error
	BCND    depletion,neq   ;If error, then try Flash-write.
        B       ers_done        ;Else, no errors erasing.
depletion:
	LACL    ERS_COUNT       ;Get erase fail count.
        ADD     #1              ;Increment fail count.
        SACL    ERS_COUNT       ;Save new count.
        SUB     #10             ;CHECK for max of 10.
        BCND    ers_error,GT    ;If ers_cout>10 then hard fail.
        CALL    FLWS            ;Else, try to recover from depletion.
        LACL    ERROR           ;Check for FLASH-WRITE error.
        BCND    ers_error,neq   ;If couldn't recover, then hard fail.
        B       ers_loop        ;Else, Try erase again.

ers_error:
*******************************************************************
** If here then an unrecoverable error has occured during erase. **
** In an actual application, the system takes some action to     **
** indicate that service is required.                            **
*******************************************************************
        B       ers_error       ;Error while erasing.

ers_done:
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
	LDP     #4		;у нас другая страница памяти :)
	LAR	AR1,#0		;начальный адрес программирования

	LACC    #1Fh,1		;#1F0000h адрес для зашивки
	SACL	FLADR+1		;начальный адрес во флеш
	SPLK	#0,FLADR
Save_Next_Block
	LAR     AR6, #0c00h     ;Using last 3K of SARAM as buffer.
	CALL	Read_512	;читаем 256 слов (512 байт)


	CALL	PROGRAM_BLOCK	;программируем

	LDP     #4		;у нас другая страница памяти :)
	SAR	AR1,*
	LACC	*
	ADD	#100h
	SACL	*
	SUB	#4000h
	BCND	prg_done,GEQ
	LAR	AR1,*

	;увеличиваем адрес чтения из флеш
	LACC 	FLADR
	AND	#07FFFh
	ADD  	#200H		;плюс 512
	SACL 	FLADR
	BIT	FLADR,0
	BCND 	Progr_Flash_NoOver,NTC
	AND  	#07FFFh
	SACL	FLADR
	LACC 	FLADR+1
	ADD  	#1
	SACL 	FLADR+1
Progr_Flash_NoOver

	B	Save_Next_Block

*******************************************************************
** Now that the data to be programmed is ready, the programming  **
** algorithm is invoked. Note that four parameters must be       **
** initialized before calling the algorithm.                     **
*******************************************************************

PROGRAM_BLOCK
	MAR	*,AR7
	POPD	*-
	SAR     AR1,*-
	SAR     AR0,*-

	LDP     #SEG_PARMS
**********Put parameters where they belong.**********
	splk    #0ff00h,PROTECT
	splk    #00c00h,PRG_bufaddr
*	splk    #00000h,PRG_paddr
	SAR	AR1,PRG_paddr		;адрес для программирования храниться здесь

	splk    #00100h,PRG_length
***********Next program flash ************
	CALL    GPGMJ           ;Program flash from buffer.
	LACL    ERROR           ;Check for program error.
	BCND    prg_error,neq   ;If error then clear ACC.

	MAR	*,AR7
	MAR	*+,AR7
	LAR     AR0,*+
	LAR     AR1,*+
	PSHD	*
	RET
*	B       prg_done        ;Else, No errors programming.

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
 .if VersionFerrum=1		;без дешифратора
*******
* чтение страницы
*  адрес для чтения, из него выбрать адрес страницы
*  ASFLMSB     15-20bit
*  AFLLSB      0-14bit
*	AR6 - куда загружать
*
Read_512

	mRead_512b

 .elseif VersionFerrum=2        ;с дешифратором
*******
* чтение страницы
*  адрес для чтения, из него выбрать адрес страницы
*  ASFLMSB     15-20bit
*  AFLLSB      0-14bit
*	AR6 - куда загружать
*
*  PA11-0 - адрес страницы
*  BA9-0  - адрес байта внутри страницы
*  X      - неважно что
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


LenPrgAlgor	.set	$-BeginPrgAlgor

 .elseif SerialProg=0
 .else
  .emsg _ERROR __ MISSING PARAMETER_
 .endif
