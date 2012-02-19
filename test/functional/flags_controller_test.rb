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

  # Fix

  test "fix" do
    get :fix, {donation_id: @hank_donation.id}, session_for(@hank)
    assert_response :success
    assert_select '.message.error .headline', /problem/
    assert_select '.message.error .detail', 'Your donor says: "Is your address correct?"'
    assert_select 'input#donation_student_name[value="Hank Rearden"]'
    assert_select 'textarea#donation_address', @hank.address
    assert_select 'textarea#event_message'
    assert_select 'input[type="submit"]'
  end

  test "fix requires login" do
    get :fix, donation_id: @hank_donation.id
    verify_login_page
  end

  test "fix requires request owner" do
    get :fix, {donation_id: @hank_donation.id}, session_for(@quentin)
    verify_wrong_login_page
  end

  # Destroy

  def destroy(donation, options)
    donation_params = options.subhash :student_name, :address
    event_params = options.subhash :message
    params = {donation_id: donation.id, donation: donation_params, event: event_params}
    current_user = options.has_key?(:current_user) ? options[:current_user] : donation.student

    assert_difference "donation.events.count", (options[:expect_events] || 1) do
      delete :destroy, params, session_for(current_user)
    end
  end

  def verify_destroy(donation, params)
    assert_redirected_to donation.request
    assert_match /notified your donor \(#{donation.user.name}\)/, flash[:notice], flash.inspect

    donation.reload
    assert_equal params[:student_name], donation.student_name
    assert_equal params[:address], donation.address
  end

  test "destroy add name" do
    @dagny.address = "123 Somewhere Road"
    @dagny.save!

    options = {student_name: "Dagny Taggart", address: "123 Somewhere Road", message: "Added my full name"}
    destroy @dagny_donation, options
    verify_destroy @dagny_donation, options
    verify_event @dagny_donation, "update", detail: "added their full name", notified?: true
  end

  test "destroy update shipping info" do
    options = {student_name: "Quentin Daniels", address: "123 Quantum Ln", message: ""}
    destroy @quentin_donation, options
    verify_destroy @quentin_donation, options
    verify_event @quentin_donation, "update", detail: "updated shipping info", notified?: true
  end

  test "destroy only message" do
    options = {student_name: "Quentin Daniels", address: @quentin.address, message: "No changes here"}
    destroy @quentin_donation, options
    verify_destroy @quentin_donation, options
    verify_event @quentin_donation, "message", message: "No changes here", notified?: true
  end

  test "destroy requires address" do
    options = {student_name: "Dagny Taggart", address: "", message: "Added my full name", expect_events: 0}
    destroy @dagny_donation, options
    assert_response :success
    assert_select '.field_with_errors', /We need your address/
  end

  test "destroy requires login" do
    options = {student_name: "Quentin Daniels", address: "123 Quantum Ln", message: "", current_user: nil, expect_events: 0}
    destroy @quentin_donation, options
    verify_login_page
  end

  test "destroy requires request owner" do
    options = {student_name: "Quentin Daniels", address: "123 Quantum Ln", message: "", current_user: @hugh, expect_events: 0}
    destroy @quentin_donation, options
    verify_wrong_login_page
  end
end
