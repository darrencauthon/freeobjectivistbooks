class HomeController < ApplicationController
  before_filter :require_login, only: :profile

  def index
    if @current_user
      redirect_to profile_url
    else
      render :home, layout: "homepage"
    end
  end

  def home
    render layout: "homepage"
  end
end
