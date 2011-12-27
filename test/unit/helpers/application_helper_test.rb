require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "student tagline" do
    tagline = "Studying architecture at Stanton Institute of Technology in New York, NY"
    assert_equal tagline, user_tagline(users :howard)
  end

  test "donor tagline" do
    assert_equal "In Boston, MA", user_tagline(users :hugh)
  end
end
