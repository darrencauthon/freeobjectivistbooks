class HomeController < ApplicationController
  def index
    render layout: "homepage"
  end

  def barf
    raise "Barf!"
  end
end
