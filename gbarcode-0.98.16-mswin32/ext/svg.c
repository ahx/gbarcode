/*
 * svg.c -- print out the barcode SVG-style
 *
 * Copyright (c) 2001 David J. Humphreys (humphrd@tcd.ie)
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 *
 * http://www.onefour.net/barcode/
 * 
 * Made with a mac! (Tested under os X, 10.1)
 * 
 * I wanted to output barcodes as SVG for some art work.
 * This will output everything as an SVG file. This file can
 * then be inserted into another SVG file.
 *
 * I don't want to get into the specifics of SVG files here. I
 * suppose there will be a few specifics on my website (above) along
 * with a few examples.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

#include "barcode.h"

/* If there is any need to print out a comment,
 * then this is the method */
int svg_comment(char *Message, FILE *f){
  fprintf(f, "<!-- %s -->\n",Message);
  return 0;
}

/* Prints the title (bc->ascii) and the 
 * desc(ription) */
int svg_desc(struct Barcode_Item *bc, FILE *f){
  fprintf(f, "<title>%s</title>\n",bc->ascii);
  fprintf(f, "<desc>\n");
    fprintf(f, "\t%s:\t%s\n",bc->encoding,bc->ascii);
    fprintf(f, "\tGNU-barcode:\t%s\n",BARCODE_VERSION);
    fprintf(f, "\tbarcode:\thttp://www.gnu.org/\n");
    fprintf(f, "\tsvg-code:\thttp://www.onefour.net/barcode\n");
  fprintf(f, "</desc>\n");
  return 0;
}

/* print out the start of the svg file,
 * with some xml voodoo.   There are a
 * lot of \"s in this code.
 * It bounds the svg file by
 * bc->width or  104 and
 * bc->height or 100
 * The title of the file is bc->ascii 
 * NOTE: margins and scale are ignored
 *       the user can simply insert the 
 *       svg file into another and then
 *       specify scale and margin.*/
int svg_start( struct Barcode_Item *bc, FILE *f){
  if(bc->height == 0) bc->height = 100;
  if(bc->width == 0)  bc->width = 104;
  fprintf(f, "<?xml version=\"1.0\" standalone=\"no\"?>\n");
  fprintf(f, "<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.0//EN\" \"http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd\">\n");
  fprintf(f, "<svg width=\"%i\" height=\"%i\">\n",bc->width ,bc->height);
  svg_desc(bc,f);
  return 0;
}

/* just close the svg file */
int svg_end(FILE *f){
  fprintf(f, "</svg>\n");
  return 0;
}

/* prints out the code for the bars.
 * the bars are drawn with rect(angles)
 * rather than lines.   The mathematics
 * for placing a line then setting the 
 * stroke width gets messy. */
int svg_bars(struct Barcode_Item *bc, FILE *f){
  int 
    i = 0,			/* Loop counter */
    height = 70,		/* Each box is 70 pixels in hieght */
    xpos = 0;			/* Where the current box is drawn */
  int current;			/* The current character in partial */
  int is_bar = 0;

  fprintf(f, "<g fill=\"black\">\n");

  for(i = 0; i < strlen(bc->partial); i++){
    current = (int)bc->partial[i] - 48;
    if(current > 9){
        height = 75;		/* Guide bar */
        current = (int)bc->partial[++i] - 48;
        i++;			/* Skip the following 'a' */
    }
    else
        height = 70;
    if(is_bar == 1){
        fprintf(f, "\t<rect x=\"%i\" y=\"0\" ",xpos); /* all bars start at y=0 */
        fprintf(f, "height=\"%i\" width=\"%i\" stroke-width=\"0\"/>\n",height,current);
        is_bar = 0;
    }
    else
        is_bar = 1;
    xpos += current;
  }
  fprintf(f, "</g>\n");
  return 0;
}

/* positions the characters that will
 * be printed.   This assumes they will
 * be under the barcode.*/
int svg_text(struct Barcode_Item *bc, FILE *f){
  unsigned 
    i = 0,
    j = 0,
    infosz = strlen(bc->textinfo),
    xpos = 0,
    prev_x = 0,
    correction = 0;		/* This correction seems to be needed to align text properly */
  double dub1, dub2;
  char printer;
  char *temp_info = malloc(infosz);
  if(!temp_info)
    return -1;
  fprintf(f, "<g font-family=\"Helvitica\" font-size=\"12\">\n");
  
  while(i < infosz){
    for(j = 0; bc->textinfo[i + j + 1] != ' ' &&
	  bc->textinfo[i + j + 1] != '\0';j++);	/* Empty loop, just increment j */

    j ++;
    strncpy(temp_info, (bc->textinfo + i),j);
    sscanf(temp_info, "%lf:%lf:%c", &dub1, &dub2, &printer);
    i += j;

    xpos = (int)dub1;
    if((xpos - prev_x) >= 10)
      correction += 2;

    prev_x = xpos;
    fprintf(f, "\t<text x=\"%i\" y=\"%i\">%c</text>\n",(xpos - correction),80,printer);
  }
  fprintf(f, "</g>\n");
  free(temp_info);
  return 0;
}

/* This is the function to call.   It calls the 
 * functions above in order.   Thers is no real
 * error detection in this code. */
int Barcode_svg_print(struct Barcode_Item *bc, FILE *f){
  svg_start(bc,f);
  svg_bars(bc,f);
  svg_text(bc,f);		/* Should test for text output bit in flags */
  svg_end(f);
  return 0;
}
