require 'test_helper'

class AnnouncementMailerTest < ActionMailer::TestCase
  include ActionDispatch::Assertions::SelectorAssertions

  test "send announcements" do
    requests = Request.granted.where(thanked: [nil, false])
    assert requests.any?

    assert_difference "ActionMailer::Base.deliveries.count", requests.count do
      AnnouncementMailer.send_announcements :thank_your_donor, requests
    end
  end

  test "thank your donor" do
    mail = AnnouncementMailer.thank_your_donor requests(:hank_wants_atlas)
    assert_equal "Thank your donor for Atlas Shrugged", mail.subject
    assert_equal ["hank@rearden.com"], mail.to
    assert_equal ["jason@rationalegoist.com"], mail.from

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Hank/
      assert_select 'p', /Hugh Akston agreed to send you Atlas Shrugged/
      assert_select 'a', /Thank Hugh Akston/
      assert_select 'p', /looking forward to reading\s+Atlas Shrugged/
    end
  end

  test "reply to thanks" do
    mail = AnnouncementMailer.reply_to_thanks events(:quentin_thanks_hugh)
    assert_equal "Now you can reply to Quentin Daniels's thank-you note on Free Objectivist Books", mail.subject
    assert_equal ["akston@patrickhenry.edu"], mail.to

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Hugh/
      assert_select 'p', /got a thank-you message from Quentin Daniels for The Virtue of Selfishness/
      assert_select 'p', /Now you can reply to Quentin/
      assert_select 'a', /Reply to Quentin/
      assert_select 'p', '"Thanks! I am looking forward to reading this"'
      assert_select 'p', /Thanks,\nFree Objectivist Books/
    end
  end
end