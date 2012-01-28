require 'test_helper'

class EventMailerTest < ActionMailer::TestCase
  include ActionDispatch::Assertions::SelectorAssertions

  test "grant" do
    mail = EventMailer.mail_for_event events(:hugh_grants_quentin)
    assert_equal "We found a donor to send you The Virtue of Selfishness!", mail.subject
    assert_equal ["quentin@mit.edu"], mail.to
    assert_equal ["jason@rationalegoist.com"], mail.from

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Quentin/
      assert_select 'p', /found a donor to send you The Virtue of Selfishness/
      assert_select 'p', /Hugh Akston in Boston, MA/
      @quentin.address.split("\n").each do |line|
        assert_select 'p', /#{line}/
      end
      assert_select 'a', /update/i
    end
  end

  test "grant no address" do
    mail = EventMailer.mail_for_event events(:hugh_grants_dagny)
    assert_equal "We found a donor to send you Capitalism: The Unknown Ideal!", mail.subject
    assert_equal ["dagny@taggart.com"], mail.to
    assert_equal ["jason@rationalegoist.com"], mail.from

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Dagny/
      assert_select 'p', /found a donor to send you Capitalism: The Unknown Ideal/
      assert_select 'p', /Hugh Akston in Boston, MA/
      assert_select 'a', /add your address/i
    end
  end

  test "flag" do
    mail = EventMailer.mail_for_event events(:hugh_flags_dagny)
    assert_equal "Problem with your shipping info on Free Objectivist Books", mail.subject
    assert_equal ["dagny@taggart.com"], mail.to
    assert_equal ["jason@rationalegoist.com"], mail.from

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Dagny/
      assert_select 'p', 'Your donor (Hugh Akston) says: "Please add your full name and address"'
      assert_select 'a', /update/i
    end
  end

  test "add name" do
    mail = EventMailer.mail_for_event events(:quentin_adds_name)
    assert_equal "Quentin Daniels added their full name on Free Objectivist Books", mail.subject
    assert_equal ["akston@patrickhenry.edu"], mail.to
    assert_equal ["jason@rationalegoist.com"], mail.from

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Hugh/
      assert_select 'p', /Quentin Daniels added their full name/
      assert_select 'p', text: /said/, count: 0
      assert_select 'p', /Please send The Virtue of Selfishness to/
      @quentin.address.split("\n").each do |line|
        assert_select 'p', /#{line}/
      end
      assert_select 'a', /See this and all the latest books/
    end
  end

  test "add address" do
    mail = EventMailer.mail_for_event events(:quentin_adds_address)
    assert_equal "Quentin Daniels added a shipping address on Free Objectivist Books", mail.subject
    assert_equal ["akston@patrickhenry.edu"], mail.to
    assert_equal ["jason@rationalegoist.com"], mail.from

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Hugh/
      assert_select 'p', /Quentin Daniels added a shipping address/
      assert_select 'p', /They said: "There you go"/
      assert_select 'p', /Please send The Virtue of Selfishness to/
      @quentin.address.split("\n").each do |line|
        assert_select 'p', /#{line}/
      end
      assert_select 'a', /See this and all the latest books/
    end
  end

  test "message" do
    mail = EventMailer.mail_for_event events(:hugh_messages_quentin)
    assert_equal "Hugh Akston sent you a message on Free Objectivist Books", mail.subject
    assert_equal ["quentin@mit.edu"], mail.to
    assert_equal ["jason@rationalegoist.com"], mail.from

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Quentin/
      assert_select 'p', /Hugh Akston sent you a message/
      assert_select 'p', /"Thanks! I will send you the book"/
      assert_select 'p', text: /Please send/, count: 0
      assert_select 'a', /Reply to Hugh/
      assert_select 'a', /See the status of your request/
    end
  end

  test "update status" do
    mail = EventMailer.mail_for_event events(:hugh_updates_quentin)
    assert_equal "Hugh Akston has sent The Virtue of Selfishness", mail.subject
    assert_equal ["quentin@mit.edu"], mail.to
    assert_equal ["jason@rationalegoist.com"], mail.from

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Quentin/
      assert_select 'p', /Hugh Akston has sent you The Virtue of Selfishness!/
      assert_select 'a', /Thank Hugh Akston/
      assert_select 'p', /Happy reading,/
    end
  end

  test "thank" do
    mail = EventMailer.mail_for_event events(:quentin_thanks_hugh)
    assert_equal "Quentin Daniels sent you a thank-you note for The Virtue of Selfishness", mail.subject
    assert_equal ["akston@patrickhenry.edu"], mail.to
    assert_equal ["jason@rationalegoist.com"], mail.from

    mail.deliver
    assert_select_email do
      assert_select 'p', /Hi Hugh/
      assert_select 'p', /Quentin Daniels sent you a thank-you note for The Virtue of Selfishness/
      assert_select 'p', /"Thanks! I am looking forward to reading this"/
      assert_select 'a', /Reply to Quentin/
    end
  end
end
