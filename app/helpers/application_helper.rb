module ApplicationHelper
  def format_address(address)
    if address.present?
      raw (h address).gsub("\n", "<br>")
    else
      "No address given"
    end
  end

  def format_number(number, precision = 2)
    number_with_precision number, precision: precision, significant: true, strip_insignificant_zeros: true
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
