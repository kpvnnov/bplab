;&D
* $Id: DAC_CHCK.ASM,v 1.5 2001-11-14 17:20:52 peter Exp $
DAC_working_check:
	SPLK 	#PULSE_FREQ_EVALUATION_40,_Mode
	mMeasurement_init
	mBegin_write_flash
	RET
