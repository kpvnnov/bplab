@echo off
rem $Id: prog_par_d.BAT,v 1.2 2001-01-12 13:04:30 peter Exp $
echo Монитор давления с паралельной флэш
echo без экг, разводка платы старая с отладочными режимами
prg2xx -p 240 -m 0x0006 -w 6 src\c2xx_bpX.out ..\BP_PAR_D.OUT



