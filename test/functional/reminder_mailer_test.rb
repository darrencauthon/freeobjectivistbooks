require 'test_helper'

class ReminderMailerTest < ActionMailer::TestCase
  test "send reminder" do
    pledges = Pledge.unfulfilled
    assert pledges.any?

    assert_difference "ActionMailer::Base.deliveries.size", pledges.count do
      ReminderMailer.send_reminder :fulfill_pledge
    end
  end

  test "fulfill pledge" do
    mail = ReminderMailer.fulfill_pledge(pledges :hugh_pledge)
    assert_equal "Fulfill your pledge of 5 books on Free Objectivist Books", mail.subject
    assert_equal ["akston@patrickhenry.edu"], mail.to

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Hugh/
      assert_select 'p', /Thank you for\s+donating 3 books so far/
      assert_select 'p', /On Jan 15, you pledged to donate 5 books/
      assert_select 'p', /Right now there are 2 students waiting/
      assert_select 'a', /Read their appeals/
      assert_select 'p', /Thanks,\nFree Objectivist Books/
    end
  end

  test "fulfill pledge for donor with no donations" do
    mail = ReminderMailer.fulfill_pledge(pledges :stadler_pledge)
    assert_equal "Fulfill your pledge of 3 books on Free Objectivist Books", mail.subject
    assert_equal ["stadler@scienceinstitute.gov"], mail.to

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Robert/
      assert_select 'p', /Thank you for\s+signing up to donate books/
      assert_select 'p', /On Jan 17, you pledged to donate 3 books/
      assert_select 'p', /Right now there are 2 students waiting/
      assert_select 'a', /Read their appeals/
      assert_select 'p', /Thanks,\nFree Objectivist Books/
    end
  end

  test "send books for donor with one outstanding donation" do
    mail = ReminderMailer.send_books(@hugh)
    assert_equal "Have you sent The Fountainhead to Quentin Daniels yet?", mail.subject
    assert_equal ["akston@patrickhenry.edu"], mail.to

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Hugh/
      assert_select 'p', /said you would donate The Fountainhead to Quentin Daniels in Boston, MA/
      assert_select 'p', /notify the student that the book is on its way/
      assert_select 'a', /donations/
      assert_select 'p', /please send it soon/
      assert_select 'p', /Thanks,\nFree Objectivist Books/
    end
  end

  test "send books for donor with multiple outstanding donations" do
    @dagny_request.flagged = false
    @dagny_request.save!

    mail = ReminderMailer.send_books(@hugh)
    assert_equal "Have you sent your 2 books to students from Free Objectivist Books yet?", mail.subject
    assert_equal ["akston@patrickhenry.edu"], mail.to

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Hugh/
      assert_select 'p', /said you would donate these books/
      assert_select 'li', minimum: 2
      assert_select 'li', /Capitalism: The Unknown Ideal to Dagny in Chicago, IL/
      assert_select 'li', /The Fountainhead to Quentin Daniels in Boston, MA/
      assert_select 'p', /notify the students that the books are on their way/
      assert_select 'a', /donations/
      assert_select 'p', /please send them soon/
      assert_select 'p', /Thanks,\nFree Objectivist Books/
    end
  end
end
