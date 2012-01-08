class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.login params[:user]
    if @user.errors.empty?
      set_current_user @user
      redirect_to root_url
    else
      render :new
    end
  end

  def destroy
    set_current_user nil
    redirect_to root_url
  end
end
