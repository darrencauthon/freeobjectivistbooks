class UserMailer < ActionMailer::Base
  default from: "jason@rationalegoist.com"

  def reset_password(user)
    @url = edit_password_url user.letmein_params
    mail to: user.email, subject: "Free Objectivist Books password reset"
  end
end
