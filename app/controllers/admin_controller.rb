class AdminController < ApplicationController
  before_filter do
    authenticate_or_request_with_http_digest("Admin") do |username|
      Rails.application.config.admin_password_hash
    end
  end

  def index
    @request_count = Request.count
    @open_request_count = Request.open.count
    @granted_request_count = Request.granted.count

    @pledge_count = Pledge.count
    @pledge_quantity = Pledge.sum :quantity

    @requests = Request.includes(:user).order('created_at desc')
    @pledges = Pledge.includes(:user).order('created_at desc')
  end
end
