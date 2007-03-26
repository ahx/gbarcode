require 'rmagick'

module Gbarcode
  include Cgbc
  protected :barcode_create, :barcode_delete, :barcode_encode, :barcode_position, :barcode_print,
  :barcode_encode_and_print,  :barcode_version, :barcode_svg_print, :initialize

  @@VERSION = BARCODE_VERSION

  # Exception thrown to signify encoding errors. Maybe a bit too stringent a method, but I didn't particularly feel like learning how 
  # to catching exceptions from C using SWIG! 
  class EncodingException < Exception
  end

  # The Main barcoding class, instatiate this with a text string and optional encoding scheme. See link:README.txt for more information
  class Barcode
    include Gbarcode
    
    # A class method for encoding a string into a barcode and writing the result out to the given filename. 
    # Default encoding = Code 39. The format of the output is taken from the filename's extension. Please note that 
    # RMagick does not do a good job of converting EPS to SVG images. If you want SVG images, use the instance method
    # to_svg instead.
    def self.encode_and_print str, filename, wdth = 0, hght=0, xoff=0, yoff=0, enc="CODE39"
      r,w = IO.pipe
      Rbarcode.barcode_print(str,w, wdth,hght,xoff,yoff, enc_to_const(enc) | BARCODE_OUT_EPS  )
      w.close
      img = Magick::Image.read(r)
      r.close
      img.write(filename)
    end

    def initialize str="", enc=nil
      @bc = barcode_create(str)
      encode(enc)
    end

    #:nodoc:
    def enc_to_const enc
      case enc.upcase
      when  "CODE 39" || "CODE39"
        const =  BARCODE_NO_CHECKSUM | BARCODE_39
      when "CODE128" || "CODE 128"
        const = BARCODE_128
      when "I25" || "INTERLEAVED 2 OF 5" || "INTRLV25" || "INTRLV 25" 
        const = BARCODE_I25
      when "CODABAR" || "CBR"
        const = BARCODE_CBR
      when "MSI"
        const = BARCODE_MSI
      when "PLESSEY" || "PLS" 
        const = BARCODE_PLS
      when "EAN" 
        const = BARCODE_EAN
      when "UPC" 
        const = BARCODE_UPC
      when "ISBN" 
        const = BARCODE_ISBN
      when "CODE93" || "CODE 93" 
        const = BARCODE_93
      when "CODE 128B" || CODE128B
        const = BARCODE_128B
      when "CODE 128C" || "CODE128C"
        const = BARCODE_128C
      else
        const =  BARCODE_NO_CHECKSUM | BARCODE_39
      end
      return const
    end
    #:nodoc:
    def create_image
      unless( @img) then
        r,w = IO.pipe
        barcode_print(@bc,w, BARCODE_OUT_EPS)
        w.close
        @img = Magick::Image.read(r)[0]
        r.close
      end
      return self
    end

    public

    # Encodes the barcode into one of the supported schemes. Default encoding is Code 39. See <<README>> for supported types
    def encode enc
      enc = "CODE39" unless enc
      enc_method  = enc_to_const(enc)
      rs = barcode_encode(@bc, enc_method)
      if (rs == 0 ) then 
        create_image()
      else
        raise EncodingException.new("#{self.class}: Text \"#{@bc.ascii}\" could not be encoded as \"#{enc}\"")
      end
      return self
    end

    # Returns the ascii text being encoded
    def ascii
      @bc.ascii
    end

    # sets the ascii text being encoded. If this is called
    def ascii= str
      @bc.ascii = str
      encode(@bc.encoding)
    end

    def width
      @bc.width
    end

    # Sets the width of the barcode image (in points 1/72 of an inch)
    def width= w
      @bc.width = w
    end
    
    # Get the height of the barcode image, if set (in points: 1/72 of an inch) 
    def height
      @bc.height
    end

    # Sets the height of the barcode image (in points 1/72 of an inch)
    def height= h
      @bc.height = h
    end

    # Retrieve a text encoding of the barcode as integers. Each integer represents a spacing, where they 
    # alternate between space and black fills (bars), starting with a leading space. The int value represents 
    # the relative width of a bar/space. 
    # Example : 03132112 = no leading space + <tt>XXX_XXX__X_XX</tt> (where "_" = space and "X" = bar)
    def partial
      @bc.partial
    end
    
    def to_s
      return "#{self.class}: (#{@bc.encoding}) #{@bc.ascii}"
    end

    # Creates an SVG image for the barcode. If no filename is given, output will be returned as a string
    def to_svg fname = nil
      if fname 
        w = File.open(fname,'w')
        barcode_svg_print(@bc,w)
        w.close()
        return self
      else
        r,w = IO.pipe
        barcode_svg_print(@bc,w)
        w.close()
        svg = r.readlines().join("\n")
        r.close
        return svg
      end
    end

    # Write the image out to a file of the given name. Format of the output is taken from the extension.
    def print_to_file fname
      @img.write(fname)
    end

    #:nodoc:all
    def to_imgformat fname=nil, frmt=nil
      if fname 
        @img.write(fname)
        return self
      elsif frmt 
        @img.format = frmt
        return @img.to_blob
      end
    end

    # Write out the barcode to an EPS image. If no filename is given, output will be returned as a string.
    def to_eps fname = nil
      if fname
        w = File.open(fname,'w')
        barcode_print(@bc,w, BARCODE_OUT_EPS)
        w.close()
        return self
      else
        r,w = IO.pipe
        barcode_print(@bc,w, BARCODE_OUT_EPS)
        w.close
        tmp =  r.readlines().join("\n")
        r.close
        return tmp
      end
    end

    # Write out the barcode to a PNG image. If no filename is given, output will be returned as a string.
    def to_png fname = nil
      if fname then 
        fname += ".png" unless (fname =~ /\.png$/i )
      end
      return to_imgformat(fname, "PNG")
    end

    # Write out the barcode to a GIF image. If no filename is given, output will be returned as a string.
    def to_gif fname = nil
      if fname then 
        fname += ".gif" unless (fname =~ /\.gif$/i )
      end
      return to_imgformat( fname, "GIF")
    end

    # Write out the barcode to a JPEG image. If no filename is given, output will be returned as a string.
    def to_jpg fname = nil
      if fname then 
        fname += ".jpg" unless (fname =~ /\.jpg$/i )
      end
      return to_imgformat(fname, "JPG")
    end

    private :enc_to_const, :create_image, :to_imgformat    
  end
end