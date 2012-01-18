class RequestsController < ApplicationController
  before_filter :require_login
  before_filter :require_student, only: [:edit, :update]
  before_filter :require_donor, only: [:flag, :update_flag]
  before_filter :require_student_or_donor, only: :show

  def load_models
    @request = Request.find params[:id] if params[:id]
  end

  def require_student
    require_user @request.user
  end

  def require_donor
    require_user @request.donor
  end

  def require_student_or_donor
    require_user @request.user, @request.donor
  end

  def index
    @requests = Request.open
    @donations = @current_user.donations if @current_user
    @pledge = @current_user.pledges.last if @current_user
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

  def update_flag
    if @request.flag params[:message]
      flash[:notice] = "The request has been flagged, and your message has been sent to #{@request.user.name}."
      redirect_to @request
    else
      render :flag
    end
  end

  def grant
    logger.info "#{@current_user.name} (#{@current_user.id}) granting request #{@request.id} " +
      "from #{@request.user.name} (#{@request.user.id}) for #{@request.book}"
    @request.donor = @current_user
    @request.save!
    redirect_to donate_url
  end
end
