class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :find_current_user, :load_models

  def find_current_user
    if session[:user_id]
      @current_user = User.find_by_id session[:user_id]
      if !@current_user
        logger.warn "couldn't find current user #{session[:user_id]}, clearing session"
        reset_session
      end
    end
    logger.info "current user: " + (@current_user ? "#{@current_user.name} (#{@current_user.id})" : "none")
  end

  def set_current_user(user)
    logger.info "setting current user: " + (@current_user ? "#{@current_user.name} (#{@current_user.id})" : "none")
    reset_session
    session[:user_id] = user && user.id
    @current_user = user
  end

  def load_models
  end

  def require_login
    if !@current_user
      logger.info "no current user, rendering login page"
      @destination = request.url
      render "sessions/new"
    end
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
