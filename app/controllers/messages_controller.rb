class MessagesController < ApplicationController
  before_filter :require_student_or_donor

  def require_student_or_donor
    require_user [@donation.student, @donation.donor]
  end

  def new
    @event = @donation.message_events.build user: @current_user
  end

  def create
    attributes = params[:event].merge(user: @current_user)
    @event = @donation.message_events.build attributes
    if @event.save
      flash[:notice] = "Your message to #{@event.to.name} has been sent."
      redirect_to @donation.request
    else
      render :new
    end
  end
end