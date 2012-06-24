require 'test_helper'

class Admin::EventsControllerTest < ActionController::TestCase
  test "index" do
    admin_auth
    get :index
    assert_response :success
    assert_select 'h1', /#{Event.count} event/
    assert_select '.event', Event.count
  end

  test "testimonials" do
    admin_auth
    get :index, testimonials: 'true'
    assert_response :success
    assert_select 'h1', /public thank-yous/
    assert_select '.event', Event.testimonials.count
  end

  test "show requires login" do
    get :index
    assert_response :unauthorized
    assert_select '.event', 0
  end
end
