;echo Default EMUINIT.CMD 
mr
ma 0x0000,0,0x4000,ROM    ;On-Chip R0M 
ma 0x8000,0,0x0c00,ROM    ;On-Chip R0M 
ma 0xff00,0,0x0100,RAM    ;On-Chip RAM 
ma 0x0060,1,0x0020,ram    ;On-Chip RAM B2
ma 0x0004,1,0x0003,ram    ;On-Chip RAM IMR...
ma 0x0200,1,0x0200,ram    ;On-Chip RAM B0,B1
ma 0x0800,1,0x1000,ram    ;On-chip 4k word
ma 0x8000,1,0x1000,ram    ;On-chip 4k word
ma 0xffd8,2,0x0028,ioport  ;On-Chip io
;
;Enable internal program and data RAM
;Set CNF = 1 and PC to 0xfe00
;
;e st0  = 0x1000
e pc   = 0x0000
map on
dasm PC

win  DISASSEMBLY
size 53,25

win  CPU
size 27,13

win  COMMAND
move 0,40,53,8

mem  0x0200@data
win  MEMORY
move 0,26,47,18

mem1 0x0280@data
win  MEMORY1
move 31,26,49,21

mem2 0xffd8@io
win  MEMORY2
move 53,14,27,12

win  COMMAND
echo   EMUINIT.CMD HAS BEEN LOADED
