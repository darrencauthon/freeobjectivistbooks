require 'test_helper'

class DonationsControllerTest < ActionController::TestCase
  test "index" do
    get :index, params, session_for(@hugh)
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

  test "index with flagged shipping info" do
    get :index, params, session_for(@cameron)
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

  test "index requires login" do
    get :index
    verify_login_page
  end
end
