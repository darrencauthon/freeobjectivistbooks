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

    @latest_events = Event.order('created_at desc').limit(10)

    @request_metrics = Request.metrics
    @pledge_metrics = Pledge.metrics
    @donation_metrics = Donation.metrics
    @book_metrics = Request.book_metrics
  end
end
