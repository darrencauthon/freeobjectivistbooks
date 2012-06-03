require 'test_helper'

class MetricsTest < ActiveSupport::TestCase
  def setup
    @metrics = Metrics.new
  end

  def values_for(metrics)
    metrics.inject({}) do |hash,metric|
      value = metric[:value] || metric[:values]["Total"]
      hash.merge(metric[:name] => value)
    end
  end

  test "request pipeline" do
    metrics = @metrics.request_pipeline
    values = values_for metrics

    assert_equal values['Active'], values['Granted'] + Request.not_granted.count, metrics.inspect
    assert_equal values['Granted'], values['Sent'] + Donation.not_sent.count, metrics.inspect
    assert_equal values['Sent'], values['Received'] + Donation.in_transit.count, metrics.inspect
    assert_equal values['Received'], values['Read'] + Donation.reading.count, metrics.inspect
    assert_equal Request.count, values['Canceled'] + values['Active'], metrics.inspect
  end

  test "pipeline breakdown" do
    metrics = @metrics.pipeline_breakdown
    values = values_for metrics[:rows]

    assert_equal Request.active.count, Request.granted.count + values['Open requests'], values.inspect
    assert_equal Donation.not_sent.count, values['Needs sending'] + Donation.not_sent.flagged.count, values.inspect
    assert_equal Donation.sent.count, values['In transit'] + Donation.received.count, values.inspect
  end

  test "donation metrics" do
    metrics = @metrics.donation_metrics
    values = values_for metrics

    assert_equal Donation.active.count, values['Flagged'] + Donation.not_flagged.count, metrics.inspect
    assert_equal Donation.received.count, values['Needs thanks'] + Donation.received.thanked.count, metrics.inspect
    assert_equal values['Total'], Donation.active.count + values['Canceled'], metrics.inspect
    assert_equal Donation.active.count, values['Thanked'] + Donation.not_thanked.count, metrics.inspect
  end

  test "pledge metrics" do
    metrics = @metrics.pledge_metrics
    values = values_for metrics
    assert_equal values['Average pledge size'], values['Books pledged'].to_f / values['Donors pledging'], metrics.inspect
  end

  test "book leaderboard" do
    metrics = @metrics.book_leaderboard
    sum = metrics.inject(0) {|sum,metric| sum += metric[:value]}
    assert_equal Request.active.count, sum
  end

  test "referral metrics" do
    keys = @metrics.referral_metrics_keys
    assert !keys.empty?, "referral metrics keys are empty"

    sum = keys.inject(0) do |sum, key|
      metrics = @metrics.referral_metrics(key)
      assert_not_nil metrics
      values = values_for metrics
      sum += values['Clicks']
    end

    assert_equal sum, Referral.count
  end
end
