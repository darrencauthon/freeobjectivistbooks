class Admin::RequestsController < AdminController
  def index
    @metrics = Metrics.new
    @requests = Request.all
  end
end
