class ProfileController < ApplicationController
  before_filter :require_login
end
