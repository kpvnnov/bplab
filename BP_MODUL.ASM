;&D

PRD     .equ    025h
TCR     .equ    026h

TwoChanel       .set	0
WriteDebug	.set	0
NotCheck280mm   .set    0
Emulator  	.set    0
DisableDisplay  .set    0
PsevdoEKG 	.set    0
VersionFerrum   .set    1
Sertificarion   .set    0

        .copy   bp206sec.asm
        .copy   bp206def.asm
        .copy   bp206bss.asm


        .text

        .copy BP_init.asm
	CALL	Pul_f_e_init_2
	SPLK	#0D45h,TmpAddress
        IN      DimStopAddress,1

        LDP     #0
        SPLK    #0FFFFh,PRD
        LDP     #4

Next_Sample

        LDP     #0
        SPLK    #0C20h,TCR
        LDP     #4

	LACC	_SampleNumber
	ADD	_SampleNumberShift
	SUB	TmpAddress
	BCND	Not_tmp_address,NEQ
	NOP
Not_tmp_address:

        MAR     *,AR2
        LAR     AR2,#SR30+14
	RPT	#14
	DMOV	*-,AR2
        LAR     AR2,#Signal
        LAR     AR0,_SampleNumber
        MAR     *0+,AR2
        IN      *,0,AR2
	LACC	*,0,AR2
        LAR     AR2,#SR30
	SACL	*
	ADD	#4000h,1
	SACL	CurrPressure

;	if (((MeasurementFlags )&( 1<<DIM_PRESSURE_FLAG )) != 0 );
;         // { Pressure_diminition_2(); }
;	  { if (( SampleNumber + SampleNumberShift ) == DimStopAddress)}
;	      { MeasurementFlags = MeasurementFlags &(~(1<<DIM_PRESSURE_FLAG));
;
;	      }
;	  }
	BIT	_MeasurementFlags,15-DIM_PRESSURE_FLAG
	BCND 	Nodim,NTC
;;	;;CALL	Pressure_diminition_2
	LACC	_SampleNumberShift
	ADD	_SampleNumber
	SUB     #8
	SUB	DimStopAddress
	BCND 	Nodim,NEQ
	LACC	_MeasurementFlags
	AND	#(~(1<<DIM_PRESSURE_FLAG))
	SACL    _MeasurementFlags
        IN      DimStopAddress,1
Nodim:

        CALL    ADC_value_processing

        LACC    _Mode,2
        ADD     #Mode_branch
        BACC

Mode_branch

        CALL    Pulse_frequency_evaluation_40
        B       End_mode

        CALL    Pressure_augment_80
        B       End_mode

        CALL    Pulse_frequency_evaluation_80
        B       End_mode

        CALL    Pressure_augment
        B       End_mode

        CALL    Pressure_augment_stop
        B       End_mode

        CALL    Check_higher_sistol_pressure
        B       End_mode

        CALL    Pressure_measurement
        B       End_mode

        CALL    Pressure_diminution_1
        B       End_mode

End_mode

        B       Next_Sample

******************************************
        .copy   bp206mac.asm

Pul_f_e_init_2:
	mMeasurement_init
	SPLK	#0+2*B10mm+B4mm,PressureTop
	;SPLK	#0-B10mm,PressureTop
	MAR	*,AR2
	LAR	AR2,#MayModify+1
	SPLK	#0A5h,*
	ret

        .copy   ADC_v_p5.asm

        .copy   Pul_f_e.asm

        .copy   Pressaug.asm

        .copy   Ch_pr_hs.asm

        .copy   Pr_a_t40.asm

        .copy   Pr_a_stp.asm

        .copy   Press_m.asm


******************************************

        .copy   Max_anal.asm

        .copy   Trend.asm

        .copy   Procedur.asm

        .copy   Division.asm

        .copy   Pr_dim1.asm

        .copy   Pr_dim2.asm

        .copy   bptable.asm
        .end
