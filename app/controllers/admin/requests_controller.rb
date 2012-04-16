class Admin::RequestsController < AdminController
  def index
    @metrics = Metrics.new
    @requests = limit_and_offset Request
  end
end
