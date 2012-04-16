class Admin::RequestsController < AdminController
  def index
    @metrics = Metrics.new

    @requests = case params[:type]
    when 'not_granted'
      Request.not_granted.reorder(:created_at)
    when 'needs_sending'
      Donation.needs_sending.reorder(:created_at).map {|d| d.request}
    when 'in_transit'
      Donation.in_transit.reorder(:status_updated_at).map {|d| d.request}
    when 'reading'
      Donation.reading.reorder(:status_updated_at).map {|d| d.request}
    else
      limit_and_offset Request
    end
  end
end
