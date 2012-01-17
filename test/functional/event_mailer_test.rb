require 'test_helper'

class EventMailerTest < ActionMailer::TestCase
  include ActionDispatch::Assertions::SelectorAssertions

  def setup
    @quentin = users :quentin
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
      assert_select 'p', text: /says/, count: 0
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
      assert_select 'p', /Quentin says: "There you go"/
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
      assert_select 'a', /See the status of your request/
    end
  end
end
