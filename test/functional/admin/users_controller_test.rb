require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase
  def setup
    @howard = users :howard
  end

  test "destroy" do
    authenticate_with_http_digest "admin", "password", "Admin"
    delete :destroy, id: @howard.id
    assert_redirected_to admin_url
    assert !User.exists?(@howard)
  end

  test "destroy requires login" do
    delete :destroy, id: @howard.id
    assert_response :unauthorized
    assert User.exists?(@howard)
  end
end
