;&D
*****************************************************************************
*       Вектора прерываний
* $Id: BP206VEC.ASM,v 1.16 2002-08-21 08:44:24 peter Exp $
*****************************************************************************
            .mmregs               ; Include standard register mnemonics.
            .global INIT,
            .global INTU,INTKEY,INTTIM,INTASP
            .global SIGNT
            .global LengthSignat

            .sect "vectors"
        B    INIT      ; 0h   RS         1   Начальные установки
        B    INTU      ; 2h   HOLD/INT1  4   Мало U батарей(INT1)
        B    INTKEY    ; 4h   INT2/INT3  5   Кнопка
        B    INTTIM    ; 6h   TINT       6   Таймер частоты дискретизации
        B    INIT      ; 8h   RINT       7   Синхронный порт прием ЗАМАСКИРОВ
        B    INIT      ; Ah   XINT       8   Синхронный порт перед.ЗАМАСКИРОВ
        B    INTASP    ; Ch   TXRXINT    9   Асинхронный порт
        B    INIT      ; Eh              10  Reserved
        B    INIT      ; 10h             11  Reserved
        B    INIT      ; 12h             12  Reserved
        .globl CurrentRevision
        B    CurrentRevision      ; 14h             13  Reserved
        .globl	CRC_FERRUM
        B    CRC_FERRUM		; 16h             14  Reserved
        .globl 	SIGNT
        B    SIGNT      	; 18h             15  Reserved
        B    INIT      ; 1Ah             16  Reserved
        B    INIT      ; 1Ch             17  Reserved
        B    INIT      ; 1Eh  INT15      -
        B    INIT      ; 20h  INT16      -
        B    INIT      ; 22h  TRAP       -  Вектор инструкции TRAP
        B    INIT      ; 24h  NMI        3
	B    INIT      ; 26h             2  Reserved
	.end