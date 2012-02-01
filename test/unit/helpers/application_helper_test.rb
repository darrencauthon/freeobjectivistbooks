require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "student tagline" do
    tagline = "Studying architecture at Stanton Institute of Technology in New York, NY"
    assert_equal tagline, user_tagline(users :howard)
  end

  test "donor tagline" do
    assert_equal "In Boston, MA", user_tagline(users :hugh)
  end

  test "pluralize omit number" do
    assert_equal "apples", pluralize_omit_number(0, "apple")
    assert_equal "apple", pluralize_omit_number(1, "apple")
    assert_equal "apples", pluralize_omit_number(2, "apple")
  end

  test "pluralize omit 1" do
    assert_equal "0 apples", pluralize_omit_1(0, "apple")
    assert_equal "apple", pluralize_omit_1(1, "apple")
    assert_equal "2 apples", pluralize_omit_1(2, "apple")
  end

  test "format number" do
    assert_equal "0", format_number(0)
    assert_equal "0.5", format_number(0.49876)
    assert_equal "0.5", format_number(0.5)
    assert_equal "0.54", format_number(0.54321)
    assert_equal "1", format_number(1)
    assert_equal "9", format_number(9)
    assert_equal "9.9", format_number(9.949)
    assert_equal "10", format_number(9.95)
    assert_equal "10", format_number(10)
    assert_equal "10", format_number(10.3)
    assert_equal "11", format_number(11)
    assert_equal "99", format_number(99)
    assert_equal "100", format_number(100)
    assert_equal "100", format_number(100.3)
    assert_equal "101", format_number(101)
    assert_equal "999", format_number(999)
    assert_equal "1,000", format_number(1000)
  end
end
