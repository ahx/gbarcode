=Gbarcode

This project is a C extension that wraps the GNU Barcode project using SWIG. 
The Gbarcode version coincides with the GNU Barcode version, the source of which is distributed 
along with the gem, as barcode is not usually installed as a dynamically loaded library on 
most systems. You should not need SWIG to be installed to use this gem, only if you wish to muck around with the 
SWIG interface file. See README_SWIG.txt for more information.

This library is distributed under the GPL, see LICENSE.txt.

For recent changes, see CHANGELOG.txt



==USAGE (SIMPLE)
	require 'rubygems'
	require 'gbarcode'
	
	# create a Code 128 barcode
	bc = Gbarcode::Barcode.new("TEST123456786995039838734", "code 128")

	# print out to a GIF
	bc.print_to_file("testout.gif")

	# re-encode as code 39
	bc.encode("code 39")
	
	# grap an inline PNG image that I can send to a web page
	ipng  = bc.to_png

RMagick is used to create the barcode images. See Gbarcode::Barcode for more output and customization methods.

==BARCODE FORMATS

Gbarcode and Rbarcode, being a wrap of GNU Barcode, supports those formats that GNU barcode supports. From the GNU barcode documentation:

	"The currently supported encoding types: EAN (13 digits, 8 digits,
	13 + 2 add-on and 13 + 5 add-on), UPC (UPC-A, UPC-E, UPC-A with 2
	or 5 digit add-on), ISBN (with or without the 5-digit add-on),
	CODE128-B (the whole set of printable ASCII characters), CODE128-C
	(two digits encoded by each barcode symbol), CODE128 (all ASCII
	values), a "raw-input" pseudo-code that generates CODE128 output,
	CODE39 (alphanumeric), "interleaved 2 of 5" (numeric), Codabar
	(numeric plus a few symbols), MSI (numeric) and Plessey (hex
	digits)."

The encodings flags are supplied as constants from Gbarcode, as as a string method arg to Rbarcode::Barcode.encode . 
Allowed values (case insensitive) are :

  CODE 39 || CODE39
  CODE128 || CODE 128
  I25 || INTERLEAVED 2 OF 5 || INTRLV25 || INTRLV 25
  CODABAR || CBR
  MSI
  PLESSEY || PLS
  EAN 
  UPC 
  ISBN 
  CODE93 || CODE 93 
  CODE 128B || CODE128B
  CODE 128C || CODE128C

Encoding defaults to Code 39, which has a very limited ascii set, and the encode method will raise an _EncodingException if encoding is not successful.


==USAGE (MORE COMPLEX)

Gbarcode, being a wrap of a C library,  is a wrapper class for the C extension library (Cgbc), which in itself 
was not very Ruby-ish, since it was a pretty straight forward wrap using SWIG. Gbarcode::Barcode provides methods
that follow more closely "The Ruby Way", but has RMagick as a dependency. If for whatever reason this is 
unacceptable and you can deal with IO stream and Postcript, here is a quick rundown of what is 
happening under the hood of Gbarcode.

Using the straight C libraries (+require "cgbc"+ ) to create a barcode involves three steps:
 * allocating the barcode object
 * setting the encoding scheme
 * printing out the barcode to a file or stream.

Example:
	require 'rubygems'
	require 'cgbc'
	include Cgbc

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
	wr.close
	myEpsBarcodeAsString = rd.readlines().join("\n")


For more details on usage of Cgbc, see the Gbarcode::Barcode source.

