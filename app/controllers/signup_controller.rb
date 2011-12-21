class SignupController < ApplicationController
  def read
    @user = User.new
  end

  def submit
    @user = User.new params[:user]
    success = @user.save
    if success
      render :confirmation
    else
      render :read
    end
  end
end
