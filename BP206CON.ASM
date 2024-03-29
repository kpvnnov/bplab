;&D
* $Id: BP206CON.ASM,v 1.13 2001-10-22 13:38:11 peter Exp $
;CLKIN 3.6864 ���
;DIV1==DIV2=0 Internal divide-by-two
;CLOCKOUT1 = 1.8432 ���
;Instruction-Cycle Time 542.5347(2) ns


*
ASPR    .set   0C00Fh   ;reset ASP
ASPSRA  .set   0E0AFh   ;Enable receiver A � �ਥ��
ASPSR   .set   0E08Fh   ;Enable receiver
ASPST   .set   0E10Fh   ;Enable transmit
      ;FREE,SOFT,URST,0,0,0,DIM,TIM,RIM,STB,CAD,SETBRK,CIO3,CIO2,CIO1,CIO0
*        1    1  1/0  0 0 0  0  0/1 0/1  0  0/1   0     1    1    1    1

CBRDR   .set    0001h
*CBRD    .set    0001h
Reset_BRD	.set 1
      ;�� CLK   Fuart
      ;�� 3,6864���. 9,6kdit/c  BRD=000Ch
      ;�� 3,6864���. 19,2kdit/c BRD=0006h
      ;�� 3,6864���. 38,4kdit/c BRD=0003h
      ;�� 3,6864���. 57,6kdit/c BRD=0002h
*

CIOSR   .set   06600h
      ;0,ADC,BI,TEMP,THRE,FE,OE,DR,DIO3,DIO2,DIO1,DIO0,IO3,IO2,IO1,IO0
*      0  1   1   0    0   1  1  0   1    1    1    1   1   1   1   1
ASPResA .set   04000h   ;��� ��⮯����ன�� ᪮��� � IOSR
ASPResF .set   02600h   ;��� 䫠��� BI(break interrupt)
                        ;FE(framing error)
                        ;��९�������(OE-overrun error) � IOSR

CTCR    .set    0FCFh
      ;0,0,0,0,FREE,SOFT,PSC,TRB,TSS,TDDR
CPRD    .set   023Fh
      ;�� CLK   Fsampl
      ;�� 3,6864���. 200��  PRD=023Fh, TDDR=0Fh
      ;�� 3,6864���. 100��  PRD=047Fh, TDDR=0Fh


CNSTCLK       .set 199
CNSTKEYB      .set 100 ;(�⭮�⥫쭮 ⠩��୮� �����)
CNSTPOWER     .set 100 ;(�⭮�⥫쭮 ⠩��୮� �����)
CNSTDISP      .set 10  ;���� �뢮�� �� ��࠭ (�⭮�⥫쭮 ⠩��୮�)
* 10 -~ 20��
CNSTREFDISP   .set 2   ;���� refresh (�⭮�⥫쭮 �뢮�� �� ��࠭)
CNTERRDISPL   .set (CNSTCLK*5) ;�६� �뢮�� �訡�� �� ��࠭
*CNTRELE       .set 10   ;�६� �ࠡ��뢠��� ५� (1 = 5 ms)
VALVE_CLOSE	.set 10   ;�६� �ࠡ��뢠��� ५� (1 = 5 ms)
CNSTASP       .set 40  ;200 ms (1 = 5 ms ) ���⮩ ��᫥����⥫쭮�� ����
;ᥩ�� ���� 10 ᥪ㭤
*CNSTASP       .set 2000  ;200 ms (1 = 5 ms ) ���⮩ ��᫥����⥫쭮�� ����


CWSGR   .set    0000h
      ;0,0,0,0,ISWS,DSWS,PSUWS,PSLWS


*
SSPR    .set   0CC08h   ;reset SSP
SSPS    .set   0CC38h   ;SSP start
      ;FREE,SOFT,TCOMP,RFNE,FT1,FT0,FR1,FR0,OVM,IN0,XRST,RRST,TXM,MCM,FSM,DLB
*


*
;IMR     .set       4h
;GREG    .set       5h
;IFR     .set       6h
FACCES0 .set   0FFE0h
FACCES1 .set   0FFE1h
PMST    .set   0FFE4h
CLK     .set   0FFE8h
ICR     .set   0FFECh
SDTR    .set   0FFF0h
SSPCR   .set   0FFF1h
ADTR    .set   0FFF4h
ASPCR   .set   0FFF5h
IOSR    .set   0FFF6h
BRD     .set   0FFF7h
TCR     .set   0FFF8h
PRD     .set   0FFF9h
TIM     .set   0FFFAh
WSGR    .set   0FFFCh
*

DATART  .set   00900h  ;㪠��⥫� �� ������� �����

;Ppa1_prog .set 04FEh  ; �������� 誠�� (5 �� �� ��)
;Ppa1_progMul2 .set 09FCh   ; ⮦� ���祭��, �� 㬭������� �� 2
;Ppa1_prog .set 027Fh    ;���� ᤥ���� 2,5 �� ��. ��.
;Ppa1_progMul2 .set 04FEh   ; ⮦� ���祭��, �� 㬭������� �� 2
Ppa1_prog .set 0h    ;���� ᤥ���� 2,5 �� ��. ��.
Ppa1_progMul2 .set 0h   ; ⮦� ���祭��, �� 㬭������� �� 2
