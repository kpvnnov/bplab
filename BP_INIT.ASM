

INIT    SETC INTM               ;запрет прерываний
        LDP  #4                 ;load data memory page pointer

        SPLK #02E04h,TMP        ;02E06H->[TMP] (store parallel long immediate)
                                ;ARP(15-13),OV,OVM,1,INTM,DP(8-0)
        LST  #0,TMP             ;       001, 0,  1,1,   1,000000110h


        SPLK #025FCh,TMP        ;025FCH->[TMP] (store parallel long immediate)
                                ;ARB(15-13),CNF,TC,SXM,C,1,1,1,1,XF,1,1,PM(1-0)
        LST  #1,TMP             ;       001,  0, 0,  1,0,1,1,1,1, 1,1,1,00

*
*
        LACC    #0              ;ZERO TO ALL DATE
        LAR     AR1,#060h
        RPT     #01Fh
        SACL    *+,AR1          ;0060h-007Fh
        LAR     AR1,#200h
        SPLK    #01FFh,TMP
        RPT     TMP
        SACL    *+,AR1          ;0200h-03FFh
        LAR     AR1,#1000h      ;!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        SPLK    #0FFFh,TMP
        RPT     TMP
        SACL    *+,AR1          ;0800h-17FFh

        SPLK    #0,SampleNumber
;        SPLK    #100,AnalysisStart
;        SPLK    #80,AnalysisInterval
	SPLK    #32,AnalysisInterval
	LACC 	AnalysisInterval
        ADD  	#DIFF_BASIS*2
        SACL 	AnalysisStart

;      FirstMeasFlag = TRUE;

	SPLK	#B0_5mm,SistolPressureAmplitude
	LACC	MeasurementFlags,0
	OR	#(1<<FIRST_MEAS_FLAG)
	SACL  	MeasurementFlags,0
