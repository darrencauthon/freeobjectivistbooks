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

  def notice_for_update(result)
    case result
    when :update
      notice = "Your info has been updated"
      notice += " and your donor (#{@request.donor.name}) has been notified" if @request.donor
      notice += "."
      notice
    when :message
      "Your message has been sent to your donor (#{@request.donor.name})."
    end
  end

  def update
    # The edit field only actually lets you update user fields for now
    @event = @request.update_user params[:request]
    if @request.user_valid? && save(@request, @request.user, @event)
      flash[:notice] = notice_for_update(@event.type.to_sym) if @event
      redirect_to @request
    else
      render :edit
    end
  end
end
