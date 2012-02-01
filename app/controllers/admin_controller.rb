class AdminController < ApplicationController
  before_filter do
    authenticate_or_request_with_http_digest("Admin") do |username|
      Rails.application.config.admin_password_hash
    end
  end

  def index
    @user_count = User.count
    @request_count = Request.count
    @pledge_count = Pledge.count
    @event_count = Event.count

    @request_metrics = Request.metrics
    @pledge_metrics = Pledge.metrics
    @book_metrics = Request.book_metrics
  end
end
