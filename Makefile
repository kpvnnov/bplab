# $Id: Makefile,v 1.4 2001-11-08 21:21:06 peter Exp $

AC=asmtms\dspa.exe
CC=asmtms\dspcl.exe

ASMOPT=-l -v2xx -s -w
CCOPT=-v2xx -o2 -iinclude 
#-g -ss 
BPNOEKG  =-dVersionFerrum=2 -dNewFerrum=1 -dMem=20 -dTwoChanel=0
BPNOEKGD =-dVersionFerrum=2 -dNewFerrum=1 -dMem=20 -dTwoChanel=0
BPNOEKGS =-dVersionFerrum=2 -dNewFerrum=1 -dMem=20 -dTwoChanel=0
BPNOEKGSD=-dVersionFerrum=2 -dNewFerrum=1 -dMem=20 -dTwoChanel=0

BPEKG  =-dVersionFerrum=2 -dNewFerrum=1 -dMem=20 -dTwoChanel=0
BPEKGD =-dVersionFerrum=2 -dNewFerrum=1 -dMem=20 -dTwoChanel=0
BPEKGS =-dVersionFerrum=2 -dNewFerrum=1 -dMem=20 -dTwoChanel=0
BPEKGSD=-dVersionFerrum=2 -dNewFerrum=1 -dMem=20 -dTwoChanel=0

INPROGRAM=flashprg\sclr4.obj flashprg\sera4.obj flashprg\sflw4.obj flashprg\spgm4.obj flashprg\sutils4.obj

all: bp_noekg bp_debug bpnekgs bpnekgsd bp_ekg bpekgd bp_ekg_s bpekgsd

bp_noekg: bp206vec.asm bp_noekg.asm bp_main.c $(INPROGRAM)
 $(AC) bp206vec.asm $(ASMOPT) $(BPNOEKG)
 $(AC) bp_noekg.asm $(ASMOPT) $(BPNOEKG)
 $(CC) bp_main $(CCOPT)  -z bp_noekg.obj -o bp_noekg.out -m bp_noekg.map -l lib\rts2xx.lib bp206.cmd

bp_debug: bp206vec.asm bp_debug.asm bp_main.c $(INPROGRAM)
 $(AC) bp206vec.asm $(ASMOPT) $(BPNOEKGD)
 $(AC) bp_debug.asm $(ASMOPT) $(BPNOEKGD)
 $(CC) bp_main $(CCOPT)  -z bp_debug.obj -o bp_debug.out -m bp_debug.map -l lib\rts2xx.lib bp206.cmd

bp_debug_2: bp206vec.asm bp_debug.asm bp_main.c $(INPROGRAM)
 $(AC) bp206vec.asm $(ASMOPT) $(BPNOEKGD)
 $(AC) bp_debug.asm $(ASMOPT) $(BPNOEKGD) -dTwoChanel=1
 $(CC) bp_main $(CCOPT)  -z bp_debug.obj -o bp_debu2.out -m bp_debu2.map -l lib\rts2xx.lib bp206.cmd

bpnekgs: bp206vec.asm bpnekgs.asm bp_main.c $(INPROGRAM)
 $(AC) bp206vec.asm $(ASMOPT) $(BPNOEKGS)
 $(AC) bpnekgs.asm  $(ASMOPT) $(BPNOEKGS)
 $(CC) bp_main $(CCOPT)  -z bpnekgs.obj -o bpnekgs.out -m bpnekgs.map -l lib\rts2xx.lib bp206.cmd

bpnekgsd: bp206vec.asm bpnekgsd.asm bp_main.c $(INPROGRAM)
 $(AC) bp206vec.asm $(ASMOPT) $(BPNOEKGSD)
 $(AC) bpnekgsd.asm $(ASMOPT) $(BPNOEKGSD)
 $(CC) bp_main $(CCOPT)  -z bpnekgsd.obj -o bpnekgsd.out -m bpnekgsd.map -l lib\rts2xx.lib bp206.cmd

bp_ekg: bp206vec.asm bp_ekg.asm bp_main.c $(INPROGRAM)
 $(AC) bp206vec.asm $(ASMOPT) $(BPEKG)
 $(AC) bp_ekg.asm   $(ASMOPT) $(BPEKG)
 $(CC) bp_main $(CCOPT)  -z bp_ekg.obj -o bp_ekg.out -m bp_ekg.map -l lib\rts2xx.lib bp206.cmd

bpekgd: bp206vec.asm bpekgd.asm bp_main.c $(INPROGRAM)
 $(AC) bp206vec.asm $(ASMOPT) $(BPEKGD)
 $(AC) bpekgd.asm   $(ASMOPT) $(BPEKGD)
 $(CC) bp_main $(CCOPT)  -z bpekgd.obj -o bpekgd.out -m bpekgd.map -l lib\rts2xx.lib bp206.cmd

bp_ekg_s: bp206vec.asm bp_ekg_s.asm bp_main.c $(INPROGRAM)
 $(AC) bp206vec.asm $(ASMOPT) $(BPEKGS)
 $(AC) bp_ekg_s.asm   $(ASMOPT) $(BPEKGS)
 $(CC) bp_main $(CCOPT)  -z bp_ekg_s.obj -o bp_ekg_s.out -m bp_ekg_s.map -l lib\rts2xx.lib bp206.cmd

bpekgsd: bp206vec.asm bpekgsd.asm bp_main.c $(INPROGRAM)
 $(AC) bp206vec.asm $(ASMOPT) $(BPEKGSD)
 $(AC) bpekgsd.asm  $(ASMOPT) $(BPEKGSD)
 $(CC) bp_main $(CCOPT)  -z bpekgsd.obj -o bpekgsd.out -m bpekgsd.map -l lib\rts2xx.lib bp206.cmd


flashprg\sclr4.obj: flashprg\sclr4.asm
  $(AC) flashprg\sclr4.asm $(ASMOPT)

flashprg\sera4.obj: flashprg\sera4.asm
  $(AC) flashprg\sera4.asm $(ASMOPT)

flashprg\sflw4.obj: flashprg\sflw4.asm
  $(AC) flashprg\sflw4.asm $(ASMOPT)

flashprg\spgm4.obj: flashprg\spgm4.asm
  $(AC) flashprg\spgm4.asm $(ASMOPT)

flashprg\sutils4.obj: flashprg\sutils4.asm
  $(AC) flashprg\sutils4.asm $(ASMOPT)

# можно добавить ключ -k - keep .asm file
main: bp_main.c
 $(CC) bp_main $(CCOPT) -ss

clean:
  -del *.obj 
  -del *.bak 
  -del *.lst 
  -del *.out
  -del *.map

