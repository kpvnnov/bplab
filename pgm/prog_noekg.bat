@echo off
rem $Id: prog_noekg.bat,v 1.1 2001-01-12 13:04:30 peter Exp $
echo Монитор давления с последовательной флэш
echo без экг, разводка платы сентябрь 2000 года (новая)
echo без отладочных режимов
prg2xx -p 240 -m 0x0006 -w 6 src\c2xx_bpX.out ..\bp_noekg.out
