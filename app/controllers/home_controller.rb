class HomeController < ApplicationController
  before_filter :require_login, only: :profile

  def index
    if @current_user
      render :profile
    else
      render :home, layout: "homepage"
    end
  end

  def home
    render layout: "homepage"
  end

  def barf
    raise "Barf!"
  end
end
