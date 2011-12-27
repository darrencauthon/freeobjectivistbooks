class ApplicationController < ActionController::Base
  protect_from_forgery

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
