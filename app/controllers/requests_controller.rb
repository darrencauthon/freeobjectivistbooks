class RequestsController < ApplicationController
  def index
    @requests = Request.all
    @pledge = @current_user.pledges.last if @current_user
  end
end
