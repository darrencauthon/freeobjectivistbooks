class DonationsController < ApplicationController
  before_filter :require_login

  def index
    @donations = @current_user.donations.active.order('created_at desc')
  end
end
