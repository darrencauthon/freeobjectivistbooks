require 'test_helper'

class RequestsControllerTest < ActionController::TestCase
  def setup
    @hugh = users :hugh
    @session = {user_id: @hugh.id}
  end

  test "index" do
    get :index
    assert_response :success
    assert_select '.request', 1
    assert_select '.request .headline', "Howard Roark wants Atlas Shrugged"
  end

  test "index shows pledge" do
    get(:index, {}, @session)
    assert_response :success
    assert_select '.overview p', "You have pledged to donate 5 books."
  end
end
