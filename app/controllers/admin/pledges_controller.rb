class Admin::PledgesController < AdminController
  def index
    @pledge_count = Pledge.count
    @pledge_quantity = Pledge.sum :quantity
    @average_pledge_quantity = Pledge.average :quantity
    @pledges = Pledge.order('created_at desc')
  end
end
