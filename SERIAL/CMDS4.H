*File name: cmds.h                                              *
*Include file with F206 Flash serial loader Level 2             *
*(c2xx_sla.asm). Declarations for F206-Host handshake commands  *
*                                                               *
*Rev 2.0                                                       *
*Written by: Sam Saba, TI Houston                       9/8/97  *
*****************************************************************
*F2xx-Host uart communication commands  H_CMDS
H_sflag_req  .set   0010h       ; Request host for new sflag
H_coffc_req  .set   0020h       ; Request host for COFFC.out
H_alg_err    .set   0030h       ; Report host algorithm error
H_com_err    .set   0040h       ; Report host communication error
H_done       .set   0050h       ; Report host algorithm in execution
H_rung       .set   0060h       ; Report host all done
H_CMD6       .set   0070h       ; reserved

*SFLAG flag command definitions for flash programming
*SFLAG can be defined in program or updated using communication or
*user application programs, before calling the required flash functions

*   SFLAG bit level definition/declarations for flash functions
*
*   Register Bits: 15 14 13 12 11 10 9 8 7 6  5  4  3  2  1  0
*   Bit position :  0  1  2  3  4  5 6 7 8 9 10 11 12 13 14 15
*
*                  F1  F0 SP                          P   E  C

*   SFLAG Bit field definitions

*   Bit 0 - C    - Clear the selected flash array
*
*   Bit 1 - E    - Erase the selected flash array

*   Bit 2 - P    - Program with selected array

*   Bit 3- 12    - Reserved for future use, could be customized
*                  by user specific s/w
      
*   Bit 13 -SP   - Special function for selecting
*                  Clear, Erase Flash 0 array and program Flash0 and
*                  Flash1 arrays. Flash1 arrays will not be cleared and
*                  erased, as new devices come in erased state. 

*   Bit 14 -F0   - Select Flash 0 array for Clear, Erase and Program

*   Bit 15 -F1   - Select Flash 1 array for Clear, Erase and Program

*   Commands for Rev 1.0 and Rev 2.0 of the serial loader s/w.
*   SFLAG          Flash functions
*               Flash 0 array functions
*   0000h          nop
*   4001h          Flash 0 clear only
*   4002h          Flash 0 erase only
*   4003h          Flash 0 clear and erase
*   4004h          Flash 0 program only  with COFFC file
*   4007h          Flash 0 clear,erase, program with COFFC file
*   6003h          Flash 0 clear,erase, program with COFFA data -3k max, from 0x0000h

*               Flash 1 array functions
*   8001h          Flash 1 clear only
*   8002h          Flash 1 erase only
*   8003h          Flash 1 clear and erase
*   8004h          Flash 1 program only  with COFFC file
*   8007h          Flash 1 clear,erase, program with COFFC file

*   Commands specific to Rev 2.0 of the serial loader s/w
*   e007h          Clear, Erase Flash 0 array and program Flash0 and
*                  Flash1 arrays. Flash1 arrays will not be cleared and
*                  erased, as new devices come in erased state. 


                             ; Flash array functions
FX_CLR       .set   15       ; Clear   if bit B0=1
FX_ERS       .set   14       ; Erase   if bit B1=1
FX_PGM       .set   13       ; Program  COFFC file if bit B2=1 
FX_FN1       .set   12       ; reserved
FX_FN2       .set   11       ; reserved
FX_FN3       .set   10       ; reserved
FX_FN4       .set    9       ; reserved
FX_FN5       .set    8       ; reserved
FX_FN6       .set    7       ; reserved

FX_FN7       .set    6       ; reserved
FX_FN8       .set    5       ; reserved
FX_FN9       .set    4       ; reserved
FX_FN10      .set    3       ; reserved
FX_FN11      .set    2       ; Program flash0/1 with COFFA data, if any
FX_ARY0      .set    1       ; Bit 14=1 selects Flash0 array
FX_ARY1      .set    0       ; Bit 15=1 select1 Flash1 array
                             ; 01 means the bit field defines flash0 functions
                             ; 10 means the bit field defines flash1 functions
                             ; 11 means flash0 and flash1 arrays

* HFLAG flag command definition for HOST status
more_data    .set   0081h       ;More blocks of data to come from host
                                ;If bit 7=1 more data to come from host.
                                ;If bit 7=0 means current block is the
                                ;last block of data
