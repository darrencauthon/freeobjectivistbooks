module ApplicationHelper
  def format_address(address)
    address.gsub "\n", "<br>" if address
  end
end
