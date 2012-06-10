require 'test_helper'

class Reminders::ConfirmReceiptTest < ActiveSupport::TestCase
  test "all reminders" do
    reminders = Reminders::ConfirmReceipt.all_reminders
    assert reminders.any?

    reminders.each do |reminder|
      assert_not_nil reminder.donation
      assert_equal reminder.donation.student, reminder.user
      assert reminder.donation.in_transit?
    end
  end

  def new_reminder
    Reminders::ConfirmReceipt.new_for_entity @quentin_donation
  end

  test "can send?" do
    assert new_reminder.can_send?
  end

  test "can't send too soon" do
    @quentin_donation_unsent.update_status status: "sent"
    @quentin_donation_unsent.save!

    reminder = Reminders::ConfirmReceipt.new_for_entity @quentin_donation_unsent
    assert !reminder.can_send?
  end

  test "can't send too often" do
    new_reminder.save!
    assert !new_reminder.can_send?
  end

  test "can't send too many" do
    4.times do
      reminder = new_reminder
      reminder.created_at = 1.year.ago
      assert new_reminder.can_send?, "can't send reminder"
      reminder.save!
    end

    assert !new_reminder.can_send?, "can still send reminder"
  end
end
