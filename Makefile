# $Id: Makefile,v 1.10 2002-04-24 14:03:12 peter Exp $

AC=asmtms\dspa.exe
CC=asmtms\dspcl.exe
LNK=asmtms\dsplnk.exe

ASMOPT=-l -v2xx -s -w
CCOPT=-v2xx -o2 -iinclude -pk
#-g -ss 

BP_ASM_DEF  =-dVersionFerrum=2 -dNewFerrum=1 -dTwoChanel=0
#MEMORY_20   =-dMem=20 
#MEMORY_40   =-dMem=40 

#��ꥪ�� 䠩�� ������奬���� �ணࠬ��஢����
INPROGRAM=flashprg\sclr4.obj flashprg\sera4.obj flashprg\sflw4.obj \
	  flashprg\spgm4.obj flashprg\sutils4.obj

all: bp20 bpd20 bps20 bpsd20 ekg20 ekgd20 ekgs20 ekgsd20

#���㫨, ����室��� ��� ᡮન ��� ���ᨩ �ணࠬ��
MODULS =bp206vec.obj bp_main.obj 
        

#--------------------------------
#�⠭���⭠� �����

bp20: bp_noekg.obj $(INPROGRAM) $(MODULS) bp_noekg.cmd
 $(LNK) bp_noekg.cmd

bp_noekg.cmd: bp206.cmd
  copy &&|
$(MODULS)
bp_noekg.obj
-o bp_noekg.out
-m bp_noekg.map
-l lib\rts2xx.lib
|+bp206.cmd bp_noekg.cmd


#bp_noekg.obj: bp_noekg.asm
# $(AC) bp_noekg $(ASMOPT) $(BP_ASM_DEF) $(MEMORY_20)

#--------------------------------
#�⠭���⭠� �����
#� �⫠���� ०����

bpd20: bp_debug.obj $(INPROGRAM) $(MODULS) bp_debug.cmd
 $(LNK) bp_debug.cmd

bp_debug.cmd: bp206.cmd
  copy &&|
$(MODULS)
bp_debug.obj
-o bp_debug.out
-m bp_debug.map
-l lib\rts2xx.lib
|+bp206.cmd bp_debug.cmd

#bp_debug.obj: bp_debug.asm
# $(AC) bp_debug $(ASMOPT) $(BP_ASM_DEF) $(MEMORY_20)


#--------------------------------
#�⠭���⭠� �����
#� �⫠���� ०����
#� ���� �������� ��������
bp2d20: $(INPROGRAM) $(MODULS) bp_debu2.cmd
 $(AC) bp_debug.asm $(ASMOPT) $(BP_ASM_DEF) -dTwoChanel=1
 $(LNK) bp_debu2.cmd
 -del bp_debug.obj


bp_debu2.cmd: bp206.cmd
  copy &&|
$(MODULS)
bp_debug.obj
-o bp_debu2.out
-m bp_debu2.map
-l lib\rts2xx.lib
|+bp206.cmd bp_debu2.cmd

#--------------------------------
#���䨪�樮���� �����

bps20: bpnekgs.obj $(INPROGRAM) $(MODULS) bpnekgs.cmd
 $(LNK) bpnekgs.cmd

bpnekgs.cmd: bp206.cmd
  copy &&|
$(MODULS)
bpnekgs.obj
-o bpnekgs.out
-m bpnekgs.map
-l lib\rts2xx.lib
|+bp206.cmd bpnekgs.cmd


#bpnekgs.obj: bpnekgs.asm
# $(AC) bpnekgs $(ASMOPT) $(BP_ASM_DEF) $(MEMORY_20)

#--------------------------------
#���䨪�樮���� �����
#� �⫠���� ०����

bpsd20: bpnekgsd.obj $(INPROGRAM) $(MODULS) bpnekgsd.cmd
 $(LNK) bpnekgsd.cmd

bpnekgsd.cmd: bp206.cmd
  copy &&|
$(MODULS)
bpnekgsd.obj
-o bpnekgsd.out
-m bpnekgsd.map
-l lib\rts2xx.lib
|+bp206.cmd bpnekgsd.cmd


#bpnekgsd.obj: bpnekgsd.asm
# $(AC) bpnekgsd $(ASMOPT) $(BP_ASM_DEF) $(MEMORY_20)


#--------------------------------
#�⠭���⭠� �����
#� � �������

ekg20: bp_ekg.obj $(INPROGRAM) $(MODULS) bp_ekg.cmd
 $(LNK) bp_ekg.cmd

bp_ekg.cmd: bp206.cmd
  copy &&|
$(MODULS)
bp_ekg.obj
-o bp_ekg.out
-m bp_ekg.map
-l lib\rts2xx.lib
|+bp206.cmd bp_ekg.cmd


#bp_ekg.obj: bp_ekg.asm
# $(AC) bp_ekg $(ASMOPT) $(BP_ASM_DEF) $(MEMORY_20)

#--------------------------------
#�⠭���⭠� �����
#� � ������� � ����� 䫥誮� �� 4 Mb

ekg40: bp_ekg40.obj $(INPROGRAM) $(MODULS) bp_ekg40.cmd
 $(LNK) bp_ekg40.cmd

bp_ekg40.cmd: bp206.cmd
  copy &&|
$(MODULS)
bp_ekg40.obj
-o bp_ekg40.out
-m bp_ekg40.map
-l lib\rts2xx.lib
|+bp206.cmd bp_ekg40.cmd


