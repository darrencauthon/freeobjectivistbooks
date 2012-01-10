class SignupController < ApplicationController
  def load_models
    @user = User.new params[:user]
    @request = @user.requests.build params[:request] if params[:request]
    @pledge = @user.pledges.build params[:pledge] if params[:pledge]
  end

  def read
    @request ||= @user.requests.build
  end

  def donate
    @pledge ||= @user.pledges.build quantity: 5
  end

  def submit
    if @user.save
      set_current_user @user
      if @user.pledges.any?
        redirect_to donate_url
      else
        render :confirmation, status: :created
      end
    else
      render params[:from_action], status: :unprocessable_entity
    end
  end
end
