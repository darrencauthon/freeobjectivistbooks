require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  include ActionDispatch::Assertions::SelectorAssertions

  def setup
    @user = users :hugh
  end

  test "reset_password" do
    mail = UserMailer.reset_password @user
    assert_match /password reset/i, mail.subject
    assert_equal [@user.email], mail.to
    assert_equal ["jason@rationalegoist.com"], mail.from

    mail.deliver
    assert_select_email do
      assert_select 'a', /reset/i
    end
  end
end
