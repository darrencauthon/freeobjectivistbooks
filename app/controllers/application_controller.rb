class UnauthorizedException < Exception; end
class ForbiddenException < Exception; end

class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :find_current_user, :load_models

  def initialize
    super
    @model_class_name = self.class.name.split("::").last.sub(/Controller$/,"").singularize
    @model_class = @model_class_name.constantize if Kernel.const_defined?(@model_class_name)
    @model_ivar_name = "@#{@model_class_name.underscore}"
  end

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
    instance_variable_set @model_ivar_name, @model_class.find(params[:id]) if @model_class && params[:id]
    @request = Request.find params[:request_id] if params[:request_id]
    @donation = Donation.find params[:donation_id] if params[:donation_id]
  end

  def require_login
    raise UnauthorizedException if !@current_user
  end

  def require_user(*users)
    require_login
    users = users.flatten.compact
    raise ForbiddenException if !@current_user.in?(users)
  end

  def save(*models)
    models = models.compact
    models.each {|m| m.save} if models.all? {|m| m.valid?}
  end

  unless Rails.application.config.consider_all_requests_local
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::RoutingError, with: :render_not_found
    rescue_from ActionController::UnknownController, with: :render_not_found
    rescue_from ActionController::UnknownAction, with: :render_not_found
    rescue_from Exception, with: :render_error
  end

  rescue_from UnauthorizedException, with: :render_unauthorized
  rescue_from ForbiddenException, with: :render_forbidden

  def render_unauthorized
    logger.info "no current user, rendering login page"
    @destination = request.url
    render "sessions/new", status: 401
  end

  def render_forbidden
    @destination = request.url
    render template: "errors/403", status: 403
  end

  def render_not_found
    render template: "errors/404", status: 404
  end

  def render_error(exception)
    render template: "errors/500", status: 500
    ExceptionNotifier::Notifier.exception_notification(request.env, exception).deliver
  end
end
