require 'test_helper'

class SignupControllerTest < ActionController::TestCase
  test "read" do
    get :read
    assert_response :success
  end

  test "donate" do
    get :donate
    assert_response :success
  end
end
