require 'test_helper'

class ProfileControllerTest < ActionController::TestCase
  test "show for requester with no donor" do
    get :show, params, session_for(@howard)
    assert_response :success
    assert_select 'h1', "Howard Roark"

    assert_select '.request', /Atlas Shrugged/ do
      assert_select '.headline', /Atlas Shrugged/
      assert_select '.status', /We are looking for a donor/
      assert_select 'a', text: /thank/i, count: 0
      assert_select 'a', /see full/i
    end

    assert_select 'h2', text: /donation/i, count: 0
  end

  test "show for requester with donor" do
    get :show, params, session_for(@quentin)
    assert_response :success
    assert_select 'h1', "Quentin Daniels"

    assert_select '.request', /Virtue of Selfishness/ do
      assert_select '.headline', /Quentin Daniels in Boston, MA wants to read The Virtue of Selfishness/
      assert_select '.status', /Hugh Akston in Boston, MA has sent/
      assert_select 'a', /Let Hugh Akston know/i
      assert_select 'a', text: /thank/i, count: 0
      assert_select 'a', /see full/i
    end

    assert_select '.request', /Fountainhead/ do
      assert_select '.headline', /Quentin Daniels in Boston, MA wants to read The Fountainhead/
      assert_select '.status', /Hugh Akston in Boston, MA will donate/
      assert_select 'a', /thank/i
      assert_select 'a', /see full/i
    end

    assert_select 'h2', text: /donation/i, count: 0
  end

  test "show for requester with donor but no address" do
    get :show, params, session_for(@dagny)
    assert_response :success
    assert_select 'h1', "Dagny"

    assert_select '.request', /Capitalism/ do
      assert_select '.headline', /Capitalism/
      assert_select '.status', /Hugh Akston in Boston, MA will donate/
      assert_select '.flagged', /We need your address/
      assert_select 'a', /add your address/i
      assert_select 'a', text: /thank/i, count: 0
      assert_select 'a', /see full/i
    end

    assert_select 'h2', text: /donation/i, count: 0
  end

  test "show for requester with flagged address" do
    get :show, params, session_for(@hank)
    assert_response :success
    assert_select 'h1', "Hank Rearden"

    assert_select '.request', /Atlas Shrugged/ do
      assert_select '.headline', /Atlas Shrugged/
      assert_select '.status', /Henry Cameron in New York, NY will donate/
      assert_select '.flagged', /problem with your shipping info/
      assert_select 'a', /update/i
      assert_select 'a', text: /thank/i, count: 0
      assert_select 'a', /see full/i
    end

    assert_select 'h2', text: /donation/i, count: 0
  end

  test "show for donor" do
    get :show, params, session_for(@hugh)
    assert_response :success
    assert_select 'h1', "Hugh Akston"
    assert_select '.pledge .headline', /You pledged to donate 5 books/
    assert_select 'h2', 'Outstanding donations'

    assert_select '.donation', text: /The Virtue of Selfishness/, count: 0      # sent
    assert_select '.donation', text: /Capitalism: The Unknown Ideal/, count: 0  # flagged
    assert_select '.donation', text: /Atlas Shrugged/, count: 0                 # also flagged

    assert_select '.donation', /The Fountainhead to/ do
      assert_select '.request .name', /Quentin Daniels/
      assert_select '.request .address', /123 Main St/
      assert_select '.actions a', /see full/i
      assert_select '.actions a', /flag/i
      assert_select '.actions a', /cancel/i
      assert_select '.actions .flagged', false
    end

    assert_select 'a', 'See all your donations'
  end

  test "show requires login" do
    get :show
    assert_response :unauthorized
    assert_select 'h1', 'Log in'
  end
end
