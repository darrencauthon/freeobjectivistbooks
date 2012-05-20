require 'test_helper'

class ReminderTest < ActiveSupport::TestCase
  # Associations

  test "user" do
    assert_equal @hugh, @hugh_reminder.user
  end

  test "pledges" do
    assert_equal [@hugh_pledge], @hugh_reminder.pledges
    assert_equal [], @cameron_reminder.pledges
  end

  test "donations" do
    expected = [@hank_donation, @hank_donation_received]
    assert_equal expected.to_set, @cameron_reminder.donations.to_set

    assert_equal [], @hugh_reminder.donations
  end

  # Constructors

  def verify_reminders_for(type)
    reminders = type.all_reminders
    assert reminders.any?
    reminders.each do |reminder|
      assert_equal type.to_s, reminder.type
      yield reminder
    end
  end

  test "reminders for fulfill pledge" do
    verify_reminders_for Reminders::FulfillPledge do |reminder|
      assert_not_nil reminder.pledge
      assert_equal reminder.pledge.user, reminder.user
      assert !reminder.pledge.fulfilled?
    end
  end

  test "reminders for send books" do
    verify_reminders_for Reminders::SendBooks do |reminder|
      assert_not_nil reminder.user
      reminder.donations.each do |donation|
        assert_equal reminder.user, donation.user
        assert donation.can_send?
      end
    end
  end

  test "reminders for confirm receipt" do
    verify_reminders_for Reminders::ConfirmReceipt do |reminder|
      assert_not_nil reminder.donation
      assert_equal reminder.donation.student, reminder.user
      assert reminder.donation.in_transit?
    end
  end

  test "reminders for read books" do
    verify_reminders_for Reminders::ReadBooks do |reminder|
      assert_not_nil reminder.donation
      assert_equal reminder.donation.student, reminder.user
      assert reminder.donation.reading?
    end
  end
end
