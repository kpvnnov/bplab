TMS320F206 Flash Programming Examples
*************************************
The files included in this package contain examples for integrating
the TMS320F206 on-chip flash EEPROM programming algorithms with
application code. The first example shows how to call the standard
flash algorithm object modules from assembly code. The second example
includes a C-callable interface to the standard algorithms, and shows
how to use this interface to call the standard algorithms from C code.

NOTE:-The 'F2XX flash array cannot be accessed while being
      programmed or erased, (i.e. the programming routines
      cannot reside in the flash module which is to be
      modified.)

I) Assembly Example For TI 320F206 Flash Programming and Erasing.
*****************************************************************
An example (ASMEXAMP.ASM) is provided for using the flash EEPROM
algorithms from assembly code. 

II) C-callable Functions For TI 320F206 Flash Programming and Erasing.
**********************************************************************
The two functions described here, erase() and program(), are
intended for in-application programming of the 'F206 flash.
These functions were written to be C-callable, but may also
be called from assembly, as long as the C stack calling
convention is used.

These functions are "wrapped around" the standard 'F206 flash
algorithms, and they have been provided to address two problems
with 'F2XX flash programming:
1) The standard algorithm files are not C-callable routines.
2) Erasing the flash requires several steps, including three
   separate algorithms: clear, erase, and possibly flash-write.
   Most 'F206 users have expressed interest for a single
   ERASE command which takes care of all these steps.

See the comments in the assembly source file (flash.asm) for
a full description of the two functions.

Among the files listed below, there is a 320F206 example
(sample.c), which shows how to use these functions from C.
The COFF file (sample_S.OUT) is ready to load onto the SARAM
of the 'F206 to give an example of flash programming. The
example performs an erase of flash1 and then programs the
first 3 locations. This example has been linked into SARAM,
for convenience (break-points), but it can re-linked
anywhere except flash1.

The following files are included in FLASH_C.EXE:
************************************************
DISCLAIM TXT    -TI disclaimer.
README   TXT    -This file (Describes these examples).        

ASMEXAMP ASM    -Assembly code example of using the std flash algos.
ASMEXAMP OBJ    -Object module for the above file.
ASMEXAMP CMD    -Linker command file for assembly example.
ASMEXAMP OUT    -COFF for ASMEXAMP.ASM.
ASMEXAMP MAP    -Linker map file for asmexamp.out.

FLASH    ASM    -Source for C-callable functions erase and program.
FLASH    OBJ    -Object module for the above file.

SAMPLE   C      -Source for C example of using erase, and program.    
SAMPLE   OBJ    -OBJ for above source.    

F206_F0  CMD    -Linker command file for C example (links to Flash0).    
F206_SA  CMD    -Linker command file for C example (links to SARAM).    

SAMPLE_S OUT    -COFF for sample.c (linked to SARAM).
SAMPLE_F OUT    -COFF for sample.c (linked to FLASH0).
SAMPLE_S MAP    -Linker map file for sample_S.out (linked to SARAM).
SAMPLE_F MAP    -Linker map file for sample_F.out (linked to FLASH0).    

SVAR20   H      -Include file for flash.asm; required for accessing
                 variables and parameters used by algorithms.
ALGOS    <DIR>  -Where algorithms are stored. Note, these are the same
 |               files which are included with the Rev2.0 programming tools.
 |               If CLKOUT frequency is not 20MHz, then the algorithms
 |               won't function properly, and may damage the flash.
 |-SCLR20.OBJ   -320F206 Clear algorithm.           
 |-SERA20.OBJ   -320F206 Erase algorithm.
 |-SFLW20.OBJ   -320F206 Flash-write algorithm.
 |-SPGM20.OBJ   -320F206 Programming algorithm.
 |-SUTILS20.OBJ -320F206 Delay, Reg access routines for algorithms.
