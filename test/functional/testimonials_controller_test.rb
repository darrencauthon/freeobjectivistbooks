require 'test_helper'

class TestimonialsControllerTest < ActionController::TestCase
  test "index" do
    get :index
    assert_response :success
    assert_select 'a', /to read/i
    assert_select 'a', /to donate/i
  end

  test "students" do
    get :students
    assert_response :success
  end

  test "donors" do
    get :donors
    assert_response :success
  end

  test "index with current user" do
    get :index, params, session_for(@hugh)
    assert_response :success
    assert_select 'a', /donate books/i
  end

  test "show" do
    testimonial = testimonials :testimonial_1
    get :show, id: testimonial.id
    assert_response :success
    assert_select 'a', /donate/i
    assert_select 'a', /read more/i
  end
end
