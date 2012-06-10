class Admin::DonationsController < AdminController
  def show
    redirect_to [:admin, @donation.request]
  end
end
