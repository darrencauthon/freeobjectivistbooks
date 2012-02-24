class StatusesController < ApplicationController
  before_filter :require_login

  def status
    @status ||= params[:status] || params[:donation][:status]
  end

  # Filters

  def allowed_users
    case status
    when "sent" then @donation.user
    when "received", "read" then @donation.student
    end
  end

  # Actions

  def edit
    @event = @donation.update_status_events.build detail: status
    @review = @donation.build_review
    render status
  end

  def notice
    case status
    when "sent" then "Thanks! We've let #{@donation.student.name} know the book is on its way."
    when "received" then "Great! We've let your donor (#{@donation.user.name}) know that you received this book."
    when "read" then "Great! Your donor (#{@donation.user.name}) will be glad to hear that you finished this book."
    end
  end

  def update
    @event = @donation.update_status params[:donation]
    @review = @donation.build_review params[:review] if params[:review] && params[:review][:text].present?

    if save @donation, @review, @event
      respond_to do |format|
        format.html do
          flash[:notice] = notice
          redirect_to @donation.request
        end
        format.js { render nothing: true }
      end
    else
      render status
    end
  end
end
