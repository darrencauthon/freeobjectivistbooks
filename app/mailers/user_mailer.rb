class UserMailer < ApplicationMailer
  def reset_password(user)
    @url = edit_password_url auth: user.auth_token
    mail_to_user user, subject: "Free Objectivist Books password reset"
  end
end
