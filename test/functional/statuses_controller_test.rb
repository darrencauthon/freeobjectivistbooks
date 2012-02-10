require 'test_helper'

class StatusesControllerTest < ActionController::TestCase
  # Sent

  test "sent" do
    assert_difference "@dagny_request.events.count" do
      put :update, {request_id: @dagny_request.id, request: {status: "sent"}}, session_for(@hugh)
    end
    assert_redirected_to @dagny_request
    assert_match /We've let Dagny know/, flash[:notice]

    @dagny_request.reload
    assert @dagny_request.status.sent?, @dagny_request.status.to_s

    verify_event @dagny_request, "update_status", detail: "sent"
  end

  test "sent requires login" do
    put :update, {request_id: @dagny_request.id, request: {status: "sent"}}
    verify_login_page
  end

  test "sent requires donor" do
    put :update, {request_id: @dagny_request.id, request: {status: "sent"}}, session_for(@dagny)
    verify_wrong_login_page
  end

  # Received form

  test "received form" do
    get :edit, {request_id: @quentin_request.id, status: "received"}, session_for(@quentin)
    assert_response :success
    assert_select 'h1', /I have received The Virtue of Selfishness/
    assert_select 'p', /Hugh Akston in Boston, MA\s+sent you this book/
    assert_select 'h2', /Add a thank-you message for Hugh Akston/
    assert_select 'input#request_event_is_thanks[type="hidden"][value=true]'
    assert_select 'textarea#request_event_message'
    assert_select 'input[type="radio"]'
    assert_select 'input[type="submit"]'
  end

  test "received form for an already-thanked request" do
    get :edit, {request_id: @dagny_request.id, status: "received"}, session_for(@dagny)
    assert_response :success
    assert_select 'h1', /I have received Capitalism: The Unknown Ideal/
    assert_select 'p', /Hugh Akston in Boston, MA\s+agreed to send you this book/
    assert_select 'h2', /Add a message for Hugh Akston/
    assert_select 'input#request_event_is_thanks', false
    assert_select 'textarea#request_event_message'
    assert_select 'input[type="radio"]', false
    assert_select 'input[type="submit"]'
  end

  test "received form requires login" do
    get :edit, request_id: @quentin_request.id, status: "received"
    verify_login_page
  end

  test "thank form requires student" do
    get :edit, {request_id: @dagny_request.id, status: "received"}, session_for(@hugh)
    verify_wrong_login_page
  end

  # Received

  test "received" do
    event = {message: "", is_thanks: true, public: nil}
    assert_difference "@quentin_request.events.count" do
      put :update, {request_id: @quentin_request.id, request: {status: "received", event: event}}, session_for(@quentin)
    end
    assert_redirected_to @quentin_request
    assert_match /We've let your donor \(Hugh Akston\) know/, flash[:notice]

    @quentin_request.reload
    assert @quentin_request.received?, @quentin_request.status.to_s
    assert !@quentin_request.thanked?

    verify_event @quentin_request, "update_status", detail: "received", is_thanks?: false, public: nil
  end

  test "received with thank-you" do
    event = {message: "Thank you", is_thanks: true, public: true}
    assert_difference "@quentin_request.events.count" do
      put :update, {request_id: @quentin_request.id, request: {status: "received", event: event}}, session_for(@quentin)
    end
    assert_redirected_to @quentin_request
    assert_match /We've let your donor \(Hugh Akston\) know/, flash[:notice]

    @quentin_request.reload
    assert @quentin_request.received?, @quentin_request.status.to_s
    assert @quentin_request.thanked?

    verify_event @quentin_request, "update_status", detail: "received", is_thanks?: true, message: "Thank you", public: true
  end

  test "received with message" do
    event = {message: "It came today"}
    assert_difference "@dagny_request.events.count" do
      put :update, {request_id: @dagny_request.id, request: {status: "received", event: event}}, session_for(@dagny)
    end
    assert_redirected_to @dagny_request
    assert_match /We've let your donor \(Hugh Akston\) know/, flash[:notice]

    @dagny_request.reload
    assert @dagny_request.received?, @dagny_request.status.to_s

    verify_event @dagny_request, "update_status", detail: "received", is_thanks?: false, message: "It came today", public: nil
  end

  test "received requires login" do
    put :update, {request_id: @quentin_request.id, request: {status: "received"}}
    verify_login_page
  end

  test "received requires student" do
    put :update, {request_id: @dagny_request.id, request: {status: "received"}}, session_for(@hugh)
    verify_wrong_login_page
  end
end
