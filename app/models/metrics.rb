class Metrics
  def request_pipeline
    calculate_metrics [
      {name: 'Total',    value: Request.count},
      {name: 'Granted',  value: Request.granted.count,   denominator: 'Total'},
      {name: 'Sent',     value: Donation.sent.count,     denominator: 'Granted'},
      {name: 'Received', value: Donation.received.count, denominator: 'Sent'},
    ]
  end

  def reminders_needed
    [
      {name: 'Open requests', value: Request.not_granted.count},
      {name: 'Needs sending', value: Donation.needs_sending.count},
      {name: 'In transit',    value: Donation.in_transit.count},
      {name: 'Flagged',       value: Donation.flagged.count},
      {name: 'Needs thanks',  value: Donation.needs_thanks.count},
    ]
  end

  def donation_metrics
    calculate_metrics [
      {name: 'Active',   value: Donation.active.count},
      {name: 'Flagged',  value: Donation.flagged.count,  denominator: 'Active'},
      {name: 'Thanked',  value: Donation.thanked.count,  denominator: 'Active'},
      {name: 'Canceled', value: Donation.canceled.count, denominator: 'Total'},
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

private
  def calculate_metrics(metrics)
    values = metrics.inject({}) {|hash,metric| hash.merge(metric[:name] => metric[:value])}

    metrics.each do |metric|
      denominator = metric[:denominator]
      metric[:percent] = metric[:value].to_f / values[denominator] if denominator && metric[:value] > 0
    end
  end
end
