@echo off
rem $Id: BE0.BAT,v 1.1 2001-01-12 12:48:11 peter Exp $
prg2xx -p 240 -m 0x0006 -w 6 -s 0x4000 -e -o src\c2xx_beX.out
