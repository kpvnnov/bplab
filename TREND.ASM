;&D
***********************************************************************
* $Id: TREND.ASM,v 1.6 2001-11-14 17:20:54 peter Exp $
*       Trend_measurement_1() - ����� ����७�� Trend-a
*                               � ������� ����権.
*
*  �������� ��p������ � ���p� ��p�頥��� �㭪��.
*
*  � p����� �pאַ� ��p��樨
*
*       SampleNumber
*       MaxNumber
*
*  � p����� ��ᢥ���� ��p��樨
*
*       Signal[]
*       Max[2]
*       DTrend[4]                       ; ���砫� L ��⮬ H
*       Duration[2]
*       Diff2MaxAdress[MaxNumber]
*       MinAvrPress[2]
*       MaxAvrPress[2]
*
*
*  ����p ��pᨨ   ��� ���������   �p�稭�
*
*     1.0.0.        26.01.2000.
*
***********************************************************************

Trend_H         .equ    TMP+1
Trend_L         .equ    TMP+2
OneLevelSignal  .equ    TMP+3
StartAdress     .equ    TMP+4
FinishAdress    .equ    TMP+5

        .text

Trend_measurement_1

        MAR     *,AR2
        LAR     AR2,#_Max2DiffAdress
        LAR     AR4,#_Duration+1         ; � AR4 &Duration[1]

;   Duration[1] = SampleNumber - Max2DiffAdress[0];

        LACC    _SampleNumber
        SUB     *,0,AR4
        SACL    *-,0,AR2                ; � AR4 &Duration[0]

;   Duration[0] = Max2DiffAdress[0] - Max2DiffAdress[1];

        LACC    *+,0,AR2
        SUB     *,0,AR4
        SACL    *,0,AR2                 ; � AR4 &Duration[0]

        LAR     AR2,#MaxAvrPress        ; � AR2 &MaxAvrPress[0]
        LAR     AR3,#DTrend+3           ; � AR3 &DTrend_H[1]

;   DTrend[1] = MaxAvrPress[0] - MaxAvrPress[1];

        LACC    *+,0,AR2                ; � AR2 &MaxAvrPress[1]
        SUB     *,0,AR3
        SACL    *,0,AR4                 ; � AR4 &Duration[0]

;   DTrend[1] = DTrend[1]/Duration[0];    // float.

        CALL    Division
        MAR     *,AR3                   ; � AR3 &DTrend_H[1]
        SACH    *-                      ; � AR3 &DTrend_L[1]
        SACL    *-,0,AR5                ; � AR3 &DTrend_H[0]

	LAR	AR0,#Signal
        LAR     AR5,#_Max2DiffAdress
	LAR	AR2,*+,AR2
	MAR	*0+,AR2

