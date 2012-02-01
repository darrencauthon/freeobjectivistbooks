require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "reset_password" do
    mail = UserMailer.reset_password @hugh
    assert_match /password reset/i, mail.subject
    assert_equal [@hugh.email], mail.to
    assert_equal ["jason@rationalegoist.com"], mail.from

    mail.deliver
    assert_select_email do
      assert_select 'a', /reset/i
    end
  end
end
