@echo off
rem $Id: bp_noekg_d.bat,v 1.1 2001-01-22 12:21:51 peter Exp $
echo ������ �������� � ��᫥����⥫쭮� ���
echo ��� ���, ࠧ����� ����� ᥭ���� 2000 ���� (�����)
echo � �⫠���묨 ��ࠬ��ࠬ�

if exist flashprg\sclr4.obj goto sclr4
echo =========================
echo Making flashprg\sclr4.asm
echo =========================
asmtms\dspa.exe flashprg\sclr4.asm -l -v2xx -s -w
:sclr4

if exist flashprg\sera4.obj goto sera4
echo =========================
echo Making flashprg\sera4.asm
echo =========================
asmtms\dspa.exe flashprg\sera4.asm -l -v2xx -s -w
:sera4

if exist flashprg\sflw4.obj goto sflw4
echo =========================
echo Making flashprg\sflw4.asm
echo =========================
asmtms\dspa.exe flashprg\sflw4.asm -l -v2xx -s -w
:sflw4

if exist flashprg\spgm4.obj goto spgm4
echo =========================
echo Making flashprg\spgm4.asm
echo =========================
asmtms\dspa.exe flashprg\spgm4.asm -l -v2xx -s -w
:spgm4

if exist flashprg\sutils4.obj goto sutils4
echo =========================
echo Making flashprg\sutils4.asm
echo =========================
asmtms\dspa.exe flashprg\sutils4.asm -l -v2xx -s -w
:sutils4

echo =========================
echo Making Bp_debug.asm
echo =========================
asmtms\dspa.exe Bp_debug.asm -l -v2xx -s -w -dVersionFerrum=2 -dNewFerrum=1
IF ERRORLEVEL 0 GOTO compile
echo =========================
echo Errors in assemble
echo =========================
goto end


:compile
if exist Bp_debug.obj goto compile1
echo =========================
echo Bp_debug.obj not found
echo =========================
goto end
:compile1

echo =========================
echo Compile
echo =========================
asmtms\dsplnk bp_debug.obj bp206.cmd -o bp_debug.out -m bp_debug.map
del bp_debug.obj

:end
