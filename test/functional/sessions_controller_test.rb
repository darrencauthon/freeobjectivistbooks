require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def setup
    @user = users :howard
  end

  test "login form" do
    get :new
    assert_response :success
    assert_select 'h1', 'Log in'
  end

  test "login" do
    post :create, user: {email: "roark@stanton.edu", password: "roark"}
    assert_redirected_to root_url
    assert_equal @user.id, session[:user_id]
  end

  test "bad login" do
    post :create, user: {email: "roark@stanton.edu", password: "wrong"}
    assert_response :success
    assert_select 'h1', 'Log in'
    assert_select '.field_with_errors', /incorrect/i
    assert_nil session[:user_id]
  end

  test "logout" do
    delete(:destroy, {}, {user_id: @user.id})
    assert_redirected_to root_url
    assert_nil session[:user_id]
  end
end
