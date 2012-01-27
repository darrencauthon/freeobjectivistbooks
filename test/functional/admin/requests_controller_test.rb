require 'test_helper'

class Admin::RequestsControllerTest < ActionController::TestCase
  test "index" do
    authenticate_with_http_digest "admin", "password", "Admin"
    get :index
    assert_response :success
    assert_select 'h1', "#{Request.count} requests"
    assert_select '.request', Request.count
  end

  test "show" do
    authenticate_with_http_digest "admin", "password", "Admin"
    get :show, id: @howard_request.id
    assert_response :success
    assert_select 'h1', "Howard Roark wants Atlas Shrugged"
  end

  test "index requires login" do
    get :index
    assert_response :unauthorized
    assert_select '.request', 0
  end
end
