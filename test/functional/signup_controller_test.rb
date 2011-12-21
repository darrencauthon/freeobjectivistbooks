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

  test "submit" do
    user = {name: "John Galt", email: "galt@gulch.com", location: "Atlantis, CO", password: "dagny",
        password_confirmation: "dagny"}
    post :submit, user: user
    assert_response :success

    user = User.find_by_name "John Galt"
    assert_equal "galt@gulch.com", user.email
    assert_equal "Atlantis, CO", user.location
    assert user.authenticate "dagny"

    assert_select 'p', /John Galt/
    assert_select 'p', /Atlantis/
    assert_select 'p', /galt@gulch.com/
  end

  test "submit failure" do
    user = {name: "John Galt", location: "Atlantis, CO", password: "dagny", password_confirmation: "dany"}
    post :submit, user: user

    assert !User.exists?(name: "John Galt")

    assert_select '.errorExplanation' do
      assert_select 'h2', /problems with your signup/
      assert_select 'li', 2
      assert_select 'li', /Email can't be blank/
      assert_select 'li', /Password didn't match/
    end
  end
end
