;&D
* $Id: MEAS_FIN.ASM,v 1.14 2002-08-13 11:43:14 zykov Exp $
Measurment_finish
	MAR  	*,AR2
 .if OnProtectInterval30s=1
	LAR	AR2,#ProtectInterval
	SPLK	#30,*
 .endif
	LAR  	AR2,#LastMeas
	LACC	*
	BCND    Measurment_finish1,EQ
	;� �祭�� ��� ����� ᬥ饭�� ����⢨⥫쭮
	SPLK	#3*60,*		;� ᥪ㭤��
Measurment_finish1

	mEnd_meas

	LACC	ErrMeas
	BCND	Measurment_finish2,NEQ	;����� �㤥� ᨤ��� sheduler!!!
	; � ᥩ�� (��� ��) �訡�� �� �뫮, 
	; ���� ��ᬮ���� ��⮫� � ���᫨�� ᫥���饥 ��������
;	Beep
	CALL 	SuperBeep

*	mResetInterval
	SETC	SXM
	LACC	SistolPressure
	ADD	#PRESS_20
	SACL	PrevPressureLevel



StandartNextMeas		;᫥���饥 ����७�� �㤥� �������
	SPLK	#0,Standartmeas		;᫥���饥 ����७�� �㤥� �������


BeginNextMeas
*****
* ���� �� ��ࠪ�
	SETC	SXM
	MAR  	*,AR2
	LAR	AR2,#MayModify+1
	LACC	*
	SUB	#0A5h		;����� ०��
	BCND	BigPeople,EQ

	LACC	PrevPressureLevel
	SUB	#LPRESS_60,0
	BCND 	Meas_not_in_baby_range,LEQ

	LACC	PrevPressureLevel
	SUB	#LPRESS_190,0
	BCND	Meas_in_range,LEQ
	SPLK	#LPRESS_180,PrevPressureLevel
	RET
Meas_not_in_baby_range:
	SPLK    #LPRESS_130,PrevPressureLevel
	RET

BigPeople:
	LACC	PrevPressureLevel
	SUB	#LPRESS_80,0
	BCND 	Meas_not_in_range,LEQ

	LACC	PrevPressureLevel
	SUB	#LPRESS_280,0
	BCND	Meas_in_range,LEQ
	SPLK	#LPRESS_280,PrevPressureLevel
	RET
Meas_not_in_range:
; .if (WriteDebug!=0) & (Sertificarion=1)
;        SPLK    #LPRESS_260,PrevPressureLevel
; .else
	SPLK    #LPRESS_160,PrevPressureLevel
; .endif
Meas_in_range:
	RET
CheckForcedMeas
	LACC	Standartmeas
	BCND	Forced_Meas,EQ	;�।��饥 �뫮 �⠭�����
				;�᪮७��� ����७�� ��������
	B	StandartNextMeas

Forced_Meas
* ����७��, �஢������ �१ �� ������
	mLoadFastInterval
	SPLK	#1,Standartmeas
	B	BeginNextMeas
**************
* shedule
*
**************
Measurment_finish2
	LACC	ErrMeas,1
	AND	#3Fh,1
	ADD	#Sheduler_case
	BACC

Sheduler_case
* 000-������ ���ணࠬ��஢�� � ��⮢ � ��᫥�������
	B	Sheduler_err_0
* �⬥�� ����७�� ��樥�⮬
	B	Sheduler_err_1
	B	Sheduler_err_2
* ����殮��� ���筨�� ��⠭�� ���� �����⨬��� ���祭��
* sheduler �몫�砥�
	B	Sheduler_err_3
	B	Sheduler_err_4
* ��������� (��ᮥ������) ������
	B	Sheduler_err_5
	B	Sheduler_err_6
* ������ ��� ��������⥬� � ������ �ய�᪠�� ������
* �祭� ����� ���⨫��� � 40 �� 20
	B	Sheduler_err_7
	B	Sheduler_err_8
*rSMALL_SPEED_AUG_PR		.set 09
	B	Sheduler_err_9
	B	Sheduler_err_10
*rTIME_PR_AUG_40_MORE_10_SEC	.set 011
	B	Sheduler_err_11
	B	Sheduler_err_12
	B	Sheduler_err_13
	B	Sheduler_err_14
*rTIME_PR_AUG_MORE_30_SEC	.set 015
	B	Sheduler_err_15
	B	Sheduler_err_16
*rTIME_PR_AUG_STOP_MORE_10_SEC	.set 017
	B	Sheduler_err_17
	B	Sheduler_err_18
* 084-��०�� ��㡪� �������
	B	Sheduler_err_19
	B	Sheduler_err_20
* 085-���⮫��᪮� �� ��樥�� ����� 270 �� ��. ��.
	B	Sheduler_err_21
	B	Sheduler_err_22
* 086-������  �஢���  ᨣ���� (��� ������⢨�)
	B	Sheduler_err_23
	B	Sheduler_err_24
* 087-�६� ����७�� �� �ॢ�ᨫ� 2 ���
	B	Sheduler_err_25
	B	Sheduler_err_26
* 088, 089-��᮪�� �����⥫쭠� ��⨢����� ��樥��,
*     �९�������� �஢������ ����७��
	B	Sheduler_err_27
	B	Sheduler_err_28
* 090-�����㦥��� ����ࠢ���� ��᫥ ����祭�� ������
	B	Sheduler_err_29
	B	Sheduler_err_30
* 091-������ ��᫥ ������ ���३ �� �� ���ணࠬ��஢��
	B	Sheduler_err_31
	B	Sheduler_err_32
