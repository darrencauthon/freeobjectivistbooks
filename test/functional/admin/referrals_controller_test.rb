require 'test_helper'

class Admin::ReferralsControllerTest < ActionController::TestCase
  test "index" do
    admin_auth
    get :index
    assert_response :success
    assert_select 'h1', 'Referrals'
    assert_select '.overview table'
  end

  test "show requires login" do
    get :index
    assert_response :unauthorized
  end
end
