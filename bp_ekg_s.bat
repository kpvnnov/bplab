@echo off
rem $Id: bp_ekg_s.bat,v 1.1 2001-01-22 12:21:51 peter Exp $
echo Монитор давления с последовательной флэш
echo c экг, разводка платы сентябрь 2000 года (новая)
echo версия для сертификации

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
echo Making Bp_ekg_s.asm
echo =========================
asmtms\dspa.exe Bp_ekg_s.asm -l -v2xx -s -w -dVersionFerrum=2 -dNewFerrum=1 
IF ERRORLEVEL 0 GOTO compile
echo =========================
echo Errors in assemble
echo =========================
goto end


:compile
if exist Bp_ekg_s.obj goto compile1
echo =========================
echo Bp_ekg_s.obj not found
echo =========================
goto end
:compile1

echo =========================
echo Compile
echo =========================
asmtms\dsplnk bp_ekg_s.obj bp206.cmd -o bp_ekg_s.out -m bp_ekg_s.map
del bp_ekg_s.obj

:end
