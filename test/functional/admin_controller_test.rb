require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  test "index" do
    authenticate_with_http_digest "admin", "password", "Admin"
    get :index
    assert_response :success
    assert_select '.request .headline', /Howard Roark \(roark@stanton.edu\)\s+wants Atlas Shrugged/
    assert_select '.pledge .headline', /Hugh Akston \(akston@patrickhenry.edu\)\s+pledged 5 books/
  end

  test "admin password is required" do
    get :index
    assert_response :unauthorized
  end
end
