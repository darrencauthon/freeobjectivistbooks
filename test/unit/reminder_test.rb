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
end
