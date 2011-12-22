class SignupController < ApplicationController
  def read
    @user = User.new
    @request = @user.requests.build
  end

  def submit
    @user = User.new params[:user]
    @request = @user.requests.build params[:request]

    if @user.save
      render :confirmation, status: :created
    else
      render :read, status: :unprocessable_entity
    end
  end
end
