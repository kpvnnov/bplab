;&D
;***********************************************************************
; $Id: PR_DIMIN.ASM,v 1.8 2001-11-14 17:20:53 peter Exp $
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
        LAR     AR0,_SampleNumber
        LAR     AR2,#Signal
        MAR     *0+,AR2

; switch ( SubroutMode )
; {

        LACC    _SubroutMode
        BCND    Pr_dimin_case1,NEQ

;  case 0:
;    if ( Signal[SampleNumber] < NewPressure )

        LACC    *,0,AR2
        SUB     _NewPressure
        RETC    GEQ

;    {
;            Valve_on();

        mValve_on

;            SubroutMode = 1;

        SPLK    #1,_SubroutMode

;            ModeCnt = VALVE_CLOSE;

        SPLK    #VALVE_CLOSE,_ModeCnt

;    }
;    break;

        RET

Pr_dimin_case1

        SUB     #1
        BCND    Pr_dimin_case2,NEQ

;  case 1:
;    if ( ModeCnt-- <= 0 )

        LACC    _ModeCnt,0
        SUB     #1
        SACL    _ModeCnt
	RETC    GT

;    {
;            Valve_hold();

        mValve_hold

;            SubroutMode = 2;

        SPLK    #2,_SubroutMode

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
        SPLK    #PRESSURE_MEASUREMENT_MANUAL,_Mode
 .else
        SPLK    #PRESSURE_MEASUREMENT,_Mode
 .endif



;            SampleNumberShift = SampleNumberShift + SampleNumber+1;

        LACC    _SampleNumberShift
        ADD     _SampleNumber
        ADD     #1
        SACL    _SampleNumberShift

;            SampleNumber = -1;

        SPLK    #0FFFFh,_SampleNumber

;            AnalysisStart = AnalysisInterval + TIME_OUT;

        LACC    _AnalysisInterval,15
	ADD     #TIME_OUT,15
        SACH    _AnalysisStart,1

;	StartMeasAdress[StepNumber] = SampleNumberShift;

	LAR	AR0,_StepNumber
	LAR	AR2,#StartMeasAdress
	MAR	*0+,AR2
	LACC	_SampleNumberShift
	SACL	*,0,AR2

;      MeasurementFlags = MeasurementFlags | (1<<FIRST_IMPULSE_FLAG)

	LACC	_MeasurementFlags
	OR	#(1<<FIRST_IMPULSE_FLAG)
	SACL    _MeasurementFlags

;    }
;    break;

        RET

; }
;}

