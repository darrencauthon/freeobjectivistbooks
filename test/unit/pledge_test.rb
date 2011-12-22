require 'test_helper'

class PledgeTest < ActiveSupport::TestCase
  def setup
    @pledge = pledges :hugh_5
    @hugh = users :hugh
  end

  def reason
    "I want to spread these great ideas."
  end

  test "user" do
    assert_equal @hugh, @pledge.user
  end

  test "build" do
    pledge = @hugh.pledges.build quantity: "5", reason: reason
    assert pledge.valid?
  end

  test "quantity is required" do
    pledge = @hugh.pledges.build quantity: "", reason: reason
    assert pledge.invalid?
  end

  test "quantity must be a number" do
    pledge = @hugh.pledges.build quantity: "x", reason: reason
    assert pledge.invalid?
  end

  test "quantity must be positive" do
    pledge = @hugh.pledges.build quantity: "0", reason: reason
    assert pledge.invalid?
  end
end
