module ApplicationHelper
  def format_address(address)
    address.gsub "\n", "<br>" if address
  end

  def user_tagline(user)
    parts = []
    parts << "studying #{user.studying}" unless user.studying.blank?
    parts << "at #{user.school}" unless user.school.blank?
    parts << "in #{user.location}" unless user.location.blank?
    tagline = parts.join " "
    tagline[0] = tagline[0].upcase
    tagline
  end
end
