class DonationsController < ApplicationController
  before_filter :require_login
  before_filter :require_donor, only: [:cancel, :destroy]

  # Filters

  def require_donor
    require_user @donation.user
  end

  # Actions

  def index
    @donations = @current_user.donations.active
  end

  def create
    @event = @request.grant @current_user
    if save @request, @event
      respond_to do |format|
        format.html { redirect_to @request }
        format.json { render json: @request, include: :user }
      end
    else
      message = @request.donation.errors.full_messages.join ", "
      respond_to do |format|
        format.html do
          flash[:error] = message
          redirect_to @request
        end
        format.json do
          response = {message: message}
          render json: response, status: :bad_request
        end
      end
    end
  end

  def cancel
    @event = @donation.cancel_events.build user: @current_user
  end

  def destroy
    @event = @donation.cancel params[:donation], @current_user
    if save @donation, @event
      if @event
        flash[:notice] = {
          headline: "We let #{@donation.student.name} know that you canceled this donation.",
          detail: "We will try to find another donor for them."
        }
      end
      redirect_to donations_url
    else
      render :cancel
    end
  end
end
