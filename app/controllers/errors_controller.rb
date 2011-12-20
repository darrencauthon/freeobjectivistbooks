class ErrorsController < ApplicationController
  def not_found
    render '404', status: :not_found
  end
end