;   DTrend[0] = Signal[Max2DiffAdress[0]] - Signal[Max2DiffAdress[1]];

        LACC    *,0,AR5
	LAR	AR2,*,AR2
	MAR	*0+,AR2                 ; � AR2 &Signal[Max2DiffAdress[1]
        SUB     *,0,AR3
        SACL    *,0,AR4                 ; � AR4 &Duration[0]

;   DTrend[0] = DTrend[0]/Duration[0];  // float

        CALL    Division
        MAR     *,AR3                   ; � AR3 &DTrend_H[0]
        SACH    *-                      ; � AR3 &DTrend_L[0]
        SACL    *,0,AR2                 ; � AR3 &DTrend_L[0]


;   Trend = Signal[Max2DiffAdress[1]];

	 .if SIM != 0
        SAR     AR2,TMP+7
        OUT     TMP+7,2         ; & ��砫� TREND
	.endif

        LACC    *,16,AR4                ; � AR4 &Duration[0]
        SACH    Trend_H
        SACL    Trend_L

;   FinishAdress = 0;                   ; �p�᢮���� �p�������� �pאַ � 横��

;   for ( k=0; k<=1; k++)

        LAR     AR6,#1                  ; � AR6 k = 1 �ᯮ������ ⮫쪮 ���
                                        ; ���稪 横��� � �� �ᯮ������ ��� ������
        LAR     AR5,#Max                ; & Max[]

;    {
;      StartAdress = FinishAdress;
;      FinishAdress = FinishAdress + Duration[k];

For_k_Trend1

        LAR     AR0,*+,AR0              ; AR0 = Duration[k] - ���稪 横�� �� i
	MAR	*-,AR5

;     Max[k] = 0;

        SPLK    #0,*,AR2                ; � AR2  &Signal....

;      for ( i=StartAdress; i < FinishAdress; i++ )
;      {

For_i_Trend1                            ; & Signal... ���p�����p����
                                        ; ᠬ����⥫쭮, � ���⥫쭮��� 横��
                                        ; ��p�������� � AR0

;       OneLevelSignal = Signal[ Max2DiffAdress[1] + i] - Trend;

        LACC    *+,0,AR5                ; � AR5  &MAX[k]
        SUB     Trend_H
        SACL    OneLevelSignal

	 .if SIM != 0
        OUT     OneLevelSignal,2       ; OneLevelSignal
	.endif

;        if ( Max[k] < OneLevelSignal)

        SUB     *,0,AR3                 ; � AR3  &Dtrend_L
        BCND    Trend1_b1,LT

;        {
;           Max[k] = OneLevelSignal;
;        }

        MAR     *,AR5                   ; � AR5  &MAX[k]
        LACC    OneLevelSignal
        SACL    *,0,AR3                 ; � AR3  &Dtrend_L

;           Trend = Trend + DTrend[k];  // float

Trend1_b1

        LACC    Trend_H,16
        OR      Trend_L
        ADDS    *+,AR3                  ; � AR3  &Dtrend_H
        ADD     *-,16,AR0               ; � AR3  &Dtrend_L
        SACH    Trend_H
        SACL    Trend_L

;      }

        BANZ    For_i_Trend1,*-,AR2     ; ���� �� i

;    }

        MAR     *,AR3                   ; � AR3  &Dtrend_L
        MAR     *+,AR3                  ; � AR3  &Dtrend_H
        MAR     *+,AR5                  ; � AR3 & DTrend_L[k+1]
        MAR     *+,AR6                  ; � AR5  &MAX[k+1]
        BANZ    For_k_Trend1,*-,AR4     ; ���� �� k

;}

        RET


***********************************************************************
*
* 	Trend_measurement_2() - ����� ����७�� Trend-a
*                               � ������� ����権.
*
*  �������� ��p������ � ���p� ��p�頥��� �㭪��.
*
*  � p����� �pאַ� ��p��樨
*
*       SampleNumber
*       MaxNumber
*
*  � p����� ��ᢥ���� ��p��樨
*
*       Signal[]
*       Max[3]
*       DTrend[6]                       ; ���砫� L ��⮬ H
*       Duration[3]
*       Diff2MaxAdress[MaxNumber]
*       MinAvrPress[3]
*       MaxAvrPress[3]
*
*
*  ����p ��pᨨ   ��� ���������   �p�稭�
*
*     1.0.0.        26.01.2000.
*
***********************************************************************/

Trend_H         .equ    TMP+1
Trend_L         .equ    TMP+2
OneLevelSignal  .equ    TMP+3
StartAdress     .equ    TMP+4
FinishAdress    .equ    TMP+5


        .text

Trend_measurement_2

        MAR     *,AR2
        LAR     AR2,#_Max2DiffAdress
        LAR     AR4,#_Duration+2         ; � AR4 &Duration[2]

;   Duration[2] = SampleNumber - Max2DiffAdress[0];

        LACC    _SampleNumber
        SUB     *,0,AR4
        SACL    *-,0,AR2                ; � AR4 &Duration[1]

;   Duration[1] = Max2DiffAdress[0] - Max2DiffAdress[1];

        LACC    *+,0,AR2
        SUB     *,0,AR4
        SACL    *-,0,AR2                ; � AR4 &Duration[0]

;   Duration[0] = Max2DiffAdress[1] - Max2DiffAdress[2];

        LACC    *+,0,AR2
        SUB     *,0,AR4
        SACL    *+,0,AR2                ; � AR4 &Duration[1]

        LAR     AR2,#MaxAvrPress        ; � AR2 &MaxAvrPress[0]
        LAR     AR3,#DTrend+5           ; � AR3 &DTrend_H[2]

;   DTrend[2] = MaxAvrPress[0] - MaxAvrPress[1];

        LACC    *+,0,AR2                ; � AR2 &MaxAvrPress[1]
        SUB     *,0,AR3
        SACL    *,0,AR4                 ; � AR4 &Duration[1]

;   DTrend[2] = DTrend[2]/Duration[1];  // float.

        CALL    Division
        MAR     *,AR3                   ; � AR3 &DTrend_H[2]
        SACH    *-                      ; � AR3 &DTrend_L[2]
        SACL    *-,0,AR6                ; � AR3 &DTrend_H[1]

	LAR	AR0,#Signal
        LAR     AR6,#_Max2DiffAdress
	LAR	AR2,*+,AR2
	MAR	*0+,AR2

