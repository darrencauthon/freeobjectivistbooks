class PasswordsController < ApplicationController
  before_filter :validate_letmein, only: [:edit, :update]

  def parse_params
    @email = params[:email]
  end

  def request_reset
    @user = User.find_by_email @email unless @email.blank?
    if @user
      UserMailer.reset_password(@user).deliver
    else
      @error = @email.blank? ? "Please enter an email address" : "No user with that email"
      render :forgot
    end
  end

  def validate_letmein
    set_current_user nil
    @user = User.find_by_id params[:id]
    result = @user ? @user.letmein?(params) : :invalid
    render "#{result}_reset" if result != :valid
  end

  def update
    if @user.update_attributes params[:user]
      set_current_user @user
      flash[:notice] = "Your password has been reset."
      redirect_to root_url
    else
      log_errors @user
      render :edit
    end
  end
end
