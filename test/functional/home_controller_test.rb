require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  def setup
    @howard = users :howard
    @hugh = users :hugh
    @quentin = users :quentin
    @dagny = users :dagny
    @hank = users :hank
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
    assert_select '.request .status', /We are looking for a donor for you/
    assert_select '.request a', text: /thank/i, count: 0
    assert_select '.request a', /see full/i
  end

  test "profile for requester with donor" do
    get :profile, params, session_for(@quentin)
    assert_response :success
    assert_select 'h1', "Quentin Daniels"
    assert_select '.request .headline', /Virtue of Selfishness/
    assert_select '.request .status', /We have found you a donor! Hugh Akston in Boston, MA/
    assert_select '.request a', /thank/i
    assert_select '.request a', /see full/i
  end

  test "profile for requester with donor but no address" do
    get :profile, params, session_for(@dagny)
    assert_response :success
    assert_select 'h1', "Dagny"
    assert_select '.request .headline', /Capitalism/
    assert_select '.request .status', /We have found you a donor!/
    assert_select '.request .flagged', /We need your address/
    assert_select '.request a', /add your address/i
    assert_select '.request a', text: /thank/i, count: 0
    assert_select '.request a', /see full/i
  end

  test "profile for requester with flagged address" do
    get :profile, params, session_for(@hank)
    assert_response :success
    assert_select 'h1', "Hank Rearden"
    assert_select '.request .headline', /Atlas Shrugged/
    assert_select '.request .status', /We have found you a donor!/
    assert_select '.request .flagged', /problem with your shipping info/
    assert_select '.request a', /update/i
    assert_select '.request a', text: /thank/i, count: 0
    assert_select '.request a', /see full/i
  end

  test "profile for donor" do
    get :profile, params, session_for(@hugh)
    assert_response :success
    assert_select 'h1', "Hugh Akston"
    assert_select '.pledge .headline', /You pledged to donate 5 books/

    assert_select '.donation', /Quentin/ do
      assert_select '.request .headline', /Virtue of Selfishness to/
      assert_select '.request .name', /Quentin Daniels/
      assert_select '.request .address', /123 Main St/
      assert_select '.actions a', /see full/i
      assert_select '.actions a', /flag/i
    end

    assert_select '.donation', /Dagny/ do
      assert_select '.request .headline', /Capitalism: The Unknown Ideal to/
      assert_select '.request .name', /Dagny/
      assert_select '.request .address', /No address/
      assert_select '.actions a', /see full/i
      assert_select '.actions .flagged', /Student has been contacted/i
    end

    assert_select '.donation', /Hank/ do
      assert_select '.request .headline', /Atlas Shrugged to/
      assert_select '.request .name', /Hank Rearden/
      assert_select '.request .address', /987 Steel Way/
      assert_select '.actions a', /see full/i
      assert_select '.actions .flagged', /Shipping info flagged/i
    end
  end

  test "profile requires login" do
    get :profile
    assert_response :unauthorized
    assert_select 'h1', 'Log in'
  end

  test "about" do
    get :about
    assert_response :success
    assert_select 'h1', /About/
  end
end
