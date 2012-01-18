require 'test_helper'

class RequestsControllerTest < ActionController::TestCase
  def setup
    @hugh = users :hugh
    @howard = users :howard
    @quentin = users :quentin
    @howard_request = requests :howard_wants_atlas
    @quentin_request = requests :quentin_wants_vos
    @dagny_request = requests :dagny_wants_cui
  end

  def verify_login_page
    assert_response :unauthorized
    assert_select 'h1', 'Log in'
  end

  def verify_wrong_login_page
    assert_response :forbidden
    assert_select 'h1', 'Wrong login?'
  end

  # Index

  test "index" do
    get :index, params, session_for(@hugh)
    assert_response :success
    assert_select '.request', 1
    assert_select '.request .headline', "Howard Roark wants Atlas Shrugged"
    assert_select '.sidebar h2', "Your donations (2)"
    assert_select '.sidebar li', /The Virtue of Selfishness to Quentin Daniels/
    assert_select '.sidebar li', /Capitalism: The Unknown Ideal to Dagny/
    assert_select '.sidebar p', "You have pledged 5 books."
  end

  test "index requires login" do
    get :index
    verify_login_page
  end

  # Show

  test "show no donor" do
    get :show, {id: @howard_request.id}, session_for(@howard)
    assert_response :success
    assert_select 'h1', "Howard Roark wants Atlas Shrugged"
    assert_select '.address', /no address/i
    assert_select 'a', /add your address/i
    assert_select 'h2', /status: looking/i
  end

  test "show with donor" do
    get :show, {id: @quentin_request.id}, session_for(@quentin)
    assert_response :success
    assert_select 'h1', "Quentin Daniels wants The Virtue of Selfishness"
    assert_select '.address', /123 Main St/
    assert_select 'a', /update/i
    assert_select 'h2', /status: donor found/i
  end

  test "show requires login" do
    get :show, id: @howard_request.id
    verify_login_page
  end

  test "show requires request owner" do
    get :show, {id: @howard_request.id}, session_for(@quentin)
    verify_wrong_login_page
  end

  # Edit

  test "edit no donor" do
    get :edit, {id: @howard_request.id}, session_for(@howard)
    assert_response :success
    assert_select 'input[type="text"][value="Howard Roark"]#user_name'
    assert_select 'textarea#user_address', ""
    assert_select 'p', /you can enter this later/i
    assert_select 'textarea#message', false
    assert_select 'input[type="submit"]'
  end

  test "edit with donor" do
    get :edit, {id: @quentin_request.id}, session_for(@quentin)
    assert_response :success
    assert_select 'input[type="text"][value="Quentin Daniels"]#user_name'
    assert_select 'textarea#user_address', @quentin.address
    assert_select 'p', text: /you can enter this later/i, count: 0
    assert_select 'textarea#message', ""
    assert_select 'input[type="submit"]'
  end

  test "edit requires login" do
    get :edit, id: @howard_request.id
    verify_login_page
  end

  test "edit requires request owner" do
    get :edit, {id: @howard_request.id}, session_for(@quentin)
    verify_wrong_login_page
  end

  # Update

  def update(request, options)
    user = request.user
    user_params = options.subhash :name, :address
    message = options[:message]
    current_user = options.has_key?(:current_user) ? options[:current_user] : user

    assert_difference "request.events.count", (options[:expect_events] || 1) do
      post :update, {id: request.id, user: user_params, message: message}, session_for(current_user)
    end
  end

  def verify_update(request, params, notice)
    assert_redirected_to request
    assert_match notice, flash[:notice], flash.inspect

    user = request.user
    user.reload
    assert_equal params[:name], user.name
    assert_equal params[:address], user.address
  end

  def verify_event(request, type, options = {})
    event = request.events.last
    assert_equal type, event.type
    assert_equal options[:detail], event.detail if options[:detail]
    assert_equal options[:notified], event.notified? if options[:notified].present?
  end

  def verify_notification(event, subject)
    assert event.notified?
    mail = ActionMailer::Base.deliveries.last
    assert_match subject, mail.subject
  end

  test "update no donor" do
    options = {name: "Howard Roark", address: "123 Independence St"}
    update @howard_request, options
    verify_update @howard_request, options, /updated/i
    verify_event @howard_request, "update", detail: "added a shipping address", notified: false
  end

  test "update add name" do
    options = {name: "Dagny Taggart", address: "", message: "Added my full name"}
    update @dagny_request, options
    verify_update @dagny_request, options, /notified/i
    verify_event @dagny_request, "update", detail: "added their full name"
  end

  test "update shipping info" do
    options = {name: "Quentin Daniels", address: "123 Quantum Ln"}
    update @quentin_request, options
    verify_update @quentin_request, options, /has been notified/i
    verify_event @quentin_request, "update", detail: "updated shipping info", notified: true
  end

  test "update only message" do
    options = {name: "Quentin Daniels", address: @quentin.address, message: "No changes here"}
    update @quentin_request, options
    verify_update @quentin_request, options, /message has been sent/i
    verify_event @quentin_request, "message", notified: true
  end

  test "update requires login" do
    options = {name: "Howard Roark", address: "123 Independence St", current_user: nil, expect_events: 0}
    update @howard_request, options
    verify_login_page
  end

  test "update requires request owner" do
    options = {name: "Howard Roark", address: "123 Independence St", current_user: @quentin, expect_events: 0}
    update @howard_request, options
    verify_wrong_login_page
  end

  # Grant

  test "grant" do
    request = requests :howard_wants_atlas
    post :grant, {id: request.id}, session_for(@hugh)
    assert_redirected_to donate_url

    request.reload
    assert_equal @hugh, request.donor
  end
end
