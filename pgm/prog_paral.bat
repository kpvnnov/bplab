@echo off
rem $Id: prog_paral.bat,v 1.1 2001-01-12 13:04:30 peter Exp $
echo Монитор давления с паралельной флэш
echo без экг, разводка платы старая без отладочных режимов
prg2xx -p 240 -m 0x0006 -w 6 src\c2xx_bpX.out ..\bp_paral.out
