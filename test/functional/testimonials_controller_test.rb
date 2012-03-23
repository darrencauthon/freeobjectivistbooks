require 'test_helper'

class TestimonialsControllerTest < ActionController::TestCase
  test "index" do
    get :index
    assert_response :success
    assert_select 'a', /to read/i
    assert_select 'a', /to donate/i
  end

  test "index with current user" do
    get :index, params, session_for(@hugh)
    assert_response :success
    assert_select 'a', /donate books/i
  end
end
