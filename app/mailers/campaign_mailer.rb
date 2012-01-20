class CampaignMailer < ApplicationMailer
  def self.send_campaign_to_group(campaign, group)
    CampaignTarget.scoped_by_group(group).find_each do |target|
      send_campaign_to_target campaign, target
    end
  end

  def self.send_campaign_to_target(campaign, target)
    if target.last_campaign == campaign.to_s
      Rails.logger.info "Already sent #{campaign} to #{target.name} <#{target.email}> at #{target.emailed_at}, skipping"
      return
    end

    Rails.logger.info "Sending #{campaign} to #{target.name} <#{target.email}>"
    mail = self.send campaign, target
    mail.deliver

    target.last_campaign = campaign
    target.emailed_at = Time.now
    target.save!
  end

  def student_club_announcement(target)
    @target = target
    mail_to_user target, subject: "Free Objectivist Books for Students"
  end
end
