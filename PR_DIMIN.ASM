;***********************************************************************
; $Id: PR_DIMIN.ASM,v 1.6 2001-08-22 14:17:43 peter Exp $
;*       Pressure_diminution() - Процесс понижения давлени на 8 мм.рт.ст.
;*       При переключении в этот режим:
;*       1. выключить клапан !
;*       2. Определить давление включения клапана ( NewPressure )
;*   	 3. SubroutMode = 0;
;***********************************************************************/
;Pressure_diminution()

Pressure_diminution

;{

        MAR     *,AR2
        LAR     AR0,SampleNumber
        LAR     AR2,#Signal
        MAR     *0+,AR2

; switch ( SubroutMode )
; {

        LACC    SubroutMode
        BCND    Pr_dimin_case1,NEQ

;  case 0:
;    if ( Signal[SampleNumber] < NewPressure )

        LACC    *,0,AR2
        SUB     NewPressure
        RETC    GEQ

;    {
;            Valve_on();

        mValve_on

;            SubroutMode = 1;

        SPLK    #1,SubroutMode

;            ModeCnt = VALVE_CLOSE;

        SPLK    #VALVE_CLOSE,ModeCnt

;    }
;    break;

        RET

Pr_dimin_case1

        SUB     #1
        BCND    Pr_dimin_case2,NEQ

;  case 1:
;    if ( ModeCnt-- <= 0 )

        LACC    ModeCnt,0
        SUB     #1
        SACL    ModeCnt
	RETC    GT

;    {
;            Valve_hold();

        mValve_hold

;            SubroutMode = 2;

        SPLK    #2,SubroutMode

;    }
;    break;

        RET

Pr_dimin_case2

;  case 2:
;    if ( Signal[SampleNumber] > Signal[SampleNumber-1] )

        LACC    *-,0,AR2
        SUB     *
        RETC    LEQ

;    {
;            /*      Подготовка к следующему режиму */
;            Mode = PRESSURE_MEASUREMENT;

 .if Sertificarion=1
        SPLK    #PRESSURE_MEASUREMENT_MANUAL,Mode
 .else
        SPLK    #PRESSURE_MEASUREMENT,Mode
 .endif



;            SampleNumberShift = SampleNumberShift + SampleNumber+1;

        LACC    SampleNumberShift
        ADD     SampleNumber
        ADD     #1
        SACL    SampleNumberShift

;            SampleNumber = -1;

        SPLK    #0FFFFh,SampleNumber

;            AnalysisStart = AnalysisInterval + TIME_OUT;

        LACC    AnalysisInterval,15
	ADD     #TIME_OUT,15
        SACH    AnalysisStart,1

;	StartMeasAdress[StepNumber] = SampleNumberShift;

	LAR	AR0,StepNumber
	LAR	AR2,#StartMeasAdress
	MAR	*0+,AR2
	LACC	SampleNumberShift
	SACL	*,0,AR2

;      MeasurementFlags = MeasurementFlags | (1<<FIRST_IMPULSE_FLAG)

	LACC	MeasurementFlags
	OR	#(1<<FIRST_IMPULSE_FLAG)
	SACL    MeasurementFlags

;    }
;    break;

        RET

; }
;}

