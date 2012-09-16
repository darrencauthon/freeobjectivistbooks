# Displays custom error pages.
class ErrorsController < ApplicationController
  # Displays an HTTP 404 Not Found page. Used for unrecognized paths.
  def not_found
    respond_to do |format|
      format.html { render '404', status: :not_found }
      format.any { render nothing: true, status: :not_found }
    end
  end
end
