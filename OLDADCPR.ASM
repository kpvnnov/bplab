* запись     	чтение
* 1.DAC1     	мусор
* 2.PR1      	DAC1 	(AIN8 - бывший PR2)
* 3.PR3      	PR1  	(AIN7 - усиленный сигнал)
* 4.PR0   	PR3     (AIN9 - второй канал,в дальнейшем лишний)
* 5.Vref-    	PR0     (AIN6 - первый канал давления)
* 6.Vref+    	Vref-
* 7.PowerDown  	Vref+
* 8.ЦАП      	результат PowerDown

ADCPRO
	SPM  	#1              ;Set P Register Output Shift Mode
				;multiplier output is left-shifted one place

	SPLK 	#SSPS,TMP    ;SSP start
	OUT  	TMP,SSPCR    ;Synchronous Serial Port Control Register
	IN   	TMP,SDTR     ;команда лишнего чтения
				;для стабильности(надежности) работы с SSP

	SPLK 	#00D00h,TMP  ;AIN0(PL0),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.первое слово для передачи(PL0)

	SPLK 	#01D00h,TMP  ;AIN1(PL1),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.первое слово для передачи(PL1)

	SPLK 	#02D00h,TMP  ;AIN1(PL2),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.первое слово для передачи(PL1)

	SPLK 	#03D00h,TMP  ;AIN1(PL3),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.первое слово для передачи(PL1)

	SPLK 	#04D00h,TMP  ;AIN1(PL4),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.первое слово для передачи(PL1)

	SPLK 	#05D00h,TMP  ;AIN1(PL5),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.первое слово для передачи(PL1)

	SPLK 	#0AD00h,TMP  ;AIN10(VREF),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.первое слово для передачи(VREF)



	SPLK 	#08D00h,TMP  ;AIN8(DAC2),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;1.первое слово для передачи(PR0)

	mImp_ssp              ;подгоняем SSP к началу передачи MSB
	mImp_ssp
	mImp_ssp


	mOnADC			;включаем выборку АЦП
	mOutDIOSR		;записываем выборку устройств в регистр вывода

	SPLK 	#07D00h,TMP  ;AIN7(PR1),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;2.второе слово для передачи (PR1)

	CALL 	CLKXF           ;1-передаем первое слово

	SETC 	SXM
	LAR  	AR3,#SR30  	;Адреса начала сдвиг.рег.ФНЧ
	LAR  	AR4,#SR30+15    ;Адреса конца сдвиг.рег.ФНЧ
	MAR     *,AR3

	SPLK 	#09D00h,TMP  ;AIN9(PR3),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;3.третье слово для передачи (PR3)

	RPT  	#30             ;задержка для A/D conversion
	NOP                     ;(N+2)*1542.5347(2)~~50mks

	CALL 	CLKXF           ;2-передаем второе слово
	IN   	TMP,SDTR     ;(1)чтение первого результата (мусор)

	SPLK 	#06D00h,TMP  ;AIN6(PR0),16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;4.четвертое слово для передачи (PR0)

	RPT  	#40             ;задержка для A/D conversion
	NOP

	CALL 	CLKXF           ;3-передаем третье слово

	IN   	TMP,SDTR    	;(2)чтение второго результата (DAC1)
	BIT  	Jobs,10   	;записать значение ЦАП в ячейку для обсчета?
	BCND 	NotWriteFromDAC,NTC
	ClearReadDAC
	LACC 	TMP
	ADD  	#Ppa1_prog,0   	;DAC1n+Ppa1_prog
	SACL 	DAC2
NotWriteFromDAC

	SPLK 	#0CC00h,TMP  ;Vref-,16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;5.пятое слово для передачи

	RPT  	#30             ;задержка для A/D conversion
	NOP

	CALL 	CLKXF           ;4-передаем четвертое слово (DAC1)
	IN   	TMP+1,SDTR   ;(3)чтение третьего результата (PR1)

	;k1=100/3.9 коэффициент усиления операционного усилителя
	;Ppa1_prog=160/k1=32768/k1 - половина значения шкалы (5мм рт.ст.)
	;                            после усилителя
	;Pr2n=(DAC1n+Ppa1_prog)*(k1/(1+k1))+Ppa1n/k1-Ppa1_prog
	;полное значение (16 разрядов) сигнала, где
	; DAC1n - значение на выходе ЦАП
	; Ppa1n - значение на выходе усилителя
	;
	MAC  	Const1,DAC2 	;Const1* DAC2= "(32768*k1/(1+k1))"*
				;* "(значение на выходе ЦАП+Ppa1_prog)"->P
	LACC 	#0
	MAC  	Const2,TMP+1 ;Const2*(TMP+1)= "1/k1=(3.9/100)*32768"*
				;*(значение усиленного канала)
	APAC
	SUB 	#Ppa1_progMul2,15 ;на 16 сдвигать нельзя
	SACH 	*,0,AR4
	CALL 	FILTER          ;FILTER

	SPLK 	#0DC00h,TMP	;Vref+,16 bit,MSB first,bipolar
	OUT  	TMP,SDTR     ;6.шестое слово для передачи


	RPT  	#30             ;задержка для A/D conversion
	NOP                     ;(N+2)*1542.5347(2)~~50mks

	CALL 	CLKXF           ;5-передаем пятое слово (Vref-)
	IN   	Channel_two,SDTR ;(4)чтение четвертого результата (PR2)

	SPLK 	#0EC00h,TMP  ;software power down
	OUT  	TMP,SDTR     ;7.седьмое слово для передачи

