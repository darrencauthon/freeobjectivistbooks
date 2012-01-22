require 'test_helper'

class Admin::RequestsControllerTest < ActionController::TestCase
  test "index" do
    authenticate_with_http_digest "admin", "password", "Admin"
    get :index
    assert_response :success
    assert_select 'h1', "#{Request.count} requests"
    assert_select '.request', Request.count
  end

  test "show requires login" do
    get :index
    assert_response :unauthorized
    assert_select '.request', 0
  end
end
