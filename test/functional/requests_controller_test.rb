require 'test_helper'

class RequestsControllerTest < ActionController::TestCase
  # Index

  test "index" do
    get :index, params, session_for(@hugh)
    assert_response :success
    assert_select '.request .headline', "Howard Roark wants Atlas Shrugged"
    assert_select '.sidebar h2', "Your donations (3)"
    assert_select '.sidebar li', /The Virtue of Selfishness to Quentin Daniels/
    assert_select '.sidebar li', /Capitalism: The Unknown Ideal to Dagny/
    assert_select '.sidebar li', /Atlas Shrugged to Hank Rearden/
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
    assert_select '.tagline', "Studying architecture at Stanton Institute of Technology in New York, NY"
    assert_select '.address', /no address/i
    assert_select 'a', /add your address/i
    assert_select 'h2', /status: looking/i
  end

  test "show with donor" do
    get :show, {id: @quentin_request.id}, session_for(@quentin)
    assert_response :success
    assert_select 'h1', "Quentin Daniels wants The Virtue of Selfishness"
    assert_select '.tagline', "Studying physics at MIT in Boston, MA"
    assert_select '.address', /123 Main St/
    assert_select 'a', /update/i
    assert_select 'a', text: /flag/i, count: 0
    assert_select 'h2', /status: donor found/i
    assert_select 'a', /thank/i
  end

  test "show to donor" do
    get :show, {id: @quentin_request.id}, session_for(@hugh)
    assert_response :success
    assert_select 'h1', "Quentin Daniels wants The Virtue of Selfishness"
    assert_select '.tagline', "Studying physics at MIT in Boston, MA"
    assert_select '.address', /123 Main St/
    assert_select 'a', /flag/i
    assert_select 'a', text: /update/i, count: 0
    assert_select 'h2', /status: donor found/i
    assert_select 'a', text: /thank/i, count: 0
  end

  test "show to student with missing address" do
    get :show, {id: @dagny_request.id}, session_for(@dagny)
    assert_response :success
    assert_select '.message.error .headline', /We need your address/
    assert_select '.message.error .headline a', /Add/
    assert_select 'h1', "Dagny wants Capitalism: The Unknown Ideal"
  end

  test "show to student with flagged address" do
    get :show, {id: @hank_request.id}, session_for(@hank)
    assert_response :success
    assert_select '.message.error .headline', /problem with your shipping info/
    assert_select '.message.error .headline a', /Update/
    assert_select 'h1', "Hank Rearden wants Atlas Shrugged"
  end

  test "show to donor with missing address" do
    get :show, {id: @dagny_request.id}, session_for(@hugh)
    assert_response :success
    assert_select '.message.error', false
    assert_select 'h1', "Dagny wants Capitalism: The Unknown Ideal"
    assert_select '.address', /no address/i
    assert_select '.flagged', /Student has been contacted/i
    assert_select 'a', text: /update/i, count: 0
    assert_select 'a', text: /thank/i, count: 0
  end

  test "show to donor with flagged address" do
    get :show, {id: @hank_request.id}, session_for(@hugh)
    assert_response :success
    assert_select '.message.error', false
    assert_select 'h1', "Hank Rearden wants Atlas Shrugged"
    assert_select '.address', /987 Steel Way/i
    assert_select '.flagged', /Shipping info flagged/i
    assert_select 'a', text: /update/i, count: 0
    assert_select 'a', text: /thank/i, count: 0
  end

  test "show requires login" do
    get :show, id: @howard_request.id
    verify_login_page
  end

  test "show requires request owner or donor" do
    get :show, {id: @howard_request.id}, session_for(@quentin)
    verify_wrong_login_page
  end

  # Grant

  test "grant" do
    request = requests :quentin_wants_opar
    assert_difference "request.events.count" do
      post :grant, {id: request.id}, session_for(@hugh)
    end
    assert_redirected_to donate_url

    request.reload
    assert_equal @hugh, request.donor
    assert !request.flagged?

    verify_event request, "grant", notified?: true
  end

  test "grant no address" do
    assert_difference "@howard_request.events.count" do
      post :grant, {id: @howard_request.id}, session_for(@hugh)
    end
    assert_redirected_to donate_url

    @howard_request.reload
    assert_equal @hugh, @howard_request.donor
    assert @howard_request.flagged?

    verify_event @howard_request, "grant", notified?: true
  end

  test "grant requires login" do
    post :grant, id: @howard_request.id
    verify_login_page
  end

  # Flag form

  test "flag form" do
    get :edit, {id: @quentin_request.id, type: "flag"}, session_for(@hugh)
    assert_response :success
    assert_select 'h1', /flag/i
    assert_select '.address', /123 Main St/
    assert_select 'p', /We'll send your message to Quentin/
    assert_select 'textarea#request_event_message'
    assert_select 'input[type="submit"]'
  end

  test "flag form requires login" do
    get :edit, id: @quentin_request.id, type: "flag"
    verify_login_page
  end

  test "flag form requires donor" do
    get :edit, {id: @quentin_request.id, type: "flag"}, session_for(@howard)
    verify_wrong_login_page
  end

  # Flag

  test "flag" do
    assert_difference "@quentin_request.events.count" do
      post :flag, {id: @quentin_request.id, request: {event: {message: "Fix this"}}}, session_for(@hugh)
    end

    assert_redirected_to @quentin_request
    assert_match /has been flagged/i, flash[:notice]

    @quentin_request.reload
    assert @quentin_request.flagged?

    verify_event @quentin_request, "flag", message: "Fix this", notified?: true
  end

  test "flag requires message" do
    assert_no_difference "@quentin_request.events.count" do
      post :flag, {id: @quentin_request.id, request: {event: {message: ""}}}, session_for(@hugh)
    end

    assert_response :success
    assert_select 'h1', /flag/i

    @quentin_request.reload
    assert !@quentin_request.flagged?
  end

  test "flag requires login" do
    post :flag, {id: @quentin_request.id, request: {event: {message: "Fix this"}}}
    verify_login_page
  end

  test "flag requires donor" do
    post :flag, {id: @quentin_request.id, request: {event: {message: "Fix this"}}}, session_for(@howard)
    verify_wrong_login_page
  end

  # Edit

  test "edit no donor" do
    get :edit, {id: @howard_request.id}, session_for(@howard)
    assert_response :success
    assert_select 'input[type="text"][value="Howard Roark"]#request_user_name'
    assert_select 'textarea#request_user_address', ""
    assert_select 'p', /you can enter this later/i
    assert_select 'textarea#event_message', false
    assert_select 'input[type="submit"]'
  end

  test "edit with donor" do
    get :edit, {id: @quentin_request.id}, session_for(@quentin)
    assert_response :success
    assert_select 'input[type="text"][value="Quentin Daniels"]#request_user_name'
    assert_select 'textarea#request_user_address', @quentin.address
    assert_select 'p', text: /you can enter this later/i, count: 0
    assert_select 'textarea#request_event_message', ""
    assert_select 'input[type="submit"]'
    assert_select '.message.error', false
  end

  test "edit missing" do
    get :edit, {id: @dagny_request.id}, session_for(@dagny)
    assert_response :success
    assert_select '.message.error .headline', /Add your address/
  end

  test "edit flagged" do
    get :edit, {id: @hank_request.id}, session_for(@hank)
    assert_response :success
    assert_select '.message.error .headline', /problem/
    assert_select '.message.error .detail', 'Your donor says: "Is your address correct?"'
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
      post :update, {id: request.id, request: {user: user_params, event: {message: message}}}, session_for(current_user)
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

  test "update no donor" do
    options = {name: "Howard Roark", address: "123 Independence St"}
    update @howard_request, options
    verify_update @howard_request, options, /updated/i
    verify_event @howard_request, "update", detail: "added a shipping address", notified?: false
  end

  test "update add name" do
    @dagny.address = "123 Somewhere Road"
    @dagny.save!

    options = {name: "Dagny Taggart", address: "123 Somewhere Road", message: "Added my full name"}
    update @dagny_request, options
    verify_update @dagny_request, options, /notified/i
    verify_event @dagny_request, "update", detail: "added their full name", notified?: true
  end

  test "update shipping info" do
    options = {name: "Quentin Daniels", address: "123 Quantum Ln"}
    update @quentin_request, options
    verify_update @quentin_request, options, /has been notified/i
    verify_event @quentin_request, "update", detail: "updated shipping info", notified?: true
  end

  test "update only message" do
    options = {name: "Quentin Daniels", address: @quentin.address, message: "No changes here"}
    update @quentin_request, options
    verify_update @quentin_request, options, /message has been sent/i
    verify_event @quentin_request, "message", message: "No changes here", notified?: true
  end

  test "update requires address if granted" do
    options = {name: "Dagny Taggart", address: "", message: "Added my full name", expect_events: 0}
    update @dagny_request, options
    assert_response :success
    assert_select '.field_with_errors', /We need your address/
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

  # Thank form

  test "thank form" do
    get :edit, {id: @hank_request.id, type: "thank"}, session_for(@hank)
    assert_response :success
    assert_select 'h1', /Thank/
    assert_select 'p', /Hugh Akston in Boston, MA agreed to send you\s+Atlas Shrugged/
    assert_select 'textarea#request_event_message'
    assert_select 'input[type="radio"]'
    assert_select 'input[type="submit"]'
  end

  test "thank form requires login" do
    get :edit, id: @hank_request.id, type: "thank"
    verify_login_page
  end

  test "thank form requires student" do
    get :edit, {id: @hank_request.id, type: "thank"}, session_for(@howard)
    verify_wrong_login_page
  end

  # Thank

  def thank_request_params
    {event: {message: "Thanks so much!", public: true}}
  end

  test "thank" do
    assert_difference "@hank_request.events.count" do
      put :thank, {id: @hank_request.id, request: thank_request_params}, session_for(@hank)
    end

    assert_redirected_to @hank_request
    assert_match /sent your thanks/i, flash[:notice]

    @hank_request.reload
    assert @hank_request.thanked?

    verify_event @hank_request, "thank", message: "Thanks so much!", notified?: true
  end

  test "thank requires message" do
    request_params = thank_request_params
    request_params[:event][:message] = ""

    assert_no_difference "@hank_request.events.count" do
      put :thank, {id: @hank_request.id, request: request_params}, session_for(@hank)
    end

    assert_response :success
    assert_select 'h1', /thank/i
    assert_select '.field_with_errors', /enter a message/

    @hank_request.reload
    assert !@hank_request.thanked?
  end

  test "thank requires explicit public bit" do
    request_params = thank_request_params
    request_params[:event].delete :public

    assert_no_difference "@hank_request.events.count" do
      put :thank, {id: @hank_request.id, request: request_params}, session_for(@hank)
    end

    assert_response :success
    assert_select 'h1', /thank/i
    assert_select '.field_with_errors', /choose/

    @hank_request.reload
    assert !@hank_request.thanked?
  end

  test "thank requires login" do
    put :thank, {id: @hank_request.id, request: thank_request_params}
    verify_login_page
  end

  test "thank requires student" do
    put :thank, {id: @hank_request.id, request: thank_request_params}, session_for(@hugh)
    verify_wrong_login_page
  end
end
