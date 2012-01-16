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

  def update
    # The edit field only actually lets you update user fields for now
    if @request.user.update_attributes params[:user]
      flash[:notice] = "Your shipping info has been updated."
      redirect_to @request
    else
      render :edit
    end
  end

  def grant
    logger.info "#{@current_user.name} (#{@current_user.id}) granting request #{@request.id} " +
      "from #{@request.user.name} (#{@request.user.id}) for #{@request.book}"
    @request.donor = @current_user
    @request.save!
    redirect_to donate_url
  end
end
