/*
 * ===================================================================
 *  TS 26.104
 *  REL-5 V5.4.0 2004-03
 *  REL-6 V6.1.0 2004-03
 *  3GPP AMR Floating-point Speech Codec
 * ===================================================================
 *
 */
/* This is valid for PC */

#ifndef _TYPEDEF_H
#define _TYPEDEF_H

typedef char Word8;
typedef unsigned char UWord8;
typedef short Word16;
typedef int Word32;
typedef float Float32;
typedef double Float64;

/*
 * definition of modes for decoder
 */
enum Mode { MR475 = 0,
	MR515,
	MR59,
	MR67,
	MR74,
	MR795,
	MR102,
	MR122,
	MRDTX,
	N_MODES     /* number of (SPC) modes */
};

#endif
