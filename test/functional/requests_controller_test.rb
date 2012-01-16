require 'test_helper'

class RequestsControllerTest < ActionController::TestCase
  def setup
    @hugh = users :hugh
    @howard = users :howard
    @quentin = users :quentin
    @howard_request = requests :howard_wants_atlas
    @quentin_request = requests :quentin_wants_vos
  end

  # Index

  test "index" do
    get :index, params, session_for(@hugh)
    assert_response :success
    assert_select '.request', 1
    assert_select '.request .headline', "Howard Roark wants Atlas Shrugged"
    assert_select '.sidebar h2', "Your donations (1)"
    assert_select '.sidebar li', /The Virtue of Selfishness to Quentin Daniels/
    assert_select '.sidebar p', "You have pledged 5 books."
  end

  test "index requires login" do
    get :index
    assert_response :success
    assert_select 'h1', 'Log in'
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

  # Update

  def update(request, options)
    user = request.user
    user_params = options.subhash :name, :address
    post :update, {id: request.id, user: user_params}, session_for(user)

    assert_redirected_to request
    assert_match /updated/, flash[:notice]

    user.reload
    assert_equal options[:name], user.name
    assert_equal options[:address], user.address
  end

  test "update no donor" do
    update @howard_request, name: "Howard Roark", address: "123 Independence St"
  end

  test "update with donor" do
    update @quentin_request, name: "Quentin Daniels", address: "123 Quantum Ln"
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
