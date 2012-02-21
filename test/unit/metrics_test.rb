require 'test_helper'

class MetricsTest < ActiveSupport::TestCase
  def setup
    @metrics = Metrics.new
  end

  test "request pipeline" do
    metrics = @metrics.request_pipeline
    values = metrics.inject({}) {|hash,metric| hash.merge(metric[:name] => metric[:value])}

    assert_equal values['Total'], values['Granted'] + Request.open.count, metrics.inspect
    assert_equal values['Granted'], values['Sent'] + Donation.not_sent.count, metrics.inspect
    assert values['Received'] <= values['Sent'], metrics.inspect
  end

  test "donation metrics" do
    metrics = @metrics.donation_metrics
    values = metrics.inject({}) {|hash,metric| hash.merge(metric[:name] => metric[:value])}

    assert_equal values['Total'], values['Active'] + values['Canceled'], metrics.inspect
    assert_equal values['Active'], values['Flagged'] + Donation.not_flagged.count, metrics.inspect
    assert_equal values['Active'], values['Thanked'] + Donation.not_thanked.count, metrics.inspect
  end

  test "pledge metrics" do
    metrics = @metrics.pledge_metrics
    values = metrics.inject({}) {|hash,metric| hash.merge(metric[:name] => metric[:value])}
    assert_equal values['Average pledge size'], values['Books pledged'].to_f / values['Donors pledging'], metrics.inspect
  end

  test "book leaderboard" do
    metrics = @metrics.book_leaderboard
    sum = metrics.inject(0) {|sum,metric| sum += metric[:value]}
    assert_equal Request.count, sum
  end
end