;   DTrend[1] = Signal[Max2DiffAdress[0]] - Signal[Max2DiffAdress[1]];

        LACC    *,0,AR6
	LAR	AR2,*+,AR2
	MAR	*0+,AR2
        SUB     *,0,AR3
        SACL    *,0,AR4                 ; � AR4 &Duration[1]

;   DTrend[1] = DTrend[1]/Duration[1];  // float

        CALL    Division
        MAR     *,AR3                   ; � AR3 &DTrend_H[1]
        SACH    *-                      ; � AR3 &DTrend_L[1]
        SACL    *-,0,AR2                ; � AR3 &DTrend_H[0]

;   DTrend[0] = Signal[Max2DiffAdress[1]] - Signal[Max2DiffAdress[2]];

        LACC    *,0,AR6
	LAR	AR2,*,AR2
	MAR	*0+,AR2
        SUB     *,0,AR3
        SACL    *,0,AR4
        MAR     *-,AR4                  ; � AR4 &Duration[0]

;   DTrend[0] = DTrend[0]/Duration[0];  // float

        CALL    Division
        MAR     *,AR3                   ; � AR3 &DTrend_H[0]
        SACH    *-                      ; � AR3 &DTrend_L[0]
        SACL    *,0,AR2                 ; � AR3 &DTrend_L[0]

;   Trend = Signal[Max2DiffAdress[2]];

	 .if SIM != 0
        SAR     AR2,TMP+7
        OUT     TMP+7,2         ; & ��砫� TREND
	.endif

        LACC    *,16,AR4                ; � AR4 &Duration[0]
        SACH    Trend_H
        SACL    Trend_L

;   FinishAdress = 0;                   ; �p�᢮���� �p�������� �pאַ � 横��

;   for ( k=0; k<=2; k++)

        LAR     AR6,#2                  ; � AR6 k = 2 �ᯮ������ ⮫쪮 ���
                                        ; ���稪 横��� � �� �ᯮ������ ��� ������
        LAR     AR5,#Max                ; & Max[]

;   {
;     StartAdress = FinishAdress;
;     FinishAdress = FinishAdress + Duration[k];

For_k_Trend2

        LAR     AR0,*+,AR0              ; AR0 = Duration[k] - ���稪 横�� �� i
	MAR	*-,AR5

;     Max[k] = 0;

        SPLK    #0,*,AR2                ; � AR2  &Signal....

;     for ( i=StartAdress; i < FinishAdress; i++ )
;     {

For_i_Trend2                            ; & Signal... ���p�����p����
                                        ; ᠬ����⥫쭮, � ���⥫쭮��� 横��
                                        ; ��p�������� � AR0

;     OneLevelSignal = Signal[ Max2DiffAdress[2] + i] - Trend;

        LACC    *+,0,AR5                ; � AR5  &MAX[k]
        SUB     Trend_H
        SACL    OneLevelSignal

	 .if SIM != 0
        OUT     OneLevelSignal,2       ; OneLevelSignal
	.endif

;     if ( Max[k] < OneLevelSignal)

        SUB     *,0,AR3                 ; � AR3  &Dtrend_L
        BCND    Trend2_b1,LT

;       {
;         Max[k] = OneLevelSignal;
;       }

        MAR     *,AR5                   ; � AR5  &MAX[k]
        LACC    OneLevelSignal
        SACL    *,0,AR3                 ; � AR3  &Dtrend_L

;     Trend = Trend + DTrend[k];  // float

Trend2_b1

        LACC    Trend_H,16
        OR      Trend_L
        ADDS    *+,AR3                  ; � AR3  &Dtrend_H
        ADD     *-,16,AR0               ; � AR3  &Dtrend_L
        SACH    Trend_H
        SACL    Trend_L

;     }

        BANZ    For_i_Trend2,*-,AR2     ; ���� �� i

;   }

        MAR     *,AR3                   ; � AR3  &Dtrend_L
        MAR     *+,AR3                  ; � AR3  &Dtrend_H
        MAR     *+,AR5                  ; � AR3 & DTrend_L[k+1]
        MAR     *+,AR6                  ; � AR5  &MAX[k+1]
        BANZ    For_k_Trend2,*-,AR4     ; ���� �� k

;}

        RET

