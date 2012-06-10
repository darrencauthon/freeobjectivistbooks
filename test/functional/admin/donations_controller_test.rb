require 'test_helper'

class Admin::DonationsControllerTest < ActionController::TestCase
  test "show" do
    admin_auth
    get :show, id: @quentin_donation.id
    assert_redirected_to [:admin, @quentin_request]
  end
end
