require 'test_helper'

class ReferralTest < ActiveSupport::TestCase
  test "users" do
    assert_equal [@hank], @email_referral.users
    assert_equal [@stadler], @fb_referral.users
  end

  test "requests" do
    assert_equal [@hank_request], @email_referral.requests
    assert_equal [], @fb_referral.requests
  end

  test "pledges" do
    assert_equal [], @email_referral.pledges
    assert_equal [@stadler_pledge], @fb_referral.pledges
  end
end
