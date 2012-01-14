class PasswordsController < ApplicationController
  before_filter :validate_letmein, only: [:edit, :update]

  def request_reset
    email = params[:email]
    @user = User.find_by_email email unless email.blank?
    if @user
      UserMailer.reset_password(@user).deliver
    else
      @error = email.blank? ? "Please enter an email address" : "No user with that email"
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
    if @user.reset_password params[:user]
      set_current_user @user
      flash[:notice] = "Your password has been reset."
      redirect_to root_url
    else
      render :edit
    end
  end
end
