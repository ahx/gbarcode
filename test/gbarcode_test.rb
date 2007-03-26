require File.dirname(__FILE__) + '/test_helper.rb'

class GbarcodeTest < Test::Unit::TestCase

  def setup
    @@BC_TEXT = "TEST1234"
  end
  # def teardown 
  # end
  
  def test_truth
    assert true
  end
  
  def test_barcode_create
    bc = Gbarcode.barcode_create("TEST1234")
    assert(bc != nil, "BC not created")
    assert(bc.ascii == @@BC_TEXT, "BC text not same")

  end

end
