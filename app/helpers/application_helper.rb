module ApplicationHelper
  def format_block(text)
    raw (h text).gsub("\n", "<br>")
  end

  def format_address(address)
    address.present? ? format_block(address) : "No address given"
  end

  def count_digits(number)
    if number == 0
      1
    elsif number < 0
      digits -number
    else
      1 + Math.log10(number).floor
    end
  end

  def format_number(number, precision = 2)
    digits = count_digits number
    precision = digits if precision < digits
    number_with_precision number, precision: precision, significant: true, strip_insignificant_zeros: true, delimiter: ","
  end

  def pluralize_omit_number(count, noun)
    count == 1 ? noun : noun.pluralize
  end

  def pluralize_omit_1(count, noun)
    count == 1 ? noun : "#{count} #{noun.pluralize}"
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
