require 'test_helper'

class MetricsTest < ActiveSupport::TestCase
  def setup
    @metrics = Metrics.new
  end

  def values_for(metrics)
    metrics.inject({}) {|hash,metric| hash.merge(metric[:name] => metric[:value])}
  end

  test "request pipeline" do
    metrics = @metrics.request_pipeline
    values = values_for metrics

    assert_equal values['Total'], values['Granted'] + Request.not_granted.count, metrics.inspect
    assert_equal values['Granted'], values['Sent'] + Donation.not_sent.count, metrics.inspect
    assert values['Received'] <= values['Sent'], metrics.inspect
  end

  test "reminders needed" do
    metrics = @metrics.reminders_needed
    values = values_for metrics

    assert_equal Request.count, Request.granted.count + values['Open requests'], metrics.inspect
    assert_equal Donation.not_sent.count, values['Needs sending'] + Donation.not_sent.flagged.count, metrics.inspect
    assert_equal Donation.sent.count, values['In transit'] + Donation.received.count, metrics.inspect
    assert_equal Donation.active.count, values['Flagged'] + Donation.not_flagged.count, metrics.inspect
    assert_equal Donation.received.count, values['Needs thanks'] + Donation.received.thanked.count, metrics.inspect
  end

  test "donation metrics" do
    metrics = @metrics.donation_metrics
    values = values_for metrics

    assert_equal values['Total'], values['Active'] + values['Canceled'], metrics.inspect
    assert_equal values['Active'], values['Flagged'] + Donation.not_flagged.count, metrics.inspect
    assert_equal values['Active'], values['Thanked'] + Donation.not_thanked.count, metrics.inspect
  end

  test "pledge metrics" do
    metrics = @metrics.pledge_metrics
    values = values_for metrics
    assert_equal values['Average pledge size'], values['Books pledged'].to_f / values['Donors pledging'], metrics.inspect
  end

  test "book leaderboard" do
    metrics = @metrics.book_leaderboard
    sum = metrics.inject(0) {|sum,metric| sum += metric[:value]}
    assert_equal Request.count, sum
  end
end
