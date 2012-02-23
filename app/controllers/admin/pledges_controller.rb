class Admin::PledgesController < AdminController
  def index
    @metrics = Metrics.new
    @pledges = Pledge.all
  end
end
