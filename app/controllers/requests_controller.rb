class RequestsController < ApplicationController
  before_filter :require_login

  # Filters

  def allowed_users
    case params[:action]
    when "show" then [@request.user, @request.donor]
    when "edit", "update" then @request.user
    end
  end

  # Actions

  def index
    @requests = Request.open.order('updated_at desc')
    @donations = @current_user.donations.active if @current_user
    @pledge = @current_user.pledges.last if @current_user
  end

  def edit
    if @request.flagged?
      redirect_to fix_donation_flag_url(@request.donation)
    else
      @event = @request.events.build type: "update"
    end
  end

  def update
    @request.attributes = params[:request]
    @event = @request.build_update_event
    if save @request, @event
      flash[:notice] = "Your info has been updated."
      redirect_to @request
    else
      render :edit
    end
  end
end
