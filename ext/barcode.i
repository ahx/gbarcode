%module "cgbc"

%{
	
#include "barcode.h"

%}


%include typemaps.i
extern int Barcode_Print(struct Barcode_Item *bc, FILE *WRITE, int flags);
extern int Barcode_Encode_and_Print(char *text, FILE *WRITE, int wid, int hei, int xoff, int yoff, int flags);
extern int Barcode_svg_print(struct Barcode_Item *bc, FILE *WRITE);
%include barcode.h
