@echo off
rem $Id: bp_ekg_4x4.bat,v 1.1 2002-04-18 14:30:42 peter Exp $
echo ������ �������� � ��᫥����⥫쭮� ��� 4 ����� (1 �����奬�)
echo c �, ࠧ����� ����� ᥭ���� 2000 ���� (�����)

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
echo Making Bp_ekg.asm
echo =========================
asmtms\dspa.exe Bp_ekg.asm -l -v2xx -s -w -dVersionFerrum=2 -dNewFerrum=1 -dMem=44
IF ERRORLEVEL 0 GOTO compile
echo =========================
echo Errors in assemble
echo =========================
goto end


:compile
if exist Bp_ekg.obj goto compile1
echo =========================
echo Bp_ekg.obj not found
echo =========================
goto end
:compile1

echo =========================
echo Compile
echo =========================
asmtms\dsplnk bp_ekg.obj bp206.cmd -o bp_ekg.out -m bp_ekg.map
del bp_ekg.obj

:end
