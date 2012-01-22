class Admin::PledgesController < AdminController
  def index
    @pledges = Pledge.order('created_at desc')
  end
end
