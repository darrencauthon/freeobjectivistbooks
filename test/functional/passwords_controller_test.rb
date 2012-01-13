require 'test_helper'

class PasswordsControllerTest < ActionController::TestCase
  def setup
    @user = users :hugh
  end

  def validate_reset_form
    assert_response :success
    assert_select 'h1', "Reset password"
    assert_select 'input#user_password'
    assert_select 'input#user_password_confirmation'
    assert_select 'input[type="submit"]'
  end

  def validate_invalid_page
    assert_response :success
    assert_select 'h1', /invalid/i
    assert_select 'p', /something went wrong/i
    assert_select "a[href=\"#{forgot_password_path}\"]"
  end

  def validate_expired_page
    assert_response :success
    assert_select 'h1', /expired/i
    assert_select 'p', /link has expired/i
    assert_select "a[href=\"#{forgot_password_path}\"]"
  end

  test "forgot" do
    get :forgot
    assert_response :success
    assert_select 'h1', "Forgot your password?"
    assert_select 'input[name="email"]'
    assert_select 'input[type="submit"]'
  end

  test "request reset" do
    assert_difference "ActionMailer::Base.deliveries.size", 1 do
      post :request_reset, email: @user.email
    end
    assert_response :success
    assert_select 'h1', "Reset sent"

    mail = ActionMailer::Base.deliveries.first
    assert_match /password/i, mail.subject
  end

  test "request reset with bad email" do
    post :request_reset, email: "wrong@bogus.com"
    assert_response :success
    assert_select 'h1', "Forgot your password?"
    assert_select '.field_with_errors', /no user/i
  end

  test "edit" do
    get :edit, @user.letmein_params
    validate_reset_form
  end

  test "edit with invalid letmein" do
    get :edit, @user.invalid_letmein_params
    validate_invalid_page
  end

  test "edit with expired letmein" do
    get :edit, @user.expired_letmein_params
    validate_expired_page
  end

  def post_password_update(password, options = {})
    confirmation = options[:confirmation] || password
    user_params = {password: password, password_confirmation: confirmation}
    params = @user.letmein_params.merge user: user_params
    post :update, params
    @user.reload

    if options[:expect_error]
      validate_reset_form
      assert_select '.field_with_errors', options[:expect_error]
      assert !@user.authenticate(password)
    else
      assert_redirected_to root_url
      assert @user.authenticate(password)
    end
  end

  test "update" do
    post_password_update "password"
  end

  test "update can't be blank" do
    post_password_update "", expect_error: /can't be blank/
  end

  test "update requires confirmation" do
    post_password_update "password", confirmation: "wrong", expect_error: /didn't match/
  end

  test "update with invalid letmein" do
    post :update, @user.invalid_letmein_params
    validate_invalid_page
  end

  test "update with expired letmein" do
    post :update, @user.expired_letmein_params
    validate_expired_page
  end
end