* ���誮� ����讥 �६� ����७�� (����� 2 ���)
*rTIME_MORE_2_MINUTES		.set 033
	B	Sheduler_err_33
*rTIME_MORE_10_SEC 		.set 034
	B	Sheduler_err_34
* 093-��������� ��������� ࠧ�殮��
	B	Sheduler_err_35
	B	Sheduler_err_36
* �� 㤠���� ��।����� ����⮫�
	B	Sheduler_err_37
	B	Sheduler_err_38
* �� 㤠���� ��।����� ��⮫�
	B	Sheduler_err_39
*rNOT_SISTOL_PRESSURE_ARTEFACT	 .set 040
* �� ����७�� �� ���䠪� �� ��⮫�
*
	B	Sheduler_err_40
* 096-�� 㤠���� ��।����� ����� ����
	B	Sheduler_err_41
*rNOT_SISTOL_AVR_DIASTOL_PRESSURE .set 042
* �� ��।����� �।��� � ����⮫� (���ᨬ� ᫨誮� "᫥��")
	B	Sheduler_err_42
* 097-���䠪�� �������� ��� ��⬨�
	B	Sheduler_err_43
	B	Sheduler_err_44
* 098-��� ����⨢��� ������ ������ ��������� १���⠬�.
*     ������⢮ ����७�� �ॢ�ᨫ� 150 (*)
	B	Sheduler_err_45
	B	Sheduler_err_46
* > 098-����७�� ��ࢠ�� ��-�� ����⭮�� ०��� ࠡ��� ������⨪�
*rTIME_PR_DIMIN_MORE_10_SEC	.set 047
* ���������� ������� �������� � 60 �� 40 ��.
*rErrorSpuskTo40 		.set 047
* ���������� ������� �������� � 40 �� 20 ��.
*rErrorSpuskTo20 		.set 047
* ������ ��� ��������⥬� � ������ �ய�᪠�� ������
* �� ���� ������� �������� �� �����������
*rSystemDiryavaya1 		.set 047
* ���������� ������� �������� � Psys+PRESS_OVER+PRESS_PRESET
* �� Psys+PRESS_OVER
*rErrorSpuskFromUp 		.set 047
* ���������� ������� �������� �� ��㯥�쪥.
*rErrorSpuskStep 		.set 047
	B	Sheduler_err_47
	B	Sheduler_err_48
	B	Sheduler_err_49
	B	Sheduler_err_50
*rERROR_ADC			.set 051
	B	Sheduler_err_51
	B	Sheduler_err_52
	B	Sheduler_err_53
	B	Sheduler_err_54
	B	Sheduler_err_55
	B	Sheduler_err_56
	B	Sheduler_err_57
	B	Sheduler_err_58
	B	Sheduler_err_59
	B	Sheduler_err_60
	B	Sheduler_err_61
	B	Sheduler_err_62
	B	Sheduler_err_63
* ������ ���ணࠬ��஢�� � ��⮢ � ��᫥�������
Sheduler_err_0
Sheduler_err_1
Sheduler_err_2

Sheduler_err_4
Sheduler_err_6
Sheduler_err_8
Sheduler_err_10
Sheduler_err_12
Sheduler_err_13
Sheduler_err_14
Sheduler_err_16
Sheduler_err_18
Sheduler_err_20
Sheduler_err_22
Sheduler_err_23
Sheduler_err_24
Sheduler_err_26
Sheduler_err_27
Sheduler_err_28
Sheduler_err_29
Sheduler_err_30
Sheduler_err_31
Sheduler_err_32
Sheduler_err_33
Sheduler_err_34
Sheduler_err_35
Sheduler_err_36
Sheduler_err_38
Sheduler_err_43
Sheduler_err_44
Sheduler_err_45
Sheduler_err_47
Sheduler_err_48
Sheduler_err_49
Sheduler_err_50
Sheduler_err_51
Sheduler_err_52
Sheduler_err_53
Sheduler_err_54
Sheduler_err_55
Sheduler_err_56
Sheduler_err_57
Sheduler_err_58
Sheduler_err_59
Sheduler_err_60
Sheduler_err_61
Sheduler_err_62
Sheduler_err_63
	B	StandartNextMeas
Sheduler_err_5
Sheduler_err_7
Sheduler_err_9
Sheduler_err_11
Sheduler_err_15
Sheduler_err_21
Sheduler_err_25
Sheduler_err_37
Sheduler_err_41
Sheduler_err_46
 .if Sertificarion=1
	B	StandartNextMeas
 .else
	B	CheckForcedMeas
 .endif

*rNOT_SISTOL_PRESSURE_ARTEFACT	 .set 040
* �� ����७�� �� ���䠪� �� ��⮫�
*
Sheduler_err_40
*rNOT_SISTOL_AVR_DIASTOL_PRESSURE .set 042
* �� ��।����� �।��� � ����⮫� (���ᨬ� ᫨誮� "᫥��")
Sheduler_err_42
	LACC	PrevPressureLevel
	ADD	#PRESS_30
	SACL	PrevPressureLevel
 .if Sertificarion=1
	B	StandartNextMeas
 .else
	B	CheckForcedMeas
 .endif

* �� 㤠���� ��।����� ��⮫�
Sheduler_err_39
	LACC	PrevPressureLevel
	ADD	#PRESS_30
	SACL	PrevPressureLevel
 .if Sertificarion=1
	B	StandartNextMeas
 .else
	B	CheckForcedMeas
 .endif
Sheduler_err_17
Sheduler_err_3
	mOff_Interval
	RET

Sheduler_err_19
	B	StandartNextMeas
