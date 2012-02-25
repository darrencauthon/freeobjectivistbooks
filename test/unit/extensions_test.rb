require 'test_helper'

class ExtensionsTest < ActiveSupport::TestCase
  test "words" do
    assert_equal ["this", "is", "a", "test"], "this is a test".words
    assert_equal ["this", "is", "a", "test"], " this  is \ta test\n".words
    assert_equal ["one"], "one".words
    assert_equal [], "".words
  end

  test "subhash" do
    hash = {a: 1, b: 2, c: 2}
    subhash = {a: 1, b: 2}
    assert_equal subhash, hash.subhash(:a, :b)
  end

  test "to bool" do
    assert true.to_bool
    assert "true".to_bool
    assert "t".to_bool
    assert "T".to_bool
    assert 1.to_bool
    assert "1".to_bool

    assert !(false.to_bool)
    assert !("false".to_bool)
    assert !("f".to_bool)
    assert !("F".to_bool)
    assert !(0.to_bool)
    assert !("0".to_bool)
    assert !(nil.to_bool)
  end
end
