require 'test_helper'

class PledgeTest < ActiveSupport::TestCase
  def setup
    super
    @hugh_pledge = pledges :hugh_pledge
    @cameron_pledge = pledges :cameron_pledge
  end

  def reason
    "I want to spread these great ideas."
  end

  test "user" do
    assert_equal @hugh, @hugh_pledge.user
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

  test "fulfilled?" do
    assert @cameron_pledge.fulfilled?
    assert !@hugh_pledge.fulfilled?
  end

  test "fulfilled" do
    verify_scope(Pledge, :unfulfilled) {|pledge| !pledge.fulfilled?}
  end
end
