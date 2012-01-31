class ProfileController < ApplicationController
  before_filter :require_login

  def show
    @show_donations = @current_user.donations.any? || @current_user.pledges.any?
    unsent_donations = @current_user.donations.not_sent
    @donations = unsent_donations.not_flagged
    @flag_count = unsent_donations.flagged.count
  end

  def donations
    @donations = @current_user.donations
  end
end
