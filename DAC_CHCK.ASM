;&D
* $Id: DAC_CHCK.ASM,v 1.4 2001-10-22 13:38:14 peter Exp $
DAC_working_check:
	SPLK 	#PULSE_FREQ_EVALUATION_40,Mode
	mMeasurement_init
	mBegin_write_flash
	RET
