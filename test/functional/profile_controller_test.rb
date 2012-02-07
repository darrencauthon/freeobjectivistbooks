require 'test_helper'

class ProfileControllerTest < ActionController::TestCase
  # Show

  test "show for requester with no donor" do
    get :show, params, session_for(@howard)
    assert_response :success
    assert_select 'h1', "Howard Roark"
    assert_select '.request .headline', /Atlas Shrugged/
    assert_select '.request .status', /We are looking for a donor for you/
    assert_select '.request a', text: /thank/i, count: 0
    assert_select '.request a', /see full/i
    assert_select 'h2', text: /donation/i, count: 0
  end

  test "show for requester with donor" do
    get :show, params, session_for(@quentin)
    assert_response :success
    assert_select 'h1', "Quentin Daniels"
    assert_select '.request .headline', /Virtue of Selfishness/
    assert_select '.request .status', /Hugh Akston in Boston, MA has sent/
    assert_select '.request a', /thank/i
    assert_select '.request a', /see full/i
    assert_select 'h2', text: /donation/i, count: 0
  end

  test "show for requester with donor but no address" do
    get :show, params, session_for(@dagny)
    assert_response :success
    assert_select 'h1', "Dagny"
    assert_select '.request .headline', /Capitalism/
    assert_select '.request .status', /We have found you a donor!/
    assert_select '.request .flagged', /We need your address/
    assert_select '.request a', /add your address/i
    assert_select '.request a', text: /thank/i, count: 0
    assert_select '.request a', /see full/i
    assert_select 'h2', text: /donation/i, count: 0
  end

  test "show for requester with flagged address" do
    get :show, params, session_for(@hank)
    assert_response :success
    assert_select 'h1', "Hank Rearden"
    assert_select '.request', /Atlas Shrugged/ do
      assert_select '.headline', /Atlas Shrugged/
      assert_select '.status', /We have found you a donor!/
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

  # Donations

  test "donations" do
    get :donations, params, session_for(@hugh)
    assert_response :success
    assert_select 'h1', "Your donations"

    assert_select '.donation', /Virtue of Selfishness to/ do
      assert_select '.request .name', /Quentin Daniels/
      assert_select '.request .address', /123 Main St/
      assert_select '.actions a', /see full/i
      assert_select '.actions a', text: /cancel/i, count: 0
      assert_select '.actions a', text: /flag/i, count: 0
    end

    assert_select '.donation', /Capitalism: The Unknown Ideal to/ do
      assert_select '.request .name', /Dagny/
      assert_select '.request .address', /No address/
      assert_select '.actions a', /see full/i
      assert_select '.actions a', text: /flag/i, count: 0
      assert_select '.actions a', /cancel/i
      assert_select '.actions .flagged', /Student has been contacted/i
    end

    assert_select '.donation', /The Fountainhead to/ do
      assert_select '.request .name', /Quentin Daniels/
      assert_select '.request .address', /123 Main St/
      assert_select '.actions form'
      assert_select '.actions a', /see full/i
      assert_select '.actions a', /flag/i
      assert_select '.actions a', /cancel/i
      assert_select '.actions .flagged', false
    end
  end

  test "donations with flagged shipping info" do
    get :donations, params, session_for(@cameron)
    assert_response :success
    assert_select 'h1', "Your donations"

    assert_select '.donation', /Atlas Shrugged to/ do
      assert_select '.request .name', /Hank Rearden/
      assert_select '.request .address', /987 Steel Way/
      assert_select '.actions a', /see full/i
      assert_select '.actions a', text: /flag/i, count: 0
      assert_select '.actions .flagged', /Shipping info flagged/i
      assert_select '.actions a', /cancel/i
    end
  end

  test "donations requires login" do
    get :donations
    assert_response :unauthorized
    assert_select 'h1', 'Log in'
  end
end
