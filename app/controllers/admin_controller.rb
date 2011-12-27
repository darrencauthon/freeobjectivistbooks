class AdminController < ApplicationController
  before_filter do
    authenticate_or_request_with_http_digest("Admin") do |username|
      Rails.application.config.admin_password_hash
    end
  end

  def index
    @request_total = Request.count
    @pledge_total = Pledge.sum :quantity
    @requests = Request.includes(:user)
    @pledges = Pledge.includes(:user)
  end
end
