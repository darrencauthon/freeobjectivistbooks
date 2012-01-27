class Admin::RequestsController < AdminController
  def load_models
    @request = Request.find params[:id] if params[:id]
  end

  def index
    @request_count = Request.count
    @open_request_count = Request.open.count
    @granted_request_count = Request.granted.count
    @flagged_request_count = Request.flagged.count
    @thanked_request_count = Request.thanked.count
    @requests = Request.order('created_at desc')
  end
end
