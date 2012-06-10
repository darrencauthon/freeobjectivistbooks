require 'test_helper'

class Reminders::ReadBooksTest < ActiveSupport::TestCase
  test "all reminders" do
    reminders = Reminders::ReadBooks.all_reminders
    assert reminders.any?

    reminders.each do |reminder|
      assert_not_nil reminder.donation
      assert_equal reminder.donation.student, reminder.user
      assert reminder.donation.reading?
    end
  end

  def new_reminder
    Reminders::ReadBooks.new_for_entity @hank_donation_received
  end

  test "can send?" do
    assert new_reminder.can_send?
  end

  test "can't send too soon" do
    @quentin_donation.update_status status: "received"
    @quentin_donation.save!

    reminder = Reminders::ReadBooks.new_for_entity @quentin_donation
    assert !reminder.can_send?
  end

  test "can't send too often" do
    new_reminder.save!
    assert !new_reminder.can_send?
  end

  test "can't send too many" do
    6.times do
      reminder = new_reminder
      reminder.created_at = 1.year.ago
      assert new_reminder.can_send?, "can't send reminder"
      reminder.save!
    end

    assert !new_reminder.can_send?, "can still send reminder"
  end
end
