;&D


INIT    SETC INTM               ;запрет прерываний
        LDP  #4                 ;load data memory page pointer

        SPLK #04E04h,TMP        ;02E06H->[TMP] (store parallel long immediate)
                                ;ARP(15-13),OV,OVM,1,INTM,DP(8-0)
        LST  #0,TMP             ;       001, 0,  1,1,   1,000000110h


        SPLK #025FCh,TMP        ;025FCH->[TMP] (store parallel long immediate)
                                ;ARB(15-13),CNF,TC,SXM,C,1,1,1,1,XF,1,1,PM(1-0)
        LST  #1,TMP             ;       001,  0, 0,  1,0,1,1,1,1, 1,1,1,00

*
*
	mar	*,ar2
        LACC    #0              ;ZERO TO ALL DATE
        LAR     AR2,#060h
        RPT     #01Fh
        SACL    *+,AR2          ;0060h-007Fh
        LAR     AR2,#200h
        SPLK    #01FFh,TMP
        RPT     TMP
        SACL    *+,AR2          ;0200h-03FFh
        LAR     AR2,#1000h      ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        SPLK    #0FFFh,TMP
        RPT     TMP
        SACL    *+,AR2          ;0800h-17FFh

;      FirstMeasFlag = TRUE;

	SPLK	#B0_5mm*2,_SistolPressureAmplitude
	LACC	_MeasurementFlags,0
	OR	#(1<<FIRST_MEAS_FLAG)
	SACL  	_MeasurementFlags,0

	SPLK	#PULSE_FREQ_EVALUATION_40,_Mode

	LAR	AR1,#0800h