* вывод значения в ЦАП
	BIT  	Jobs,12    	;будем подгонять ЦАП ?
	BCND 	DACC,TC    	; будем обязательно

	LACC 	TMP+1
	ADD  	#4000h,1
	SUB  	#0800h
	BCND 	DACC,LEQ
	SUB  	#0D0h,8
	BCND 	OUTDAC,LEQ
DACC
	SendToDAC
	LACC 	Jobs
	OR   	#10h     	;надо загнать в ЦАП значение,и
				;установить сброс значения в канал
	SACL 	Jobs     	;устанавливаем флаг сброса значения ЦАП в канал

	;то, что нужно загонять в ЦАП
	;Ppa0n/k1+Ppa0n-Ppa1_prog
	;k1=100/3.9, 1/k1=0.039~~ 1/32+1/128=0.03906

	SETC 	SXM
	LACC	Channel_one,16
*	SUB	#1333*2,15    	;(-32768-x)-(-32768-x)*0.03906=-32768
				;чтобы не было переполнения ЦАП
				;не загонишь ниже нуля

*	BCND    VisheChemPorog,NOV	; переполнения небыло
*	LACC 	#0
*	B	DostigliKrishi
VisheChemPorog
	LACC 	Channel_one,10
	ADD  	Channel_one,5   ;+Ppa0n*(1/32)
	ADD  	Channel_one,3	;+Ppa0n*(1/128)
	ADD  	#4000h,11
	SUB  	#Ppa1_prog,10
	SACH 	DAC,2
	LACC 	#0FFCh,0
	AND  	DAC
DostigliKrishi
	SACL 	DAC

OUTDAC  OUT  	DAC,SDTR   	;8.передаем восьмое слово (для ЦАП)
*
	RPT  	#30             ;задержка для A/D conversion
	NOP                     ;(N+2)*1542.5347(2)~~50mks

	CALL 	CLKXF      	;6-передаем шестое слово(Vref+)

	RPT  	#30             ;задержка для A/D conversion
	NOP

	CALL 	CLKXF		;7-передаем седьмое слово
				;0EC00h АЦП в режим Power Down

	IN   	Channel_one,SDTR ;PR0->[Channel_one]
				;(5)чтение пятого результата (PR0)
	LACC    Channel_one
	ADD  	#4000h,1
	AND  	#0FFFFh
	SUB  	Preset0
	BCND 	No_minus,GEQ
	LACC 	#0
No_minus
	SACL 	CurrPressure



	mOffPeriph   		;выключаем всю периферию

	BIT  	Jobs,12    	;будем подгонять ЦАП ?
	BCND 	NotDAC,NTC 	;в ЦАП не надо загонять

	mOnDAC			;включаем выборку ЦАП

	ReadDAC
NotDAC
	mOutDIOSR		;записываем выборку устройств в регистр вывода

	LACC 	Jobs
	AND  	#0FFF7H
	SACL 	Jobs

	IN   	TMP,SDTR    	;(6)чтение шестого результата (Vref-)
	CLRC 	SXM             ;Проверка работы АЦП
	LACC 	TMP,0
	SETC 	SXM
	SUB  	#12,4
	BCND 	CONTA1,LT
	SPLK 	#rERROR_ADC,ErrMeas	;Ошибка в АЦП
	LACC 	DPA0,0
	AND  	#0FFE3h
	SACL 	DPA0
	OUT  	DPA0,PA0
;//!!!        SPLK #8,MODEPR
*
CONTA1  RPT  	#30             ;задержка для A/D conversion
	NOP                     ;(N+2)*1542.5347(2)~~50mks

	CALL 	CLKXF           ;8-передаем восьмое слово в ЦАП
	IN   	TMP,SDTR     ;(7)чтение седьмого результата
				;(Vref+)

	mOffPeriph   		;выключаем всю периферию
	mOutDIOSR		;записываем выборку устройств в регистр вывода


	CLRC 	SXM             ;Проверка работы АЦП
	LACC 	TMP,0
	SETC 	SXM
	SUB  	#0FEAh,4
*
	IN   	TMP,SDTR   	;(8)чтение восьмого результата
				;(мусор с ЦАПа)
*
	SPLK 	#SSPR,TMP    ;RESET SSP
	OUT  	TMP,SSPCR
	RETC 	GT              ;возврат если ACC>0 ?????
	SPLK 	#rERROR_ADC,ErrMeas	;Ошибка в АЦП
	LACC 	DPA0,0
	AND  	#0FFE3h
	SACL 	DPA0
	OUT  	DPA0,PA0
;//!!!        SPLK #8,MODEPR
	RET

