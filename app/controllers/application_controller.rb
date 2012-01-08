class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :find_current_user

  def find_current_user
    @current_user = User.find session[:user_id] if session[:user_id]
  end

  def set_current_user(user)
    reset_session
    session[:user_id] = user && user.id
    @current_user = user
  end

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_error
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::RoutingError, with: :render_not_found
    rescue_from ActionController::UnknownController, with: :render_not_found
    rescue_from ActionController::UnknownAction, with: :render_not_found
  end

  def render_not_found
    render template: "errors/404", status: 404
  end

  def render_error(exception)
    render template: "errors/500", status: 500
    ExceptionNotifier::Notifier.exception_notification(request.env, exception).deliver
  end
end
