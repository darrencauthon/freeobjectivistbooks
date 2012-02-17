class DonationsController < ApplicationController
  before_filter :require_login
  before_filter :require_donor, only: [:cancel, :destroy]

  # Filters

  def require_donor
    require_user @donation.user
  end

  # Actions

  def index
    @donations = @current_user.donations.active.order('created_at desc')
  end

  def create
    @donation = @request.grant @current_user
    respond_to do |format|
      format.html { redirect_to @request }
      format.json { render json: @request.as_json(include: :user) }
    end
  end

  def cancel
    @event = @donation.cancel_events.build
  end

  def destroy
    @event = @donation.cancel params[:donation]
    if save @donation, @event
      flash[:notice] = {
        headline: "We let #{@donation.student.name} know that you canceled this donation.",
        detail: "We will try to find another donor for them."
      }
      redirect_to donations_url
    else
      render :cancel
    end
  end
end
