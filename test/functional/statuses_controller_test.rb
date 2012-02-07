require 'test_helper'

class StatusesControllerTest < ActionController::TestCase
  # Update

  test "update" do
    assert_difference "@dagny_request.events.count" do
      put :update, {request_id: @dagny_request.id, request: {status: "sent"}}, session_for(@hugh)
    end
    assert_redirected_to @dagny_request
    assert_match /We've let Dagny know/, flash[:notice]

    @dagny_request.reload
    assert @dagny_request.status.sent?, @dagny_request.status.to_s

    verify_event @dagny_request, "update_status", detail: "sent"
  end

  test "update requires login" do
    put :update, {request_id: @dagny_request.id, request: {status: "sent"}}
    verify_login_page
  end

  test "update requires donor" do
    put :update, {request_id: @dagny_request.id, request: {status: "sent"}}, session_for(@dagny)
    verify_wrong_login_page
  end
end
