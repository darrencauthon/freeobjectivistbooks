class Metrics
  def request_pipeline
    calculate_metrics [
      {name: 'Total',    value: Request.count},
      {name: 'Granted',  value: Request.granted.count,   denominator_name: 'Total'},
      {name: 'Sent',     value: Donation.sent.count,     denominator_name: 'Granted'},
      {name: 'Received', value: Donation.received.count, denominator_name: 'Sent'},
      {name: 'Read',     value: Donation.read.count,     denominator_name: 'Received'},
    ]
  end

  def reminders_needed
    [
      {name: 'Open requests', value: Request.not_granted.count},
      {name: 'Needs sending', value: Donation.needs_sending.count},
      {name: 'Flagged',       value: Donation.flagged.count},
      {name: 'In transit',    value: Donation.in_transit.count},
      {name: 'Reading',       value: Donation.reading.count},
      {name: 'Needs thanks',  value: Donation.needs_thanks.count},
    ]
  end

  def donation_metrics
    calculate_metrics [
      {name: 'Thanked',  value: Donation.thanked.count,  denominator_name: 'Active', denominator_value: Donation.active.count},
      {name: 'Reviewed', value: Review.count,            denominator_name: 'Read',   denominator_value: Donation.read.count},
      {name: 'Canceled', value: Donation.canceled.count, denominator_name: 'Total'},
      {name: 'Total',    value: Donation.count},
    ]
  end

  def pledge_metrics
    [
      {name: 'Donors pledging',     value: Pledge.count},
      {name: 'Books pledged',       value: Pledge.sum(:quantity)},
      {name: 'Average pledge size', value: Pledge.average(:quantity)},
    ]
  end

  def book_leaderboard
    counts = Request.unscoped.group(:book).count.map {|book,count| {name: book, value: count}}
    counts.sort {|a,b| b[:value] <=> a[:value]}
  end

  def referral_counts
    @referral_counts ||= Referral.unscoped.group(:source, :medium).count
  end

  def count_referrals(model)
    counts = model.unscoped.joins(:referral).group(:source, :medium).count
    counts.default = 0
    counts
  end

  def user_referrals
    @user_referrals ||= count_referrals User
  end

  def request_referrals
    @request_referrals ||= count_referrals Request
  end

  def pledge_referrals
    @pledge_referrals ||= count_referrals Pledge
  end

  def referral_metrics_keys
    keys = referral_counts.keys.map {|pair| {source: pair.first, medium: pair.second}}
    keys.sort_by {|key| "#{key[:source]}#{key[:medium]}"}
  end

  def referral_metrics(key)
    pair = [key[:source], key[:medium]]
    calculate_metrics [
      {name: 'Clicks',   value: referral_counts[pair]},
      {name: 'Signups',  value: user_referrals[pair],    denominator_name: 'Clicks'},
      {name: 'Requests', value: request_referrals[pair], denominator_name: 'Signups'},
      {name: 'Pledges',  value: pledge_referrals[pair],  denominator_name: 'Signups'},
    ]
  end

private
  def calculate_metrics(metrics)
    values = metrics.inject({}) {|hash,metric| hash.merge(metric[:name] => metric[:value])}

    metrics.each do |metric|
      value = metric[:value]
      denominator_name = metric[:denominator_name]
      denominator_value = metric[:denominator_value]
      denominator_value ||= values[denominator_name] if denominator_name
      metric[:percent] = value.to_f / denominator_value if denominator_value && denominator_value != 0
    end
  end
end
