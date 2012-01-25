class MessagesController < ApplicationController
  before_filter :require_student_or_donor

  def load_models
    @request = Request.find params[:request_id]
  end

  def require_student_or_donor
    require_user [@request.user, @request.donor]
  end

  def new
    @event = @request.message_events.build user: @current_user
  end

  def create
    attributes = params[:event].merge(user: @current_user)
    @event = @request.message_events.build attributes
    if @event.save
      flash[:notice] = "Your message to #{@event.to.name} has been sent."
      redirect_to @request
    else
      render :new
    end
  end
end