/********************************************************************/
/* float.h  v7.00                                                   */
/* Copyright (c) 1988-1996 Texas Instruments Inc.                   */
/*    KEY:  FLT_     - APPLIES TO TYPE FLOAT                        */
/*          DBL_     - APPLIES TO TYPE DOUBLE                       */
/*          LDBL_    - APPLIES TO TYPE LONG DOUBLE                  */
/********************************************************************/
#ifndef _FLOAT
#define _FLOAT

#define FLT_RADIX                         2   /* RADIX OF EXPONENT         */
#define FLT_ROUNDS                        0   /* TRUNCATE TOWARDS ZERO     */

#define FLT_DIG                           6   /* DECIMAL PRECISION         */
#define FLT_MANT_DIG                     24   /* BITS IN MANTISSA          */
#define FLT_MIN_EXP                    -125   /* SMALLEST EXPONENT         */
#define FLT_MAX_EXP                     128   /* LARGEST EXPONENT          */
#define FLT_EPSILON         1.19209290E-07F   /* SMALLEST X WHERE 1+X != 1 */
#define FLT_MIN             1.17549435E-38F   /* SMALLEST POSITIVE VALUE   */
#define FLT_MAX             3.40282347E+38F   /* LARGEST POSITIVE VALUE    */
#define FLT_MIN_10_EXP                  -37   /* MIN POWER OF 10           */
#define FLT_MAX_10_EXP                   38   /* MAX POWER OF 10           */

#define DBL_DIG                           6   /* DECIMAL PRECISION         */
#define DBL_MANT_DIG                     24   /* BITS IN MANTISSA          */
#define DBL_MIN_EXP                    -125   /* SMALLEST EXPONENT         */
#define DBL_MAX_EXP                     128   /* LARGEST EXPONENT          */
#define DBL_EPSILON         1.19209290E-07F   /* SMALLEST X WHERE 1+X != 1 */
#define DBL_MIN             1.17549435E-38F   /* SMALLEST POSITIVE VALUE   */
#define DBL_MAX             3.40282347E+38F   /* LARGEST POSITIVE VALUE    */
#define DBL_MIN_10_EXP                  -37   /* MIN POWER OF 10           */
#define DBL_MAX_10_EXP                   38   /* MAX POWER OF 10           */

#define LDBL_DIG                          6   /* DECIMAL PRECISION         */
#define LDBL_MANT_DIG                    24   /* BITS IN MANTISSA          */
#define LDBL_MIN_EXP                   -125   /* SMALLEST EXPONENT         */
#define LDBL_MAX_EXP                    128   /* LARGEST EXPONENT          */
#define LDBL_EPSILON        1.19209290E-07F   /* SMALLEST X WHERE 1+X != 1 */
#define LDBL_MIN            1.17549435E-38F   /* SMALLEST POSITIVE VALUE   */
#define LDBL_MAX            3.40282347E+38F   /* LARGEST POSITIVE VALUE    */
#define LDBL_MIN_10_EXP                 -37   /* MIN POWER OF 10           */
#define LDBL_MAX_10_EXP                  38   /* MAX POWER OF 10           */

#endif
