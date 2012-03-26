require 'test_helper'

class AnnouncementMailerTest < ActionMailer::TestCase
  test "send campaign" do
    Mailgun::Campaign.test_mode = true
    requests = Donation.not_thanked.map {|donation| donation.request}
    assert requests.any?

    assert_difference "ActionMailer::Base.deliveries.count", requests.count do
      AnnouncementMailer.send_campaign :thank_your_donor, requests
    end
  end

  test "thank your donor" do
    mail = AnnouncementMailer.thank_your_donor @hank_request
    assert_equal "Thank your donor for Atlas Shrugged", mail.subject
    assert_equal ["hank@rearden.com"], mail.to
    assert_equal ["jason@rationalegoist.com"], mail.from

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Hank/
      assert_select 'p', /Henry Cameron agreed to send you Atlas Shrugged/
      assert_select 'a', /Thank Henry Cameron/
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

  test "mark sent books" do
    mail = AnnouncementMailer.mark_sent_books @hugh
    assert_equal "Have you sent your Objectivist books? Let me and the students know", mail.subject
    assert_equal ["akston@patrickhenry.edu"], mail.to

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Hugh/
      assert_select 'p', /Have you sent your 3 books yet/
      assert_select 'a', /See your donations/
      assert_select 'p', /If you've already sent your books/
    end
  end

  test "mark received books" do
    mail = AnnouncementMailer.mark_received_books @quentin_request
    assert_equal "Have you received The Virtue of Selfishness? Let us and your donor know", mail.subject
    assert_equal ["quentin@mit.edu"], mail.to

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Quentin/
      assert_select 'p', /Have you received The Virtue of Selfishness yet/
      assert_select 'p', /Hugh Akston has sent you this book \(confirmed on Jan 19\)/
      assert_select 'a', /Yes, I have received The Virtue of Selfishness/
    end
  end

  test "mark read books" do
    mail = AnnouncementMailer.mark_read_books @hank_donation_received
    assert_equal "Let us know when you finish reading The Fountainhead", mail.subject
    assert_equal ["hank@rearden.com"], mail.to

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Hank/
      assert_select 'p', /You received The Fountainhead on Jan 19\s+\((about )?\d+ \w+ ago\)/
      assert_select 'a', /Yes, I have finished reading The Fountainhead/
      assert_select 'p', /your donor, Henry Cameron/
    end
  end
end
