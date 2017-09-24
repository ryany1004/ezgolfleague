class UserMailer < ApplicationMailer
  def welcome(user)
    mail(to: user.email, from: 'support@ezgolfleague.com', subject: "Welcome to EZ Golf League - Here's How to Get Started")
  end
end
