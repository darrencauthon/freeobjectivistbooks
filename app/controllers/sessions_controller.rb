class SessionsController < ApplicationController
  def load_models
    @destination = params[:destination] if params[:destination]
  end

  def create
    user = User.login params[:email], params[:password]
    if user
      set_current_user user
      redirect_to @destination || root_url
    else
      flash.now[:error] = "Incorrect email or password."
      render :new
    end
  end

  def destroy
    set_current_user nil
    redirect_to root_url
  end
end
