# Represents a target for the CampaignMailer, for doing email promotions.
class CampaignTarget < ActiveRecord::Base
  validates_presence_of :email
end
