class Admin::RequestsController < AdminController
  def load_models
    @request = Request.find params[:id] if params[:id]
  end

  def index
    @metrics = Request.metrics
    @requests = Request.order('created_at desc')
  end
end
