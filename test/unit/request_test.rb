require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  def setup
    @request = requests :howard_wants_atlas
  end

  test "user" do
    assert_equal users(:howard), @request.user
  end

  test "user is required" do
    @request.user = nil
    assert @request.invalid?
  end

  test "book is required" do
    @request.book = nil
    assert @request.invalid?
  end
end
