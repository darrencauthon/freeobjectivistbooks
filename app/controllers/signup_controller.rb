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
      render :confirmation, status: :created
    else
      render params[:from_action], status: :unprocessable_entity
    end
  end
end
