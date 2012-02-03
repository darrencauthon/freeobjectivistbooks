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
    when "flag", "update_status", "cancel" then @request.donor
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
    respond_to do |format|
      format.html { redirect_to @request }
      format.json { render json: @request.as_json(include: :user) }
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

  def flag
    @event = @request.flag params[:request]
    if save @request, @event
      flash[:notice] = "The request has been flagged, and your message has been sent to #{@request.user.name}."
      redirect_to @request
    else
      render :flag
    end
  end

  def update_status
    @request.update_status params[:request]
    respond_to do |format|
      format.html do
        flash[:notice] = "Thanks! We've let #{@request.user.name} know the book is on its way."
        redirect_to @request
      end
      format.js { render nothing: true }
    end
  end

  def thank
    @event = @request.thank params[:request]
    if save @request, @event
      flash[:notice] = "We sent your thanks to your donor (#{@request.donor.name})."
      redirect_to @request
    else
      render :thank
    end
  end

  def cancel
    @event = @request.cancel params[:request]
    if save @request, @event
      flash[:notice] = {
        headline: "We let #{@request.user.name} know that you canceled this donation.",
        detail: "We will try to find another donor for them."
      }
      redirect_to donations_url
    else
      render :cancel
    end
  end

  def save(*models)
    models = models.compact
    models.each {|m| m.save} if models.all? {|m| m.valid?}
  end
end
