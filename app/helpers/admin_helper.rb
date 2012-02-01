module AdminHelper
  def admin_user_link(user)
    link_to user.name, admin_user_path(user)
  end
end