require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  def setup
    @howard = users :howard
    @hugh = users :hugh
    @quentin = users :quentin
  end

  test "index is home if not logged in" do
    get :index
    assert_response :success
    assert_select 'h1', "Free Objectivist Books for Students"
  end

  test "index is profile if logged in" do
    get :index, params, session_for(@howard)
    assert_response :success
    assert_select 'h1', "Howard Roark"
  end

  test "home" do
    get :home, params, session_for(@howard)
    assert_response :success
    assert_select 'h1', "Free Objectivist Books for Students"
  end

  test "profile for requester with no donor" do
    get :profile, params, session_for(@howard)
    assert_response :success
    assert_select 'h1', "Howard Roark"
    assert_select '.request .headline', /Atlas Shrugged/
    assert_select '.request .donation', /We are looking for a donor for you/
  end

  test "profile for requester with donor" do
    get :profile, params, session_for(@quentin)
    assert_response :success
    assert_select 'h1', "Quentin Daniels"
    assert_select '.request .headline', /Virtue of Selfishness/
    assert_select '.request .donation', /We have found you a donor! Hugh Akston in Boston, MA/
  end

  test "profile for donor" do
    get :profile, params, session_for(@hugh)
    assert_response :success
    assert_select 'h1', "Hugh Akston"
    assert_select '.pledge .headline', /You pledged to donate 5 books/
    assert_select '.request .headline', /Virtue of Selfishness to Quentin Daniels/
    assert_select '.request .address', /123 Main St/
  end

  test "profile for donor when student is missing address" do
    @quentin.address = ""
    @quentin.save!

    get :profile, params, session_for(@hugh)
    assert_response :success
    assert_select 'h1', "Hugh Akston"
    assert_select '.pledge .headline', /You pledged to donate 5 books/
    assert_select '.request .headline', /Virtue of Selfishness to Quentin Daniels/
    assert_select '.request .address', /This student hasn't given their full address yet/
  end

  test "profile requires login" do
    get :profile
    assert_response :success
    assert_select 'h1', 'Log in'
  end

  test "about" do
    get :about
    assert_response :success
    assert_select 'h1', /About/
  end
end
