require 'test_helper'

class FlagsControllerTest < ActionController::TestCase
  # New

  test "new" do
    get :new, {donation_id: @quentin_donation.id}, session_for(@hugh)
    assert_response :success
    assert_select 'h1', /flag/i
    assert_select '.address', /123 Main St/
    assert_select 'p', /We'll send your message to Quentin/
    assert_select 'textarea#event_message'
    assert_select 'input[type="submit"]'
  end

  test "new requires login" do
    get :new, donation_id: @quentin_donation.id
    verify_login_page
  end

  test "new requires donor" do
    get :new, {donation_id: @quentin_donation.id}, session_for(@howard)
    verify_wrong_login_page
  end

  # Create

  test "create" do
    assert_difference "@quentin_donation.events.count" do
      post :create, {donation_id: @quentin_donation.id, event: {message: "Fix this"}}, session_for(@hugh)
    end

    assert_redirected_to @quentin_request
    assert_match /has been flagged/i, flash[:notice]

    @quentin_donation.reload
    assert @quentin_donation.flagged?

    @quentin_request.reload
    assert @quentin_request.flagged?

    verify_event @quentin_donation, "flag", message: "Fix this", notified?: true
  end

  test "create requires message" do
    assert_no_difference "@quentin_donation.events.count" do
      post :create, {donation_id: @quentin_donation.id, event: {message: ""}}, session_for(@hugh)
    end

    assert_response :success
    assert_select 'h1', /flag/i

    @quentin_donation.reload
    assert !@quentin_donation.flagged?

    @quentin_request.reload
    assert !@quentin_request.flagged?
  end

  test "create requires login" do
    post :create, {donation_id: @quentin_donation.id, event: {message: "Fix this"}}
    verify_login_page
  end

  test "create requires donor" do
    post :create, {donation_id: @quentin_donation.id, event: {message: "Fix this"}}, session_for(@howard)
    verify_wrong_login_page
  end
end
