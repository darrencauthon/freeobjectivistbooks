require 'test_helper'

class CampaignMailerTest < ActionMailer::TestCase
  def setup
    @cmuoc = campaign_targets :cmuoc
  end

  test "send campaign to group" do
    assert_difference "ActionMailer::Base.deliveries.count", 2 do
      CampaignMailer.send_campaign_to_group :student_club_announcement, "Objectivist Clubs"
    end

    @cmuoc.reload
    assert_equal "student_club_announcement", @cmuoc.last_campaign
  end

  test "send campaign skips targets that got it already" do
    CampaignMailer.send_campaign_to_target :student_club_announcement, @cmuoc

    assert_difference "ActionMailer::Base.deliveries.count", 1 do
      CampaignMailer.send_campaign_to_group :student_club_announcement, "Objectivist Clubs"
    end
  end

  test "student club announcement" do
    mail = CampaignMailer.student_club_announcement @cmuoc
    assert_equal "Free Objectivist Books for Students", mail.subject
    assert_equal ["reason@andrew.cmu.edu"], mail.to
    assert_equal ["jason@rationalegoist.com"], mail.from
    assert_match /CMU Objectivist Club:/, mail.body.encoded
  end
end
