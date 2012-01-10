require 'test_helper'

class SignupControllerTest < ActionController::TestCase
  def request_reason
    "Everyone tells me I really need to read this book!"
  end

  def pledge_reason
    "I want to spread these great ideas."
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
    { book: "The Fountainhead", other_book: "", reason: request_reason, pledge: "1" }
  end

  def pledge_attributes
    { quantity: 5, reason: pledge_reason }
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

  test "read submit" do
    user = user_attributes
    request = request_attributes

    post :submit, user: user, request: request, from_action: "read"
    assert_response :success

    user = User.find_by_name "John Galt"
    assert_not_nil user
    assert_equal "galt@gulch.com", user.email
    assert_equal "Atlantis, CO", user.location
    assert user.authenticate "dagny"

    assert_equal user.id, session[:user_id]

    request = user.requests.first
    assert_not_nil request
    assert_equal "The Fountainhead", request.book
    assert_equal request_reason, request.reason

    assert_equal [], user.pledges

    assert_select 'p.overview', /We will look for a donor/
    assert_select 'p', /John Galt/
    assert_select 'p', /Atlantis/
    assert_select 'p', /Fountainhead/
    assert_select 'p', request_reason
    assert_select 'p', /galt@gulch.com/
  end

  test "read submit failure" do
    user = user_attributes
    user[:email] = ""
    user[:password_confirmation] = "dany"

    request = request_attributes
    request.delete :pledge

    post :submit, user: user, request: request, from_action: "read"
    assert_response :unprocessable_entity

    assert !User.exists?(name: "John Galt")

    assert_select '.errorExplanation h2', /problems with your signup/
    assert_select '.field_with_errors', /can't be blank/
    assert_select '.field_with_errors', /didn't match/
    assert_select '.field_with_errors', /must pledge to read/
  end

  test "donate submit" do
    user = user_attributes
    pledge = pledge_attributes

    post :submit, user: user, pledge: pledge, from_action: "donate"
    assert_redirected_to donate_url

    user = User.find_by_name "John Galt"
    assert_not_nil user
    assert_equal "galt@gulch.com", user.email
    assert_equal "Atlantis, CO", user.location
    assert user.authenticate "dagny"

    assert_equal user.id, session[:user_id]

    pledge = user.pledges.first
    assert_not_nil pledge
    assert_equal 5, pledge.quantity
    assert_equal pledge_reason, pledge.reason

    assert_equal [], user.requests
  end

  test "donate submit failure" do
    user = user_attributes
    user[:email] = ""
    user[:password_confirmation] = "dany"

    pledge = pledge_attributes
    pledge[:quantity] = "x"

    post :submit, user: user, pledge: pledge, from_action: "donate"
    assert_response :unprocessable_entity

    assert !User.exists?(name: "John Galt")

    assert_select '.errorExplanation h2', /problems with your signup/
    assert_select '.field_with_errors', /can't be blank/
    assert_select '.field_with_errors', /didn't match/
    assert_select '.field_with_errors', /Please enter a number/
  end
end
