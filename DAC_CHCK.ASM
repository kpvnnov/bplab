* $Id: DAC_CHCK.ASM,v 1.3 2000-12-13 13:43:27 peter Exp $
DAC_working_check:
	SPLK 	#PULSE_FREQUENCY_EVALUATION,Mode
	SPLK	#0,SubroutMode		;для первоначального case
	Clear_measurement
	mBegin_write_flash
	RET
