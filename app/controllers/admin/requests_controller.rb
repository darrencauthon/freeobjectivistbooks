class Admin::RequestsController < AdminController
  def index
    @metrics = Metrics.new
    @requests = Request.order('created_at desc')
  end
end
