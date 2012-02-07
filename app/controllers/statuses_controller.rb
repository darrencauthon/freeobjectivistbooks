class StatusesController < ApplicationController
  before_filter :require_login
  before_filter :require_donor

  def load_models
    @request = Request.find params[:request_id]
  end

  def require_donor
    require_user @request.donor
  end

  def update
    @request.update_status params[:request]
    respond_to do |format|
      format.html do
        flash[:notice] = "Thanks! We've let #{@request.user.name} know the book is on its way."
        redirect_to @request
      end
      format.js { render nothing: true }
    end
  end
end
