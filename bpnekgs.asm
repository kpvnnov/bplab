;&D
* $Id: bpnekgs.asm,v 1.3 2002-04-23 11:12:18 peter Exp $
*************************************************
* ������� "�ᥢ�����"
*************************************************
PsevdoEKG	.set 0

*************************************************
* ������� ����� ���
*************************************************
ChannelEKG	.set 0
*************************************************
* ������⢮ � ��ꥬ �����奬 �����
*************************************************
Mem		.set 20 	;���� �����奬� 2 Mb

*********************
* ������� �� �⫠���� �����, �� ���஬ ��������
* ��⠭���� ����窨 �஢�� �������� ������ ?
********************
PresetPressure	.set 0
********************************
* ������ � ������� ��������
* �����뢠�� �� �, �� ⢮���� �� �室�
* �� ��࠭� ��ᢥ稢��� "111"
********************************
WriteDebug	.set	0
*!!!!!!!!!!!!!!!!!!!!!!!
* �⪫�砥� �஢��� 280 ��
* � ������� ������ ��������� ������ !!!!!!!!!!
NotCheck280mm	.set	0
*!!!!!!!!!!!!!!!!!!!!!!!

*******************************
* ������� �� �⫠���� �����
* �� ���஬ �뢮����� �㦥��� On Off
* ����祭�� � �몫�祭�� 襤㫥�
********************************
Sheduler_Debug	.set	0

*********************
* �� ��࠭� �㤥� ⮫쪮 ��� �������� �� ������
*********************
Only_Pusk	.set	1

********************
* �뢮���� ���ଠ�� � ᬥ饭�� �������� ?
********************
PrintPreset	.set	0

************************
* ����� ���ࢠ� ��᫥ ����७�� 30 ᥪ㭤 ����祭?
OnProtectInterval30s	.set	1


************
* �����뢠�� �� �� ��࠭� �६� ��⠢襥�� �� ��砫� ����७��
*
*******************
ShowBeginTime	.set	0

*****************************
*
* � ⥪�� ����砥��� ��⠢�� �஢�ન ��直� ����稭
* �� ��室 �� �।���
*****************************
DebugStop	.set  	0

Sertificarion	.set    1

 .copy bp206.asm