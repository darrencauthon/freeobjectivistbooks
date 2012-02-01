require 'test_helper'

class PledgeTest < ActiveSupport::TestCase
  def setup
    super
    @pledge = pledges :hugh_5
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

  test "metrics" do
    metrics = Pledge.metrics
    values = metrics.inject({}) {|hash,metric| hash.merge(metric[:name] => metric[:value])}
    assert_equal values['average pledge size'], values['books pledged'].to_f / values['donors pledging'], metrics.inspect
  end
end
