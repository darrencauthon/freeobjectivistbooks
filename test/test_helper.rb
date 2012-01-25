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

  def params(params = {})
    params
  end

  def session_for(user)
    user ? {user_id: user.id} : {}
  end

  def setup
    @hugh = users :hugh
    @howard = users :howard
    @quentin = users :quentin
    @dagny = users :dagny
    @hank = users :hank

    @howard_request = requests :howard_wants_atlas
    @quentin_request = requests :quentin_wants_vos
    @dagny_request = requests :dagny_wants_cui
    @hank_request = requests :hank_wants_atlas
  end

  def verify_login_page
    assert_response :unauthorized
    assert_select 'h1', 'Log in'
  end

  def verify_wrong_login_page
    assert_response :forbidden
    assert_select 'h1', 'Wrong login?'
  end

  def verify_event(request, type, options = {})
    request.reload
    event = request.events.last
    assert_equal type, event.type
    options.keys.each do |key|
      assert_equal options[key], event.send(key), "verify_event: #{key} didn't match"
    end
  end
end

# from https://gist.github.com/1282275
class ActionController::TestCase
  require 'digest/md5'

  def authenticate_with_http_digest(user, password, realm)
    ActionController::Base.class_eval { include ActionController::Testing }

    @controller.instance_eval %Q(
      alias real_process_with_new_base_test process_with_new_base_test

      def process_with_new_base_test(request, response)
        credentials = {
      	  :uri => request.url,
      	  :realm => "#{realm}",
      	  :username => "#{user}",
      	  :nonce => ActionController::HttpAuthentication::Digest.nonce(request.env['action_dispatch.secret_token']),
      	  :opaque => ActionController::HttpAuthentication::Digest.opaque(request.env['action_dispatch.secret_token'])
        }
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Digest.encode_credentials(request.request_method, credentials, "#{password}", false)

        real_process_with_new_base_test(request, response)
      end
    )
  end
end

class User
  def invalid_letmein_params
    letmein_params.merge auth: "wrong"
  end

  def expired_letmein_params
    letmein_params.merge timestamp: 1.year.ago.iso8601
  end
end
