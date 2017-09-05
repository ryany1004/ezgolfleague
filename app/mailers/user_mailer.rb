class UserMailer < ApplicationMailer
  def welcome(user)
    mail(to: user.email, subject: "Welcome to EZ Golf League - Here's How to Get Started")
  end
end
