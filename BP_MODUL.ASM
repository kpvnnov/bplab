
PRD     .equ    025h
TCR     .equ    026h

        .copy   bp206sec.asm
        .copy   bp206def.asm
        .copy   bp206bss.asm


        .text

        .copy BP_init.asm

        CALL    InitPulse

        LDP     #0
        SPLK    #0FFFFh,PRD
        LDP     #4

Next_Sample

        LDP     #0
        SPLK    #0C20h,TCR
        LDP     #4

        MAR     *,AR1
        LAR     AR1,#Signal
        LAR     AR0,SampleNumber
        MAR     *0+,AR1
        IN      *,0

        CALL    ADC_value_processing

        LACC    Mode,2
        ADD     #Mode_branch
        BACC

Mode_branch

        CALL    Pulse_frequency_evaluation
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
	CALL	Analysis_of_end
        LACC    SampleNumber
        ADD     #1
        SACL    SampleNumber

        B       Next_Sample

******************************************
        .copy   bp206mac.asm

        .copy   ADC_v_p5.asm

        .copy   Pul_f_e.asm

        .copy   Pressaug.asm

        .copy   Ch_pr_hs.asm

        .copy   Pr_a_stp.asm

        .copy   Press_m.asm


******************************************

        .copy   Max_anal.asm

        .copy   Trend.asm

        .copy   Procedur.asm

        .copy   Division.asm

        .copy   Pr_dimin.asm

        .copy   Anal_end.asm

        .end
