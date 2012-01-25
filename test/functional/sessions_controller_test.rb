require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def destination
    "http://test.com/foo/bar"
  end

  test "login form" do
    get :new
    assert_response :success
    assert_select 'h1', 'Log in'
  end

  test "login form with destination" do
    get :new, destination: destination
    assert_response :success
    assert_select 'h1', 'Log in'
    assert_select "input[type='hidden'][value='#{destination}']"
  end

  test "login" do
    post :create, email: "roark@stanton.edu", password: "roark"
    assert_redirected_to root_url
    assert_equal @howard.id, session[:user_id]
  end

  test "login with destination" do
    url = "http://test.com/foo/bar"
    post :create, email: "roark@stanton.edu", password: "roark", destination: destination
    assert_redirected_to destination
    assert_equal @howard.id, session[:user_id]
  end

  test "bad login" do
    post :create, email: "roark@stanton.edu", password: "wrong"
    assert_response :success
    assert_select 'h1', 'Log in'
    assert_select '.field_with_errors', /incorrect/i
    assert_select 'input[name="email"][value="roark@stanton.edu"]'
    assert_nil session[:user_id]
  end

  test "logout" do
    delete :destroy, params, session_for(@howard)
    assert_redirected_to root_url
    assert_nil session[:user_id]
  end
end
