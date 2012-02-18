class FlagsController < ApplicationController
  def allowed_users
    @donation.donor
  end

  def new
    @event = @donation.flag_events.build
  end

  def create
    @event = @donation.flag params[:event]
    if save @donation, @event
      flash[:notice] = "The request has been flagged, and your message has been sent to #{@donation.student.name}."
      redirect_to @donation.request
    else
      render :new
    end
  end
end
