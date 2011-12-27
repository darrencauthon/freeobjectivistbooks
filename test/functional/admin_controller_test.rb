require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "index" do
    digest_auth "admin", "admin", "Admin", "password"
    get :index
    assert_response :success
    assert_select '.request p.summary', /Howard Roark (roark@stanton.edu) wants Atlas Shrugged/
    assert_select '.pledge p.summary', /Hugh Akston (akston@patrickhenry.edu) pledged 5 books/
  end

  test "admin password is required" do
    get :index
    assert_response :unauthorized
  end
end
