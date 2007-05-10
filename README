=Gbarcode

This project is a C extension that wraps the GNU Barcode project using SWIG. 
The Gbarcode version coincides with the GNU Barcode version, the source of which is distributed 
along with the gem, as barcode is not usually installed as a dynamically loaded library on 
most systems. You should not need SWIG to be installed to use this gem, only if you wish to muck around with the 
SWIG interface file. See README_SWIG.txt for more information.

This library is distributed under the GPL, see LICENSE.txt.

For recent changes, see CHANGELOG.txt

==USAGE

The Gbarcode class, being a straight wrap of the GNU Barcode C library, is not very Ruby centric. 
The example of the usage will illustrate this point.

	require 'rubygems'
	require 'gbarcode'

	# include the module so I type less ;-)
	include Gbarcode
	
	# There are three stages to creating a barcode
	# 1) allocating the space with a string
	# 2) encoding the string as some barcode
	# 3) printing out the barcode to Postscript
	
	# allocate the barcode for text "TEST1234"
	bc = barcode_create("TEST1234")

	# encode the barcode using code 39,since code 39 does not use a checksum, we can pass in this additional flag.
	barcode_encode(bc, BARCODE_NO_CHECKSUM | BARCODE_39)

	#print out the barcode to a Postscript file, using the default width and height and page placement
	barcode_print(bc, File.new("testout.ps", "w"), 0,0,0,0,0)

	#print out the barcode to a Postscript EPS file, using the default width and height and page placement
	barcode_print(bc, File.new("testout.eps", "w"), 0,0,0,0,BARCODE_OUT_EPS)

	# you can even read the output to a stream like so
	rd, wr = IO.pipe
	barcode_print(bc, wr, 0,0,0,0,BARCODE_OUT_EPS)
	wr.close() # must close this to use the read pipe
	myEpsBarcodeAsString = rd.readlines().join("\n")
	rd.close()	# it is good practice to also close this pipe
	
It is good practice to close any IO pipes, or else you may get over-run by zombie processes when
using with long-running applications (e.g. Rails)


==BARCODE FORMATS

Gbarcode and Rbarcode, being a wrap of GNU Barcode, supports those formats that GNU barcode supports. From the GNU barcode documentation:

The encodings flags are supplied as constants from Gbarcode. Notice the use of the bitwise OR operation on the flag in the USAGE section.
Here are a  listing of the flags, taken from the GNU barcode docs:
	BARCODE_EAN
	BARCODE_UPC
	BARCODE_ISBN
	BARCODE_128B
	BARCODE_128C
	BARCODE_128
	BARCODE_128RAW
	BARCODE_39
	BARCODE_I25
	BARCODE_CBR
	BARCODE_MSI
	BARCODE_PLS
	BARCODE_93
	     The currently supported encoding types: EAN (13 digits, 8 digits,
	     13 + 2 add-on and 13 + 5 add-on), UPC (UPC-A, UPC-E, UPC-A with 2
	     or 5 digit add-on), ISBN (with or without the 5-digit add-on),
	     CODE128-B (the whole set of printable ASCII characters), CODE128-C
	     (two digits encoded by each barcode symbol), CODE128 (all ASCII
	     values), a "raw-input" pseudo-code that generates CODE128 output,
	     CODE39 (alphanumeric), "interleaved 2 of 5" (numeric), Codabar
	     (numeric plus a few symbols), MSI (numeric) and Plessey (hex
	     digits).  *Note Supported Encodings::.

	BARCODE_ANY
	     This special encoding type (represented by a value of zero, so it
	     will be the default) tells the encoding procedure to look for the
	     first encoding type that can deal with a textual string.
	     Therefore, a 11-digit code will be printed as UPC (as well as
	     6-digit, 11+2 and 11+5), a 12-digit (or 7-digit, or 12+2 or 12+5)
	     as EAN13, an ISBN code (with or without hyphens, with or without
	     add-5) will be encoded in its EAN13 representation, an even number
	     of digits is encoded using CODE128C and a generic string is
	     encoded using CODE128B. Since code-39 offers a much larger
	     representation for the same text string, code128-b is preferred
	     over code39 for alphanumeric strings.

	BARCODE_NO_CHECKSUM
	     Instructs the engine not to add the checksum character to the
	     output. Not all the encoding types can drop the checksum; those
	     where the checksum is mandatory (like EAN and UPC) just ignore the
	     flag.


