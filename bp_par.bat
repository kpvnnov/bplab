@echo off
rem $Id: bp_par.bat,v 1.2 2001-04-26 16:11:02 peter Exp $
echo Монитор давления с паралельной флэш
echo без экг, разводка платы старая

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
echo Making Bp_paral.asm
echo =========================
asmtms\dspa.exe Bp_paral.asm -l -v2xx -s -w -dVersionFerrum=1 -dNewFerrum=0 -dMem=20
IF ERRORLEVEL 0 GOTO compile
echo =========================
echo Errors in assemble
echo =========================
goto end


:compile
if exist Bp_paral.obj goto compile1
echo =========================
echo Bp_paral.obj not found
echo =========================
goto end
:compile1

echo =========================
echo Compile
echo =========================
asmtms\dsplnk bp_paral.obj bp206.cmd -o bp_paral.out -m bp_paral.map
del bp_paral.obj
:end



