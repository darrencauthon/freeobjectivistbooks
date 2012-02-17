class Admin::RequestsController < AdminController
  def index
    @metrics = Request.metrics
    @requests = Request.order('created_at desc')
  end
end
