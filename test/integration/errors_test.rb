require 'test_helper'

class ErrorsTest < ActionDispatch::IntegrationTest
  fixtures :all

  test "not found" do
    get "/does/not/exist"
    assert_response :not_found
    assert_select 'h1', /not found/i
  end

  test "request not found" do
    get "/requests/123456789"
    assert_response :not_found
    assert_select 'h1', /not found/i
  end

  test "server error" do
    get "/test/exception"
    assert_response :internal_server_error
    assert_select 'h1', /error/i
  end

  test "not found XML" do
    get "/crossdomain.xml"
    assert_response :not_found
  end
end
