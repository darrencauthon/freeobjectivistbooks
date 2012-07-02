class LocationsController < ApplicationController
  def index
    @users = Request.active.includes(:user).all.map {|request| request.user}.uniq
    @location_names = @users.map {|user| user.location}.uniq
    @locations = Location.where(name: @location_names).select {|location| location.locality?}
    @countries = @locations.map {|location| location.country}.uniq
  end
end
