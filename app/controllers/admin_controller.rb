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
    @review_count = Review.count
    @referral_count = Referral.count
    @public_thanks_count = Event.public_thanks.count
    @testimonial_count = Testimonial.count

    @latest_events = Event.reverse_order.limit(10)

    @metrics = Metrics.new
  end
end
