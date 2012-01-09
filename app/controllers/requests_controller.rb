class RequestsController < ApplicationController
  before_filter :require_login

  def load_models
    @request = Request.find params[:id] if params[:id]
  end

  def index
    @requests = Request.open
    @donations = @current_user.donations if @current_user
    @pledge = @current_user.pledges.last if @current_user
  end

  def grant
    @request.donor = @current_user
    @request.save!
    redirect_to donate_url
  end
end
