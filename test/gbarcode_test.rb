require File.dirname(__FILE__) + '/test_helper.rb'

class GbarcodeTest < Test::Unit::TestCase

  def setup 
    @@BC_TEXT = "Gbarcode"
    @@BC = Gbarcode.barcode_create(@@BC_TEXT)
    Gbarcode.barcode_encode(@@BC, Gbarcode::BARCODE_128B)
  end

  def teardown
    Gbarcode.barcode_delete(@@BC)
  end
  
  def test_barcode_create
    assert(@@BC != nil, "BC not created")
  end
  
  def test_barcode_delete
    r = Gbarcode.barcode_delete(Gbarcode.barcode_create(@@BC_TEXT))
    assert(r == 0, "barcode_delete failed")
  end
  
  def test_ascii
    assert_equal(@@BC.ascii, "Gbarcode")
  end
  
  def test_barcode_encode
    b = Gbarcode.barcode_create("1234")
    r = Gbarcode.barcode_encode(b, Gbarcode::BARCODE_39)
    assert(r == 0, "encoding unsuccessful")
  end
  
  def test_encoding
    assert_equal(@@BC.encoding, "code 128-B")
  end
  
  def test_barcode_print
    r,w = File.pipe
    Gbarcode.barcode_print(@@BC,w,0)
    w.close()
    b = lines_without_comments r
    r.close()
    f = lines_without_comments File.open(File.dirname(__FILE__) + "/assets/gb-code128b.eps")
    assert_equal(b, f)
  end
  
  
  private
  
  def lines_without_comments(eps_file)
    eps_file.readlines.reject!{|l| l =~ /^%/ }
  end
end