Here are some flags that can be given to the barcode_print method:

	`BARCODE_OUT_PS'
	`BARCODE_OUT_EPS'
	`BARCODE_OUT_PCL'
	`BARCODE_OUT_PCL_III'
	     The currently supported encoding types: full-page postscript and
	     encapsulated postscript; PCL (print command language, for HP
	     printers) and PCL-III (same as PCL, but uses a font not available
	     on older printers).

	`BARCODE_NO_ASCII'
	     Instructs the engine not to print the ascii string on output. By
	     default the bar code is accompanied with an ascii version of the
	     text it encodes.
	
	`BARCODE_OUT_NOHEADERS'
	     The flag instructs the printing engine not to print the header and
	     footer part of the file. This makes sense for the postscript
	     engine but might not make sense for other engines; such other
	     engines will silently ignore the flag just like the PCL back-end
	     does
	
Multiple flags are given by bitwise OR-ing them together (e.g. "BARCODE_NO_CHECKSUM | BARCODE_39" ) For more details on GNU barcode itself, see the GNU Barcode site at http://www.gnu.org/software/barcode/barcode.html .

==FUNCTION REFERENCE

Since RDoc for some reason was not picking up my comments from the C code, here is a reference for the functions exported by the library:


Gbarcode::BarcodeItem = Gbarcode.barcode_create( _text_ )
	Class method for creating a BarcodeItem for the given string
		[text] The barcode text to encode
		+returns+ Gbarcode::BarcodeItem

int = Gbarcode.barcode_delete( Gbarcode::BarcodeItem )
	Class method for destroying the BarcodeItem. Return 0 if successful

int = Gbarcode.barcode_encode( Gbarcode::BarcodeItem, <ENCODING FLAGS> )
	Encodes the BarcodeItem to one of the flags above. Returns 0 if successful.
	
int = Gbarcode.barcode_print( Gbarcode::BarcodeItem, File, <OUTPUT FLAGS>)'
	     Print the bar code described by bc to the specified file.  Valid
	     flags are the output type, BARCODE_NO_ASCII and
	     BARCODE_OUT_NOHEADERS, other flags are ignored. If any of these
	     flags is zero, it will be inherited from bc->flags which therefore
	     takes precedence. The function returns 0 on success and -1 in case
	     of error (with bc->error set accordingly). In case of success, the
	     bar code is printed to the specified file, which won't be closed
	     after use.

int = Gbarcode.barcode_position( Gbarcode::BarcodeItem, int width, int height, int xoff, int yoff, double scalef);'
	     The function is a shortcut to assign values to the BarcodeItem object. Sets the dimensions, page offsets and scaling factors all in one go. See below for more complete documentation of BarcodeItem.

int = Gbarcode.barcode_encode_and_print(char *text, FILE *f, int wid, int hei, int xoff, int yoff, int flags);'
	     The function deals with the whole life of the barcode object by
	     calling the other functions; it uses all the specified flags.

Gbarcode::BarcodeItem.ascii
    Returns the ASCII text that is being encoded

Gbarcode::BarcodeItem.ascii=
	Sets the ASCII text to be encoded. Please note that if the barcode was already encoded, you will
	need to re-encode it once this method has been called, or else you will be printing out the wrong barcode!

Gbarcode::BarcodeItem.encoding
	Gets the encoding scheme as a human readable string

Gbarcode::BarcodeItem.partial
	Gets a representation of the barcode as a sequence of integers representing the width of a span.
	The integers alternate between specifying white space and a black bar, starting with white space.

Gbarcode::BarcodeItem.textinfo
	Gets the Postscript representation of the ASCII text that will be printed to the barcode file.

Gbarcode::BarcodeItem.width=
Gbarcode::BarcodeItem.width
	Set/get the width in points, which are 1/72  of an inch, or about 1 pixel on most monitors

Gbarcode::BarcodeItem.width=
Gbarcode::BarcodeItem.width
	Set/get the height in points

Gbarcode::BarcodeItem.xoff=
Gbarcode::BarcodeItem.xoff
	Set/get the page X coordinate offset 

Gbarcode::BarcodeItem.yoff=
Gbarcode::BarcodeItem.yoff
	Set/get the page Y coordinate offset

Gbarcode::BarcodeItem.margin=
Gbarcode::BarcodeItem.margin
	Set/get the margin around the barcode in points

Gbarcode::BarcodeItem.scalef=
Gbarcode::BarcodeItem.scalef
	Set/get the scaling factor of the barcode

