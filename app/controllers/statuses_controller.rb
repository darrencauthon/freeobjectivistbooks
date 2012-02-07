class StatusesController < ApplicationController
  before_filter :require_login
  before_filter :check_user

  # Filters

  def load_models
    @request = Request.find params[:request_id]
  end

  def allowed_users
    status = params[:status] || params[:request][:status]
    case status
    when "sent" then @request.donor
    when "received" then @request.user
    end
  end

  def check_user
    require_user allowed_users
  end

  # Actions

  def edit
    @event = @request.events.build type: "update_status", detail: params[:status]
    render params[:status]
  end

  def notice_for_status(status)
    case status
    when "sent" then "Thanks! We've let #{@request.user.name} know the book is on its way."
    when "received" then "Great! We've let your donor (#{@request.donor.name}) know that you received this book."
    end
  end

  def update
    @request.update_status params[:request]
    respond_to do |format|
      format.html do
        flash[:notice] = notice_for_status @request.status
        redirect_to @request
      end
      format.js { render nothing: true }
    end
  end
end
