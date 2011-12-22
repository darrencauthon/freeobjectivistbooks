require 'test_helper'

class SignupControllerTest < ActionController::TestCase
  def reason
    "Everyone tells me I really need to read this book!"
  end

  def user_attributes
    {
      name: "John Galt",
      email: "galt@gulch.com",
      location: "Atlantis, CO",
      password: "dagny",
      password_confirmation: "dagny"
    }
  end

  def request_attributes
    { book: "The Fountainhead", other_book: "", reason: reason, pledge: "1" }
  end

  test "read" do
    get :read
    assert_response :success

    assert_select '#request_book_atlas_shrugged[checked="checked"]'
    assert_select '.errorExplanation', false
  end

  test "donate" do
    get :donate
    assert_response :success
    assert_select '.errorExplanation', false
  end

  test "submit" do
    user = user_attributes
    request = request_attributes

    post :submit, user: user, request: request
    assert_response :success

    user = User.find_by_name "John Galt"
    assert_not_nil user
    assert_equal "galt@gulch.com", user.email
    assert_equal "Atlantis, CO", user.location
    assert user.authenticate "dagny"

    request = user.requests.first
    assert_not_nil request
    assert_equal "The Fountainhead", request.book
    assert_equal reason, request.reason

    assert_select 'p', /John Galt/
    assert_select 'p', /Atlantis/
    assert_select 'p', /Fountainhead/
    assert_select 'p', reason
    assert_select 'p', /galt@gulch.com/
  end

  test "submit failure" do
    user = user_attributes
    user.delete :email
    user[:password_confirmation] = "dany"

    request = request_attributes
    request.delete :pledge

    post :submit, user: user, request: request
    assert_response :unprocessable_entity

    assert !User.exists?(name: "John Galt")

    assert_select '.errorExplanation h2', /problems with your signup/
    assert_select '.field_with_errors', /can't be blank/
    assert_select '.field_with_errors', /didn't match/
    assert_select '.field_with_errors', /must pledge to read/
  end
end
