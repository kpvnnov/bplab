/******************************************************************************/
/* ioports.h  v7.00                                                           */
/* Copyright (c) 1988-1996 Texas Instruments Inc.                             */
/*                                                                            */
/* Include file to setup I/O ports for the TMS320C25                          */
/*                                                                            */
/******************************************************************************/

/*----------------------------------------------------------------------------*/
/* DEFINE THE _PSWITCH CONSTANT.  THIS CONTROLS HOW THE INPORT AND OUTPORT    */
/* MACROS ARE EXPANDED.                                                       */
/*                                                                            */
/* IF _PSWITCH IS 0 (DEFAULT), THE CODE IS OPTIMIZED FOR USING CONSTANT PORT  */
/* NUMBERS.  IF _PSWITCH IS 1, THE CODE HANDLES VARIABLE AND CONSTANT PORT    */
/* NUMBERS EQUALLY.                                                           */
/*----------------------------------------------------------------------------*/
#define _PSWITCH 0

#if _PSWITCH == 0
#define inport(a,b) \
      do            \
        switch (a)  \
          {         \
            case 0  : *(b) = _inport0();  break; \
            case 1  : *(b) = _inport1();  break; \
            case 2  : *(b) = _inport2();  break; \
            case 3  : *(b) = _inport3();  break; \
            case 4  : *(b) = _inport4();  break; \
            case 5  : *(b) = _inport5();  break; \
            case 6  : *(b) = _inport6();  break; \
            case 7  : *(b) = _inport7();  break; \
            case 8  : *(b) = _inport8();  break; \
            case 9  : *(b) = _inport9();  break; \
            case 10 : *(b) = _inport10(); break; \
            case 11 : *(b) = _inport11(); break; \
            case 12 : *(b) = _inport12(); break; \
            case 13 : *(b) = _inport13(); break; \
            case 14 : *(b) = _inport14(); break; \
            case 15 : *(b) = _inport15(); break; \
          }         \
      while (0)

#define outport(a,b) \
      do             \
        switch (a)   \
          {          \
            case 0  : _outport0(b);  break; \
            case 1  : _outport1(b);  break; \
            case 2  : _outport2(b);  break; \
            case 3  : _outport3(b);  break; \
            case 4  : _outport4(b);  break; \
            case 5  : _outport5(b);  break; \
            case 6  : _outport6(b);  break; \
            case 7  : _outport7(b);  break; \
            case 8  : _outport8(b);  break; \
            case 9  : _outport9(b);  break; \
            case 10 : _outport10(b); break; \
            case 11 : _outport11(b); break; \
            case 12 : _outport12(b); break; \
            case 13 : _outport13(b); break; \
            case 14 : _outport14(b); break; \
            case 15 : _outport15(b); break; \
          }          \
      while (0)
#else

#define inport(a,b) *(b)=_in_port(a)
#define outport(a,b) _out_port(a,b)

#endif

/*--------------------------------------------------------------------------*/
/* DECLARE FUNCTIONS DEFINED IN IOPORTS.ASM                                 */
/*--------------------------------------------------------------------------*/
extern void _out_port();
extern void _outport0();
extern void _outport1();
extern void _outport2();
extern void _outport3();
extern void _outport4();
extern void _outport5();
extern void _outport6();
extern void _outport7();
extern void _outport8();
extern void _outport9();
extern void _outport10();
extern void _outport11();
extern void _outport12();
extern void _outport13();
extern void _outport14();
extern void _outport15();

extern int _in_port();
extern int _inport0();
extern int _inport1();
extern int _inport2();
extern int _inport3();
extern int _inport4();
extern int _inport5();
extern int _inport6();
extern int _inport7();
extern int _inport8();
extern int _inport9();
extern int _inport10();
extern int _inport11();
extern int _inport12();
extern int _inport13();
extern int _inport14();
extern int _inport15();
