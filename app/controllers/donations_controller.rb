class DonationsController < ApplicationController
  before_filter :require_login

  def load_models
    @request = Request.find params[:request_id] if params[:request_id]
  end

  def index
    @donations = @current_user.donations.active.order('created_at desc')
  end

  def create
    @donation = @request.grant @current_user
    respond_to do |format|
      format.html { redirect_to @request }
      format.json { render json: @request.as_json(include: :user) }
    end
  end
end
