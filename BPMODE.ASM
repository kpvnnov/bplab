;&D
*****************************************************************************
* ०��� �ਡ�� (����७�� ��������, �뢮� �訡�� �� ��࠭ � �.�.)
* $Id: BPMODE.ASM,v 1.14 2001-11-23 15:37:38 peter Exp $
*****************************************************************************

	SETC    SXM
        SPM     #0
	LACC    _Mode,2
	ADD     #Mode_branch
	BACC

Mode_branch
***************************
* ����祭�� ��⠭�� ���������� �奬�.
***************************
	CALL	Level_zero
	B       End_mode

***************************
* �஢�ઠ ��砫쭮�� ᬥ饭�� ��� ( 1-� ����� ).
***************************
	CALL	Start_shift
	B	End_mode

***************************
* �����祭�� �������� �� 40  ��.��.��.
***************************
	CALL    Pressure_augment_40
	B       End_mode
;VALVE_WORKING_CHECK
***************************
* �஢�ઠ ࠡ��� ���(�����஢��)
***************************
	CALL    DAC_working_check
	B       End_mode

***************************
* �業�� ����� ���� �� 40 ��.��.��.
***************************
	CALL    Pulse_frequency_evaluation_40
	B       End_mode
;HERMITICITY_CHECK
***************************
* �����祭�� �������� �� 80  ��.��.��.
***************************
	CALL    Pressure_augment_80
	B       End_mode
;VALVE_WORKING_CHECK
***************************
* �業�� ����� ���� �� 80 ��.��.��.
***************************
	CALL    Pulse_frequency_evaluation_80
	B       End_mode
;HERMITICITY_CHECK
***************************
* �����祭�� �������� �� ��⮫��᪮� + N ��.��.��.
***************************
	CALL    Pressure_augment
	B       End_mode

***************************
* ��⠭���� 㢥��祭�� �������
***************************
	CALL    Pressure_augment_stop
	B       End_mode

***************************
* �஢�ઠ �ॢ�襭�� ��⮫��᪮�� �������
***************************
	CALL    Check_higher_sistol_pressure
	B       End_mode

***************************
* ����७�� ������� ����権 � �஢�� �������
***************************
	CALL    Pressure_measurement
	B       End_mode

***************************
* ��������� �஢�� �������� �� 8 ��.��.��.
***************************
	CALL    Pressure_diminution_1
	B       End_mode

***************************
* �뢮� १���⮢ ����७�� �� ��������
***************************
	CALL	Measurment_finish
	B       End_mode

 .if Sertificarion=1
***************************
* ���⮥ ��ﭨ� �� ��㯥�쪥 2-3 ᥪ㭤�
***************************
	CALL    Pressure_measurement_Manual
	B       End_mode
 .endif

 .if WriteDebug=0
 .elseif WriteDebug<3
****************************
* ������ �⫠��筠� �� 䫥�
****************************
        CALL	DebugWriting
        B	End_mode
 .endif


End_mode

**�⫠���
*	SUB	#1152
*	BCND	NoOverFlow,LT
*	LACC	#0
*	SACL    _SampleNumber
*NoOverFlow
**
	RET

 .if WriteDebug=0
 .elseif WriteDebug<3
DebugWriting:
	CALL	pStart_Debug_Write
	LACC	_SampleNumber
	ADD	_SampleNumberShift
*	ADD	TimeNakachka
	SUB     #TWO_MINUTES
	BCND	End_Debug_mode_ret,LT
	mEnd_error_meas rTIME_MORE_2_MINUTES
End_Debug_mode_ret:
	RET

 .endif

