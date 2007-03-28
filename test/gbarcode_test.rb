require File.dirname(__FILE__) + '/test_helper.rb'

class GbarcodeTest < Test::Unit::TestCase

  def setup 
    @@BC_TEXT = "Gbarcode"
    @@BC = Gbarcode::Barcode.new(@@BC_TEXT, "CODE128B")
  end

  def test_barcode_create
    assert(@@BC != nil, "BC not created")
  end

  def test_ascii
    assert_equal(@@BC.ascii, "Gbarcode")
  end

  def test_to_eps 
    b = Gbarcode::Barcode.new("Gbarcode", "code 128b").to_eps
    f = File.open(File.dirname(__FILE__) + "/assets/gb-code128b.eps").readlines.join("\n")
    assert_equal(b,f)
  end
end
