/***************************************************************************/
/*                  Измерение арториального давления        14.03.97 12:22 */
/***************************************************************************/
/* */
-m F206pow.map
-o F206pow.out
F206pow.obj

MEMORY
{
 PAGE 0: CODE(RX):    org = 0h     , len = 4000h /*Program Memory*/


 PAGE 1: B1(RW):      org = 200h   , len = 080h


}
SECTIONS
{
  .text:   {} > CODE, PAGE 0   /*Program Memory*/
  .bss:    {} > B1    PAGE 1  /*Data Memory*/

}
