require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  def setup
    super
    @sf = locations :san_francisco
  end

  test "lat/lon" do
    assert_equal 37.7749295, @sf.lat
    assert_equal -122.4194155, @sf.lon
  end

  test "locality?" do
    assert @sf.locality?
  end
end
