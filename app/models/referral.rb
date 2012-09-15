# Represents a referral from an external website to freeobjectivistbooks.org.
#
# We create one of these in ApplicationController#store_referral whenever we
# have the utm_source or utm_medium params. We also store the referring URL
# and the landing URL. We then keep the Referral in the session and associate
# it with any signups.
class Referral < ActiveRecord::Base
  has_many :users
  has_many :requests
  has_many :pledges

  def tag
    "#{source}:#{medium}"
  end
end
