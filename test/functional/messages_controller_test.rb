require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
  # New

  test "new for donor" do
    get :new, {request_id: @quentin_request.id}, session_for(@hugh)
    assert_response :success
    assert_select 'h1', /Send a message to Quentin Daniels/
    assert_select '.overview', /Quentin Daniels wants to read\s+The Virtue of Selfishness/
    assert_select 'textarea#event_message'
    assert_select 'input[type="submit"]'
    assert_select 'a', 'Cancel'
  end

  test "new for student" do
    get :new, {request_id: @quentin_request.id}, session_for(@quentin)
    assert_response :success
    assert_select 'h1', /Send a message to Hugh Akston/
    assert_select '.overview', /Hugh Akston agreed to send you\s+The Virtue of Selfishness/
    assert_select 'textarea#event_message'
    assert_select 'input[type="submit"]'
    assert_select 'a', 'Cancel'
  end

  test "new requires login" do
    get :new, request_id: @quentin_request.id
    verify_login_page
  end

  test "new requires student or donor" do
    get :new, {request_id: @quentin_request.id}, session_for(@howard)
    verify_wrong_login_page
  end

  # Flag

  test "create from student" do
    assert_difference "@quentin_request.events.count" do
      post :create, {request_id: @quentin_request.id, event: {message: "Hi Hugh!"}}, session_for(@quentin)
    end

    assert_redirected_to @quentin_request
    assert_match /message to Hugh Akston has been sent/i, flash[:notice]

    verify_event @quentin_request, "message", user: @quentin, message: "Hi Hugh!", notified?: true
  end

  test "create from donor" do
    assert_difference "@quentin_request.events.count" do
      post :create, {request_id: @quentin_request.id, event: {message: "Hi Quentin!"}}, session_for(@hugh)
    end

    assert_redirected_to @quentin_request
    assert_match /message to Quentin Daniels has been sent/i, flash[:notice]

    verify_event @quentin_request, "message", user: @hugh, message: "Hi Quentin!", notified?: true
  end

  test "create requires message" do
    assert_no_difference "@quentin_request.events.count" do
      post :create, {request_id: @quentin_request.id, event: {message: ""}}, session_for(@quentin)
    end

    assert_response :success
    assert_select 'h1', /Send a message/i
  end

  test "create requires login" do
    post :create, {request_id: @quentin_request.id, event: {message: "Hello"}}
    verify_login_page
  end

  test "create requires student or donor" do
    post :create, {request_id: @quentin_request.id, event: {message: "Hello"}}, session_for(@howard)
    verify_wrong_login_page
  end
end
