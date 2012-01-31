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
end
