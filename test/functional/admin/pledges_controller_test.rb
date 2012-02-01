require 'test_helper'

class Admin::PledgesControllerTest < ActionController::TestCase
  test "index" do
    admin_auth
    get :index
    assert_response :success
    assert_select 'h1', 'Pledges'
    assert_select '.overview table'
    assert_select '.pledge', Pledge.count
  end

  test "show requires login" do
    get :index
    assert_response :unauthorized
    assert_select '.pledge', 0
  end
end
