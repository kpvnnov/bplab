/***********************************************/
/* Filname: sample.c                           */
/* Description: This is an example of how to   */
/* program the 'F2XX flash from assembly code. */
/* The C-callable interface for the standard   */
/* flash algorithms is used. This interface is */
/* defined in the file <flash.asm>, as two     */
/* C-callable functions: erase(), and program()*/
/* At link time, this example must be combined */
/* with the code in <flash.asm> as well as with*/
/* the object modules for the standard algos.  */
/***********************************************/
/* This example is setup for the TMS320F206,   */
/* and uses the SARAM as a buffer for program- */
/* -ming data. The code first erases module1,  */
/* then programs the first three locations.    */
/***********************************************/
/* Rev1.0                            10/97 RDP */
/***********************************************/

extern  int  erase();        /* Declare external func for flash erase. */
extern  int  program();      /* Declare external func for flash program. */

main()
{
    int *a;        
    if (erase(0xff00,0x4000,0x7fff)) 
    { /*Flash is erased, now let's program it.*/

	    /* Init program buffer. */ 
		a=(int *)0xC00;  /*Use last 3K of SARAM for data buffer*/
		a[0]=0x7A80;
		a[1]=0x0FDF;
		a[2]=0x7A80;
	
        /*Program the flash from the buffer*/
        if (program(0xff00,0xc00,0x4000,0x3))
        { /*Flash programmed ok.*/
            while(1){} /*Spin here forever*/  
        }
        else
        { /*Flash fails programming, EXIT*/
            while(1){} /*Spin here forever*/  
        }
    } 
    else
    { /*Flash fails erase, EXIT*/
        while(1){} /*Spin here forever*/  
    }
}

