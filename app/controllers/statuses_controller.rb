class StatusesController < ApplicationController
  before_filter :require_login
  before_filter :check_user

  # Filters

  def allowed_users
    status = params[:status] || params[:donation][:status]
    case status
    when "sent" then @donation.user
    when "received" then @donation.student
    end
  end

  def check_user
    require_user allowed_users
  end

  # Actions

  def edit
    @event = @donation.update_status_events.build detail: params[:status]
    render params[:status]
  end

  def notice_for_status(status)
    case status
    when "sent" then "Thanks! We've let #{@donation.student.name} know the book is on its way."
    when "received" then "Great! We've let your donor (#{@donation.user.name}) know that you received this book."
    end
  end

  def update
    @donation.update_status params[:donation]
    respond_to do |format|
      format.html do
        flash[:notice] = notice_for_status @donation.status
        redirect_to @donation.request
      end
      format.js { render nothing: true }
    end
  end
end
