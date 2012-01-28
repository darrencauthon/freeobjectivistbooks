class RequestsController < ApplicationController
  before_filter :require_login
  before_filter :check_user

  # Filters

  def load_models
    @request = Request.find params[:id] if params[:id]
  end

  def allowed_users_for_action(action)
    case action
    when "update", "thank" then @request.user
    when "flag" then @request.donor
    end
  end

  def allowed_users
    case params[:action]
    when "show" then [@request.user, @request.donor]
    when "edit" then allowed_users_for_action(params[:type] || "update")
    else allowed_users_for_action(params[:action])
    end
  end

  def check_user
    users = Array(allowed_users)
    require_user users unless users.empty?
  end

  # Actions

  def index
    @requests = Request.open.order('created_at desc')
    @donations = @current_user.donations if @current_user
    @pledge = @current_user.pledges.last if @current_user
  end

  def edit
    @event = @request.events.build type: (params[:type] || "update")
    render params[:type] || :edit
  end

  def grant
    @request.grant @current_user
    redirect_to donate_url
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
    result = @request.update_user params[:user], params[:message]
    unless result == :error
      flash[:notice] = notice_for_update(result)
      redirect_to @request
    else
      render :edit
    end
  end

  def flag
    @event = @request.flag params[:request]
    if save_request_and_event
      flash[:notice] = "The request has been flagged, and your message has been sent to #{@request.user.name}."
      redirect_to @request
    else
      render :flag
    end
  end

  def thank
    @event = @request.thank params[:request]
    if save_request_and_event
      flash[:notice] = "We sent your thanks to your donor (#{@request.donor.name})."
      redirect_to @request
    else
      render :thank
    end
  end

  def save_request_and_event
    @request.save && @event.save if @request.valid? && @event.valid?
  end
end
