require 'test/unit'
require '../lib/dyi/length'

class TC_Length < Test::Unit::TestCase
  include DYI
  
  def setup
    @one_px = Length.new(1)
  end
  
  def test_initialize
    assert_not_nil @one_px
    assert Length.new(3)
    assert_instance_of(Length, @one_px)
    
    assert equal_f?(1, @one_px)
    assert equal_f?(@one_px, Length.new(@one_px))
    assert equal_f?(Length.new(0), Length::ZERO)
    
    assert_same(@one_px, Length.new(@one_px))
  end
  
  def test_unit_conversion
    assert equal_f?(Length.new('4px'), Length.new(4))
    
    assert equal_f?(1, Length.new('1px').to_f)
    assert equal_f?(1.25, Length.new('1pt').to_f)
    assert equal_f?(35.43307, Length.new('1cm').to_f)
    assert equal_f?(3.543307, Length.new('1mm').to_f)
    assert equal_f?(90.0, Length.new('1in').to_f)
    assert equal_f?(15.0, Length.new('1pc').to_f)
    
    assert equal_f?(Length.new('1px') * 1.25, Length.new('1pt'))
    assert equal_f?(Length.new('1px') * 35.43307, Length.new('1cm'))
    assert equal_f?(Length.new('1px') * 3.543307, Length.new('1mm'))
    assert equal_f?(Length.new('1px') * 90.0, Length.new('1in'))
    assert equal_f?(Length.new('1px') * 15.0, Length.new('1pc'))
    
    assert equal_f?(1.25, Length.new('1px') * 1.25)
    assert equal_f?(1.25, Length.new('1cm') * 1.25 / 35.43307)
    assert equal_f?(1.25, Length.new('1mm') * 1.25 / 3.543307)
    assert equal_f?(1.25, Length.new('1in') * 1.25 / 90.0)
    assert equal_f?(1.25, Length.new('1pc') * 1.25 / 15.0)
  end
  
  def test_unary
    assert equal_f?(@one_px, +@one_px)
    assert equal_f?(Length.new(-2), -Length.new(2))
  end
  
  def test_binary_operator
    assert equal_f?(3+5, Length.new(3) + Length.new(5))
    assert equal_f?(4.2+5.3, Length.new(4.2) + Length.new(5.3))
    assert equal_f?(Length.new(5 + 2), Length.new(5) + 2)
    
    assert equal_f?(12 - 5, Length.new(12) - Length.new(5))
    assert equal_f?(4.2 - 5.3, Length.new(4.2) - Length.new(5.3))
    assert equal_f?(Length.new(7 - 4), Length.new(7) - Length.new(4))
    assert equal_f?(Length.new(7 - 4), Length.new(7) - 4)
    
    assert equal_f?(4 * 7, Length.new(4) * 7)
    assert equal_f?(3.82 * 1.2, Length.new(3.82) * 1.2)
    assert_raise(TypeError){
      Length.new(4) * Length.new(7)
    }
    
    assert equal_f?(5 ** 3, Length.new(5) ** 3)
    assert_raise(TypeError){
      Length.new(5) ** Length.new(3)
    }
    
    assert equal_f?(6 / 5, Length.new(6).div(Length.new(5)))
    assert_raise(TypeError){
      Length.new(6).div(2)
    }
    
    assert equal_f?(7 % 5, Length.new(7) % Length.new(5))
    assert_raise(TypeError){
      Length.new(2) % 3
    }
    
    assert equal_f?(3.82 / 1.2, Length.new(3.82) / 1.2)
    assert equal_f?(4 / 2, Length.new(4) / Length.new(2))
  end
  
  private
  
  def equal_f?(left, right)
    (left.to_f - right.to_f).abs <= 0.0000001
  end
end