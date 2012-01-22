require 'test_helper'

class Admin::PledgesControllerTest < ActionController::TestCase
  test "index" do
    authenticate_with_http_digest "admin", "password", "Admin"
    get :index
    assert_response :success
    assert_select 'h1', /#{Pledge.count} pledge/
    assert_select '.pledge', Pledge.count
  end

  test "show requires login" do
    get :index
    assert_response :unauthorized
    assert_select '.pledge', 0
  end
end
