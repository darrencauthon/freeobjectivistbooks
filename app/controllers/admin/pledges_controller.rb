class Admin::PledgesController < AdminController
  def index
    @metrics = Pledge.metrics
    @pledges = Pledge.order('created_at desc')
  end
end