#bp_ekg40.obj: bp_ekg40.asm
#$(AC) bp_ekg40 $(ASMOPT) $(BP_ASM_DEF)
#--------------------------------
#�⠭���⭠� �����
#� � ������� � ����� 䫥誮� �� 4 Mb

ekg44: bp_ekg44.obj $(INPROGRAM) $(MODULS) bp_ekg44.cmd
 $(LNK) bp_ekg44.cmd

bp_ekg44.cmd: bp206.cmd
  copy &&|
$(MODULS)
bp_ekg44.obj
-o bp_ekg44.out
-m bp_ekg44.map
-l lib\rts2xx.lib
|+bp206.cmd bp_ekg44.cmd


bp_ekg44.obj: bp_ekg44.asm
$(AC) bp_ekg44 $(ASMOPT) $(BP_ASM_DEF)


#--------------------------------
#�⠭���⭠� �����
#� �⫠���� ०����

ekgd20: bpekgd.obj $(INPROGRAM) $(MODULS) bpekgd.cmd
 $(LNK) bpekgd.cmd

bpekgd.cmd: bp206.cmd
  copy &&|
$(MODULS)
bpekgd.obj
-o bpekgd.out
-m bpekgd.map
-l lib\rts2xx.lib
|+bp206.cmd bpekgd.cmd

#bpekgd.obj: bpekgd.asm
# $(AC) bpekgd $(ASMOPT) $(BP_ASM_DEF) $(MEMORY_20)

#--------------------------------
#���䨪�樮���� �����
#� � �������

ekgs20: bp_ekg_s.obj $(INPROGRAM) $(MODULS) bp_ekg_s.cmd
 $(LNK) bp_ekg_s.cmd

bp_ekg_s.cmd: bp206.cmd
  copy &&|
$(MODULS)
bp_ekg_s.obj
-o bp_ekg_s.out
-m bp_ekg_s.map
-l lib\rts2xx.lib
|+bp206.cmd bp_ekg_s.cmd


#bp_ekg_s.obj: bp_ekg_s.asm
# $(AC) bp_ekg_s $(ASMOPT) $(BP_ASM_DEF) $(MEMORY_20)

#--------------------------------
#���䨪�樮���� �����
#� � �������
#� �⫠���� ०����

ekgsd20: bpekgsd.obj $(INPROGRAM) $(MODULS) bpekgsd.cmd
 $(LNK) bpekgsd.cmd

bpekgsd.cmd: bp206.cmd
  copy &&|
$(MODULS)
bpekgsd.obj
-o bpekgsd.out
-m bpekgsd.map
-l lib\rts2xx.lib
|+bp206.cmd bpekgsd.cmd


#bpekgsd.obj: bpekgsd.asm
# $(AC) bpekgsd $(ASMOPT) $(BP_ASM_DEF) $(MEMORY_20)

#--------------------------------
#���䨪�樮���� �����
#� � �������
#� �⫠���� ०����

ekgsd44: ekgsd44.obj $(INPROGRAM) $(MODULS) ekgsd44.cmd
 $(LNK) ekgsd44.cmd

ekgsd44.cmd: bp206.cmd
  copy &&|
$(MODULS)
ekgsd44.obj
-o ekgsd44.out
-m ekgsd44.map
-l lib\rts2xx.lib
|+bp206.cmd ekgsd44.cmd

#-------------------------
# ������奬��� �ணࠬ��஢����
flashprg\sclr4.obj: flashprg\sclr4.asm
  $(AC) flashprg\sclr4 $(ASMOPT)

flashprg\sera4.obj: flashprg\sera4.asm
  $(AC) flashprg\sera4 $(ASMOPT)

flashprg\sflw4.obj: flashprg\sflw4.asm
  $(AC) flashprg\sflw4 $(ASMOPT)

flashprg\spgm4.obj: flashprg\spgm4.asm
  $(AC) flashprg\spgm4 $(ASMOPT)

flashprg\sutils4.obj: flashprg\sutils4.asm
  $(AC) flashprg\sutils4 $(ASMOPT)

#---------------------------
#⠡��� ����஢
#bp206vec.obj: bp206vec.asm
# $(AC) bp206vec $(ASMOPT) $(BP_ASM_DEF)

.asm.obj:
 $(AC) $&.asm $(ASMOPT) $(BP_ASM_DEF) 


#---------------------------
#�஢�ઠ "��誠�������" ��६�����
ch_range.obj: ch_range.c
 $(CC) ch_range $(CCOPT)

#---------------------------
# �������� ��६����
memory.obj: memory.c
 $(CC) memory $(CCOPT) -ss

#---------------------------
f_f_meas.obj: f_f_meas.c
 $(CC) f_f_meas $(CCOPT) -ss -k 

#---------------------------
pr_aug40.obj: pr_aug40.c
 $(CC) pr_aug40 $(CCOPT) -ss -k 

#---------------------------
bp_main.obj: bp_main.c
 $(CC) bp_main $(CCOPT) -ss -k 

time_int.obj: time_int.c
 $(CC) time_int $(CCOPT) -ss -k 


.c.obj:
 $(CC) $&.c $(CCOPT)


#  -ss
# ����� �������� ���� -k - keep .asm file
#main: bp_main.c
# $(CC) bp_main $(CCOPT) -ss



clean:
  -del *.obj 
  -del *.bak 
  -del *.lst 
  -del *.out
  -del *.map
  -del bp_*.cmd

