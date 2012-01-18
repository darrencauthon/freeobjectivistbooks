class ApplicationMailer < ActionMailer::Base
  default from: "Free Objectivist Books <jason@rationalegoist.com>"

  def mail_to_user(user, options)
    options = if Rails.application.config.email_recipient_override
      options.merge(
        to: Rails.application.config.email_recipient_override,
        subject: "#{options[:subject]} (recipient was: #{user.email})",
      )
    else
      options.merge(to: user.email)
    end

    mail options
  end
end
