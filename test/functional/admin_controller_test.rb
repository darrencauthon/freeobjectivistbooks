require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "index" do
    authenticate_with_http_digest "admin", "password", "Admin"
    get :index
    assert_response :success
    assert_select 'a', /user/
    assert_select 'a', /requested/
    assert_select 'a', /pledged/
  end

  test "admin password is required" do
    get :index
    assert_response :unauthorized
  end
end
