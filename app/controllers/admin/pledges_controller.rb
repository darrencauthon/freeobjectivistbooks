class Admin::PledgesController < AdminController
  def index
    @metrics = Metrics.new
    @pledges = Pledge.order('created_at desc')
  end
end
