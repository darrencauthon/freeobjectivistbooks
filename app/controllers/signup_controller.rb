class SignupController < ApplicationController
  def load_models
    @user = User.new params[:user]
    @request = @user.requests.build params[:request] if params[:request]
    @pledge = @user.pledges.build params[:pledge] if params[:pledge]
  end

  def read
    session[:seen_signup] = true
    @request ||= @user.requests.build
  end

  def donate
    session[:seen_signup] = true
    @pledge ||= @user.pledges.build quantity: 5
  end

  def submit
    if @user.save
      logger.info "new signup: #{@user.name} (#{@user.id})"
      set_current_user @user
      if @user.pledges.any?
        redirect_to donate_url
      elsif @user.requests.any?
        redirect_to @user.requests.first
      else
        redirect_to profile_path
      end
    else
      render params[:from_action], status: :unprocessable_entity
    end
  end
end
