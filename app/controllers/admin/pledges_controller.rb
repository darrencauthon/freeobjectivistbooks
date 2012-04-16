class Admin::PledgesController < AdminController
  def index
    @metrics = Metrics.new
    @pledges = limit_and_offset Pledge
  end
end
