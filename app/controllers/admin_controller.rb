class AdminController < ApplicationController
  before_filter do
    authenticate_or_request_with_http_digest("Admin") do |username|
      Rails.application.config.admin_password_hash
    end
  end

  def index
    @user_count = User.count

    @request_count = Request.count
    @open_request_count = Request.open.count
    @granted_request_count = Request.granted.count
    @flagged_request_count = Request.flagged.count

    @pledge_count = Pledge.count
    @pledge_quantity = Pledge.sum :quantity

    @book_counts = Request.group(:book).count
    @books = @book_counts.keys.sort {|a,b| @book_counts[b] <=> @book_counts[a]}
  end
end
