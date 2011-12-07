require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "index" do
    get :index
    assert_response :success
  end

  test "about" do
    get :about
    assert_response :success
  end
end
