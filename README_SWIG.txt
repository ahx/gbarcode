=SWIG Wrap of GNU Barcode

SWIG (http://www.swig.org) was used to wrap the GNU Barcode C library 
(http://www.gnu.org/software/barcode/barcode.html) into Ruby.

The SWIG interface file  +ext/barcode.i+ may be found in the extension folder. The 
resulting Ruby C extension module can is +ext/barcode_wrap.c+ and the resulting
dynamic lib module is in <tt>ext/cgbc.<_ext_></tt> where <_ext_> is specific to 
the installed platform.

The SWIG command line used was:

	swig -ruby -autorename barcode.i

See the SWIG docs for more information on how to modify the interface file.
