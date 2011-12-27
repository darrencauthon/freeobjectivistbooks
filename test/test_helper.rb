ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def digest_auth(path, username, realm, password)
    token = @request.env['action_dispatch.secret_token']

    credentials = {
      uri: "http://test.host/#{path}",
      realm: realm,
      username: username,
      nonce: ActionController::HttpAuthentication::Digest.nonce(token),
      opaque: ActionController::HttpAuthentication::Digest.opaque(token),
    }

    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Digest.encode_credentials(
      @request.request_method, credentials, password, false)
  end
end
