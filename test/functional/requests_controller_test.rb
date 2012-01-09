require 'test_helper'

class RequestsControllerTest < ActionController::TestCase
  def setup
    @hugh = users :hugh
    @session = {user_id: @hugh.id}
  end

  test "index" do
    get(:index, {}, @session)
    assert_response :success
    assert_select '.request', 1
    assert_select '.request .headline', "Howard Roark wants Atlas Shrugged"
    assert_select '.donations h2', "Your donations (1)"
    assert_select '.donations li', /The Virtue of Selfishness to Quentin Daniels/
    assert_select '.donations p', "You have pledged 5 books."
  end

  test "index requires login" do
    get :index
    assert_response :success
    assert_select 'h1', 'Log in'
  end

  test "grant" do
    request = requests :howard_wants_atlas
    post(:grant, {id: request.id}, @session)
    assert_redirected_to donate_url

    request.reload
    assert_equal @hugh, request.donor
  end
end
