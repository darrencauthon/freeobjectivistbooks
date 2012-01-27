class ErrorsController < ApplicationController
  def not_found
    respond_to do |format|
      format.html { render '404', status: :not_found }
      format.any { render nothing: true, status: :not_found }
    end
  end
end
