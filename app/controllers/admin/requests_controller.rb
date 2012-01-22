class Admin::RequestsController < AdminController
  def index
    @request_count = Request.count
    @open_request_count = Request.open.count
    @granted_request_count = Request.granted.count
    @flagged_request_count = Request.flagged.count
    @requests = Request.order('created_at desc')
  end
end
