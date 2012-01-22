class Admin::RequestsController < AdminController
  def index
    @requests = Request.order('created_at desc')
  end
end
